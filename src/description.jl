using Base.Dates: value

description(interval::AnchoredInterval{P}) where P = description(interval, P > zero(P) ? "B" : "E")

function description(interval::AnchoredInterval{P, T}, s::String) where {P, T}
    return string(
        first(inclusivity(interval)) ? '[' : '(',
        description(anchor(interval), abs(P), s),
        last(inclusivity(interval)) ? ']' : ')',
    )
end

function description(interval::AnchoredInterval{P, ZonedDateTime}, s::String) where P
    return string(
        first(inclusivity(interval)) ? '[' : '(',
        description(anchor(interval), abs(P), s),
        anchor(interval).zone.offset,
        last(inclusivity(interval)) ? ']' : ')',
    )
end

#=
function largest_nonzero(dt::AbstractDateTime)
    millisecond(dt) == 0 || return Millisecond(1)
    second(dt) == 0 || return Second(1)
    minute(dt) == 0 || return Minute(1)
    hour(dt) == 0 || return Hour(1)
    day(dt) == 0 || return Day(1)
    month(dt) == 0 || return Month(1)
    return Year(1)
end
=#


#=
Create date_string
Create time_string
trim time_string as far as necessary

if p < Day(1)
    print: date_string prefix time_string
else
    print: prefix date_string time_string
end
=#


function description(dt::Date, p::Period, suffix::String)
    ds = @sprintf("%04d-%02d-%02d", year(dt), month(dt), day(dt))
    return "$(prefix(p))$suffix $ds"
end

function description(dt::AbstractDateTime, p::Period, suffix::String)
    ts = time_string(dt, p)

    # If we would display only HE00, display HE24 for the previous day instead
    if p isa Hour && ts == "00" && suffix == "E"
        ts = "24"
        dt -= Day(1)
    end

    ds = @sprintf("%04d-%02d-%02d", year(dt), month(dt), day(dt))

    if p isa TimePeriod
        return "$ds $(prefix(p))$suffix$ts"
    else
        return "$(prefix(p))$suffix $ds$(ts in ("00", "24") ? "" : " $ts")"
    end
end

function time_string(dt::AbstractDateTime, p::Period)
    ts = @sprintf("%02d:%02d:%02d.%03d", hour(dt), minute(dt), second(dt), millisecond(dt))

    # Trim excess precision from time_string
    max_replacements = p isa Second ? 1 : p isa Minute ? 2 : 3
    return replace(ts, Regex("([:.]00+){1,$max_replacements}+\$"), "")
end

function prefix(p::Period)
    string(value(p) == 1 ? "" : value(p), prefix(typeof(p)))
end

prefix(::Type{Year}) = "Y"
prefix(::Type{Month}) = "Mo"
prefix(::Type{Day}) = "D"
prefix(::Type{Hour}) = "H"
prefix(::Type{Minute}) = "M"
prefix(::Type{Second}) = "S"
prefix(::Type{Millisecond}) = "ms"
prefix(::Type) = "?"


#=
function description(dt::TimeType, p::Year, s::String)
    return @sprintf("%s%s%04d", prefix(value(p), "Y"), s, year(dt))
end

function description(dt::TimeType, p::Month, s::String)
    return @sprintf("%04d %s%s%02d", year(dt), prefix(value(p), "Mo"), s, month(dt))
end

function description(dt::TimeType, p::Day, s::String)
    return @sprintf("%04d-%02d %s%s%02d", year(dt), month(dt), prefix(value(p), "D"), s, day(dt))
end

function description(dt::TimeType, p::Hour, s::String)
    hr = hour(dt)

    if s == "E"
        # Display HE24 as HE24
        hr = mod(hr - 1, 24) + 1
        if hr == 24
            dt -= Day(1)
        end
    end

    return @sprintf(
        "%04d-%02d-%02d %s%s%02d",
        year(dt), month(dt), day(dt),
        prefix(value(p), "H"), s,
        hr,
    )
end

function description(dt::TimeType, p::Minute, s::String)
    return @sprintf(
        "%04d-%02d-%02d %s%s%02d:%02d",
        year(dt), month(dt), day(dt),
        prefix(value(p), "M"), s,
        hour(dt), minute(dt),
    )
end

function description(dt::TimeType, p::Second, s::String)
    return @sprintf(
        "%04d-%02d-%02d %s%s%02d:%02d:%02d",
        year(dt), month(dt), day(dt),
        prefix(value(p), "S"), s,
        hour(dt), minute(dt), second(dt),
    )
end
=#
