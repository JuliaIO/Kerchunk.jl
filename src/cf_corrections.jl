# TODO: don't use this function, since some CF convention tags
# don't work with it.
# Instead simply load via YAXArrays, which does the work correctly.
# For some reason - Rasters.jl doesn't apply the CF conventions
# (or maybe it's ZarrDatasets.jl's problem).

function do_correction!(f!, store, path)
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

function add_scale_offset_filter_and_set_mask!(zarray::Dict, zattrs::Dict)
    scale = get(zattrs, "scale_factor", 1.0)
    offset = get(zattrs, "add_offset", 0.0)
    if iszero(offset) && isone(scale)
        return # we need neither scale nor offset
    end
    pop!(zattrs, "scale_factor")
    pop!(zattrs, "add_offset")
    filter_dict = Zarr.JSON.lower(
        Zarr.FixedScaleOffsetFilter{
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
        old_dtype = Zarr.typestr(zarray["dtype"])
        new_dtype = unsigned(old_dtype)
        zattrs["_FillValue"] = reinterpret(new_dtype, old_dtype(zattrs["_FillValue"])) * scale + offset
        pop!(zattrs, "_Unsigned")
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
    if haskey(zarray, "fill_value")
        zarray["fill_value"] = zattrs["_FillValue"] # TODO: this should be made obsolete!
    end
end

function set_unsigned!(zarray::Dict{Symbol, <: Any}, zattrs::Dict{Symbol, <: Any})
    if haskey(zattrs, "_Unsigned") && zattrs["_Unsigned"] == "true"
        #=
        filter_dict = Zarr.JSON.lower(Zarr.AsTypeFilter{}())
        current_filters = zarray["filters"]
        new_filters = if isnothing(current_filters) || isempty(current_filters)
            [filter_dict]
        else
            pushfirst!(collect(current_filters), filter_dict)
        end
        zarray["filters"] = new_filters
        =#
        old_dtype = Zarr.typestr(zarray["dtype"])
        zarray["dtype"] = replace(zarray["dtype"], "i" => "u")
        zarray["fillvalue"] = reinterpret(unsigned(old_dtype), old_dtype(zarray["fillvalue"]))
    end
end

function move_filter_to_compressors!(zarray::Dict{Symbol, <: Any}, zattrs::Dict{Symbol, <: Any})
end

function cache_group!(store::ReferenceStore, group::String)
    mkpath(joinpath(store.cache_dir, group))
    for key in (group * "/" .* Zarr.subkeys(store, group))
        cached_file_path = joinpath(store.cache_dir, key)
        touch(cached_file_path)
        bytes = _get_file_bytes(store, store[key])
        write(cached_file_path, bytes)
        store.cache[key] = (cached_file_path,)
    end
end