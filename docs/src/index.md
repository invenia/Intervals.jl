# Intervals

This package defines:
* `AbstractInterval`, along with its subtypes:
  * [`Interval{T}`](@ref Interval), which represents a non-iterable range between two endpoints of type `T`
  * [`AnchoredInterval{P, T}`](@ref AnchoredInterval), which represents a non-iterable range defined by a single
    value `anchor::T` and the value type `P` which represents the size of the range
    * [`HourEnding`](@ref), a type alias for `AnchoredInterval{Hour(-1), T}`
    * [`HourBeginning`](@ref), a type alias for `AnchoredInterval{Hour(1), T}`
    * [`HE`](@ref) and [`HB`](@ref), pseudoconstructors for `HourEnding` and `HourBeginning` that round the
      anchor up (`HE`) or down (`HB`) to the nearest hour
* [`Inclusivity`](@ref), which represents whether an `AbstractInterval` is open, half-open, or
  closed

## Example Usage

### Intersection

```julia
using Intervals

julia> a = 1..10
Interval{Int64}(1, 10, Inclusivity(true, true))

julia> b = 5..15
Interval{Int64}(5, 15, Inclusivity(true, true))

julia> intersect(a, b)
Interval{Int64}(5, 10, Inclusivity(true, true))
```

### Inclusivity

```julia
julia> a = Interval(1, 10)
Interval{Int64}(1, 10, Inclusivity(true, true))

julia> b = Interval(5, 15, false, false)
Interval{Int64}(5, 15, Inclusivity(false, false))

julia> 5 in a
true

julia> 5 in b
false

julia> intersect(a, b)
Interval{Int64}(5, 10, Inclusivity(false, true))

julia> c = Interval(15, 20)
Interval{Int64}(15, 20, Inclusivity(true, true))

julia> isempty(intersect(b, c))
true
```

### Display

```julia
julia> a = Interval('a', 'z')
Interval{Char}('a', 'z', Inclusivity(true, true))

julia> string(a)
"[a..z]"

julia> b = Interval(Date(2013), Date(2016), true, false)
Interval{Date}(2013-01-01, 2016-01-01, Inclusivity(true, false))

julia> string(b)
"[2013-01-01..2016-01-01)"

julia> c = HourEnding(DateTime(2016, 8, 11))
HourEnding{DateTime}(2016-08-11T00:00:00, Inclusivity(false, true))

julia> string(c)
"(2016-08-10 HE24]"
```

### `HourEnding` and `HE`

```julia
julia> using TimeZones

julia> unrounded = HourEnding(ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg"))
HourEnding{TimeZones.ZonedDateTime}(2013-02-13T00:30:00-06:00, Inclusivity(false, true))

julia> he = HE(ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg"))
HourEnding{TimeZones.ZonedDateTime}(2013-02-13T01:00:00-06:00, Inclusivity(false, true))

julia> he + Base.Dates.Hour(1)
HourEnding{TimeZones.ZonedDateTime}(2013-02-13T02:00:00-06:00, Inclusivity(false, true))

julia> foreach(println, he:he + Base.Dates.Day(1))
(2013-02-13 HE01-06:00]
(2013-02-13 HE02-06:00]
(2013-02-13 HE03-06:00]
(2013-02-13 HE04-06:00]
(2013-02-13 HE05-06:00]
(2013-02-13 HE06-06:00]
(2013-02-13 HE07-06:00]
(2013-02-13 HE08-06:00]
(2013-02-13 HE09-06:00]
(2013-02-13 HE10-06:00]
(2013-02-13 HE11-06:00]
(2013-02-13 HE12-06:00]
(2013-02-13 HE13-06:00]
(2013-02-13 HE14-06:00]
(2013-02-13 HE15-06:00]
(2013-02-13 HE16-06:00]
(2013-02-13 HE17-06:00]
(2013-02-13 HE18-06:00]
(2013-02-13 HE19-06:00]
(2013-02-13 HE20-06:00]
(2013-02-13 HE21-06:00]
(2013-02-13 HE22-06:00]
(2013-02-13 HE23-06:00]
(2013-02-13 HE24-06:00]
(2013-02-14 HE01-06:00]

julia> ZonedDateTime(he)
2013-02-13T01:00:00-06:00
```

### Comparisons

When determining whether one `AbstractInterval` is less than (or greater than) another, two
sets of comparison operators are available: `<`/`>` and `≪`/`≫`.

The standard `<` and `>` operators simply compare the leftmost endpoint of the intervals,
and are used for things like `sort`, `min`, `max`, etc.

The `≪` and `≫` operators (the Unicode symbols for "much less than" and "much greater than",
accessible from the REPL with `\ll` and `\gg`, respectively) are used in this context to
mean "less/greater than and disjoint"; they will verify that there is no overlap between
the intervals.

```julia
julia> 0..10 < 10..20
true

julia> 0..10 ≪ 10..20
false

julia> 0..10 ≪ 11..20
true
```

## API

```@docs
Inclusivity
Inclusivity(::Integer)
Interval
AnchoredInterval
≪
≫
HourEnding
HourBeginning
HE
HB
```
