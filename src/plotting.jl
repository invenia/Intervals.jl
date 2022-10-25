interval_markers(x::AbstractInterval{T,L,U}) where {T,L,U} = interval_markers(L, U)
interval_markers(L::Type{<:Bound}, U::Type{<:Bound}) = interval_marker.([L, U])
interval_marker(x::Type{Closed}) = :vline
interval_marker(x::Type{Open}) = :none

# TODO: Add support for plotting unbounded intervals
@recipe function f(xs::AbstractVector{<:AbstractInterval{T,L,U}}, ys) where {T, L <: Bounded, U <: Bounded}
    new_xs = T[]
    new_ys = []
    markers = Symbol[]
    for (x, y) in zip(xs, ys)
        # To cause line to not be connected, need to add a breaker point with
        # NaN in one of the coordinates. We put that in `new_ys` as that is probably a
        # float. where-as new_xs is potentially a DateTime etc that would not accept NaN
        append!(new_xs, [lowerbound(x), upperbound(x), upperbound(x)])
        append!(new_ys, [y, y, NaN])
        append!(markers, interval_markers(x))
        push!(markers, :none)
    end

    # Work around GR bug that shows :none as a marker
    # TODO: remove once https://github.com/jheinen/GR.jl/issues/295  is fixed
    markeralpha := [x == :none ? 0 : 1 for x in markers]

    markershape := markers
    seriestype  := :path  # always a path, even in a scatter plot
    new_xs, new_ys
end
