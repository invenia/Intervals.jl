var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Intervals-1",
    "page": "Home",
    "title": "Intervals",
    "category": "section",
    "text": "This package defines:AbstractInterval, along with its subtypes:\nInterval{T}, which represents a non-iterable range between two endpoints of type T\nAnchoredInterval{P, T}, which represents a non-iterable range defined by a single value anchor::T and the value type P which represents the size of the range\nHourEnding, a type alias for AnchoredInterval{Hour(-1), T}\nHourBeginning, a type alias for AnchoredInterval{Hour(1), T}\nHE and HB, pseudoconstructors for HourEnding and HourBeginning that round the anchor up (HE) or down (HB) to the nearest hour\nInclusivity, which represents whether an AbstractInterval is open, half-open, or closed"
},

{
    "location": "index.html#Example-Usage-1",
    "page": "Home",
    "title": "Example Usage",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Intersection-1",
    "page": "Home",
    "title": "Intersection",
    "category": "section",
    "text": "using Intervals\n\njulia> a = 1..10\nInterval{Int64}(1, 10, Inclusivity(true, true))\n\njulia> b = 5..15\nInterval{Int64}(5, 15, Inclusivity(true, true))\n\njulia> intersect(a, b)\nInterval{Int64}(5, 10, Inclusivity(true, true))"
},

{
    "location": "index.html#Inclusivity-1",
    "page": "Home",
    "title": "Inclusivity",
    "category": "section",
    "text": "julia> a = Interval(1, 10)\nInterval{Int64}(1, 10, Inclusivity(true, true))\n\njulia> b = Interval(5, 15, false, false)\nInterval{Int64}(5, 15, Inclusivity(false, false))\n\njulia> in(5, a)\ntrue\n\njulia> in(5, b)\nfalse\n\njulia> intersect(a, b)\nInterval{Int64}(5, 10, Inclusivity(false, true))\n\njulia> c = Interval(15, 20)\nInterval{Int64}(15, 20, Inclusivity(true, true))\n\njulia> isempty(intersect(b, c))\ntrue"
},

{
    "location": "index.html#Display-1",
    "page": "Home",
    "title": "Display",
    "category": "section",
    "text": "julia> a = Interval(\'a\', \'z\')\nInterval{Char}(\'a\', \'z\', Inclusivity(true, true))\n\njulia> string(a)\n\"[a..z]\"\n\njulia> b = Interval(Date(2013), Date(2016), true, false)\nInterval{Date}(2013-01-01, 2016-01-01, Inclusivity(true, false))\n\njulia> string(b)\n\"[2013-01-01..2016-01-01)\"\n\njulia> c = HourEnding(DateTime(2016, 8, 11))\nHourEnding{DateTime}(2016-08-11T00:00:00, Inclusivity(false, true))\n\njulia> string(c)\n\"(2016-08-10 HE24]\""
},

{
    "location": "index.html#HourEnding-and-HE-1",
    "page": "Home",
    "title": "HourEnding and HE",
    "category": "section",
    "text": "julia> using TimeZones\n\njulia> unrounded = HourEnding(ZonedDateTime(2013, 2, 13, 0, 30, tz\"America/Winnipeg\"))\nHourEnding{TimeZones.ZonedDateTime}(2013-02-13T00:30:00-06:00, Inclusivity(false, true))\n\njulia> he = HE(ZonedDateTime(2013, 2, 13, 0, 30, tz\"America/Winnipeg\"))\nHourEnding{TimeZones.ZonedDateTime}(2013-02-13T01:00:00-06:00, Inclusivity(false, true))\n\njulia> he + Base.Dates.Hour(1)\nHourEnding{TimeZones.ZonedDateTime}(2013-02-13T02:00:00-06:00, Inclusivity(false, true))\n\njulia> for h in he:he + Base.Dates.Day(1)\n           println(he)\n       end\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n(2013-02-13 HE01-06:00]\n\njulia> ZonedDateTime(he)\n2013-02-13T01:00:00-06:00"
},

