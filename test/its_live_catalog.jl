using JSON3, Kerchunk, Zarr, YAXArrays
using Test

# We need to set the AWS config to say we're coming from the "us-west-2" region,
# otherwise AWS will actually refuse to recognize the s3 URL as a bucket, 
# and instead will require us to use the HTTP endpoint, which AWSS3.jl won't support.
import AWS
AWS.global_aws_config(AWS.AWSConfig(; region="us-west-2"))

@testset "ITS_LIVE catalog" begin
    # We make the catalog path relative to the module Kerchunk.jl, so that it can be run from the REPL.
    catalog_path = joinpath(dirname(dirname(pathof(Kerchunk))), "test", "data", "its_live_catalog.json")
    catalog_json = JSON3.read(open(catalog_path)) 
    # This catalog is actually a collection of catalogs, since the data is stored in different projections.
    # We simply access the first in the list.
    arbitrary_choice_dictionary = catalog_json[first(keys(catalog_json))]
    # We create a ReferenceStore, which is a dictionary of references to the data.
    st = Kerchunk.ReferenceStore(arbitrary_choice_dictionary)
    # We open the Zarr array from the ReferenceStore.
    za = Zarr.zopen(st)
    # We test that reading works.
    @test_nowarn za["vx"][1, 1] # test that reading works
end
