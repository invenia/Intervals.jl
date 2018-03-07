# Intervals

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Intervals.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/Intervals.jl/latest)
[![Build Status](https://travis-ci.org/invenia/Intervals.jl.svg?branch=master)](https://travis-ci.org/invenia/Intervals.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/invenia/Intervals.jl?svg=true)](https://ci.appveyor.com/project/invenia/Intervals-jl)
[![CodeCov](https://codecov.io/gh/invenia/Intervals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Intervals.jl)

This package defines:
* `AbstractInterval`, along with its subtypes:
  * `Interval{T}`, which represents a non-iterable range between two endpoints of type `T`
  * `AnchoredInterval{P, T}`, which represents a non-iterable range defined by a single
    value `anchor::T` and the value type `P` which represents the size of the range
    * `HourEnding`, a type alias for `AnchoredInterval{Hour(-1)}`
    * `HourBeginning`, a type alias for `AnchoredInterval{Hour(1)}`
    * `HE` and `HB`, pseudoconstructors for `HourEnding` and `HourBeginning` that round the
      anchor up (`HE`) or down (`HB`) to the nearest hour
* `Inclusivity`, which represents whether an `AbstractInterval` is open, half-open, or
  closed
