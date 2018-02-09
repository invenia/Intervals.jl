"""
    Inclusivity(start::Bool, finish::Bool) -> Inclusivity

Defines whether an `Interval` is open, partially open, or closed.
"""
struct Inclusivity
    start::Bool
    finish::Bool
end

"""
    Inclusivity(i::Integer) -> Inclusivity

Defines whether an interval is open, partially open, or closed using an integer code:

### Inclusivity Values

0: Neither endpoint is included (the `Interval` is open)
1: The start is included, and the end is not included (the `Interval` is partially open)
2: The end is included, and the start is not included (the `Interval` is partially open)
3: Both endpoints are included (the `Interval` is closed)

Note that this function does not perform bounds-checking: instead it checks the values of
the two least-significant bits of the integer. This means that `Inclusivity(5)` is
equivalent to `Inclusivity(1)`.
"""
Inclusivity(i::Integer) = Inclusivity(i & 0b01 > 0, i & 0b10 > 0)

function Base.convert(::Type{I}, x::Inclusivity) where I <: Integer
    return I(x.finish << 1 + x.start)
end

Base.start(x::Inclusivity) = x.start
finish(x::Inclusivity) = x.finish

Base.isless(a::Inclusivity, b::Inclusivity) = isless(convert(Int, a), convert(Int, b))

function Base.show(io::IO, x::Inclusivity)
    if get(io, :compact, false)
        print(io, x)
    else
        print(io, "Inclusivity($(x.start), $(x.finish))")
    end
end

function Base.print(io::IO, x::Inclusivity)
    start = x.start ? '[' : '('
    finish = x.finish ? ']' : ')'
    desc = x.start && x.finish ? "Closed" : !x.start && !x.finish ? "Open" : "Partial"
    print(io, "Inclusivity ", start, desc, finish)
end
