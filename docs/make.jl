using Documenter, Intervals

makedocs(;
    modules=[Intervals],
    format=Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/Intervals.jl/blob/{commit}{path}#L{line}",
    sitename="Intervals.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
    strict=true,
)

deploydocs(;
    repo="github.com/invenia/Intervals.jl",
)
