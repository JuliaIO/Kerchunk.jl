module Kerchunk

using JSON3, Base64 # for decoding
using URIs, Mustache # to resolve paths
using FilePathsBase, AWSS3 # to access files
using Zarr # this is where the magic happens


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


function __init__()
    push!(Zarr.storageregexlist, r"^reference://"=>ReferenceStore)
    Zarr.filterdict["astype"] = AstypeFilter
end

end
