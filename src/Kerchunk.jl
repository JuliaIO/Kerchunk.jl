module Kerchunk

using JSON3, Base64 # for decoding
using URIs, Mustache # to resolve paths
using FilePathsBase, AWSS3 # to access files
using Zarr # this is where the magic happens

# Zarr filters that are not yet released in Zarr.jl
@static if :FixedScaleOffsetFilter in names(Zarr; all = true)
    include("required_zarr_filters.jl")
end

# Utility functions
include("readbytes.jl")

# Reference store implementation
include("referencestore.jl")

# CF corrections in style
include("astype_filter.jl")
include("cf_corrections.jl")

# Materializing a reference store
include("materialize.jl")

export ReferenceStore

# File paths from Zarr stores
include("zarrstorepath.jl")
export ZarrStorePath

# The `__init__` function always runs when the package is loaded, 
# and we use it to mutate registry arrays and dicts in other packages
# (Zarr) that wouldn't work if you tried to precompile it.
# This is because the modifications are active in the precompile session,
# but are not saved to the other package's precompile file.
function __init__()
    push!(Zarr.storageregexlist, r"^reference://"=>ReferenceStore)
    Zarr.filterdict["astype"] = AstypeFilter
    @static if :FixedScaleOffsetFilter in names(Zarr; all = true)
        filterdict["delta"] = DeltaFilter
        filterdict["fixedscaleoffset"] = FixedScaleOffsetFilter
        filterdict["fletcher32"] = Fletcher32Filter
        filterdict["quantize"] = QuantizeFilter
        filterdict["shuffle"] = ShuffleFilter
    end
end

end
