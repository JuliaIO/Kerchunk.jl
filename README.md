# Kerchunk

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaIO.github.io/Kerchunk.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaIO.github.io/Kerchunk.jl/dev/)
[![Build Status](https://github.com/JuliaIO/Kerchunk.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaIO/Kerchunk.jl/actions/workflows/CI.yml?query=branch%3Amain)

Kerchunk.jl is a Julia package that enables loading Kerchunk reference catalogs as Zarr arrays via a storage backend.

## Installation

```julia
] 
add Kerchunk
```

## Quick start

```julia
using Kerchunk, Zarr

za = Zarr.zopen(Kerchunk.ReferenceStore("path/to/kerchunk/catalog.json"))
# and treat it like any other Zarr array!
# You can even wrap it in YAXArrays.jl to get DimensionalData.jl accessors:
using YAXArrays
YAXArrays.open_dataset(za)
```

## Background

[`kerchunk`] is a Python package that generates the reference catalogs.

## Alternatives and related packages

- You can always use Python's `xarray` directly via PythonCall.jl
- [FSSpec.jl](https://github.com/asinghvi17/FSSpec.jl) is an alternative storage backends for Zarr.jl that wraps the same [`fsspec`](https://github.com/fsspec/filesystem_spec) that `xarray` uses under the hood.

This package is of course built on top of [Zarr.jl](https://github.com/JuliaIO/Zarr.jl), which is a pure-Julia Zarr array library.
[YAXArrays.jl](https://github.com/JuliaDataCubes/YAXArrays.jl) is a Julia package that can wrap Zarr arrays in a DimensionalData-compatible interface.