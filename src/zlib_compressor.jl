import Zarr: Compressor, zcompress, zuncompress, getCompressor, JSON, compressortypes

import CodecZstd

"""
    ZstdCompressor(clevel=-1)
Returns a `ZstdCompressor` struct that can serve as a Zarr array compressor. Keyword arguments are:
* `clevel=-1` the compression level, number between -1 (Default), 0 (no compression) and 9 (max compression)
*  default is -1 compromise between speed and compression (currently equivalent to level 6).
"""
struct ZstdCompressor <: Compressor
    level::Int
    checksum::Bool
end

ZstdCompressor(;level=-1, checksum = false) = ZstdCompressor(level, checksum)

function getCompressor(::Type{ZstdCompressor}, d::Dict)
    ZstdCompressor(d["level"], get(d, "checksum", false))
end

JSON.lower(z::ZstdCompressor) = Dict("id"=>"zstd", "level" => z.level, "checksum" => z.checksum)

function zuncompress(a, ::ZstdCompressor, T)
    result = transcode(CodecZstd.ZstdDecompressor,a)
    Zarr._reinterpret(Base.nonmissingtype(T),result)
end

function zcompress(a, ::ZstdCompressor)
    a_uint8 = vec(Zarr._reinterpret(UInt8,a))
    transcode(CodecZstd.ZstdCompressor, a_uint8)
end


