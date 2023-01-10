interval_markers(x::AbstractInterval{T,L,R}) where {T,L,R} = interval_markers(L, R)
interval_markers(L::Type{<:Bound}, R::Type{<:Bound}) = interval_marker.([L, R])
interval_marker(x::Type{Closed}) = :vline
interval_marker(x::Type{Open}) = :none

# TODO: Add support for plotting unbounded intervals
@recipe function f(xs::AbstractVector{<:AbstractInterval{T,L,R}}, ys) where {T, L <: Bounded, R <: Bounded}
    new_xs = T[]
    new_ys = []
    markers = Symbol[]
    for (x, y) in zip(xs, ys)
        # To cause line to not be connected, need to add a breaker point with
        # NaN in one of the coordinates. We put that in `new_ys` as that is probably a
        # float. where-as new_xs is potentially a DateTime etc that would not accept NaN
        append!(new_xs, [first(x), last(x), last(x)])
        append!(new_ys, [y, y, NaN])
        append!(markers, interval_markers(x))
        push!(markers, :none)
    end

    pop!(markers) # Remove the last :none. 
    
    # These two are not necessary but keep things consistent
    # This is because the segment builder will just look until no more nan
    # https://github.com/JuliaPlots/Plots.jl/blob/8265d6ee8f612581b286a51e476e8acfe45adea7/src/utils.jl#L163
    pop!(new_ys); pop!(new_xs)

    # Work around GR bug that shows :none as a marker
    # TODO: remove once https://github.com/jheinen/GR.jl/issues/295  is fixed
    markeralpha := [x == :none ? 0 : 1 for x in markers]

    markershape := markers
    seriestype  := :path  # always a path, even in a scatter plot
    new_xs, new_ys
end
