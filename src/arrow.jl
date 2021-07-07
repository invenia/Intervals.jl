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

# Note: The type returnedy by the `ArrowType` function is not passed into the `JuliaType`
# function. Instead the result of `typeof(toarrow(...))` is passed into `JuliaType`.
# To reproduce this use an isbits object as a type parameter in `ArrowType`.

# An inefficient Arrow serialization format which supports non-concrete element types
let name = Symbol("JuliaLang.Intervals.AnchoredInterval{P,T}")
    ArrowTypes.arrowname(::Type{<:AnchoredInterval{P,T}}) where {P,T} = name
    function ArrowTypes.ArrowType(::Type{<:AnchoredInterval{P,T}}) where {P,T}
        return NamedTuple{(:anchor,), Tuple{Tuple{typeof(P), T, String, String}}}
    end
    function ArrowTypes.toarrow(x::AnchoredInterval{P,T}) where {P,T}
        L, R = bounds_types(x)
        return (; anchor=(P, x.anchor, string(arrowname(L)), string(arrowname(R))))
    end
    function ArrowTypes.JuliaType(::Val{name})
        return AnchoredInterval
    end
    function ArrowTypes.fromarrow(::Type{AnchoredInterval}, anchor)
        P = anchor[1]
        T = typeof(anchor[2])  # Note: Arrow can't access the original `T` anyway
        L = ArrowTypes.JuliaType(Val(Symbol(anchor[3])))
        R = ArrowTypes.JuliaType(Val(Symbol(anchor[4])))
        return AnchoredInterval{P,T,L,R}(anchor[2])
    end
end
