const INTERVAL_REGEX = r"""
    (\[|\()                # Left bound type (1)
    (?|"([^"]*)"|([^,]*))  # Left bound value (2)
    ,\ ?
    (?|"([^"]*)"|([^,]*))  # Right bound value (3)
    (\]|\))                # Right bound type (4)
    """x

function Base.parse(::Type{Interval{T}}, str::AbstractString, args...; kwargs...) where T
    m = match(INTERVAL_REGEX, str)

    if m === nothing
        throw(ArgumentError("Unable to parse \"$str\" as an interval"))
    end

    if isempty(m[2])
        L = Unbounded
        left = nothing
    else
        L = m[1] == "[" ? Closed : Open
        left = parse(T, m[2], args...; kwargs...)
    end

    if isempty(m[3])
        R = Unbounded
        right = nothing
    else
        R = m[4] == "]" ? Closed : Open
        right = parse(T, m[3], args...; kwargs...)
    end

    return Interval{T,L,R}(left, right)
end
