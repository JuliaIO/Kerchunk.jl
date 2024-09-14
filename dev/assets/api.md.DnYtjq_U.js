import{_ as a,c as i,a5 as s,o as t}from"./chunks/framework.BfCslVPr.js";const k=JSON.parse('{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"api.md","filePath":"api.md","lastUpdated":null}'),r={name:"api.md"};function l(o,e,n,d,h,c){return t(),i("div",null,e[0]||(e[0]=[s(`<ul><li><a href="#Kerchunk.DeltaFilter"><code>Kerchunk.DeltaFilter</code></a></li><li><a href="#Kerchunk.FixedScaleOffsetFilter"><code>Kerchunk.FixedScaleOffsetFilter</code></a></li><li><a href="#Kerchunk.Fletcher32Filter"><code>Kerchunk.Fletcher32Filter</code></a></li><li><a href="#Kerchunk.QuantizeFilter"><code>Kerchunk.QuantizeFilter</code></a></li><li><a href="#Kerchunk.ReferenceStore"><code>Kerchunk.ReferenceStore</code></a></li><li><a href="#Kerchunk._get_file_bytes"><code>Kerchunk._get_file_bytes</code></a></li><li><a href="#Kerchunk.add_scale_offset_filter_and_set_mask!-Tuple{Dict, Dict}"><code>Kerchunk.add_scale_offset_filter_and_set_mask!</code></a></li><li><a href="#Kerchunk.apply_templates-Tuple{ReferenceStore, String}"><code>Kerchunk.apply_templates</code></a></li><li><a href="#Kerchunk.do_correction!-Tuple{Any, ReferenceStore, Any}"><code>Kerchunk.do_correction!</code></a></li><li><a href="#Kerchunk.materialize-Tuple{Union{String, FilePathsBase.AbstractPath}, ReferenceStore}"><code>Kerchunk.materialize</code></a></li><li><a href="#Kerchunk.move_compressor_from_filters!-Tuple{Dict, Dict}"><code>Kerchunk.move_compressor_from_filters!</code></a></li><li><a href="#Kerchunk.readbytes-Tuple{Any, Integer, Integer}"><code>Kerchunk.readbytes</code></a></li><li><a href="#Kerchunk.resolve_uri-Union{Tuple{HasTemplates}, Tuple{ReferenceStore{&lt;:Any, HasTemplates}, String}} where HasTemplates"><code>Kerchunk.resolve_uri</code></a></li></ul><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.DeltaFilter" href="#Kerchunk.DeltaFilter">#</a> <b><u>Kerchunk.DeltaFilter</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">DeltaFilter</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(; DecodingType, [EncodingType </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> DecodingType])</span></span></code></pre></div><p>Delta-based compression for Zarr arrays. (Delta encoding is Julia <code>diff</code>, decoding is Julia <code>cumsum</code>).</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/required_zarr_filters.jl#L18-L22" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.FixedScaleOffsetFilter" href="#Kerchunk.FixedScaleOffsetFilter">#</a> <b><u>Kerchunk.FixedScaleOffsetFilter</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">FixedScaleOffsetFilter{T,TENC}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(scale, offset)</span></span></code></pre></div><p>A compressor that scales and offsets the data.</p><div class="tip custom-block"><p class="custom-block-title">Note</p><p>The geographic CF standards define scale/offset decoding as <code>x * scale + offset</code>, but this filter defines it as <code>x / scale + offset</code>. Constructing a <code>FixedScaleOffsetFilter</code> from CF data means <code>FixedScaleOffsetFilter(1/cf_scale_factor, cf_add_offset)</code>.</p></div><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/required_zarr_filters.jl#L57-L66" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.Fletcher32Filter" href="#Kerchunk.Fletcher32Filter">#</a> <b><u>Kerchunk.Fletcher32Filter</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Fletcher32Filter</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span></code></pre></div><p>A compressor that uses the Fletcher32 checksum algorithm to compress and uncompress data.</p><p>Note that this goes from UInt8 to UInt8, and is effectively only checking the checksum and cropping the last 4 bytes of the data during decoding.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/required_zarr_filters.jl#L115-L122" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.QuantizeFilter" href="#Kerchunk.QuantizeFilter">#</a> <b><u>Kerchunk.QuantizeFilter</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">QuantizeFilter</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(; digits, DecodingType, [EncodingType </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> DecodingType])</span></span></code></pre></div><p>Quantization based compression for Zarr arrays.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/required_zarr_filters.jl#L195-L199" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.ReferenceStore" href="#Kerchunk.ReferenceStore">#</a> <b><u>Kerchunk.ReferenceStore</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(filename_or_dict) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&lt;:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> Zarr.AbstractStore</span></span></code></pre></div><p>A <code>ReferenceStore</code> is a &quot;fake filesystem&quot; encoded by some key-value store dictionary, either held in memory, or read from a JSON file in the <a href="https://fsspec.github.io/kerchunk/" target="_blank" rel="noreferrer">Kerchunk format</a>.</p><p>Generally, you will only need to construct this if you have an in-memory Dict or other representation, or if you want to explicitly modify the store before constructing a ZGroup, which eagerly loads metadata.</p><p><strong>Extended help</strong></p><p><strong>Implementation</strong></p><p>The reference store has several fields:</p><ul><li><p><code>mapper</code>: The actual key-value store that file information (<code>string of base64 bytes</code>, <code>[single uri]</code>, <code>[uri, byte_offset, byte_length]</code>) is stored in. The type here is parametrized so this may be mutable if in memory, or immutable, e.g a JSON3.Object.</p></li><li><p><code>zmetadata</code>: The toplevel Zarr metadata, sometimes stored separately.</p></li><li><p><code>templates</code>: Key-value store for template expansion, if URLs need to be compressed.</p></li><li><p><code>cache</code>: Key-value store for explicitly downloaded or otherwise modified keys.</p></li></ul><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/referencestore.jl#L60-L81" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk._get_file_bytes" href="#Kerchunk._get_file_bytes">#</a> <b><u>Kerchunk._get_file_bytes</u></b> — <i>Function</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">_get_file_bytes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, reference)</span></span></code></pre></div><p>By hook or by crook, this function will return the bytes for the given reference. The reference could be a base64 encoded binary string, a path to a file, or a subrange of a file.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/referencestore.jl#L320-L325" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.add_scale_offset_filter_and_set_mask!-Tuple{Dict, Dict}" href="#Kerchunk.add_scale_offset_filter_and_set_mask!-Tuple{Dict, Dict}">#</a> <b><u>Kerchunk.add_scale_offset_filter_and_set_mask!</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">add_scale_offset_filter_and_set_mask!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(zarray</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Dict</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, zattrs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Dict</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Adapts the CF metadata convention of scale/offset, valid_range, _FillValue, and _Unsigned by modifying the Zarr metadata to add:</p><ul><li><p>An additional reinterpretation filter is added to the filter stack if <code>_Unsigned=true</code>. This allows the values to be interpreted as UInts instead of Ints, which removes the sign error that would otherwise plague your dataset.</p></li><li><p>A <code>FixedScaleOffset</code> filter replaces <code>scale_factor</code> and <code>add_offset</code>.</p></li><li><p><code>valid_range</code> and <code>_FillValue</code> are mutated based on the scale factor and added offset, and the native Zarr <code>fill_value</code> is replaced by the mutated and read <code>_FillValue</code>.</p></li></ul><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/cf_corrections.jl#L86-L98" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.apply_templates-Tuple{ReferenceStore, String}" href="#Kerchunk.apply_templates-Tuple{ReferenceStore, String}">#</a> <b><u>Kerchunk.apply_templates</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">apply_templates</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, source</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">String</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>This function applies the templates stored in <code>store</code> to the source string, and returns the resolved string.</p><p>It uses Mustache.jl under the hood, but all <code>{</code> <code>{</code> <code>template</code> <code>}</code> <code>}</code> values are set to <strong>not</strong> URI-encode characters.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/referencestore.jl#L390-L396" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.do_correction!-Tuple{Any, ReferenceStore, Any}" href="#Kerchunk.do_correction!-Tuple{Any, ReferenceStore, Any}">#</a> <b><u>Kerchunk.do_correction!</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">do_correction!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(f!, store, path)</span></span></code></pre></div><p>Applies <code>f!</code> on the parsed <code>.zarray</code> and <code>.zattrs</code> files about the array at path <code>path</code> in the Zarr store <code>store</code>. These corrections mutate the files <code>.zarray</code> and <code>.zmetadata</code>, and attempt to save them to the store.</p><p>Available corrections are <a href="/Kerchunk.jl/dev/api#Kerchunk.add_scale_offset_filter_and_set_mask!-Tuple{Dict, Dict}"><code>add_scale_offset_filter_and_set_mask!</code></a> and <a href="/Kerchunk.jl/dev/api#Kerchunk.move_compressor_from_filters!-Tuple{Dict, Dict}"><code>move_compressor_from_filters!</code></a>.</p><p>TODOs:</p><ul><li>Make this work for consolidated metadata (check for the presence of a .zmetadata key)?</li></ul><p><strong>Usage</strong></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">st,  </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Zarr</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">storefromstring</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;reference://catalog.json&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Kerchunk</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">do_correction!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(Kerchunk</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">add_scale_offset_filter_and_set_mask!, st, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;SomeVariable&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">zopen</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(st)</span></span></code></pre></div><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/cf_corrections.jl#L26-L46" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.materialize-Tuple{Union{String, FilePathsBase.AbstractPath}, ReferenceStore}" href="#Kerchunk.materialize-Tuple{Union{String, FilePathsBase.AbstractPath}, ReferenceStore}">#</a> <b><u>Kerchunk.materialize</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">materialize</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(path, store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Materialize a Zarr directory from a Kerchunk catalog. This actually downloads and writes the files to the given path, and you can open that with any Zarr reader.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/materialize.jl#L3-L7" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.move_compressor_from_filters!-Tuple{Dict, Dict}" href="#Kerchunk.move_compressor_from_filters!-Tuple{Dict, Dict}">#</a> <b><u>Kerchunk.move_compressor_from_filters!</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">move_compressor_from_filters!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(zarray, zattrs)</span></span></code></pre></div><p>Checks if the last entry of <code>zarray[&quot;filters&quot;]</code> is actually a compressor, and if there is no other compressor moves it from the filter array to the <code>zarray[&quot;compressor&quot;]</code> field.</p><p>This is a common issue with Kerchunk metadata, since it seems numcodecs doesn&#39;t distinguish between compressors and filters. This function will not be needed for Zarr v3 datasets, since the compressors and filters are all codecs in that schema.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/cf_corrections.jl#L145-L156" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.readbytes-Tuple{Any, Integer, Integer}" href="#Kerchunk.readbytes-Tuple{Any, Integer, Integer}">#</a> <b><u>Kerchunk.readbytes</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">readbytes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(path, start</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Integer</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, stop</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Integer</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Vector{UInt8}</span></span></code></pre></div><p>Read bytes from a file at a given range.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/readbytes.jl#L1-L5" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.resolve_uri-Union{Tuple{HasTemplates}, Tuple{ReferenceStore{&lt;:Any, HasTemplates}, String}} where HasTemplates" href="#Kerchunk.resolve_uri-Union{Tuple{HasTemplates}, Tuple{ReferenceStore{&lt;:Any, HasTemplates}, String}} where HasTemplates">#</a> <b><u>Kerchunk.resolve_uri</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">resolve_uri</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, source</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">String</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>This function resolves a string which may or may not have templating to a URI.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/f57bea1205a64002e14a8e3f0df16066dcda1e03/src/referencestore.jl#L355-L359" target="_blank" rel="noreferrer">source</a></p></div><br>`,27)]))}const u=a(r,[["render",l]]);export{k as __pageData,u as default};