# One way to benchmark how much performance the Kerchunk implementation
# is costing us is to use an actual Zarr file.
# We can simulate a Kerchunk catalog but use an actual Zarr array,
# so the difference in benchmark speeds between Kerchunk and Zarr
# should provide useful data.

