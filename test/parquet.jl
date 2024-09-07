using CondaPkg, Parquet

# Generate the Parquet reference file
CondaPkg.withenv() do 
run(```
$(CondaPkg.which("python")) -c "
import numpy as np
import fsspec
import fsspec.implementations.reference
import zarr
lz = fsspec.implementations.reference.LazyReferenceMapper.create(\"ref.parquet\")
z = zarr.open_group(lz, mode=\"w\")
d = z.create_dataset(\"name\", shape=(10,10))
d[:, :] = np.random.randn(10, 10)
g2 = z.create_group(\"deep\")
d = g2.create_dataset(\"name\", shape=(15, 15))
d[:, :] = np.random.randn(15, 15)
"
```)
end

