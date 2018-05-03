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

#### Equality

Two `AbstractInterval`s are considered equal if they have identical left and right
endpoints (taking `Inclusivity` into account):

```julia
julia> a = Interval(DateTime(2013, 2, 13), DateTime(2013, 2, 13, 1), true, false)
Interval{DateTime}(2013-02-13T00:00:00, 2013-02-13T01:00:00, Inclusivity(true, false))

julia> b = Interval(DateTime(2013, 2, 13), DateTime(2013, 2, 13, 1), false, true)
Interval{DateTime}(2013-02-13T00:00:00, 2013-02-13T01:00:00, Inclusivity(false, true))

julia> c = HourEnding(DateTime(2013, 2, 13, 1))
HourEnding{DateTime}(2013-02-13T01:00:00, Inclusivity(false, true))

julia> a == b
false

julia> b == c
true
```

#### Less Than

When determining whether one `AbstractInterval` is less than (or greater than) another, two
sets of comparison operators are available: `<`/`>` and `≪`/`≫`.

The standard `<` and `>` operators (which are not explicitly defined, but are derived from
`isless`) simply compare the leftmost endpoint of the intervals, and are used for things
like `sort`, `min`, `max`, etc.

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

### `DataFrame` Considerations

Even in `DataFrame`s, equality comparisons between `AbstractInterval`s perform as expected:

```julia
julia> using DataFrames

julia> he = HourEnding(DateTime(2016, 11, 16, 1)):HourEnding(DateTime(2016, 11, 16, 12))
HourEnding{DateTime}(2016-11-16T01:00:00, Inclusivity(false, true)):1 hour:HourEnding{DateTime}(2016-11-16T12:00:00, Inclusivity(false, true))

julia> df1 = DataFrame(; time=he, data=1:12)
12×2 DataFrames.DataFrame
│ Row │ time              │ data │
├─────┼───────────────────┼──────┤
│ 1   │ (2016-11-16 HE01] │ 1    │
│ 2   │ (2016-11-16 HE02] │ 2    │
│ 3   │ (2016-11-16 HE03] │ 3    │
│ 4   │ (2016-11-16 HE04] │ 4    │
│ 5   │ (2016-11-16 HE05] │ 5    │
│ 6   │ (2016-11-16 HE06] │ 6    │
│ 7   │ (2016-11-16 HE07] │ 7    │
│ 8   │ (2016-11-16 HE08] │ 8    │
│ 9   │ (2016-11-16 HE09] │ 9    │
│ 10  │ (2016-11-16 HE10] │ 10   │
│ 11  │ (2016-11-16 HE11] │ 11   │
│ 12  │ (2016-11-16 HE12] │ 12   │

julia> df2 = DataFrame(; time=Interval.(he), data=1:12)
12×2 DataFrames.DataFrame
│ Row │ time                                         │ data │
├─────┼──────────────────────────────────────────────┼──────┤
│ 1   │ (2016-11-16T00:00:00 .. 2016-11-16T01:00:00] │ 1    │
│ 2   │ (2016-11-16T01:00:00 .. 2016-11-16T02:00:00] │ 2    │
│ 3   │ (2016-11-16T02:00:00 .. 2016-11-16T03:00:00] │ 3    │
│ 4   │ (2016-11-16T03:00:00 .. 2016-11-16T04:00:00] │ 4    │
│ 5   │ (2016-11-16T04:00:00 .. 2016-11-16T05:00:00] │ 5    │
│ 6   │ (2016-11-16T05:00:00 .. 2016-11-16T06:00:00] │ 6    │
│ 7   │ (2016-11-16T06:00:00 .. 2016-11-16T07:00:00] │ 7    │
│ 8   │ (2016-11-16T07:00:00 .. 2016-11-16T08:00:00] │ 8    │
│ 9   │ (2016-11-16T08:00:00 .. 2016-11-16T09:00:00] │ 9    │
│ 10  │ (2016-11-16T09:00:00 .. 2016-11-16T10:00:00] │ 10   │
│ 11  │ (2016-11-16T10:00:00 .. 2016-11-16T11:00:00] │ 11   │
│ 12  │ (2016-11-16T11:00:00 .. 2016-11-16T12:00:00] │ 12   │

julia> df1 == df2
true
```

However, the fact that `join` uses hashing to determine equality can cause problems:

