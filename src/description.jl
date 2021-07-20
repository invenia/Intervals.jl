description(i::AnchoredInterval{P}) where P = description(i, P > zero(P) ? "B" : "E")

function description(interval::AnchoredInterval{P,T,L,R}, s::String) where {P,T,L,R}
    return string(
        L === Closed ? '[' : '(',
        description(anchor(interval), abs(P), s),
        R === Closed ? ']' : ')',
    )
end

function description(interval::AnchoredInterval{P, ZonedDateTime, L, R}, s::String) where {P,L,R}
    return string(
        L === Closed ? '[' : '(',
        description(anchor(interval), abs(P), s),
        anchor(interval).zone.offset,
        R === Closed ? ']' : ')',
    )
end

function description(dt::Date, p::Period, suffix::String)
    ds = @sprintf("%04d-%02d-%02d", year(dt), month(dt), day(dt))
    return "$(prefix(p))$suffix $ds"
end

function description(dt::AbstractDateTime, p::Period, suffix::String)
    ts = time_string(dt, p)

    # If we would display only HE00, display HE24 for the previous day instead
    if ts == "00" && suffix == "E"
        P, max_val = coarserperiod(typeof(p))
        dt -= oneunit(P)
        ts = string(max_val)
    end

    ds = @sprintf("%04d-%02d-%02d", year(dt), month(dt), day(dt))

    if p isa TimePeriod
        return "$ds $(prefix(p))$suffix$ts"
    else
        ts = (ts == "00:00:00" && !isa(dt, ZonedDateTime)) ? "" : " $ts"
        return "$(prefix(p))$suffix $ds$ts"
    end
end

function time_string(dt::AbstractDateTime, p::Period)
    t = (hour(dt), minute(dt), second(dt), millisecond(dt))
    if p isa Hour && all(t[2:end] .== 0)
        return @sprintf("%02d", t[1])
    elseif p isa Minute && all(t[3:end] .== 0)
        return @sprintf("%02d:%02d", t[1:2]...)
    elseif !isa(p, Millisecond) && t[4] == 0
        return @sprintf("%02d:%02d:%02d", t[1:3]...)
    else
        return @sprintf("%02d:%02d:%02d.%03d", t...)
    end
end

function prefix(p::Period)
    string(value(p) == 1 ? "" : value(p), prefix(typeof(p)))
end

prefix(::Type{Year}) = "Y"
prefix(::Type{Month}) = "Mo"
prefix(::Type{Week}) = "W"
prefix(::Type{Day}) = "D"
prefix(::Type{Hour}) = "H"
prefix(::Type{Minute}) = "M"
prefix(::Type{Second}) = "S"
prefix(::Type{Millisecond}) = "ms"

# `Quarter` defined after Julia1.6.
if VERSION >= v"1.6"
    prefix(::Type{Quarter}) = "Q"
end

# informative error if no prefix is defined for the given type.
prefix(T::Type{<:Period}) = error("A prefix for period $T has not yet been defined")
