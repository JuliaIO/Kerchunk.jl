using HDF5
using H5Zblosc, H5Zzstd, H5Zlz4, H5Zbitshuffle
# Generate a random array
A = rand(100,100)

compressors = (;
    zstd = (; filters = [ZstdFilter(3)]),
    blosc = (; filters = [BloscFilter(; level=9, shuffle=H5Zblosc.BITSHUFFLE, compressor="blosclz")]),
    lz4 = (; filters = [Lz4Filter(0)]),
    bitshuffle = (; filters = [BitshuffleFilter()]),
)

for (key, kwargs) in pairs(compressors)
    h5open(joinpath("data", "test_$key.h5"), "w") do f
        g = create_dataset(f, "A", HDF5.datatype(A), size(A); chunk = (20, 20), kwargs...)
        g[:, :] = A
    end
end
