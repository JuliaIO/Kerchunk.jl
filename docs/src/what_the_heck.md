# What is Kerchunk?

## Available data sources

## Tips and tricks

#### Version mismatches

Python and Julia load different versions of libraries, which can cause incompatibilities.  For example, both NCDatasets.jl and Python's netcdf4 library depend on libhdf5, but the versions they try to load are incompatible.