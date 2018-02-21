"""
    Inclusivity(first::Bool, last::Bool) -> Inclusivity

Defines whether an `AbstractInterval` is open, half-open, or closed.
"""
struct Inclusivity
    first::Bool
    last::Bool
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
    desc = Int(x) == 3 ? "Closed" : Int(x) == 0 ? "Open" : Int(x) == 1 ? "Left" : "Right"
    print(io, "Inclusivity ", first, desc, last)
end
