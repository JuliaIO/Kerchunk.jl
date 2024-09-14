# One way to benchmark how much performance the Kerchunk implementation
# is costing us is to use an actual Zarr file.

# We can simulate a Kerchunk catalog but use an actual Zarr array,
# so the difference in benchmark speeds between Kerchunk and Zarr
# should provide useful data.

using Zarr, Kerchunk

#=
# Use the ITS_LIVE data as an example.  Get each of its subkeys using S3,
# and create a JSON file that looks like a Kerchunk catalog.

# Then, access ITS_LIVE using (a) Kerchunk and (b) Zarr, and compare the
# performance using the pre-existing benchmark suite.

function _mockup_kerchunk(file_location, bucket, path_prefix)
    keys = s3_list_keys("its-live-data", "datacubes/v2/N00E020/ITS_LIVE_vel_EPSG32735_G0120_X750000_Y10050000.zarr")
    url = "s3://$(bucket)/$(path_prefix)"
    open(file_location, "w") do f
        println(f, "{ \"version\": 1, \"refs\": {")
        for key in keys
            println(""""$key": ["$url"],""")
        end
        println(f, "}")
    end
end
=#

struct DirectoryDict{PathType} <: AbstractDict{String, Tuple{String}}
    directory::PathType
end

function Base.keys(d::DirectoryDict)
    return Iterators.map(walkdir(d.directory)) do (rootpath, dirs, files)
        if rootpath == d.directory
            return files
        else
            return joinpath.((normpath(relpath(rootpath, d.directory)),), files)
        end
    end |> Iterators.flatten |> collect     
end

function Base.values(d::DirectoryDict)
    return getindex.((d,), keys(d))
end

function Base.pairs(d::DirectoryDict)
    ks = keys(d)
    return [k => d[k] for k in ks]
end

function Base.filter(f, d::DirectoryDict)
    ks = keys(d)
    return Dict(Iterators.filter(f, (k => d[k] for k in ks)))
end

function Base.haskey(d::DirectoryDict, k::String)
    return Base.isfile(joinpath(d.directory, k))
end

function Base.getindex(d::DirectoryDict, k::String)
    return (joinpath(d.directory, k),)
end

function Base.length(d::DirectoryDict)
    return sum(Iterators.map(x -> length(last(x)), walkdir(d.directory)))
end


dd = DirectoryDict(joinpath(pathof(Kerchunk) |> dirname |> dirname, "test", "data", "test.zarr"))
st = ReferenceStore(Dict("version" => "1", "refs" => dd))
@test_nowarn Zarr.zopen(st)
zg = Zarr.zopen(st)
@test isempty(setdiff(keys(zg.arrays), ("unnamed", "ti", "x", "y")))
@test_nowarn collect(zg["unnamed"])
@test_nowarn collect(zg["ti"])
# TODO: these are broken?!
@test_broken collect(zg["x"])
@test_broken collect(zg["y"])