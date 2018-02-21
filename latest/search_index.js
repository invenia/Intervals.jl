var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#PeriodIntervals-1",
    "page": "Home",
    "title": "PeriodIntervals",
    "category": "section",
    "text": "This package defines:AbstractInterval, along with its subtypes:\nInterval{T}, which represents a non-iterable range between two endpoints of type T\nAnchoredInterval{P, T}, which represents a non-iterable range defined by a single value anchor::T and the value type P which represents the size of the range\nHourEnding, a type alias for AnchoredInterval{Hour(-1), T}\nHourBeginning, a type alias for AnchoredInterval{Hour(1), T}\nInclusivity, which represents whether an AbstractInterval is open, half-open, or closedTODO: Rename this package, because \"PeriodIntervals\" no longer fits."
},

{
    "location": "index.html#PeriodIntervals.Inclusivity",
    "page": "Home",
    "title": "PeriodIntervals.Inclusivity",
    "category": "Type",
    "text": "Inclusivity(first::Bool, last::Bool) -> Inclusivity\n\nDefines whether an AbstractInterval is open, half-open, or closed.\n\n\n\n"
},

{
    "location": "index.html#PeriodIntervals.Inclusivity-Tuple{Integer}",
    "page": "Home",
    "title": "PeriodIntervals.Inclusivity",
    "category": "Method",
    "text": "Inclusivity(i::Integer) -> Inclusivity\n\nDefines whether an interval is open, half-open, or closed, using an integer code:\n\nInclusivity Values\n\n0: Neither endpoint is included (the AbstractInterval is open) 1: Only the lesser endpoint is included (the AbstractInterval is left-closed) 2: Only the greater endpoint is included (the AbstractInterval is right-closed) 3: Both endpoints are included (the AbstractInterval is closed)\n\nNote that this constructor does not perform bounds-checking: instead it checks the values of the two least-significant bits of the integer. This means that Inclusivity(5) is equivalent to Inclusivity(1).\n\n\n\n"
},

{
    "location": "index.html#PeriodIntervals.Interval",
    "page": "Home",
    "title": "PeriodIntervals.Interval",
    "category": "Type",
    "text": "Interval(first, last, [inclusivity::Inclusivity]) -> Interval\n\nAn Interval represents a non-iterable range or span of values (non-interable because, unlike a StepRange, no step is defined).\n\nAn Interval can be closed (both first and last are included), open (neither first nor last are included in the span), or half-open. This openness is defined by an Inclusivity value, which defaults to closed.\n\nExample\n\njulia> i = Interval(0, 100, Inclusivity(true, false))\nInterval{Int64}(0, 100, Inclusivity(true, false))\n\njulia> in(0, i)\ntrue\n\njulia> in(50, i)\ntrue\n\njulia> in(100, i)\nfalse\n\njulia> intersect(Interval(0, 25, Inclusivity(false, false)), Interval(20, 50, Inclusivity(true, true))\nInterval{Int64}(20, 25, Inclusivity(true, false))\n\nInfix Constructor: ..\n\nA closed Interval can be constructed with the .. infix constructor:\n\njulia> Dates.today() - Dates.Week(1) .. Dates.today()\nInterval{Date}(2018-01-24, 2018-01-31, Inclusivity(true, true))\n\nNote on Ordering\n\nThe Interval constructor will compare first and last; if it findes that first > last, they will be reversed to ensure that first < last. This simplifies calls to in and intersect:\n\njulia> i = Interval(Date(2016, 8, 11), Date(2013, 2, 13), Inclusivity(false, true))\nInterval{Date}(2013-02-13, 2016-08-11, Inclusivity(true, false))\n\nNote that the Inclusivity value is also reversed in this case.\n\nSee also: AnchoredInterval, Inclusivity\n\n\n\n"
},

{
    "location": "index.html#PeriodIntervals.AnchoredInterval",
    "page": "Home",
    "title": "PeriodIntervals.AnchoredInterval",
    "category": "Type",
    "text": "AnchoredInterval{P, T}(anchor::T, [inclusivity::Inclusivity]) where {P, T} -> AnchoredInterval{P, T}\n\nAnchoredInterval is a subtype of AbstractInterval that represents a non-iterable range or span of values defined not by a startpoint and an endpoint but instead by a single anchor point and the value type P which represents the size of the range. When P is positive, the anchor represents the lesser endpoint (the beginning of the range); when P is negative, the anchor represents the greater endpoint (the end of the range).\n\nThe interval represented by an AnchoredInterval value may be closed (both endpoints are included in the interval), open (neither endpoint is included), or half-open. This openness is defined by an Inclusivity value, which defaults to half-open (with the lesser endpoint included for positive values of P and the greater endpoint included for negative values).\n\nWhy?\n\nAnchoredIntervals are most useful in cases where a single value is used to stand in for a range of values. This happens most often with dates and times, where \"HE15\" is often used as shorthand for (14:00..15:00].\n\nTo this end, HourEnding is a type alias for AnchoredInterval{Hour(-1)}. Similarly, HourBeginning is a type alias for AnchoredInterval{Hour(1)}.\n\nRounding\n\nIf P is a Period, the anchor provided is rounded up or down to the nearest P, as appropriate, using ceil or floor. This means that AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12, 30)) is equivalent to AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 13)).\n\nExample\n\njulia> AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12))\nHourEnding{DateTime}(2016-08-11T12:00:00, Inclusivity(false, true))\n\njulia> AnchoredInterval{Day(1)}(DateTime(2016, 8, 11))\nAnchoredInterval{1 day, DateTime}(2016-08-11T00:00:00, Inclusivity(true, false))\n\njulia> AnchoredInterval{Minute(5)}(DateTime(2016, 8, 11, 12, 30, 5), Inclusivity(true, true))\nAnchoredInterval{5 minutes, DateTime}(2016-08-11T12:30:00, Inclusivity(true, true))\n\nSee also: Interval, Inclusivity\n\n\n\n"
},

{
    "location": "index.html#API-1",
    "page": "Home",
    "title": "API",
    "category": "section",
    "text": "Inclusivity\nInclusivity(::Integer)\nInterval\nAnchoredInterval"
},

]}
