#=
# FSSpec/Kerchunk ecosystem integration testing

This is a showcase of what you can do, and a way to find persistent issues through the ecosystem.

You can read a Kerchunk in three ways:
1. Kerchunk.jl + Zarr.jl: fully native Julia, fast
2. FSSpec.jl + Zarr.jl: call out to Python for downloading but Julia for reading.  Middle ground, more robust to 
=#
using Test
using FSSpec, Kerchunk, Zarr
using YAXArrays, PyYAXArrays, PythonCall
const xarray = pyimport("xarray")
using ZarrDatasets, Rasters
using CairoMakie, BenchmarkTools

s1 = FSSpec.FSStore("reference://"; fo = "catalog.json")
s2 = Kerchunk.ReferenceStore("catalog.json")

z1 = Zarr.zopen(s1; consolidated = false)
z2 = Zarr.zopen(s2; consolidated = false)

z1["SST"][1, 1]
z2["SST"][1, 1]


ds = xarray.open_dataset("reference://", storage_options = Dict("fo" => "catalog.json"), engine = "zarr")
@test isnan(pyconvert(Float64, ds["SST"][1, 1].values[]))


ya1 = YAXArrays.open_dataset(z1)
ya2 = YAXArrays.open_dataset(z2)
ya3 = YAXArrays.open_dataset(ds)

@benchmark collect($(ya2["SST"]))
@benchmark collect($(ya3["SST"]))

zd1 = ZarrDataset(z1)
zd2 = ZarrDataset(z2)

rs = RasterStack("reference://catalog.json"; lazy = true, source = Rasters.Zarrsource(), raw = true, maskingval=NaN)


# f, a, p = heatmap(ya1["SST"]; axis = (; title = "Kerchunk.jl"))
heatmap(ya2["SST"]; axis = (; title = "FSSpec.jl"))
heatmap(f[1, 3], ya3["SST"]; axis = (; title = "PyYAXArrays/Xarray"))


#=
# Issues so far

- YAXArrays doesn't compute missing values
- ZarrDatasets may be forcing read in serial / not complying with DiskArrays (but YAX is fine here)
    - This seems to be because `collect` is super slow but `arr[:, :]` is fast somehow?!
=#