{
    "location": "index.html#Comparisons-1",
    "page": "Home",
    "title": "Comparisons",
    "category": "section",
    "text": "When determining whether one AbstractInterval is less than (or greater than) another, two sets of comparison operators are available: </> and ≪/≫.The standard < and > operators simply compare the leftmost endpoint of the intervals, and are used for things like sort, min, max, etc.The ≪ and ≫ operators (the Unicode symbols for \"much less than\" and \"much greater than\", accessible from the REPL with \\ll and \\gg, respectively) are used in this context to mean \"less/greater than and disjoint\"; they will verify that there is no overlap between the intervals.julia> 0..10 < 10..20\ntrue\n\njulia> 0..10 ≪ 10..20\nfalse\n\njulia> 0..10 ≪ 11..20\ntrue"
},

{
    "location": "index.html#Intervals.Inclusivity",
    "page": "Home",
    "title": "Intervals.Inclusivity",
    "category": "type",
    "text": "Inclusivity(first::Bool, last::Bool) -> Inclusivity\n\nDefines whether an AbstractInterval is open, half-open, or closed.\n\n\n\n"
},

{
    "location": "index.html#Intervals.Inclusivity-Tuple{Integer}",
    "page": "Home",
    "title": "Intervals.Inclusivity",
    "category": "method",
    "text": "Inclusivity(i::Integer) -> Inclusivity\n\nDefines whether an interval is open, half-open, or closed, using an integer code:\n\nInclusivity Values\n\n0: Neither endpoint is included (the AbstractInterval is open)\n1: Only the lesser endpoint is included (the AbstractInterval is left-closed)\n2: Only the greater endpoint is included (the AbstractInterval is right-closed)\n3: Both endpoints are included (the AbstractInterval is closed)\n\nNote that this constructor does not perform bounds-checking: instead it checks the values of the two least-significant bits of the integer. This means that Inclusivity(5) is equivalent to Inclusivity(1).\n\n\n\n"
},

{
    "location": "index.html#Intervals.Interval",
    "page": "Home",
    "title": "Intervals.Interval",
    "category": "type",
    "text": "Interval(first, last, [inclusivity::Inclusivity]) -> Interval\nInterval(first, last, [closed_left::Bool, closed_right::Bool]) -> Interval\n\nAn Interval represents a non-iterable range or span of values (non-interable because, unlike a StepRange, no step is defined).\n\nAn Interval can be closed (both first and last are included in the interval), open (neither first nor last are included), or half-open. This openness is defined by an Inclusivity value, which defaults to closed.\n\nExample\n\njulia> i = Interval(0, 100, true, false)\nInterval{Int64}(0, 100, Inclusivity(true, false))\n\njulia> in(0, i)\ntrue\n\njulia> in(50, i)\ntrue\n\njulia> in(100, i)\nfalse\n\njulia> intersect(Interval(0, 25, false, false), Interval(20, 50, true, true)\nInterval{Int64}(20, 25, Inclusivity(true, false))\n\nInfix Constructor: ..\n\nA closed Interval can be constructed with the .. infix constructor:\n\njulia> Dates.today() - Dates.Week(1) .. Dates.today()\nInterval{Date}(2018-01-24, 2018-01-31, Inclusivity(true, true))\n\nNote on Ordering\n\nThe Interval constructor will compare first and last; if it findes that first > last, they will be reversed to ensure that first < last. This simplifies calls to in and intersect:\n\njulia> i = Interval(Date(2016, 8, 11), Date(2013, 2, 13), false, true)\nInterval{Date}(2013-02-13, 2016-08-11, Inclusivity(true, false))\n\nNote that the Inclusivity value is also reversed in this case.\n\nSee also: AnchoredInterval, Inclusivity\n\n\n\n"
},

