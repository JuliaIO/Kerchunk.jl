#=
# CF corrections

The [Climate and Forecast Conventions](https://cfconventions.org/conventions.html) 
("CF" conventions) are a _very_ popular way to encode geospatial metadata.  

Notably, NetCDF (`.nc`), GeoTiff and GRIB files all follow this metadata format.

The way CF conventions are framed is not quite compatible with Zarr's more modular structure
of filters and compressors, instead each attribute has its own effect and can depend on the 
value or presence of other attributes!  

Kerchunk (and to some extent, Virtualizarr) aim to be more in line with the Zarr spec, but
pure Zarr readers cannot read many CF encoded datasets correctly.  While this works with
Xarray since it reads the CF metadata and applies it, other Zarr implementations do not
have this luxury.  So, we implement some corrections that make life easier on the Zarr
end, by which the values we read out of the data would be the same values one would read
from the associated NetCDF file.

=#

@static if :FixedScaleOffsetFilter in names(Zarr; all = true)
    import Zarr: FixedScaleOffsetFilter
end

"""
    do_correction!(f!, store, path)

Applies `f!` on the parsed `.zarray` and `.zattrs` files about the array 
at path `path` in the Zarr store `store`.  These corrections mutate the 
files `.zarray` and `.zmetadata`, and attempt to save them to the store.

Available corrections are [`add_scale_offset_filter_and_set_mask!`](@ref) and
[`move_compressor_from_filters!`](@ref).

TODOs:
- Make this work for consolidated metadata (check for the presence of a .zmetadata key)?

## Usage

````julia
st,  = Zarr.storefromstring("reference://catalog.json")
Kerchunk.do_correction!(Kerchunk.add_scale_offset_filter_and_set_mask!, st, "SomeVariable")
zopen(st)
````
"""
function do_correction!(f!, store::ReferenceStore, path)
    
    if !Zarr.is_zarray(store, path)
        error("Kerchunk: $path in $store is not a `zarray`!  Halting correction.")
    end

    zarray = Zarr.JSON.parse(store[path * "/.zarray"])
    zattrs = Zarr.JSON.parse(store[path * "/.zattrs"])

    f!(zarray, zattrs)

    # Cache always overrides raw data, so by embedding the new metadata
    # in the cache, we can ensure it's always read instead of the old
    # stuff, without modifying the file.
    store.cache[path * "/.zarray"] = (Zarr.JSON.json(zarray),)
    store.cache[path * "/.zattrs"] = (Zarr.JSON.json(zattrs),)

    return
end


function do_correction!(f!, store::Zarr.AbstractStore, path)

    if !Zarr.is_zarray(store, path)
        error("Kerchunk: $path in $store is not a `zarray`!  Halting correction.")
    end
    
    zarray = Zarr.JSON.parse(store[path * "/.zarray"])
    zattrs = Zarr.JSON.parse(store[path * "/.zattrs"])

    f!(zarray, zattrs)

    # Write directly to the store, this is a lossy operation!!
    store[path * "/.zarray"] = Zarr.JSON.json(zarray)
    store[path * "/.zattrs"] = Zarr.JSON.json(zattrs)

    return
end

"""
    add_scale_offset_filter_and_set_mask!(zarray::Dict, zattrs::Dict)

Adapts the CF metadata convention of scale/offset, valid_range, _FillValue,
and _Unsigned by modifying the Zarr metadata:
- An additional reinterpretation filter is added to the filter stack
  if `_Unsigned=true`.  This allows the values to be interpreted as 
  UInts instead of Ints, which removes the sign error that would otherwise
  plague your dataset.
- A `FixedScaleOffset` filter replaces `scale_factor` and `add_offset`.
- `valid_range` and `_FillValue` are mutated based on the scale factor and added offset,
  and the native Zarr `fill_value` is replaced by the mutated and read `_FillValue`.

The values of the other attributes depend on `_Unsigned`, so we unify all these changes
into a single function.
"""
function add_scale_offset_filter_and_set_mask!(zarray::Dict, zattrs::Dict)
    scale = get(zattrs, "scale_factor", 1.0)
    offset = get(zattrs, "add_offset", 0.0)
    if iszero(offset) && isone(scale)
        return # we need neither scale nor offset
    end
    pop!(zattrs, "scale_factor")
    pop!(zattrs, "add_offset")
    filter_dict = Zarr.JSON.lower(
        FixedScaleOffsetFilter{
            Float64,
            Zarr.typestr(zarray["dtype"]), 
            Zarr.typestr(get(zarray, "astype", "<f8"))
            }(1/scale, offset) # Zarr filter is not the same as CF definition.  Hopefully this doesn't get too unstable...
        )
    current_filters = zarray["filters"]
    new_filters = if isnothing(current_filters) || isempty(current_filters)
        [filter_dict]
    else
        pushfirst!(collect(current_filters), filter_dict)
    end
    if haskey(zattrs, "_Unsigned") && zattrs["_Unsigned"] == "true" # correct for unsigned values
        # Extract the _Unsigned attribute
        old_dtype = Zarr.typestr(zarray["dtype"])
        new_dtype = unsigned(old_dtype)
        pop!(zattrs, "_Unsigned")

        # Apply the scale and offset to the fill value, valid range, and valid min/max
        if haskey(zattrs, "_FillValue")
            zattrs["_FillValue"] = reinterpret(new_dtype, old_dtype(zattrs["_FillValue"])) * scale + offset
        end
        if haskey(zattrs, "valid_range")
            zattrs["valid_range"] = reinterpret(new_dtype, old_dtype.(zattrs["valid_range"])) .* scale .+ offset
        end
        if haskey(zattrs, "valid_min")
            zattrs["valid_min"] = reinterpret(new_dtype, old_dtype(zattrs["valid_min"])) * scale + offset
        end
        if haskey(zattrs, "valid_min")
            zattrs["valid_min"] = reinterpret(new_dtype, old_dtype(zattrs["valid_min"])) * scale + offset
        end
        # Add a type conversion filter before the scale/offset, to ensure that 
        # only unsigned values are used!
        insert!(new_filters, 2, AstypeFilter{old_dtype, new_dtype}() |> Zarr.JSON.lower)
    end
    zarray["filters"] = new_filters
    zarray["dtype"] = Zarr.typestr(Float64) # TODO: should this be f32??
    if haskey(zarray, "fill_value") && haskey(zattrs, "_FillValue")
        zarray["fill_value"] = zattrs["_FillValue"] # TODO: this should be made obsolete!
    end
end

"""
    move_compressor_from_filters!(zarray, zattrs)

Checks if the last entry of `zarray["filters"]` is actually a compressor,
and if there is no other compressor moves it from the filter array to the 
`zarray["compressor"]` field.

This is a common issue with Kerchunk metadata, since it seems numcodecs doesn't
distinguish between compressors and filters.  This function will not be needed
for Zarr v3 datasets, since the compressors and filters are all codecs in that 
schema.
"""
function move_compressor_from_filters!(zarray::Dict, zattrs::Dict)
    if get(zarray, "filters", nothing) |> isnothing
        return # No filters, so nothing to be done here
    else # there are some filters
        if !isnothing(zarray["compressor"])
            return # there is already a compressor, we can't have multiple
        else
            if last(zarray["filters"])["id"] in keys(Zarr.compressortypes)
                compressor = pop!(zarray["filters"])
                zarray["compressor"] = compressor
                return
            else # the last filter, first to be applied when decoding, is **not** a compressor.
                return
            end
        end
    end
end


# # CF correction mega function

function apply_cf_corrections!(store::ReferenceStore)
    if haskey(store.mapper, ".zmetadata")
        @warn "Kerchunk.jl cannot apply corrections on consolidated stores yet!"
        return
    end

    for dir in Zarr.subdirs(store, "")
        if Zarr.is_zarray(store, dir)
            do_correction!(move_compressor_from_filters!, store, dir)
            do_correction!(add_scale_offset_filter_and_set_mask!, store, dir)
        end
    end
end