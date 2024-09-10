import{_ as a,c as i,a5 as s,o as t}from"./chunks/framework.BTlLJ524.js";const k=JSON.parse('{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"api.md","filePath":"api.md","lastUpdated":null}'),r={name:"api.md"};function l(n,e,h,p,o,d){return t(),i("div",null,e[0]||(e[0]=[s('<ul><li><a href="#Kerchunk.ReferenceStore"><code>Kerchunk.ReferenceStore</code></a></li><li><a href="#Kerchunk._get_file_bytes"><code>Kerchunk._get_file_bytes</code></a></li><li><a href="#Kerchunk.apply_templates-Tuple{ReferenceStore, String}"><code>Kerchunk.apply_templates</code></a></li><li><a href="#Kerchunk.materialize-Tuple{Union{String, FilePathsBase.AbstractPath}, ReferenceStore}"><code>Kerchunk.materialize</code></a></li><li><a href="#Kerchunk.readbytes-Tuple{Any, Integer, Integer}"><code>Kerchunk.readbytes</code></a></li><li><a href="#Kerchunk.resolve_uri-Union{Tuple{HasTemplates}, Tuple{ReferenceStore{&lt;:Any, HasTemplates}, String}} where HasTemplates"><code>Kerchunk.resolve_uri</code></a></li></ul><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.ReferenceStore" href="#Kerchunk.ReferenceStore">#</a> <b><u>Kerchunk.ReferenceStore</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(filename_or_dict) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&lt;:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> Zarr.AbstractStore</span></span></code></pre></div><p>A <code>ReferenceStore</code> is a</p><p>Generally, you will only need to construct this if you have an in-memory Dict or other representation.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/32332b0c62ca8fe0dc4a69f064fd52cc230520a1/src/referencestore.jl#L60-L67" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk._get_file_bytes" href="#Kerchunk._get_file_bytes">#</a> <b><u>Kerchunk._get_file_bytes</u></b> — <i>Function</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">_get_file_bytes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, reference)</span></span></code></pre></div><p>By hook or by crook, this function will return the bytes for the given reference. The reference could be a base64 encoded binary string, a path to a file, or a subrange of a file.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/32332b0c62ca8fe0dc4a69f064fd52cc230520a1/src/referencestore.jl#L272-L277" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.apply_templates-Tuple{ReferenceStore, String}" href="#Kerchunk.apply_templates-Tuple{ReferenceStore, String}">#</a> <b><u>Kerchunk.apply_templates</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">apply_templates</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, source</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">String</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>This function applies the templates stored in <code>store</code> to the source string, and returns the resolved string.</p><p>It uses Mustache.jl under the hood, but all <code>{</code> <code>{</code> <code>template</code> <code>}</code> <code>}</code> values are set to <strong>not</strong> URI-encode characters.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/32332b0c62ca8fe0dc4a69f064fd52cc230520a1/src/referencestore.jl#L341-L347" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.materialize-Tuple{Union{String, FilePathsBase.AbstractPath}, ReferenceStore}" href="#Kerchunk.materialize-Tuple{Union{String, FilePathsBase.AbstractPath}, ReferenceStore}">#</a> <b><u>Kerchunk.materialize</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">materialize</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(path, store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Materialize a Zarr directory from a Kerchunk catalog. This actually downloads and writes the files to the given path, and you can open that with any Zarr reader.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/32332b0c62ca8fe0dc4a69f064fd52cc230520a1/src/materialize.jl#L3-L7" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.readbytes-Tuple{Any, Integer, Integer}" href="#Kerchunk.readbytes-Tuple{Any, Integer, Integer}">#</a> <b><u>Kerchunk.readbytes</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">readbytes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(path, start</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Integer</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, stop</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Integer</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Vector{UInt8}</span></span></code></pre></div><p>Read bytes from a file at a given range.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/32332b0c62ca8fe0dc4a69f064fd52cc230520a1/src/readbytes.jl#L1-L5" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="Kerchunk.resolve_uri-Union{Tuple{HasTemplates}, Tuple{ReferenceStore{&lt;:Any, HasTemplates}, String}} where HasTemplates" href="#Kerchunk.resolve_uri-Union{Tuple{HasTemplates}, Tuple{ReferenceStore{&lt;:Any, HasTemplates}, String}} where HasTemplates">#</a> <b><u>Kerchunk.resolve_uri</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">resolve_uri</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(store</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ReferenceStore</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, source</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">String</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>This function resolves a string which may or may not have templating to a URI.</p><p><a href="https://github.com/JuliaIO/Kerchunk.jl/blob/32332b0c62ca8fe0dc4a69f064fd52cc230520a1/src/referencestore.jl#L306-L310" target="_blank" rel="noreferrer">source</a></p></div><br>',13)]))}const u=a(r,[["render",l]]);export{k as __pageData,u as default};