{
    "location": "index.html#Intervals.AnchoredInterval",
    "page": "Home",
    "title": "Intervals.AnchoredInterval",
    "category": "type",
    "text": "AnchoredInterval{P, T}(anchor::T, [inclusivity::Inclusivity]) where {P, T} -> AnchoredInterval{P, T}\nAnchoredInterval{P, T}(anchor::T, [closed_left::Bool, closed_right::Bool]) where {P, T} -> AnchoredInterval{P, T}\n\nAnchoredInterval is a subtype of AbstractInterval that represents a non-iterable range or span of values defined not by two endpoints but instead by a single anchor point and the value type P which represents the size of the range. When P is positive, the anchor represents the lesser endpoint (the beginning of the range); when P is negative, the anchor represents the greater endpoint (the end of the range).\n\nThe interval represented by an AnchoredInterval value may be closed (both endpoints are included in the interval), open (neither endpoint is included), or half-open. This openness is defined by an Inclusivity value, which defaults to half-open (with the lesser endpoint included for positive values of P and the greater endpoint included for negative values).\n\nWhy?\n\nAnchoredIntervals are most useful in cases where a single value is used to stand in for a range of values. This happens most often with dates and times, where \"HE15\" is often used as shorthand for (14:00..15:00].\n\nTo this end, HourEnding is a type alias for AnchoredInterval{Hour(-1)}. Similarly, HourBeginning is a type alias for AnchoredInterval{Hour(1)}.\n\nRounding\n\nWhile the user may expect an HourEnding or HourBeginning value to be anchored to a specific hour, the constructor makes no guarantees that the anchor provided is rounded:\n\njulia> HourEnding(DateTime(2016, 8, 11, 2, 30))\nHourEnding{DateTime}(2016-08-11T02:30:00, Inclusivity(false, true))\n\nThe HE and HB pseudoconstructors round the input up or down to the nearest hour, as appropriate:\n\njulia> HE(DateTime(2016, 8, 11, 2, 30))\nHourEnding{DateTime}(2016-08-11T03:00:00, Inclusivity(false, true))\n\njulia> HB(DateTime(2016, 8, 11, 2, 30))\nHourBeginning{DateTime}(2016-08-11T02:00:00, Inclusivity(true, false))\n\nExample\n\njulia> AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12))\nHourEnding{DateTime}(2016-08-11T12:00:00, Inclusivity(false, true))\n\njulia> AnchoredInterval{Day(1)}(DateTime(2016, 8, 11))\nAnchoredInterval{1 day, DateTime}(2016-08-11T00:00:00, Inclusivity(true, false))\n\njulia> AnchoredInterval{Minute(5)}(DateTime(2016, 8, 11, 12, 30), true, true)\nAnchoredInterval{5 minutes, DateTime}(2016-08-11T12:30:00, Inclusivity(true, true))\n\nSee also: Interval, Inclusivity, HE, HB\n\n\n\n"
},

{
    "location": "index.html#Intervals.:≪",
    "page": "Home",
    "title": "Intervals.:≪",
    "category": "function",
    "text": "≪(a::AbstractInterval, b::AbstractInterval) -> Bool\nless_than_disjoint(a::AbstractInterval, b::AbstractInterval) -> Bool\n\nLess-than-and-disjoint comparison operator. Returns true if a is less than b and they are disjoint (they do not overlap).\n\njulia> 0..10 ≪ 10..20\nfalse\n\njulia> 0..10 ≪ 11..20\ntrue\n\n\n\n"
},

{
    "location": "index.html#Intervals.:≫",
    "page": "Home",
    "title": "Intervals.:≫",
    "category": "function",
    "text": "≫(a::AbstractInterval, b::AbstractInterval) -> Bool\ngreater_than_disjoint(a::AbstractInterval, b::AbstractInterval) -> Bool\n\nGreater-than-and-disjoint comparison operator. Returns true if a is greater than b and they are disjoint (they do not overlap).\n\njulia> 10..20 ≫ 0..10\nfalse\n\njulia> 11..20 ≫ 0..10\ntrue\n\n\n\n"
},

{
    "location": "index.html#API-1",
    "page": "Home",
    "title": "API",
    "category": "section",
    "text": "Inclusivity\nInclusivity(::Integer)\nInterval\nAnchoredInterval\n≪\n≫"
},

]}
