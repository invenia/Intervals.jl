using Documenter, Intervals

makedocs(;
    modules=[Intervals],
    format=:html,
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
)

deploydocs(;
    repo="github.com/invenia/Intervals.jl",
    target="build",
    julia="0.6",
    deps=nothing,
    make=nothing,
)
