#=
# Required Zarr Filters

This file implements all the filters in my Zarr.jl PR, so that
we can register Kerchunk and users can use it without Zarr being an issue.


=#

import Zarr: Filter, zencode, zdecode, JSON, getfilter, filterdict, typestr

#=
# Delta compression


=#

"""
    DeltaFilter(; DecodingType, [EncodingType = DecodingType])

Delta-based compression for Zarr arrays.  (Delta encoding is Julia `diff`, decoding is Julia `cumsum`).
"""
struct DeltaFilter{T, TENC} <: Filter{T, TENC}
end

function DeltaFilter(; DecodingType = Float16, EncodingType = DecodingType)
    return DeltaFilter{DecodingType, EncodingType}()
end

DeltaFilter{T}() where T = DeltaFilter{T, T}()

function zencode(data::AbstractArray, filter::DeltaFilter{DecodingType, EncodingType}) where {DecodingType, EncodingType}
    arr = reinterpret(DecodingType, vec(data))

    enc = similar(arr, EncodingType)
    # perform the delta operation
    enc[begin] = arr[begin]
    enc[begin+1:end] .= diff(arr)
    return enc
end

function zdecode(data::AbstractArray, filter::DeltaFilter{DecodingType, EncodingType}) where {DecodingType, EncodingType}
    encoded = reinterpret(EncodingType, vec(data))
    decoded = DecodingType.(cumsum(encoded))
    return decoded
end

function JSON.lower(filter::DeltaFilter{T, Tenc}) where {T, Tenc}
    return Dict("id" => "delta", "dtype" => typestr(T), "atype" => typestr(Tenc))
end

function getfilter(::Type{<: DeltaFilter}, d)
    return DeltaFilter{typestr(d["dtype"], haskey(d, "atype") ? typestr(d["atype"]) : d["dtype"])}()
end


"""
    FixedScaleOffsetFilter{T,TENC}(scale, offset)

A compressor that scales and offsets the data.

!!! note
    The geographic CF standards define scale/offset decoding as `x * scale + offset`,
    but this filter defines it as `x / scale + offset`.  Constructing a `FixedScaleOffsetFilter`
    from CF data means `FixedScaleOffsetFilter(1/cf_scale_factor, cf_add_offset)`.
"""
struct FixedScaleOffsetFilter{ScaleOffsetType, T, Tenc} <: Filter{T, Tenc}
    scale::ScaleOffsetType
    offset::ScaleOffsetType
end

FixedScaleOffsetFilter{T}(scale::ScaleOffsetType, offset::ScaleOffsetType) where {T, ScaleOffsetType} = FixedScaleOffsetFilter{T, ScaleOffsetType}(scale, offset)
FixedScaleOffsetFilter(scale::ScaleOffsetType, offset::ScaleOffsetType) where {ScaleOffsetType} = FixedScaleOffsetFilter{ScaleOffsetType, ScaleOffsetType}(scale, offset)

function FixedScaleOffsetFilter(; scale::ScaleOffsetType, offset::ScaleOffsetType, T, Tenc = T) where ScaleOffsetType
    return FixedScaleOffsetFilter{ScaleOffsetType, T, Tenc}(scale, offset)
end

function zencode(a::AbstractArray, c::FixedScaleOffsetFilter{ScaleOffsetType, T, Tenc}) where {T, Tenc, ScaleOffsetType}
    return @. convert(Tenc, # convert to the encoding type after applying the scale and offset
        round((a - c.offset) * c.scale) # apply scale and offset, and round to nearest integer
    )
end

function zdecode(a::AbstractArray, c::FixedScaleOffsetFilter{ScaleOffsetType, T, Tenc}) where {T, Tenc, ScaleOffsetType}
    return @. convert(Base.nonmissingtype(T), (a / c.scale) + c.offset)
end


