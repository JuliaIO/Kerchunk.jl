using CondaPkg, PythonCall

using Zarr, JSON3

# You can't import kerchunk.hdf because importing h5py introduces a version of libhdf5 that is incompatible with any extant netcdf4_jll.


using Rasters, NCDatasets, Dates, YAXArrays

using Test

@testset "Reading a Kerchunked NetCDF file" begin

    # First, we create a NetCDF dataset:

    ras = Raster(rand(LinRange(0, 10, 100), X(1:100), Y(5:150), Ti(DateTime("2000-01-31"):Month(1):DateTime("2001-01-31"))))

    write("test.nc", ras; source = :netcdf, force = true)
    @test Raster("test.nc") == ras # test read-write roundtrip

    # Create a Kerchunk catalog.
    # The reason I do this by `run` is because the hdf5 C library versions used by 
    # Julia and Python are fundamentally incompatible, so we can't use the same process for both.
    CondaPkg.withenv() do
        run(```
$(CondaPkg.which("python")) -c "
import kerchunk.hdf as hdf; import os; import ujson
h5chunks = hdf.SingleHdf5ToZarr('test.nc', inline_threshold=300)
with open('test.json', 'w') as f:
    f.write(ujson.dumps(h5chunks.translate())) 
"
        ```) # strange indenting because I had weird Python indentation issues when there were spaces...
    end

    py_kerchunk_catalog = JSON3.read(read("test.json", String))

    st  = Kerchunk.ReferenceStore("test.json")
    st2 = Kerchunk.ReferenceStore(py_kerchunk_catalog)

    #=
    # explore why fsspec might be causing problems
    fs, = fsspec.core.url_to_fs("s3://its-live-data/datacubes/v2/N00E020/ITS_LIVE_vel_EPSG32735_G0120_X750000_Y10050000.zarr")
    fs2, = fsspec.core.url_to_fs("reference://"; fo = py_kerchunk_catalog)
    st.mapper.dirfs.ls("/")
    =#

    # ds = xr.open_dataset("reference://", engine="zarr", backend_kwargs={"consolidated": False, "storage_options": {"fo" : h5chunks.translate()}})

    ds = Zarr.zopen(st; consolidated = false)

    ya = YAXArrays.open_dataset(ds)

    @test all(map(==, ya["unnamed"] |> collect, ras |> collect)) # if not, this goes to YAXArrays 

    ds = Zarr.zopen(st2; consolidated = false)

    ya = YAXArrays.open_dataset(ds)

    @test all(map(==, ya["unnamed"] |> collect, ras |> collect)) # if not, this goes to YAXArrays
end