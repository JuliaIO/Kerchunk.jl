import{_ as s,c as e,a5 as t,o as i}from"./chunks/framework.KBT3hDmv.js";const g=JSON.parse('{"title":"ITS_LIVE data","description":"","frontmatter":{},"headers":[],"relativePath":"tutorials/its_live.md","filePath":"tutorials/its_live.md","lastUpdated":null}'),n={name:"tutorials/its_live.md"};function l(p,a,r,o,d,h){return i(),e("div",null,a[0]||(a[0]=[t(`<h1 id="ITS_LIVE-data" tabindex="-1">ITS_LIVE data <a class="header-anchor" href="#ITS_LIVE-data" aria-label="Permalink to &quot;ITS_LIVE data {#ITS_LIVE-data}&quot;">​</a></h1><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Rasters       </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Raster data analysis in Julia</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> ZarrDatasets  </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Zarr support for Rasters</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Kerchunk      </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Kerchunk support for Zarr</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Statistics    </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Basic statistics</span></span></code></pre></div><p>We can load the catalog from the catalog file that we ship in the repo:</p><div class="language-@example vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">@example</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>catalog_path = joinpath(dirname(dirname(pathof(Kerchunk))), &quot;test&quot;, &quot;data&quot;, &quot;its_live_catalog.json&quot;)</span></span>
<span class="line"><span>rs = RasterStack(&quot;reference://$(catalog_path)&quot;; source = Rasters.Zarrsource())</span></span></code></pre></div><p>We&#39;ve now loaded the dataset lazily in a <code>RasterStack</code>, which is essentially a stack of multiple variables. Now, we can apply arbitrary Rasters.jl functions to the stack, or plot it, and treat it as a general Julia array!</p><p>Let&#39;s plot first:</p><div class="language-@example vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">@example</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>using CairoMakie</span></span>
<span class="line"><span>heatmap(rs.v)</span></span></code></pre></div><p>We can also aggregate the data to a lower resolution, which downloads the entire dataset. Here, we aggregate by a factor of 10 in both dimensions, so a 10x10 window is aggregated to a single pixel.</p><div class="language-@example vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">@example</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>vs2 = Rasters.aggregate(rs, mean, 10) # now everything is loaded in disk</span></span></code></pre></div><p>and plot this aggregated data:</p><div class="language-@example vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">@example</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>arrows(dims(vs2, X) |&gt; collect, dims(vs2, Y) |&gt; collect, vs2.vx .* 20, vs2.vy .* 20; arrowsize = 5)</span></span></code></pre></div><hr><p><em>This page was generated using <a href="https://github.com/fredrikekre/Literate.jl" target="_blank" rel="noreferrer">Literate.jl</a>.</em></p>`,13)]))}const k=s(n,[["render",l]]);export{g as __pageData,k as default};