function getfilter(::Type{<: FixedScaleOffsetFilter}, d::Dict)
    scale = d["scale"]
    offset = d["offset"]
    # Types must be converted from strings to the actual Julia types they represent.
    string_T = d["dtype"]
    string_Tenc = get(d, "atype", string_T)
    T = typestr(string_T)
    Tenc = typestr(string_Tenc)
    return FixedScaleOffsetFilter{Tenc, T, Tenc}(scale, offset)
end

function JSON.lower(c::FixedScaleOffsetFilter{ScaleOffsetType, T, Tenc}) where {ScaleOffsetType, T, Tenc}
    return Dict("id" => "fixedscaleoffset", "scale" => c.scale, "offset" => c.offset, "dtype" => typestr(T), "atype" => typestr(Tenc))
end

#=
# Fletcher32 filter

This "filter" basically injects a 4-byte checksum at the end of the data, to ensure data integrity.

The implementation is based on the [numcodecs implementation here](https://github.com/zarr-developers/numcodecs/blob/79d1a8d4f9c89d3513836aba0758e0d2a2a1cfaf/numcodecs/fletcher32.pyx)
and the [original C implementation for NetCDF](https://github.com/Unidata/netcdf-c/blob/main/plugins/H5checksum.c#L109) linked therein.

=#

"""
    Fletcher32Filter()

A compressor that uses the Fletcher32 checksum algorithm to compress and uncompress data.

Note that this goes from UInt8 to UInt8, and is effectively only checking 
the checksum and cropping the last 4 bytes of the data during decoding.
"""
struct Fletcher32Filter <: Filter{UInt8, UInt8}
end

getfilter(::Type{<: Fletcher32Filter}, d::Dict) = Fletcher32Filter()
JSON.lower(::Fletcher32Filter) = Dict("id" => "fletcher32")

function _checksum_fletcher32(data::AbstractVector{UInt8})
    len = length(data) / 2 # length in 16-bit words
    sum1::UInt32 = 0
    sum2::UInt32 = 0
    data_idx = 1

    #=
    Compute the checksum for pairs of bytes.
    The magic `360` value is the largest number of sums that can be performed without overflow in UInt32.
    =#
    while len > 0
        tlen = len > 360 ? 360 : len
        len -= tlen
        while tlen > 0
            sum1 += begin # create a 16 bit word from two bytes, the first one shifted to the end of the word
                (UInt16(data[data_idx]) << 8) | UInt16(data[data_idx + 1]) 
            end
            sum2 += sum1
            data_idx += 2
            tlen -= 1
            if tlen < 1
                break
            end
        end
        sum1 = (sum1 & 0xffff) + (sum1 >> 16)
        sum2 = (sum2 & 0xffff) + (sum2 >> 16)
    end

    # if the length of the data is odd, add the first byte to the checksum again (?!)
    if length(data) % 2 == 1 
        sum1 += UInt16(data[1]) << 8
        sum2 += sum1
        sum1 = (sum1 & 0xffff) + (sum1 >> 16)
        sum2 = (sum2 & 0xffff) + (sum2 >> 16)
    end
    return (sum2 << 16) | sum1
end

function zencode(data, ::Fletcher32Filter)
    bytes = reinterpret(UInt8, data)
    checksum = _checksum_fletcher32(bytes)
    result = copy(bytes)
    append!(result, reinterpret(UInt8, [checksum])) # TODO: decompose this without the extra allocation of wrapping in Array
    return result
end

function zdecode(data, ::Fletcher32Filter)
    bytes = reinterpret(UInt8, data)
    checksum = _checksum_fletcher32(view(bytes, 1:length(bytes) - 4))
    stored_checksum = only(reinterpret(UInt32, view(bytes, (length(bytes) - 3):length(bytes))))
    if checksum != stored_checksum
        throw(ErrorException("""
        Checksum mismatch in Fletcher32 decoding.  
        
        The computed value is $(checksum) and the stored value is $(stored_checksum).  
        This might be a sign that the data is corrupted.
        """)) # TODO: make this a custom error type
    end
    return view(bytes, 1:length(bytes) - 4)
end
#=
# Quantize compression


=#

"""
    QuantizeFilter(; digits, DecodingType, [EncodingType = DecodingType])

Quantization based compression for Zarr arrays.
"""
struct QuantizeFilter{T, TENC} <: Filter{T, TENC}
    digits::Int32
end

function QuantizeFilter(; digits = 10, T = Float16, Tenc = T)
    return QuantizeFilter{T, Tenc}(digits)
end

QuantizeFilter{T, Tenc}(; digits = 10) where {T, Tenc} = QuantizeFilter{T, Tenc}(digits)
QuantizeFilter{T}(; digits = 10) where T = QuantizeFilter{T, T}(digits)

function zencode(data::AbstractArray, filter::QuantizeFilter{DecodingType, EncodingType}) where {DecodingType, EncodingType}
    arr = reinterpret(DecodingType, vec(data))

    precision = 10.0^(-filter.digits)

    _exponent = log(10, precision) # log 10 in base `precision`
    exponent = _exponent < 0 ? floor(Int, _exponent) : ceil(Int, _exponent)

    bits = ceil(log(2, 10.0^(-exponent)))
    scale = 2.0^bits

    enc = @. round(scale * arr) / scale

    if EncodingType == DecodingType
        return enc
    else
        return reinterpret(EncodingType, enc)
    end
end

# Decoding is a no-op; quantization is a lossy filter but data is encoded directly.
function zdecode(data::AbstractArray, filter::QuantizeFilter{DecodingType, EncodingType}) where {DecodingType, EncodingType}
    return data
end

function JSON.lower(filter::QuantizeFilter{T, Tenc}) where {T, Tenc}
    return Dict("type" => "quantize", "digits" => filter.digits, "dtype" => typestr(T), "atype" => typestr(Tenc))
end

function getfilter(::Type{<: QuantizeFilter}, d)
    return QuantizeFilter{typestr(d["dtype"], typestr(d["atype"]))}(; digits = d["digits"])
end
#=
# Shuffle compression

This file implements the shuffle compressor.
=#

struct ShuffleFilter <: Filter{UInt8, UInt8}
    elementsize::Csize_t
end

ShuffleFilter(; elementsize = 4) = ShuffleFilter(elementsize)

function _do_shuffle!(dest::AbstractVector{UInt8}, source::AbstractVector{UInt8}, elementsize::Csize_t)
    count = fld(length(source), elementsize) # elementsize is in bytes, so this works
    for i in 0:(count-1)
        offset = i * elementsize
        for byte_index in 0:(elementsize-1)
            j = byte_index * count + i
            dest[j+1] = source[offset + byte_index+1]
        end
    end
end

function _do_unshuffle!(dest::AbstractVector{UInt8}, source::AbstractVector{UInt8}, elementsize::Csize_t)
    count = fld(length(source), elementsize) # elementsize is in bytes, so this works
    for i in 0:(elementsize-1)
        offset = i * count
        for byte_index in 0:(count-1)
            j = byte_index * elementsize + i
            dest[j+1] = source[offset + byte_index+1]
        end
    end
end

function zencode(a::AbstractArray, c::ShuffleFilter)
    if c.elementsize <= 1 # no shuffling needed if elementsize is 1
        return a
    end
    source = reinterpret(UInt8, vec(a))
    dest = Vector{UInt8}(undef, length(source))
    _do_shuffle!(dest, source, c.elementsize)
    return dest
end

function zdecode(a::AbstractArray, c::ShuffleFilter)
    if c.elementsize <= 1 # no shuffling needed if elementsize is 1
        return a
    end
    source = reinterpret(UInt8, vec(a))
    dest = Vector{UInt8}(undef, length(source))
    _do_unshuffle!(dest, source, c.elementsize)
    return dest
end

function getfilter(::Type{ShuffleFilter}, d::Dict)
    return ShuffleFilter(d["elementsize"])
end

function JSON.lower(c::ShuffleFilter)
    return Dict("id" => "shuffle", "elementsize" => Int64(c.elementsize))
end
