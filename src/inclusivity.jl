"""
    Inclusivity(first::Bool, last::Bool) -> Inclusivity

Defines whether an `AbstractInterval` is open, half-open, or closed.
"""

struct Inclusivity
    first::Bool
    last::Bool

    function Inclusivity(first::Bool, last::Bool; ignore_depwarn::Bool=false)
        if !ignore_depwarn
            depwarn(
                "`Inclusivity(::Bool, ::Bool)` is deprecated and has no direct replacement. " *
                "See `Interval` or `AnchoredInterval` constructors for alternatives.",
                :Inclusivity,
            )
        end
        return new(first, last)
    end
end

"""
    Inclusivity(i::Integer) -> Inclusivity

Defines whether an interval is open, half-open, or closed, using an integer code:

### Inclusivity Values

* `0`: Neither endpoint is included (the `AbstractInterval` is open)
* `1`: Only the lesser endpoint is included (the `AbstractInterval` is left-closed)
* `2`: Only the greater endpoint is included (the `AbstractInterval` is right-closed)
* `3`: Both endpoints are included (the `AbstractInterval` is closed)

Note that this constructor does not perform bounds-checking: instead it checks the values
of the two least-significant bits of the integer. This means that `Inclusivity(5)` is
equivalent to `Inclusivity(1)`.
"""

function Inclusivity(i::Integer)
    depwarn(
        "`Inclusivity(::Integer)` is deprecated and has no direct replacement. " *
        "See `Interval` or `AnchoredInterval` constructors for alternatives.",
        :Inclusivity,
    )
    return Inclusivity(i & 0b01 > 0, i & 0b10 > 0; ignore_depwarn=true)
end

function Base.copy(x::Inclusivity)
    depwarn(
        "`copy(::Inclusivity)` is deprecated and has no direct replacement. " *
        "See `Interval` or `AnchoredInterval` constructors for alternatives.",
        :copy,
    )
    return Inclusivity(x.first, x.last; ignore_depwarn=true)
end

function Base.convert(::Type{I}, x::Inclusivity) where I <: Integer
    return I(x.last << 1 + x.first)
end

Base.broadcastable(i::Inclusivity) = Ref(i)

Base.first(x::Inclusivity) = x.first
Base.last(x::Inclusivity) = x.last

isclosed(x::Inclusivity) = first(x) && last(x)
Base.isopen(x::Inclusivity) = !(first(x) || last(x))

Base.isless(a::Inclusivity, b::Inclusivity) = isless(convert(Int, a), convert(Int, b))

function Base.show(io::IO, x::T) where T <: Inclusivity
    if get(io, :compact, false)
        print(io, x)
    else
        print(io, "$T($(x.first), $(x.last))")
    end
end

function Base.print(io::IO, x::Inclusivity)
    open_char = first(x) ? '[' : '('
    close_char = last(x) ? ']' : ')'
    desc = isclosed(x) ? "Closed" : isopen(x) ? "Open" : first(x) ? "Left" : "Right"
    print(io, "Inclusivity ", open_char, desc, close_char)
end
