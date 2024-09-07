#=
Kerchunk has two file formats - JSON as discussed earlier, and Parquet.
The Parquet format is a bit complicated - files are nested in 
a directory structure and row indices are computable by 
the chunk index.
The files are also paginated based on a parameter.

Files might look something like this:

```
ref.parquet/deep/name/refs.0.parq
ref.parquet/name/refs.0.parq
ref.parquet/.zmetadata
```

One must first parse `.zmetadata`, a JSON file, which has two fields:
- A `dict[str, str]` that encodes the zmetadata, this may contain inlined files also
- A field `record_size` that encodes how many records may be stored in a single Parquet file.

=#