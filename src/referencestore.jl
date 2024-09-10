#=

# ReferenceStore

This is a first implementation of a key-value reference store that can store files as:
- base64 encoded UInt8 (byte) file contents
- references to other stores (`[filepath, start_byte_index, end_byte_index]`)

Currently, this only works for local files.  In future it will work on HTTP and S3 stores as well.

Future optimizations include:
- Lazy directory caching so that subdirs and subkeys are fast
- Parallel read strategy for concurrent reads
- Simple templating via Mustache or similar (kerchunk does not natively generate full Jinja templates, but could be extended to do so)

Things not in the immediate future are:
- Complex `jinja` template support

## Notes on templating

Mustache.jl performs URI character escaping on `{{template}}` values, which is apparently not done in Python.  
So we have to unescape them, except it doesn't percent encode, so we actually have to change the template and 
indicate that the no html encoding by modifying the `_type` field of each token.  Horrifying, I know. 

## Notes on file access

Files can be:
- base64 encoded string (in memory file)
- reference to a full file (file path in a single element vector)
- reference to a subrange of a file (`file path`, `start index`, `number of bytes to read` in a three element vector)

Files can also be generated, so we have to parse that and then actually materialize the store, at least for now.

## The JSON schema
```json
{
  "version": (required, must be equal to) 1,
  "templates": (optional, zero or more arbitrary keys) {
    "template_name": jinja-str
  },
  "gen": (optional, zero or more items) [
    "key": (required) jinja-str,
    "url": (required) jinja-str,
    "offset": (optional, required with "length") jinja-str,
    "length": (optional, required with "offset") jinja-str,
    "dimensions": (required, one or more arbitrary keys) {
      "variable_name": (required)
        {"start": (optional) int, "stop": (required) int, "step": (optional) int}
        OR
        [int, ...]
    }
  ],
  "refs": (optional, zero or more arbitrary keys) {
    "key_name": (required) str OR [url(jinja-str)] OR [url(jinja-str), offset(int), length(int)]
  }
}
```
=#

"""
    ReferenceStore(filename_or_dict)

A `ReferenceStore` is a 
"""
struct ReferenceStore{MapperType <: AbstractDict, HasTemplates} <: Zarr.AbstractStore
    mapper::MapperType
    zmetadata::Dict{String, Any}
    templates::Dict{String, String}
end

function ReferenceStore(filename::Union{String, FilePathsBase.AbstractPath})
    parsed = JSON3.read(read(filename))
    return ReferenceStore(parsed)
end

function ReferenceStore(parsed::AbstractDict{<: Union{String, Symbol}, <: Any})
    @assert haskey(parsed, "version") "ReferenceStore requires a version field, did not find one.  if you have a Kerchunk v0 then you have a problem!"
    @assert parsed["version"] == 1 "ReferenceStore only supports Kerchunk version 1, found $version"
    @assert !haskey(parsed, "gen") "ReferenceStore does not support generated paths, please file an issue on Github if you need these!"

    has_templates = haskey(parsed, "templates")
    templates = if has_templates
        td = Dict{String, String}()
        for (k, v) in parsed["templates"]
            td[string(k)] = string(v)
        end
        td
    else
        Dict{String, String}()
    end

    zmetadata = if haskey(parsed, ".zmetadata")
        td = Dict{String, Any}()
        for (k, v) in parsed[".zmetadata"]
            td[string(k)] = v
        end
        td
    else
        Dict{String, Any}()
    end

    refs = parsed["refs"]

    return ReferenceStore{typeof(refs), has_templates}(refs, zmetadata, templates)
end

function Base.show(io::IO, ::MIME"text/plain", store::ReferenceStore)
    println(io, "ReferenceStore with $(length(store.mapper)) references")
end

function Base.show(io::IO, store::ReferenceStore)
    println(io, "ReferenceStore with $(length(store.mapper)) references")
end

function Base.getindex(store::ReferenceStore, key::String)
    return store.mapper[key]
end

