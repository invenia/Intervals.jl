# Intervals

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Intervals.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/Intervals.jl/latest)
[![Build Status](https://travis-ci.com/invenia/Intervals.jl.svg?branch=master)](https://travis-ci.com/invenia/Intervals.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/invenia/Intervals.jl?svg=true)](https://ci.appveyor.com/project/invenia/Intervals-jl)
[![CodeCov](https://codecov.io/gh/invenia/Intervals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Intervals.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This package defines:
* `AbstractInterval`, along with its subtypes:
  * `Interval{T,L,R}`, which represents a non-iterable range between two endpoints of type `T`
    with left/right bounds respectively being `L` and `R`
  * `AnchoredInterval{P,T,L,R}`, which represents a non-iterable range defined by a single
    value `anchor::T` and the value type `P` which represents the span of the range. Left/right bounds are specifed
    by `L` and `R` respectively
    * `HourEnding`, a type alias for `AnchoredInterval{Hour(-1)}`
    * `HourBeginning`, a type alias for `AnchoredInterval{Hour(1)}`
    * `HE` and `HB`, pseudoconstructors for `HourEnding` and `HourBeginning` that round the
      anchor up (`HE`) or down (`HB`) to the nearest hour

