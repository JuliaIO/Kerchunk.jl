using Kerchunk
using Documenter

DocMeta.setdocmeta!(Kerchunk, :DocTestSetup, :(using Kerchunk); recursive=true)

makedocs(;
    modules=[Kerchunk],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="Kerchunk.jl",
    format=Documenter.HTML(;
        canonical="https://JuliaIO.github.io/Kerchunk.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaIO/Kerchunk.jl",
    devbranch="main",
)