```julia
julia> df3 = DataFrame(; time=he, tag='a':'l')
12×2 DataFrames.DataFrame
│ Row │ time              │ tag │
├─────┼───────────────────┼─────┤
│ 1   │ (2016-11-16 HE01] │ 'a' │
│ 2   │ (2016-11-16 HE02] │ 'b' │
│ 3   │ (2016-11-16 HE03] │ 'c' │
│ 4   │ (2016-11-16 HE04] │ 'd' │
│ 5   │ (2016-11-16 HE05] │ 'e' │
│ 6   │ (2016-11-16 HE06] │ 'f' │
│ 7   │ (2016-11-16 HE07] │ 'g' │
│ 8   │ (2016-11-16 HE08] │ 'h' │
│ 9   │ (2016-11-16 HE09] │ 'i' │
│ 10  │ (2016-11-16 HE10] │ 'j' │
│ 11  │ (2016-11-16 HE11] │ 'k' │
│ 12  │ (2016-11-16 HE12] │ 'l' │

julia> join(df1, df3; on=:time)
12×3 DataFrames.DataFrame
│ Row │ time              │ data │ tag │
├─────┼───────────────────┼──────┼─────┤
│ 1   │ (2016-11-16 HE01] │ 1    │ 'a' │
│ 2   │ (2016-11-16 HE02] │ 2    │ 'b' │
│ 3   │ (2016-11-16 HE03] │ 3    │ 'c' │
│ 4   │ (2016-11-16 HE04] │ 4    │ 'd' │
│ 5   │ (2016-11-16 HE05] │ 5    │ 'e' │
│ 6   │ (2016-11-16 HE06] │ 6    │ 'f' │
│ 7   │ (2016-11-16 HE07] │ 7    │ 'g' │
│ 8   │ (2016-11-16 HE08] │ 8    │ 'h' │
│ 9   │ (2016-11-16 HE09] │ 9    │ 'i' │
│ 10  │ (2016-11-16 HE10] │ 10   │ 'j' │
│ 11  │ (2016-11-16 HE11] │ 11   │ 'k' │
│ 12  │ (2016-11-16 HE12] │ 12   │ 'l' │

julia> join(df2, df3; on=:time)
0×3 DataFrames.DataFrame

```

When `join`ing two `DataFrame`s on a column that contains a mix of `AbstractInterval`
types, it is best to explicitly convert `AnchoredInterval`s to `Interval`s:

```julia
julia> df3[:time] = Interval.(df3[:time])
12-element Array{Intervals.Interval{DateTime},1}:
 (2016-11-16T00:00:00 .. 2016-11-16T01:00:00]
 (2016-11-16T01:00:00 .. 2016-11-16T02:00:00]
 (2016-11-16T02:00:00 .. 2016-11-16T03:00:00]
 (2016-11-16T03:00:00 .. 2016-11-16T04:00:00]
 (2016-11-16T04:00:00 .. 2016-11-16T05:00:00]
 (2016-11-16T05:00:00 .. 2016-11-16T06:00:00]
 (2016-11-16T06:00:00 .. 2016-11-16T07:00:00]
 (2016-11-16T07:00:00 .. 2016-11-16T08:00:00]
 (2016-11-16T08:00:00 .. 2016-11-16T09:00:00]
 (2016-11-16T09:00:00 .. 2016-11-16T10:00:00]
 (2016-11-16T10:00:00 .. 2016-11-16T11:00:00]
 (2016-11-16T11:00:00 .. 2016-11-16T12:00:00]

julia> join(df2, df3; on=:time)
12×3 DataFrames.DataFrame
│ Row │ time                                         │ data │ tag │
├─────┼──────────────────────────────────────────────┼──────┼─────┤
│ 1   │ (2016-11-16T00:00:00 .. 2016-11-16T01:00:00] │ 1    │ 'a' │
│ 2   │ (2016-11-16T01:00:00 .. 2016-11-16T02:00:00] │ 2    │ 'b' │
│ 3   │ (2016-11-16T02:00:00 .. 2016-11-16T03:00:00] │ 3    │ 'c' │
│ 4   │ (2016-11-16T03:00:00 .. 2016-11-16T04:00:00] │ 4    │ 'd' │
│ 5   │ (2016-11-16T04:00:00 .. 2016-11-16T05:00:00] │ 5    │ 'e' │
│ 6   │ (2016-11-16T05:00:00 .. 2016-11-16T06:00:00] │ 6    │ 'f' │
│ 7   │ (2016-11-16T06:00:00 .. 2016-11-16T07:00:00] │ 7    │ 'g' │
│ 8   │ (2016-11-16T07:00:00 .. 2016-11-16T08:00:00] │ 8    │ 'h' │
│ 9   │ (2016-11-16T08:00:00 .. 2016-11-16T09:00:00] │ 9    │ 'i' │
│ 10  │ (2016-11-16T09:00:00 .. 2016-11-16T10:00:00] │ 10   │ 'j' │
│ 11  │ (2016-11-16T10:00:00 .. 2016-11-16T11:00:00] │ 11   │ 'k' │
│ 12  │ (2016-11-16T11:00:00 .. 2016-11-16T12:00:00] │ 12   │ 'l' │
```

## API

```@docs
Inclusivity
Inclusivity(::Integer)
Interval
AnchoredInterval
HourEnding
HourBeginning
HE
HB
≪
≫
```
