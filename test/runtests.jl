using CondaPkg, PythonCall

using Kerchunk

# Raster creation and analysis packages
using Rasters, NCDatasets # to save a raster
using YAXArrays # to open a raster

using Test

@testset "Kerchunk.jl" begin
    include("python_local_kerchunk.jl")
    include("its_live.jl")
end
