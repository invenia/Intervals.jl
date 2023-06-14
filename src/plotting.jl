interval_markers(x::AbstractInterval{T,L,R}) where {T,L,R} = interval_markers(L, R)
interval_markers(L::Type{<:Bound}, R::Type{<:Bound}) = interval_marker.([L, R])
interval_marker(x::Type{Closed}) = :vline
interval_marker(x::Type{Open}) = :none

_alpha(marker::Symbol) = marker === :none ? 0 : 1

# TODO: Add support for plotting unbounded intervals
@recipe function f(xs::AbstractVector{<:AbstractInterval{T,L,R}}, ys) where {T, L <: Bounded, R <: Bounded}
    new_xs = Vector{T}[]
    new_ys = []
    markers = Vector{Symbol}[]
    for (x, y) in zip(xs, ys)
        marker = interval_markers(x)

        # To cause line to not be connected, need to add a breaker point with
        # NaN in one of the coordinates. We put that in `new_ys` as that is probably a
        # float. where-as new_xs is potentially a DateTime etc that would not accept NaN
        push!(new_xs, [first(x), last(x)])
        push!(new_ys, [y, y])
        push!(markers, interval_markers(x))
    end

    # Work around GR bug that shows `:none` as a marker
    # TODO: remove once https://github.com/jheinen/GR.jl/issues/295 is fixed
    markeralpha := permutedims([_alpha.(m) for m in markers])

    markershape := markers
    seriestype  := :path                 # always a path, even in a scatter plot
    markershape := permutedims(markers)  # force markershape to be set the endpoints

    return new_xs, new_ys
end
