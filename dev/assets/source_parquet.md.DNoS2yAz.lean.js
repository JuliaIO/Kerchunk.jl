import{_ as a,c as t,a5 as s,o as r}from"./chunks/framework.BTlLJ524.js";const h=JSON.parse('{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"source/parquet.md","filePath":"source/parquet.md","lastUpdated":null}'),i={name:"source/parquet.md"};function n(p,e,o,d,l,c){return r(),t("div",null,e[0]||(e[0]=[s(`<p>Kerchunk has two file formats - JSON as discussed earlier, and Parquet. The Parquet format is a bit complicated - files are nested in a directory structure and row indices are computable by the chunk index. The files are also paginated based on a parameter.</p><p>Files might look something like this:</p><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>ref.parquet/deep/name/refs.0.parq</span></span>
<span class="line"><span>ref.parquet/name/refs.0.parq</span></span>
<span class="line"><span>ref.parquet/.zmetadata</span></span></code></pre></div><p>One must first parse <code>.zmetadata</code>, a JSON file, which has two fields:</p><ul><li><p>A <code>dict[str, str]</code> that encodes the zmetadata, this may contain inlined files also</p></li><li><p>A field <code>record_size</code> that encodes how many records may be stored in a single Parquet file.</p></li></ul><hr><p><em>This page was generated using <a href="https://github.com/fredrikekre/Literate.jl" target="_blank" rel="noreferrer">Literate.jl</a>.</em></p>`,7)]))}const m=a(i,[["render",n]]);export{h as __pageData,m as default};
