module Kerchunk

using JSON3, Base64 # for decoding
using URIs, Mustache # to resolve paths
using FilePathsBase, AWSS3 # to access files
using Zarr # this is where the magic happens


# Utility functions
include("readbytes.jl")

# Reference store implementation
include("referencestore.jl")

# Materializing a reference store
include("materialize.jl")

export ReferenceStore

end
