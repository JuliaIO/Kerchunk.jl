# What is Kerchunk?

## Available data sources

## Tips and tricks

#### Where's my CRS?

That's an interesting question.  Over the short term, Julia doesn't have support for CF-style (climate-and-forecast conventions) CRS metadata.  Additionally, CRS from e.g NetCDF files are stored as empty variables, which Kerchunk removes.  

There are two places you might look for CRS information. 
- First, see if the global metadata contains a `crs_wkt` or `spatial_ref` field.  If so, you can use that.  Other potential keys to look for are `proj4string`, `proj4text`, or `spatial_epsg`.
- Second, you might find a `grid_mapping` metadata field in a layer / Zarr group, which will contain a link to the CRS.  If the value of that `grid_mapping` field is also a key in the global metadata, then that will contain the CRS.

If you're using `Rasters.jl` to load the data, you can set the CRS on a `Raster` or `RasterStack` like this:

```julia
ras = Rasters.setcrs(ras, new_crs)
```

and if you have a WKT string, for example, you can construct `new_crs` like this:

```julia
new_crs = Rasters.ESRIWellKnownText(wkt_string)
# or
new_crs = Rasters.EPSG(epsg_code)
# or
new_crs = Rasters.ProjString(proj4_string)
```

#### S3 redirect errors

Many S3 buckets are restricted to only allow access from certain regions.  If you get an error like this:
```
nested task error: AWS.AWSExceptions.AWSException: PermanentRedirect -- The bucket you are attempting to access must be addressed using the specified endpoint. Please send all future requests to this endpoint.

HTTP.Exceptions.StatusError(301, "GET", "/its-live-data/velocity_image_pair/landsatOLI/v02/N70W040/LC08_L1GT_004010_20140206_20200912_02_T2_X_LC08_L1GT_004010_20140529_20200911_02_T2_G0120V02_P008.nc", HTTP.Messages.Response:
"""
HTTP/1.1 301 Moved Permanently
...
```

then you can set your AWS config to say you're coming from a different region, like this:
```
import AWS
AWS.global_aws_config(AWS.AWSConfig(; region="us-west-2"))
```

#### Version mismatches

Python and Julia load different versions of libraries, which can cause incompatibilities.  For example, both NCDatasets.jl and Python's netcdf4 library depend on libhdf5, but the versions they try to load are incompatible.