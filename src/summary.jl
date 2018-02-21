using Base.Dates: value

summary(interval::AnchoredInterval{P}) where P = summary(interval, P > zero(P) ? "B" : "E")

function summary(interval::AnchoredInterval{P, T}, s::String) where {P, T}
    return string(
        first(inclusivity(interval)) ? '[' : '(',
        summary(anchor(interval), abs(P), s),
        last(inclusivity(interval)) ? ']' : ')',
    )
end

function summary(interval::AnchoredInterval{P, ZonedDateTime}, s::String) where P
    return string(
        first(inclusivity(interval)) ? '[' : '(',
        summary(anchor(interval), abs(P), s),
        anchor(interval).zone.offset,
        last(inclusivity(interval)) ? ']' : ')',
    )
end

function summary(dt::TimeType, p::Year, s::String)
    return @sprintf("%s%s%04d", summary(value(p), "Y"), s, year(dt))
end

function summary(dt::TimeType, p::Month, s::String)
    return @sprintf("%04d %s%s%02d", year(dt), summary(value(p), "Mo"), s, month(dt))
end

function summary(dt::TimeType, p::Day, s::String)
    return @sprintf("%04d-%02d %s%s%02d", year(dt), month(dt), summary(value(p), "D"), s, day(dt))
end

function summary(dt::TimeType, p::Hour, s::String)
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
        summary(value(p), "H"), s,
        hr,
    )
end

function summary(dt::TimeType, p::Minute, s::String)
    return @sprintf(
        "%04d-%02d-%02d %s%s%02d:%02d",
        year(dt), month(dt), day(dt),
        summary(value(p), "M"), s,
        hour(dt), minute(dt),
    )
end

function summary(dt::TimeType, p::Second, s::String)
    return @sprintf(
        "%04d-%02d-%02d %s%s%02d:%02d:%02d",
        year(dt), month(dt), day(dt),
        summary(value(p), "S"), s,
        hour(dt), minute(dt), second(dt),
    )
end

summary(i::Integer, suffix::String) = string(i == 1 ? "" : i, suffix)
