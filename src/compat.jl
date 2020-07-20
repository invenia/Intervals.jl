# These `deserialize` methods are used to be able to deserialize intervals using the
# structure that was used before Intervals 1.3.

struct _LegacyInterval{T}
    first::T
    last::T
    inclusivity::Inclusivity
end

function Serialization.deserialize(s::AbstractSerializer, ::Type{Interval{T}}) where T
    old = deserialize(s, _LegacyInterval{T})

    L = bound_type(first(old.inclusivity))
    R = bound_type(last(old.inclusivity))

    return Interval{T,L,R}(old.first, old.last)
end

struct _LegacyAnchoredInterval{P,T}
    anchor::T
    inclusivity::Inclusivity
end

function Serialization.deserialize(s::AbstractSerializer, ::Type{AnchoredInterval{P,T}}) where {P,T}
    old = deserialize(s, _LegacyAnchoredInterval{P,T})

    L = bound_type(first(old.inclusivity))
    R = bound_type(last(old.inclusivity))

    return AnchoredInterval{P,T,L,R}(old.anchor)
end

# Works around an issue where a `StepRangeLen` tries to convert the step to an
# `AbstractInterval`.
# Issue introduced in https://github.com/JuliaLang/julia/pull/23194 (a698230daf6)
# and fixed in https://github.com/JuliaLang/julia/pull/34412 (fca037a162)
if v"0.7.0-DEV.1399" <= VERSION < v"1.5.0-DEV.127"
    Base.step(r::StepRangeLen{<:AbstractInterval}) = r.step
end
