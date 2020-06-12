var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#Intervals-1",
    "page": "Home",
    "title": "Intervals",
    "category": "section",
    "text": "DocTestSetup = quote\n    using Intervals, Dates, TimeZones\n\n    # This is a hack to have nice printing that doesn\'t include module names.\n    # https://github.com/JuliaDocs/Documenter.jl/issues/944\n    @eval Main begin\n        using Dates, TimeZones\n    end\nendThis package defines:AbstractInterval, along with its subtypes:\nInterval{T,L,R}, which represents a non-iterable range between two endpoints of type T with left/right bounds respectively being L and R\nAnchoredInterval{P,T,L,R}, which represents a non-iterable range defined by a single value anchor::T and the value type P which represents the span of the range. Left/right bounds are specifed by L and R respectively\nHourEnding, a type alias for AnchoredInterval{Hour(-1)}\nHourBeginning, a type alias for AnchoredInterval{Hour(1)}\nHE and HB, pseudoconstructors for HourEnding and HourBeginning that round the anchor up (HE) or down (HB) to the nearest hour"
},

{
    "location": "#Example-Usage-1",
    "page": "Home",
    "title": "Example Usage",
    "category": "section",
    "text": ""
},

{
    "location": "#Intersection-1",
    "page": "Home",
    "title": "Intersection",
    "category": "section",
    "text": "julia> a = 1..10\nInterval{Int64,Closed,Closed}(1, 10)\n\njulia> b = 5..15\nInterval{Int64,Closed,Closed}(5, 15)\n\njulia> intersect(a, b)\nInterval{Int64,Closed,Closed}(5, 10)"
},

{
    "location": "#Bounds-1",
    "page": "Home",
    "title": "Bounds",
    "category": "section",
    "text": "julia> a = Interval{Closed,Closed}(1, 10)\nInterval{Int64,Closed,Closed}(1, 10)\n\njulia> b = Interval{Open,Open}(5, 15)\nInterval{Int64,Open,Open}(5, 15)\n\njulia> 5 in a\ntrue\n\njulia> 5 in b\nfalse\n\njulia> intersect(a, b)\nInterval{Int64,Open,Closed}(5, 10)\n\njulia> c = Interval(15, 20)\nInterval{Int64,Closed,Closed}(15, 20)\n\njulia> isempty(intersect(b, c))\ntrue"
},

{
    "location": "#Display-1",
    "page": "Home",
    "title": "Display",
    "category": "section",
    "text": "julia> a = Interval(\'a\', \'z\')\nInterval{Char,Closed,Closed}(\'a\', \'z\')\n\njulia> string(a)\n\"[a .. z]\"\n\njulia> using Dates\n\njulia> b = Interval{Closed,Open}(Date(2013), Date(2016))\nInterval{Date,Closed,Open}(2013-01-01, 2016-01-01)\n\njulia> string(b)\n\"[2013-01-01 .. 2016-01-01)\"\n\njulia> c = HourEnding(DateTime(2016, 8, 11))\nAnchoredInterval{-1 hour,DateTime,Open,Closed}(2016-08-11T00:00:00)\n\njulia> string(c)\n\"(2016-08-10 HE24]\""
},

{
    "location": "#HourEnding-and-HE-1",
    "page": "Home",
    "title": "HourEnding and HE",
    "category": "section",
    "text": "julia> using TimeZones, Dates\n\njulia> unrounded = HourEnding(ZonedDateTime(2013, 2, 13, 0, 30, tz\"America/Winnipeg\"))\nAnchoredInterval{-1 hour,ZonedDateTime,Open,Closed}(ZonedDateTime(2013, 2, 13, 0, 30, tz\"America/Winnipeg\"))\n\njulia> he = HE(ZonedDateTime(2013, 2, 13, 0, 30, tz\"America/Winnipeg\"))\nAnchoredInterval{-1 hour,ZonedDateTime,Open,Closed}(ZonedDateTime(2013, 2, 13, 1, tz\"America/Winnipeg\"))\n\njulia> he + Hour(1)\nAnchoredInterval{-1 hour,ZonedDateTime,Open,Closed}(ZonedDateTime(2013, 2, 13, 2, tz\"America/Winnipeg\"))\n\njulia> foreach(println, he:he + Day(1))\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE02-06:00]\n(2013-02-13 HE03-06:00]\n(2013-02-13 HE04-06:00]\n(2013-02-13 HE05-06:00]\n(2013-02-13 HE06-06:00]\n(2013-02-13 HE07-06:00]\n(2013-02-13 HE08-06:00]\n(2013-02-13 HE09-06:00]\n(2013-02-13 HE10-06:00]\n(2013-02-13 HE11-06:00]\n(2013-02-13 HE12-06:00]\n(2013-02-13 HE13-06:00]\n(2013-02-13 HE14-06:00]\n(2013-02-13 HE15-06:00]\n(2013-02-13 HE16-06:00]\n(2013-02-13 HE17-06:00]\n(2013-02-13 HE18-06:00]\n(2013-02-13 HE19-06:00]\n(2013-02-13 HE20-06:00]\n(2013-02-13 HE21-06:00]\n(2013-02-13 HE22-06:00]\n(2013-02-13 HE23-06:00]\n(2013-02-13 HE24-06:00]\n(2013-02-14 HE01-06:00]\n\njulia> anchor(he)\n2013-02-13T01:00:00-06:00"
},

