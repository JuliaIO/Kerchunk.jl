import Zarr: Filter, zencode, zdecode, getfilter, JSON, filterdict

# We implement here some filters:
# - AsTypeFilter from numcodecs, due to be upstreamed to Zarr
# - CFMaskFilter (to apply before fixedscaleoffset), a translation of Xarray's CFMaskCoder as a Zarr filter
# - CFTimeDeltaFilter
# - CFDatetimeFilter

struct AstypeFilter{EncodedType, DecodedType} <: Filter{EncodedType, DecodedType}
end

function JSON.lower(::AstypeFilter{EncodedType, DecodedType}) where {EncodedType, DecodedType}
    Dict(
        "id" => "astype", 
        "encode_dtype" => Zarr.typestr(EncodedType),
        "decode_dtype" => Zarr.typestr(DecodedType)
    )
end

function Zarr.getfilter(::Type{<: AstypeFilter}, d::Dict)
    return AstypeFilter{Zarr.typestr(d["encode_dtype"]), Zarr.typestr(get(d, "decode_dtype", d["encode_dtype"]))}()
end

function zdecode(ain, ::AstypeFilter{EncodedType, DecodedType}) where {EncodedType, DecodedType}
    data = reinterpret(EncodedType, ain)
    if sizeof(EncodedType) == sizeof(DecodedType)
        return reinterpret(DecodedType, data)
    else
        return DecodedType.(data)
    end
end

function zencode(ain, ::AstypeFilter{EncodedType, DecodedType}) where {EncodedType, DecodedType}
    data = reinterpret(DecodedType, ain)
    if sizeof(EncodedType) == sizeof(DecodedType)
        return reinterpret(EncodedType, data)
    else
        return EncodedType.(data)
    end
end
