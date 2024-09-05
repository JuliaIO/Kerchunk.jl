"""
    readbytes(path, start::Integer, stop::Integer)::Vector{UInt8}

Read bytes from a file at a given range.
"""
function readbytes(path, start::Integer, stop::Integer)
    @assert start < stop "In `readbytes`, start ($(start)) must be less than stop ($(stop))."
    open(path) do f
        seek(f, start)
        return read(f, stop + 1 - start)
    end
end

function readbytes(path::Zarr.AWSS3.S3Path, start::Integer, stop::Integer)
    @assert start < stop "In `readbytes`, start ($(start)) must be less than stop ($(stop))."
    return read(path; byte_range = (start+1):stop)
end