{
    "location": "#Plotting-1",
    "page": "Home",
    "title": "Plotting",
    "category": "section",
    "text": "AbstractInterval subtypes can be plotted with Plots.jl.julia> using Plots\n\njulia> start_dt = DateTime(2017,1,1,0,0,0);\n\njulia> end_dt = DateTime(2017,1,1,10,30,0);\n\njulia> datetimes = start_dt:Hour(1):end_dt\n2017-01-01T00:00:00:1 hour:2017-01-01T10:00:00\n\njulia> intervals = HE.(datetimes);\n\njulia> plot(intervals, 1:11)(Image: plot)In the plot, inclusive boundaries are marked with a vertical bar, whereas exclusive boundaries just end."
},

{
    "location": "#Comparisons-1",
    "page": "Home",
    "title": "Comparisons",
    "category": "section",
    "text": ""
},

{
    "location": "#Equality-1",
    "page": "Home",
    "title": "Equality",
    "category": "section",
    "text": "Two AbstractIntervals are considered equal if they have identical left and right endpoints (taking bounds into account):julia> a = Interval{Closed,Open}(DateTime(2013, 2, 13), DateTime(2013, 2, 13, 1))\nInterval{DateTime,Closed,Open}(2013-02-13T00:00:00, 2013-02-13T01:00:00)\n\njulia> b = Interval{Open,Closed}(DateTime(2013, 2, 13), DateTime(2013, 2, 13, 1))\nInterval{DateTime,Open,Closed}(2013-02-13T00:00:00, 2013-02-13T01:00:00)\n\njulia> c = HourEnding(DateTime(2013, 2, 13, 1))\nAnchoredInterval{-1 hour,DateTime,Open,Closed}(2013-02-13T01:00:00)\n\njulia> a == b\nfalse\n\njulia> b == c\ntrue"
},

{
    "location": "#Less-Than-1",
    "page": "Home",
    "title": "Less Than",
    "category": "section",
    "text": "When determining whether one AbstractInterval is less than (or greater than) another, two sets of comparison operators are available: </> and ≪/≫.The standard < and > operators (which are not explicitly defined, but are derived from isless) simply compare the leftmost endpoint of the intervals, and are used for things like sort, min, max, etc.The ≪ and ≫ operators (the Unicode symbols for \"much less than\" and \"much greater than\", accessible from the REPL with \\ll and \\gg, respectively) are used in this context to mean \"less/greater than and disjoint\"; they will verify that there is no overlap between the intervals.julia> 0..10 < 10..20\ntrue\n\njulia> 0..10 ≪ 10..20\nfalse\n\njulia> 0..10 ≪ 11..20\ntrue"
},

