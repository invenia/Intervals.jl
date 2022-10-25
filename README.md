# Intervals

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Intervals.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/Intervals.jl/latest)
[![CI](https://github.com/Invenia/Intervals.jl/workflows/CI/badge.svg)](https://github.com/Invenia/Intervals.jl/actions?query=workflow%3ACI)
[![CodeCov](https://codecov.io/gh/invenia/Intervals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Intervals.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This package defines:
* `AbstractInterval`, along with its subtypes:
  * `Interval{T,L,U}`, which represents a non-iterable range between two endpoints of type `T`
    with lower/upper bounds types respectively being `L` and `U`
  * `AnchoredInterval{P,T,L,U}`, which represents a non-iterable range defined by a single
    value `anchor::T` and the value type `P` which represents the span of the range. Lower/upper bounds types are specifed
    by `L` and `U` respectively
    * `HourEnding`, a type alias for `AnchoredInterval{Hour(-1)}`
    * `HourBeginning`, a type alias for `AnchoredInterval{Hour(1)}`
    * `HE` and `HB`, pseudoconstructors for `HourEnding` and `HourBeginning` that round the
      anchor up (`HE`) or down (`HB`) to the nearest hour
* `Bound`, abstract type for all possible bounds type classifications:
  * `Closed`, indicating the endpoint value of the interval is included
  * `Open`, indicating the endpoint value of the interval is not included
  * `Unbounded`, indicating the endpoint value is effectively infinite
