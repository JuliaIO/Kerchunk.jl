# This file is meant to materialize a Zarr directory from a Kerchunk catalog.

"""
    materialize(path, store::ReferenceStore)

Materialize a Zarr directory from a Kerchunk catalog.  This actually downloads and writes the files to the given path, and you can open that with any Zarr reader.
"""
function materialize(path::Union{String, FilePathsBase.AbstractPath}, store::ReferenceStore)
    mkpath(path)
    for key in keys(store.mapper)
        println("Writing $key")
        mkpath(splitdir(joinpath(path, string(key)))[1])
        write(joinpath(path, string(key)), _get_file_bytes(store, store.mapper[key]))
    end
    return path
end