{
    "location": "#Intervals.Interval",
    "page": "Home",
    "title": "Intervals.Interval",
    "category": "type",
    "text": "Interval{T, L <: Bound, R <: Bound}\n\nAn Interval represents a non-iterable range or span of values (non-interable because, unlike a StepRange, no step is defined).\n\nAn Interval can be closed (both first and last are included in the interval), open (neither first nor last are included), or half-open. This openness is defined by the bounds information which is stored as the type parameters L and R.\n\nExample\n\njulia> interval = Interval{Closed,Open}(0, 100)\nInterval{Int64,Closed,Open}}(0, 100)\n\njulia> 0 in interval\ntrue\n\njulia> 50 in interval\ntrue\n\njulia> 100 in interval\nfalse\n\njulia> intersect(Interval{Open,Open}(0, 25), Interval{Closed,Closed}(20, 50)\nInterval{Int64,Closed,Open}(20, 25)\n\nInfix Constructor: ..\n\nA closed Interval can be constructed with the .. infix constructor:\n\njulia> Dates.today() - Dates.Week(1) .. Dates.today()\nInterval{Date,Closed,Closed}(2018-01-24, 2018-01-31)\n\nNote on Ordering\n\nThe Interval constructor will compare first and last; if it finds that first > last, they will be reversed to ensure that first < last. This simplifies calls to in and intersect:\n\njulia> i = Interval{Open,Closed}(Date(2016, 8, 11), Date(2013, 2, 13))\nInterval{Date,Closed,Open}(2013-02-13, 2016-08-11)\n\nNote that the bounds are also reversed in this case.\n\nSee also: AnchoredInterval\n\n\n\n\n\n"
},

{
    "location": "#Intervals.AnchoredInterval",
    "page": "Home",
    "title": "Intervals.AnchoredInterval",
    "category": "type",
    "text": "AnchoredInterval{P,T,L,R}\n\nAnchoredInterval is a subtype of AbstractInterval that represents a non-iterable range or span of values defined not by two endpoints but instead by a single anchor point and the value type P which represents the size of the range. When P is positive, the anchor represents the lesser endpoint (the beginning of the range); when P is negative, the anchor represents the greater endpoint (the end of the range).\n\nThe interval represented by an AnchoredInterval value may be closed (both endpoints are included in the interval), open (neither endpoint is included), or half-open. This openness is defined by the bounds types L and R, which defaults to half-open (with the lesser endpoint included for positive values of P and the greater endpoint included for negative values).\n\nWhy?\n\nAnchoredIntervals are most useful in cases where a single value is used to stand in for a range of values. This happens most often with dates and times, where \"HE15\" is often used as shorthand for (14:00..15:00].\n\nTo this end, HourEnding is a type alias for AnchoredInterval{Hour(-1)}. Similarly, HourBeginning is a type alias for AnchoredInterval{Hour(1)}.\n\nRounding\n\nWhile the user may expect an HourEnding or HourBeginning value to be anchored to a specific hour, the constructor makes no guarantees that the anchor provided is rounded:\n\njulia> HourEnding(DateTime(2016, 8, 11, 2, 30))\nAnchoredInterval{-1 hour,DateTime,Open,Closed}(2016-08-11T02:30:00)\n\nThe HE and HB pseudoconstructors round the input up or down to the nearest hour, as appropriate:\n\njulia> HE(DateTime(2016, 8, 11, 2, 30))\nAnchoredInterval{-1 hour,DateTime,Open,Closed}(2016-08-11T03:00:00)\n\njulia> HB(DateTime(2016, 8, 11, 2, 30))\nAnchoredInterval{1 hour,DateTime,Closed,Open}(2016-08-11T02:00:00)\n\nExample\n\njulia> AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12))\nAnchoredInterval{-1 hour,DateTime,Open,Closed}(2016-08-11T12:00:00)\n\njulia> AnchoredInterval{Day(1)}(DateTime(2016, 8, 11))\nAnchoredInterval{1 day,DateTime,Closed,Open}(2016-08-11T00:00:00)\n\njulia> AnchoredInterval{Minute(5),Closed,Closed}(DateTime(2016, 8, 11, 12, 30))\nAnchoredInterval{5 minutes,DateTime,Closed,Closed}(2016-08-11T12:30:00)\n\nSee also: Interval, HE, HB\n\n\n\n\n\n"
},

{
    "location": "#Intervals.HourEnding",
    "page": "Home",
    "title": "Intervals.HourEnding",
    "category": "type",
    "text": "HourEnding{T<:TimeType, L, R} <: AbstractInterval{T}\n\nA type alias for AnchoredInterval{Hour(-1), T} which is used to denote a 1-hour period of time which ends at a time instant (of type T).\n\n\n\n\n\n"
},

{
    "location": "#Intervals.HourBeginning",
    "page": "Home",
    "title": "Intervals.HourBeginning",
    "category": "type",
    "text": "HourBeginning{T<:TimeType, L, R} <: AbstractInterval{T}\n\nA type alias for AnchoredInterval{Hour(1), T} which is used to denote a 1-hour period of time which begins at a time instant (of type T).\n\n\n\n\n\n"
},

