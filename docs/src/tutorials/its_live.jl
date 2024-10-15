#=
# ITS_LIVE data
=#

using Rasters, ZarrDatasets
using Kerchunk
using Statistics

rs = RasterStack("reference://$(joinpath(dirname(dirname(pathof(Kerchunk))), "test", "data", "its_live_catalog.json"))")
#
vs2 = Rasters.aggregate(rs, mean, 10) # now everything is loaded in disk
#
arrows(dims(vs2, X) |> collect, dims(vs2, Y) |> collect, vs2.vx .* 20, vs2.vy .* 20; arrowsize = 5)