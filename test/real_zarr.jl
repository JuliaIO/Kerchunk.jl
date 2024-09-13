# One way to benchmark how much performance the Kerchunk implementation
# is costing us is to use an actual Zarr file.

# We can simulate a Kerchunk catalog but use an actual Zarr array,
# so the difference in benchmark speeds between Kerchunk and Zarr
# should provide useful data.

using Zarr, Kerchunk

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