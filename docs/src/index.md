# Intervals

This package defines:
* `AbstractInterval`, along with its subtypes:
  * `Interval{T}`, which represents a non-iterable range between two endpoints of type `T`
  * `AnchoredInterval{P, T}`, which represents a non-iterable range defined by a single
    value `anchor::T` and the value type `P` which represents the size of the range
    * `HourEnding`, a type alias for `AnchoredInterval{Hour(-1), T}`
    * `HourBeginning`, a type alias for `AnchoredInterval{Hour(1), T}`
* `Inclusivity`, which represents whether an `AbstractInterval` is open, half-open, or
  closed

## API

```@docs
Inclusivity
Inclusivity(::Integer)
Interval
AnchoredInterval
```
