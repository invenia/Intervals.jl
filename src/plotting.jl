interval_markers(x::AbstractInterval{T,L,R}) where {T,L,R} = interval_markers(L, R)
interval_markers(L::Type{<:Bound}, R::Type{<:Bound}) = interval_marker.([L, R])
interval_marker(x::Type{Closed}) = :vline
interval_marker(x::Type{Open}) = :none

# TODO: Add support for plotting unbounded intervals
@recipe function f(xs::AbstractVector{<:AbstractInterval{T,L,R}}, ys) where {T, L <: Bounded, R <: Bounded}
    new_xs = Vector{T}[]
    new_ys = Vector{Any}[]
    markers = Symbol[]
    for (x, y) in zip(xs, ys)
        # To cause line to not be connected, need to divide individually separated segments into separate vectors
        # This is as of v1.11 in Plots.
        # See https://github.com/JuliaPlots/Plots.jl/blob/master/src/utils.jl#L104
        append!(new_xs, [[first(x), last(x)]])
        append!(new_ys, [[y, y]])
    end
    append!(markers, interval_markers(first(xs)))
    
    # Work around GR bug that shows :none as a marker
    # TODO: remove once https://github.com/jheinen/GR.jl/issues/295  is fixed
    markeralpha := [x == :none ? 0 : 1 for x in markers]

    markershape := markers
    seriestype  := :path  # always a path, even in a scatter plot

    new_xs, new_ys
    
end
