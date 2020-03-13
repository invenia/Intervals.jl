
interval_markers(x::AbstractInterval) = interval_markers(inclusivity(x))
interval_markers(x::Inclusivity) = interval_markers(first(x), last(x))
interval_markers(start::Bool, stop::Bool) = interval_markers.([start, stop])
interval_markers(x::Bool) = x ? :vline : :none

@recipe function f(xs::AbstractVector{<:AbstractInterval{T}}, ys) where T
    new_xs = T[]
    new_ys = []
    markers = Symbol[]
    for (x, y) in zip(xs, ys)
        # To cause line to not be connected, need to add a breaker point with
        # NaN in one of the coordinates. We pute that in `new_ys` as that is probably a
        # float. where-as new_xs is potentially a DateTime etc that would not accept NaN
        append!(new_xs, [first(x), last(x), last(x)])
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