{
    "location": "#Intervals.HE",
    "page": "Home",
    "title": "Intervals.HE",
    "category": "function",
    "text": "HE(anchor) -> HourEnding\n\nHE is a pseudoconstructor for HourEnding that rounds the anchor provided up to the nearest hour.\n\n\n\n\n\n"
},

{
    "location": "#Intervals.HB",
    "page": "Home",
    "title": "Intervals.HB",
    "category": "function",
    "text": "HB(anchor) -> HourBeginning\n\nHB is a pseudoconstructor for HourBeginning that rounds the anchor provided down to the nearest hour.\n\n\n\n\n\n"
},

{
    "location": "#Intervals.:≪",
    "page": "Home",
    "title": "Intervals.:≪",
    "category": "function",
    "text": "≪(a::AbstractInterval, b::AbstractInterval) -> Bool\nless_than_disjoint(a::AbstractInterval, b::AbstractInterval) -> Bool\n\nLess-than-and-disjoint comparison operator. Returns true if a is less than b and they are disjoint (they do not overlap).\n\njulia> 0..10 ≪ 10..20\nfalse\n\njulia> 0..10 ≪ 11..20\ntrue\n\n\n\n\n\n"
},

{
    "location": "#Intervals.:≫",
    "page": "Home",
    "title": "Intervals.:≫",
    "category": "function",
    "text": "≫(a::AbstractInterval, b::AbstractInterval) -> Bool\ngreater_than_disjoint(a::AbstractInterval, b::AbstractInterval) -> Bool\n\nGreater-than-and-disjoint comparison operator. Returns true if a is greater than b and they are disjoint (they do not overlap).\n\njulia> 10..20 ≫ 0..10\nfalse\n\njulia> 11..20 ≫ 0..10\ntrue\n\n\n\n\n\n"
},

{
    "location": "#Base.:==",
    "page": "Home",
    "title": "Base.:==",
    "category": "function",
    "text": "==(a::Endpoint, b::Endpoint) -> Bool\n\nDetermine if two endpoints are equal. When both endpoints are left or right then the points and inclusiveness must be the same.\n\nChecking the equality of left-endpoint and a right-endpoint is slightly more difficult. A left-endpoint and a right-endpoint are only equal when they use the same point and are both included. Note that left/right endpoints which are both not included are not equal as the left-endpoint contains values below that point while the right-endpoint only contains values that are above that point.\n\nVisualizing two contiguous intervals can assist in understanding this logic:\n\n[x..y][y..z] -> RightEndpoint == LeftEndpoint\n[x..y)[y..z] -> RightEndpoint != LeftEndpoint\n[x..y](y..z] -> RightEndpoint != LeftEndpoint\n[x..y)(y..z] -> RightEndpoint != LeftEndpoint\n\n\n\n\n\n"
},

{
    "location": "#Base.union",
    "page": "Home",
    "title": "Base.union",
    "category": "function",
    "text": "union(intervals::AbstractVector{<:AbstractInterval})\n\nFlattens a vector of overlapping intervals into a new, smaller vector containing only non-overlapping intervals.\n\n\n\n\n\n"
},

{
    "location": "#Base.union!",
    "page": "Home",
    "title": "Base.union!",
    "category": "function",
    "text": "union!(intervals::AbstractVector{<:Union{Interval, AbstractInterval}})\n\nFlattens a vector of overlapping intervals in-place to be a smaller vector containing only non-overlapping intervals.\n\n\n\n\n\n"
},

{
    "location": "#Intervals.span",
    "page": "Home",
    "title": "Intervals.span",
    "category": "function",
    "text": "span(interval::AbstractInterval)\n\nCompute the span of the interval, that is last(interval) - first(interval).\n\n\n\n\n\n"
},

{
    "location": "#Intervals.superset",
    "page": "Home",
    "title": "Intervals.superset",
    "category": "function",
    "text": "superset(intervals::AbstractArray{<:AbstractInterval}) -> Interval\n\nCreate the smallest single interval which encompasses all of the provided intervals.\n\n\n\n\n\n"
},

{
    "location": "#API-1",
    "page": "Home",
    "title": "API",
    "category": "section",
    "text": "Interval\nAnchoredInterval\nHourEnding\nHourBeginning\nHE\nHB\n≪\n≫\n==\nunion\nunion!\nspan\nsuperset"
},

]}
