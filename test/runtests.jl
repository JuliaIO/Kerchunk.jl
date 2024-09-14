using CondaPkg, PythonCall

using Kerchunk

# Raster creation and analysis packages
using Rasters, NCDatasets # to save a raster
using YAXArrays # to open a raster

using Test

@testset "Kerchunk.jl" begin
    @static if !(Sys.iswindows())
        include("python_local_kerchunk.jl")
    end
    if ( false ) # an ode to GEMB :P
        # In all seriousness, this will only be possible to test when:
        # - HTTPPaths are a thing
        # - we update this catalog to switch all URLs from the s3 protocol to the new ITS_LIVE HTTP
        # protocol
        # The bucket you are attempting to access must be addressed using the specified endpoint. 
        # Please send all future requests to this endpoint.
        # `its-live-data.s3-us-west-2.amazonaws.com`
        include("its_live_catalog.jl")
    end
    include("corrections.jl")
    include("real_zarr.jl")
    end
end
