# These `deserialize` methods are used to be able to deserialize intervals using the
# structure that was used before Intervals 1.3.

function Serialization.deserialize(s::AbstractSerializer, ::Type{Interval{T}}) where T
    left = deserialize(s)
    right = deserialize(s)
    inclusivity = deserialize(s)

    L = bound_type(first(inclusivity))
    R = bound_type(last(inclusivity))

    return Interval{T,L,R}(left, right)
end

function Serialization.deserialize(s::AbstractSerializer, ::Type{AnchoredInterval{P,T}}) where {P,T}
    anchor = deserialize(s)
    inclusivity = deserialize(s)

    L = bound_type(first(inclusivity))
    R = bound_type(last(inclusivity))

    return AnchoredInterval{P,T,L,R}(anchor)
end
