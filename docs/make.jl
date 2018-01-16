using Documenter, PeriodIntervals

makedocs(;
    modules=[PeriodIntervals],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/PeriodIntervals.jl/blob/{commit}{path}#L{line}",
    sitename="PeriodIntervals.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
)

deploydocs(;
    repo="github.com/invenia/PeriodIntervals.jl",
    target="build",
    julia="0.6",
    deps=nothing,
    make=nothing,
)
