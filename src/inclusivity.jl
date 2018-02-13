"""
    Inclusivity(first::Bool, last::Bool) -> Inclusivity

Defines whether an `AbstractInterval` is open, partially open, or closed.
"""
struct Inclusivity
    first::Bool
    last::Bool
end

"""
    Inclusivity(i::Integer) -> Inclusivity

Defines whether an interval is open, partially open, or closed using an integer code:

### Inclusivity Values

0: Neither endpoint is included (the `Interval` is open)
1: The start is included, and the end is not included (the `Interval` is partially open)
2: The end is included, and the first is not included (the `Interval` is partially open)
3: Both endpoints are included (the `Interval` is closed)

Note that this function does not perform bounds-checking: instead it checks the values of
the two least-significant bits of the integer. This means that `Inclusivity(5)` is
equivalent to `Inclusivity(1)`.
"""
Inclusivity(i::Integer) = Inclusivity(i & 0b01 > 0, i & 0b10 > 0)

Base.copy(x::Inclusivity) = Inclusivity(x.first, x.last)

function Base.convert(::Type{I}, x::Inclusivity) where I <: Integer
    return I(x.last << 1 + x.first)
end

Base.first(x::Inclusivity) = x.first
Base.last(x::Inclusivity) = x.last

Base.isless(a::Inclusivity, b::Inclusivity) = isless(convert(Int, a), convert(Int, b))

function Base.show(io::IO, x::Inclusivity)
    if get(io, :compact, false)
        print(io, x)
    else
        print(io, "Inclusivity($(x.first), $(x.last))")
    end
end

function Base.print(io::IO, x::Inclusivity)
    first = x.first ? '[' : '('
    last = x.last ? ']' : ')'
    desc = x.first && x.last ? "Closed" : !x.first && !x.last ? "Open" : "Partial"
    print(io, "Inclusivity ", first, desc, last)
end
