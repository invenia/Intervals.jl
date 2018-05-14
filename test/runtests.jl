using Intervals
using TimeZones
using Compat
using Compat.Test
using Compat.Dates

# The method based on keyword arguments is not in Compat, so to avoid
# deprecation warnings on 0.7 we need this little definition.
if VERSION < v"0.7.0-DEV.4524"
    function sprint(f::Function, args...; context=nothing)
        if context !== nothing
            Base.sprint((io, args...) -> f(IOContext(io, context), args...), args...)
        else
            Base.sprint(f, args...)
        end
    end
end

# The name of the module is no longer printed for types reachable from Main
if VERSION < v"0.7.0-DEV.2657"
    mod_prefix = "Intervals."
    tz_prefix = "TimeZones."
else
    mod_prefix = tz_prefix = ""
end

@testset "Intervals" begin
    include("inclusivity.jl")
    include("endpoint.jl")
    include("interval.jl")
    include("anchoredinterval.jl")
    include("comparisons.jl")
end
