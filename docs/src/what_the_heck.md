# What is Kerchunk?

## Available data sources

## Tips and tricks


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