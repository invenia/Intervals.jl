using Base: depwarn

# BEGIN Intervals 1.X.Y deprecations

function Base.convert(::Type{T}, interval::AnchoredInterval{P, T}) where {P, T}
    depwarn("`convert($T, interval::AnchoredInterval{P,$T})` is deprecated, use `anchor(interval)` instead.", :convert)
    anchor(interval)
end

for T in (:Date, :DateTime)
    @eval function Dates.$T(interval::AnchoredInterval{P, $T}) where P
        Base.depwarn("`$($T)(interval::AnchoredInterval{P,$($T)})` is deprecated, use `anchor(interval)` instead.", $(QuoteNode(T)))
        return anchor(interval)
    end
end

# END Intervals 1.X.Y deprecations
