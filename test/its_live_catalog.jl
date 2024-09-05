using JSON3, Kerchunk, Zarr, YAXArrays
using Test

@testset "ITS_LIVE catalog" begin
    catalog_json = JSON3.read(open(joinpath(dirname(dirname(pathof(Kerchunk))), "test", "its_live_catalog.json"))) 
    arbitrary_choice_dictionary = catalog_json[first(keys(catalog_json))]
    st = Kerchunk.ReferenceStore(arbitrary_choice_dictionary)
    za = Zarr.zopen(st)
    @test_nowarn za["vx"][1, 1] # test that reading works
end
