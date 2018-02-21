# PeriodIntervals

This package defines:
* `AbstractInterval`, along with its subtypes:
  * `Interval{T}`, which represents a non-iterable range between two values of type `T`
  * `AnchoredInterval{P, T}`, which represents a non-iterable range defined by a single
    value `anchor::T` and the value type `P` which represents the size of the range
    * `HourEnding`, a type alias for `AnchoredInterval{Hour(-1)}`
    * `HourBeginning`, a type alias for `AnchoredInterval{Hour(1)}`
* `Inclusivity`, which represents whether an `AbstractInterval` is open, half-open, or
  closed

**TODO:** Rename this package, because "PeriodIntervals" no longer fits.

## API

```@docs
Inclusivity
Interval
AnchoredInterval
```
