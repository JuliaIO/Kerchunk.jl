import{_ as a,c as n,a5 as p,o as i}from"./chunks/framework.ajcgp9jS.js";const u=JSON.parse('{"title":"Solar Dynamics Observatory","description":"","frontmatter":{},"headers":[],"relativePath":"tutorials/solar_dynamics_observatory.md","filePath":"tutorials/solar_dynamics_observatory.md","lastUpdated":null}'),e={name:"tutorials/solar_dynamics_observatory.md"};function l(t,s,c,o,r,d){return i(),n("div",null,s[0]||(s[0]=[p(`<h1 id="Solar-Dynamics-Observatory" tabindex="-1">Solar Dynamics Observatory <a class="header-anchor" href="#Solar-Dynamics-Observatory" aria-label="Permalink to &quot;Solar Dynamics Observatory {#Solar-Dynamics-Observatory}&quot;">​</a></h1><p>First, we download the Kerchunk catalog:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Downloads</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Downloads</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">download</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;https://esip-qhub-public.s3-us-west-2.amazonaws.com/noaa/nwm/nwm_reanalysis.json.zst&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;nwm_reanalysis.json.zst&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>&quot;nwm_reanalysis.json.zst&quot;</span></span></code></pre></div><p>This is a compressed file. We can decompress it in memory using the <a href="https://github.com/JuliaIO/TranscodingStreams.jl" target="_blank" rel="noreferrer"><code>TranscodingStreams.jl</code></a> API.</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> CodecZstd</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">write</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;nwm_reanalysis.json&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">transcode</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(ZstdDecompressor, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">read</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;nwm_reanalysis.json.zst&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)))</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>205497114</span></span></code></pre></div><p>We can also open the decompressed catalog directly in Zarr.jl, or any package that sits on top of it. Let&#39;s open it in plain Zarr first:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Zarr</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> ZarrDatasets, Rasters, YAXArrays</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>[ Info: new driver key :zarr, updating backendlist.</span></span></code></pre></div><p>We can open in Zarr directly, which gives us a ZarrGroup:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">zg </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Zarr</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">zopen</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;reference://nwm_reanalysis.json&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>ZarrGroup at ReferenceStore with 2939545 references</span></span>
<span class="line"><span> and path </span></span>
<span class="line"><span>Variables: time elevation qBtmVertRunoff q_lateral qSfcLatRunoff streamflow feature_id velocity latitude qBucket order longitude</span></span></code></pre></div><p>or in ZarrDatasets.jl, which accounts for CF conventions:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">zd </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> ZarrDataset</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;reference://nwm_reanalysis.json&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>Dataset: </span></span>
<span class="line"><span>Group: root</span></span>
<span class="line"><span></span></span>
<span class="line"><span>Dimensions</span></span>
<span class="line"><span>   time = 367439</span></span>
<span class="line"><span>   feature_id = 2776738</span></span>
<span class="line"><span></span></span>
<span class="line"><span>Variables</span></span>
<span class="line"><span>  time   (367439)</span></span>
<span class="line"><span>    Datatype:    Dates.DateTime (Int32)</span></span>
<span class="line"><span>    Dimensions:  time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     units                = minutes since 1970-01-01 00:00:00 UTC</span></span>
<span class="line"><span>     NAME                 = time</span></span>
<span class="line"><span>     long_name            = valid output time</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 1</span></span>
<span class="line"><span>     standard_name        = time</span></span>
<span class="line"><span>     valid_min            = 4777980</span></span>
<span class="line"><span>     valid_max            = 4862880</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  elevation   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float32} (Float32)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     units                = meters</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     long_name            = Feature Elevation</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     standard_name        = Elevation</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  qBtmVertRunoff   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float64} (Float64)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     missing_value        = -9999000</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     units                = m3</span></span>
<span class="line"><span>     long_name            = Runoff from bottom of soil to bucket</span></span>
<span class="line"><span>     grid_mapping         = crs</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span>     valid_range          = Any[0, 20000000]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  q_lateral   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float64} (Float64)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     missing_value        = -99990</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     units                = m3 s-1</span></span>
<span class="line"><span>     long_name            = Runoff into channel reach</span></span>
<span class="line"><span>     grid_mapping         = crs</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span>     valid_range          = Any[0, 500000]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  qSfcLatRunoff   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float64} (Float64)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     missing_value        = -999900000</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     units                = m3 s-1</span></span>
<span class="line"><span>     long_name            = Runoff from terrain routing</span></span>
<span class="line"><span>     grid_mapping         = crs</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span>     valid_range          = Any[0, 2000000000]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  streamflow   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float64} (Float64)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     missing_value        = -999900</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     units                = m3 s-1</span></span>
<span class="line"><span>     long_name            = River Flow</span></span>
<span class="line"><span>     grid_mapping         = crs</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span>     valid_range          = Any[0, 5000000]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  feature_id   (2776738)</span></span>
<span class="line"><span>    Datatype:    Int32 (Int32)</span></span>
<span class="line"><span>    Dimensions:  feature_id</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     cf_role              = timeseries_id</span></span>
<span class="line"><span>     long_name            = Reach ID</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     comment              = NHDPlusv2 ComIDs within CONUS, arbitrary Reach IDs outside of CONUS</span></span>
<span class="line"><span>     NAME                 = feature_id</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  velocity   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float64} (Float64)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     missing_value        = -999900</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     units                = m s-1</span></span>
<span class="line"><span>     long_name            = River Velocity</span></span>
<span class="line"><span>     grid_mapping         = crs</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span>     valid_range          = Any[0, 5000000]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  latitude   (2776738)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float32} (Float32)</span></span>
<span class="line"><span>    Dimensions:  feature_id</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     units                = degrees_north</span></span>
<span class="line"><span>     long_name            = Feature latitude</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     standard_name        = latitude</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  qBucket   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float64} (Float64)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     missing_value        = -999900000</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     units                = m3 s-1</span></span>
<span class="line"><span>     long_name            = Flux from gw bucket</span></span>
<span class="line"><span>     grid_mapping         = crs</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span>     valid_range          = Any[0, 2000000000]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  order   (2776738 × 367439)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Int32} (Int32)</span></span>
<span class="line"><span>    Dimensions:  feature_id × time</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     coordinates          = longitude latitude</span></span>
<span class="line"><span>     long_name            = Streamflow Order</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     standard_name        = order</span></span>
<span class="line"><span>     _FillValue           = 0</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  longitude   (2776738)</span></span>
<span class="line"><span>    Datatype:    Union{Missing, Float32} (Float32)</span></span>
<span class="line"><span>    Dimensions:  feature_id</span></span>
<span class="line"><span>    Attributes:</span></span>
<span class="line"><span>     units                = degrees_east</span></span>
<span class="line"><span>     long_name            = Feature longitude</span></span>
<span class="line"><span>     _Netcdf4Dimid        = 0</span></span>
<span class="line"><span>     standard_name        = longitude</span></span>
<span class="line"><span>     _FillValue           = 0.0</span></span>
<span class="line"><span></span></span>
<span class="line"><span>Global attributes</span></span>
<span class="line"><span>  TITLE                = OUTPUT FROM WRF-Hydro v5.2.0-beta2</span></span>
<span class="line"><span>  code_version         = v5.2.0-beta2</span></span>
<span class="line"><span>  stream_order_output  = 1</span></span>
<span class="line"><span>  proj4                = +proj=lcc +units=m +a=6370000.0 +b=6370000.0 +lat_1=30.0 +lat_2=60.0 +lat_0=40.0 +lon_0=-97.0 +x_0=0 +y_0=0 +k_0=1.0 +nadgrids=@</span></span>
<span class="line"><span>  cdm_datatype         = Station</span></span>
<span class="line"><span>  model_initialization_time = 1979-02-01_00:00:00</span></span>
<span class="line"><span>  model_output_valid_time = 1979-02-01_01:00:00</span></span>
<span class="line"><span>  dev_channelBucket_only = 0</span></span>
<span class="line"><span>  model_configuration  = retrospective</span></span>
<span class="line"><span>  featureType          = timeSeries</span></span>
<span class="line"><span>  dev_channel_only     = 0</span></span>
<span class="line"><span>  Conventions          = CF-1.6</span></span>
<span class="line"><span>  model_total_valid_times = 1416</span></span>
<span class="line"><span>  station_dimension    = feature_id</span></span>
<span class="line"><span>  dev_NOAH_TIMESTEP    = 3600</span></span>
<span class="line"><span>  dev_OVRTSWCRT        = 1</span></span>
<span class="line"><span>  _NCProperties        = version=2,netcdf=4.7.4,hdf5=1.10.7,</span></span>
<span class="line"><span>  model_output_type    = channel_rt</span></span>
<span class="line"><span>  dev                  = dev_ prefix indicates development/internal meta data</span></span></code></pre></div><p>Note the more descriptive display here.</p><p>or in YAXArrays.jl,</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">ya </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> YAXArrays</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">open_dataset</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>And perform random operations Or visualize a subset (show this!!!!)</p><hr><p><em>This page was generated using <a href="https://github.com/fredrikekre/Literate.jl" target="_blank" rel="noreferrer">Literate.jl</a>.</em></p>`,22)]))}const g=a(e,[["render",l]]);export{u as __pageData,g as default};
