#=
# ZarrStorePath

This type of file path simply wraps a Zarr store and a subsidiary path
as a FilePathsBase.jl abstract path.
=#

# By definition, in the Zarr spec, 
struct ZarrStorePath{StoreType <: Zarr.AbstractStore} <: FilePathsBase.AbstractPath
    store::StoreType
    segments::Tuple{Vararg{String}}
end

function Base.getproperty(z::ZarrStorePath, p::Symbol)
    if p === :separator
        return "/"
    elseif p === :root
        return _root(z)
    elseif p === :drive
        return ""
    elseif hasfield(ZarrStorePath, p)
        return getfield(z, p)
    else
        error("ZarrStorePath has no property $p")
    end
end

Base.read(z::ZarrStorePath) = Base.getindex(z.store, join(z.segments, "/", ""))
Base.write(z::ZarrStorePath, data) = Base.setindex!(z.store, data, join(z.segments, "/", ""))

Base.ispath(z::ZarrStorePath) = Zarr.isinitialized(z.store, join(z.segments, "/", ""))
function Base.readdir(z::ZarrStorePath)
    subdirs = vcat(Zarr.subdirs(z.store, join(z.segments, "/", "")), Zarr.subkeys(z.store, join(z.segments, "/", "")))
    # TODO: cut out the segments
end

function readbytes(z::ZarrStorePath{Zarr.GCStore}, start::Integer, stop::Integer)
    s = z.store
    i = join(z.segments, "/", "")
    url = string(Zarr.GOOGLE_STORAGE_API,"/",s.bucket,"/",k)
    headers = Zarr._gcs_request_headers()
    headers["Range"] = "$(start)-$(stop-1)"
    r = Zarr.HTTP.request("GET",url,headers,status_exception = false)
    if r.status >= 300
        if r.status == 404
        @debug "get: $url: not found"
        nothing
        else
        error("Error connecting to $url :", String(r.body))
        end
    else
        @debug "get: $url"
        r.body
    end
end

function readbytes(z::ZarrStorePath{S3Store}, start::Integer, stop::Integer)
    s = z.store
    i = join(z.segments, "/", "")
    try
        return s3_get(s.aws,s.bucket,i,raw=true,retry=false,byte_range=(start+1):stop)
      catch e
        if e isa AWSS3.AWS.AWSException && e.code == "NoSuchKey"
          return nothing
        else
          throw(e)
        end
      end
end

# function readbytes(z::ZarrStorePath, start)