function Base.setindex!(store::ReferenceStore, value, key::String)
    error("ReferenceStore is read-only for now")
    #store.mapper[key] = value
end


function Base.keys(store::ReferenceStore)
    return keys(store.mapper)
end

function Base.values(store::ReferenceStore)
    return values(store.mapper)
end

# Implement the Zarr interface

# Utility functions copied from Zarr.jl
function _pdict(d::AbstractDict{<: Symbol, Any}, path)
    p = (isempty(path) || endswith(path,'/')) ? path : path*'/'
    return filter(((k,v),) -> startswith(string(k), path) ,d)
end

function _searchsubdict(d2,p,condition)
    o = Set{String}()
    pspl = split(rstrip(p,'/'), '/')
    lp = if length(pspl) == 1 && isempty(pspl[1])
        0
    else
        length(pspl)
    end
    for k in Iterators.map(string, keys(d2))
      sp = split(k,'/')
        if condition(sp,lp)
            push!(o,sp[lp+1])
        end
    end
    collect(o)
end


# The actual Zarr store API implementation follows.

function Zarr.storefromstring(::Type{<: ReferenceStore}, url, _)
    
    # Parse the resolved string as a URI
    uri = URIs.URI(url[(length("reference://")+1):end])

    # If the URI's scheme is empty, we're resolving a local file path.
    # Note that we always use PosixPaths here, because the Zarr spec mandates that
    # all path separators be forward slashes.  Kerchunk also mandates this.
    file_path = if isempty(uri.scheme)
        if isabspath(uri.uri)
            FilePathsBase.PosixPath(uri.uri)
        elseif ispath(uri.uri)
            FilePathsBase.PosixPath(joinpath(pwd(), uri.uri))
        else
            error("Invalid path, presumed local but not resolvable as absolute or relative path: $(uri.path)")
        end
    elseif uri.scheme == "file" # Otherwise, we check the protocol and create the appropriate path type.
        FilePathsBase.SystemPath(uri.path)
    elseif uri.scheme == "s3"
        AWSS3.S3Path(uri.uri)
    end # TODO: add more protocols, like HTTP, Google Cloud, Azure, etc.
    return ReferenceStore(file_path), "" # ReferenceStore never has a relative path
end

function Zarr.subdirs(store::ReferenceStore, key)
    d2 = _pdict(store.mapper, key)
    return _searchsubdict(d2, key, (sp, lp) -> length(sp) > lp + 1)
end

function Zarr.subkeys(store::ReferenceStore, key::String)
    d2 = _pdict(store.mapper, key)
    _searchsubdict(d2, key, (sp,lp)->length(sp) == lp+1)
end

function Zarr.storagesize(store::ReferenceStore, key::String) 
    spec = store[key]
    if spec isa String
        return length(string)
    elseif spec isa JSON3.Array
        if length(spec) == 1
            return filesize(resolve_uri(store, only(spec)))
        elseif length(spec) == 3
            return spec[3] - spec[2] # since we know the byte range, we can return the length directly
        else
            error("Invalid path spec $spec \n expected 1 or 3 elements, got $(length(spec))")
        end
    else
        error("Invalid path spec $spec \n expected a string or array, got $(typeof(spec))")
    end
end


function Zarr.read_items!(store::ReferenceStore, c::AbstractChannel, p, i)
    cinds = [Zarr.citostring(ii) for ii in i]
    ckeys = ["$p/$cind" for cind in cinds]
    for (idx, ii) in enumerate(i)
        file_value = if Zarr.isinitialized(store, ckeys[idx])
            _get_file_bytes(store, store[ckeys[idx]])
        else
            nothing
        end
        put!(c, (ii => file_value))
    end
end

function Zarr.isinitialized(store::ReferenceStore, p::String) # TODO: this is broken?!
    return haskey(store.mapper, p)
end

function Zarr.isinitialized(store::ReferenceStore, p::String, i::Int) # TODO: this is broken?!
    return haskey(store.mapper, "$p/$i")
end

