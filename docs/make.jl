using Documenter
using Intervals

# Including these modules results in printing without the module names
# https://github.com/JuliaDocs/Documenter.jl/issues/944
using Dates
using TimeZones

makedocs(;
    modules=[Intervals],
    format=Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/Intervals.jl/blob/{commit}{path}#L{line}",
    sitename="Intervals.jl",
    authors="Invenia Technical Computing Corporation",
    checkdocs=:exports,
    strict=true,
    doctest=true,
)

deploydocs(;
    repo="github.com/invenia/Intervals.jl",
)
