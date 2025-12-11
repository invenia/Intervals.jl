for T in (Closed, Open, Unbounded)
    name = QuoteNode(Symbol("JuliaLang.Intervals.$(string(T))"))

    @eval begin
        ArrowTypes.arrowname(::Type{$T}) = $name
        ArrowTypes.JuliaType(::Val{$name}) = $T
    end
end

# Use a more efficient Arrow serialization when a vector uses a concrete element type
let name = Symbol("JuliaLang.Intervals.Interval{T,L,R}")
    ArrowTypes.arrowname(::Type{Interval{T,L,R}}) where {T, L <: Bound, R <: Bound} = name
    function ArrowTypes.ArrowType(::Type{Interval{T,L,R}}) where {T, L <: Bound, R <: Bound}
        return Interval{T,L,R}
    end
    function ArrowTypes.arrowmetadata(::Type{Interval{T,L,R}}) where {T, L <: Bound, R <: Bound}
        return join(arrowname.([L, R]), ",")
    end
    function ArrowTypes.JuliaType(::Val{name}, ::Type{NamedTuple{(:first, :last), Tuple{T, T}}}, meta) where T
        L, R = ArrowTypes.JuliaType.(Val.(Symbol.(split(meta, ","))))
        return Interval{T,L,R}
    end
    function ArrowTypes.fromarrow(::Type{Interval{T,L,R}}, left, right) where {T, L <: Bound, R <: Bound}
        return Interval{T,L,R}(
            L === Unbounded ? nothing : left,
            R === Unbounded ? nothing : right,
        )
    end
end

# A less efficient Arrow serialization format for when a vector contains non-concrete element types
let name = Symbol("JuliaLang.Intervals.Interval{T}")
    ArrowTypes.arrowname(::Type{<:Interval{T}}) where T = name
    function ArrowTypes.ArrowType(::Type{<:Interval{T}}) where T
        return NamedTuple{(:left, :right), Tuple{Tuple{String, T}, Tuple{String, T}}}
    end
    function ArrowTypes.toarrow(x::Interval{T}) where T
        L, R = bounds_types(x)
        return (; left=(string(arrowname(L)), x.first), right=(string(arrowname(R)), x.last))
    end
    function ArrowTypes.JuliaType(::Val{name}, ::Type{NamedTuple{names, types}}) where {names, types}
        T = fieldtype(fieldtype(types, 1), 2)
        return Interval{T}
    end
    function ArrowTypes.fromarrow(::Type{Interval{T}}, left, right) where T
        L = ArrowTypes.JuliaType(Val(Symbol(left[1])))
        R = ArrowTypes.JuliaType(Val(Symbol(right[1])))
        return Interval{T,L,R}(
            L === Unbounded ? nothing : left[2],
            R === Unbounded ? nothing : right[2],
        )
    end
end

# AnchoredInterval support was initially implemented in https://github.com/invenia/Intervals.jl/pull/167
# but was not roundtrippable since all Periods were coerced to Second.
# A new implementation that stores the period type will be needed.
