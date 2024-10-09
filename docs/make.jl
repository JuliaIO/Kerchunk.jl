# The first thing to do is to make sure Python's dynamic libraries
# are loaded first.
using CondaPkg, PythonCall
PythonCall.pyimport("aiohttp")

using Kerchunk
using Documenter, DocumenterVitepress


DocMeta.setdocmeta!(Kerchunk, :DocTestSetup, :(using Kerchunk); recursive=true)

using Literate


# First, remove any codecov files that may have been generated by the CI run
for (root, dirs, files) in walkdir(dirname(@__DIR__)) # walk through `GeometryOps/*`
    # Iterate through all files in the current directory
    for file in files
        # If the file is a codecov file, remove it
        if splitext(file)[2] == ".cov"
            rm(joinpath(root, file))
        end
    end
end

# Now, we convert the source code to markdown files using Literate.jl
source_path = joinpath(dirname(@__DIR__), "src")
output_path = joinpath(@__DIR__, "src", "source")
mkpath(output_path)

literate_pages = Any[]

# We don't want Literate to convert the code into Documenter blocks, so we use a custom postprocessor
# to add the `@meta` block to the markdown file, which will be used by Documenter to add an edit link.
function _add_meta_edit_link_generator(path)
    return function (input)
        return """
        ```@meta
        EditURL = "$(path).jl"
        ```

        """ * input # we add `.jl` because `relpath` eats the file extension, apparently :shrug:
    end
end

# First letter of `str` is made uppercase and returned
ucfirst(str::String) = string(uppercase(str[1]), str[2:end])

function process_literate_recursive!(pages::Vector{Any}, path::String)
    global source_path
    global output_path
    if isdir(path)
        contents = []
        process_literate_recursive!.((contents,), normpath.(readdir(path; join = true)))
        push!(pages, ucfirst(splitdir(path)[2]) => contents)
    elseif isfile(path)
        if endswith(path, ".jl")
            relative_path = relpath(path, source_path)
            output_dir = joinpath(output_path, splitdir(relative_path)[1])
            Literate.markdown(
                path, output_dir; 
                flavor = Literate.CommonMarkFlavor(), 
                postprocess = _add_meta_edit_link_generator(joinpath(relpath(source_path, output_dir), relative_path))
            )
            push!(pages, joinpath("source", splitext(relative_path)[1] * ".md"))
        end
    end
end

withenv("JULIA_DEBUG" => "Literate") do # allow Literate debug output to escape to the terminal!
    global literate_pages
    vec = []
    process_literate_recursive!(vec, source_path)
    literate_pages = vec[1][2] # this is a hack to get the pages in the correct order, without an initial "src" folder.  
    # TODO: We should probably fix the above in `process_literate_recursive!`.
end

# Now, process the tutorials
Literate.markdown(
    joinpath("tutorials", "solar_dynamics_observatory.jl"), "tutorials"; 
    flavor = Literate.DocumenterFlavor(), 
)

makedocs(;
    modules=[Kerchunk],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="Kerchunk.jl",
    format=MarkdownVitepress(repo = "github.com/JuliaIO/Kerchunk.jl"),
    pages=[
        "Home" => "index.md",
        "What is Kerchunk?" => "what_the_heck.md",
        "Tutorials" => [
            "tutorials/solar_dynamics_observatory.md",
        ],
        "API" => "api.md",
        "Source code" => literate_pages,
    ],
    warnonly = true,
)

deploydocs(;
    repo="github.com/JuliaIO/Kerchunk.jl",
    devbranch="main",
)
