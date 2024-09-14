using JSON3, Kerchunk, Test

zarray_sst = "{\n    \"chunks\": [\n        226,\n        226\n    ],\n    \"compressor\": {\n        \"id\": \"zlib\",\n        \"level\": 1\n    },\n    \"dtype\": \"<i2\",\n    \"fill_value\": -1,\n    \"filters\": null,\n    \"order\": \"C\",\n    \"shape\": [\n        5424,\n        5424\n    ],\n    \"zarr_format\": 2\n}"

zattrs_sst = "{\n    \"_ARRAY_DIMENSIONS\": [\n        \"y\",\n        \"x\"\n    ],\n    \"_FillValue\": -1,\n    \"_Netcdf4Dimid\": 0,\n    \"_Unsigned\": \"true\",\n    \"add_offset\": 180.0,\n    \"algorithm_type\": \"regression\",\n    \"ancillary_variables\": \"DQF\",\n    \"cell_methods\": \"retrieval_local_zenith_angle: point (good or degraded quality pixel produced) quantitative_local_zenith_angle: point (good quality pixel produced) retrieval_solar_zenith_angle: point (good quality pixel produced) t: point area: point\",\n    \"coordinates\": \"retrieval_local_zenith_angle quantitative_local_zenith_angle retrieval_solar_zenith_angle t y x\",\n    \"grid_mapping\": \"goes_imager_projection\",\n    \"long_name\": \"ABI L2+ Sea Surface (Skin) Temperature\",\n    \"resolution\": \"y: 0.000056 rad x: 0.000056 rad\",\n    \"scale_factor\": 0.0024416300002485514,\n    \"standard_name\": \"sea_surface_skin_temperature\",\n    \"units\": \"K\",\n    \"valid_range\": [\n        0,\n        -6\n    ]\n}"


@testset "CF scale/offset/mask" begin
    zarray = Zarr.JSON.parse(zarray_sst)
    zattrs = Zarr.JSON.parse(zattrs_sst)

    old_fillvalue = zattrs["_FillValue"]
    old_correct_fillvalue = reinterpret(UInt16, Int16(zattrs["_FillValue"]))
    old_scalefactor = zattrs["scale_factor"]
    old_offset = zattrs["add_offset"]

    Kerchunk.add_scale_offset_filter_and_set_mask!(zarray, zattrs)

    # test that FSO + Astype filters were added
    @test "fixedscaleoffset" in getindex.(zarray["filters"], "id")
    @test "astype" in getindex.(zarray["filters"], "id")

    # test that the fill value was appropriately translated
    @test zarray["fill_value"] == old_correct_fillvalue * old_scalefactor + old_offset
end