Zarr.is_zarray(store::ReferenceStore, p::String) = ((normpath(p) in ("/", ".")) ? ".zarray" : normpath("$p/.zarray")) in keys(store)
Zarr.is_zgroup(store::ReferenceStore, p::String) = ((normpath(p) in ("/", ".")) ? ".zgroup" : normpath("$p/.zgroup")) in keys(store)

Zarr.getattrs(store::ReferenceStore, p::String) = if haskey(store.mapper, normpath(p) in ("/", ".") ? ".zattrs" : "$p/.zattrs")
    Zarr.JSON.parse(String(_get_file_bytes(store, store[normpath(p) in ("/", ".") ? ".zattrs" : "$p/.zattrs"])))
else
    Dict{String, Any}()
end

Zarr.store_read_strategy(::ReferenceStore) = Zarr.SequentialRead()
Zarr.read_items!(s::ReferenceStore, c::AbstractChannel, ::Zarr.SequentialRead, p, i) = Zarr.read_items!(s, c, p, i)


# End of Zarr interface implementation

# Begin file access implementation

"""
    _get_file_bytes(store::ReferenceStore, reference)

By hook or by crook, this function will return the bytes for the given reference.
The reference could be a base64 encoded binary string, a path to a file, or a subrange of a file.
"""
function _get_file_bytes end

function _get_file_bytes(store::ReferenceStore, bytes::String)
    # single file
    if startswith(bytes, "base64:") # base64 encoded binary
        # TODO: make this more efficient by reinterpret + view
        return base64decode(bytes[7:end])
    else # JSON file
        return Vector{UInt8}(bytes)
    end
end

function _get_file_bytes(store::ReferenceStore, spec::JSON3.Array)
    if Base.length(spec) == 1
        # path to file, read the whole thing
        file = only(spec)
        return read(resolve_uri(store, file))
    elseif Base.length(spec) == 3
        # subpath to file
        filename, offset, length = spec
        uri = resolve_uri(store, filename)
        return readbytes(uri, offset #= mimic Python behaviour =#, offset + length)
    else
        error("Invalid path spec $spec \n expected 1 or 3 elements, got $(length(spec))")
    end
end


"""
    resolve_uri(store::ReferenceStore, source::String)

This function resolves a string which may or may not have templating to a URI.
"""
function resolve_uri(store::ReferenceStore{<: Any, HasTemplates}, source::String) where {HasTemplates}
    resolved = if HasTemplates
        apply_templates(store, source)
    else
        source
    end
    # Parse the resolved string as a URI
    uri = URIs.URI(resolved)

    # If the URI's scheme is empty, we're resolving a local file path.
    # Note that we always use PosixPaths here, because the Zarr spec mandates that
    # all path separators be forward slashes.  Kerchunk also mandates this.
    if isempty(uri.scheme)
        if isabspath(source)
            return FilePathsBase.PosixPath(source)
        elseif ispath(source)
            return FilePathsBase.PosixPath(joinpath(pwd(), source))
        else
            error("Invalid path, presumed local but not resolvable as absolute or relative path: $source")
        end
    end
    # Otherwise, we check the protocol and create the appropriate path type.
    if uri.scheme == "file"
        return FilePathsBase.SystemPath(uri.path)
    elseif uri.scheme == "s3"
        return Zarr.AWSS3.S3Path(uri.uri)
    end # TODO: add more protocols, like HTTP, Google Cloud, Azure, etc.
end


"""
    apply_templates(store::ReferenceStore, source::String)

This function applies the templates stored in `store` to the source string, and returns the resolved string.

It uses Mustache.jl under the hood, but all `{{template}}` values are set to **not** URI-encode characters.
"""
function apply_templates(store::ReferenceStore, source::String)
    tokens = Mustache.parse(source)
    # Adjust tokens so that `{{var}}` becomes `{{{var}}}`, the latter of which
    # is rendered without URI escaping.
    for token in tokens.tokens
        if token._type == "name"
            token._type = "{"
        end
    end
    return Mustache.render(tokens, store.templates)
end