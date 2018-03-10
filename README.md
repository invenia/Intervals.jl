# Intervals

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Intervals.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/Intervals.jl/latest)
[![Build Status](https://travis-ci.org/invenia/Intervals.jl.svg?branch=master)](https://travis-ci.org/invenia/Intervals.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/invenia/Intervals.jl?svg=true)](https://ci.appveyor.com/project/invenia/Intervals-jl)
[![CodeCov](https://codecov.io/gh/invenia/Intervals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Intervals.jl)

This package defines:
* `AbstractInterval`, along with its subtypes:
  * `Interval{T}`, which represents a non-iterable range between two endpoints of type `T`
  * `AnchoredInterval{T, S, E}`, which represents a non-iterable range defined by a single
    value `anchor::T` and `span::S` which represents the size of the range. The type
    parameter `E` is an instance of `Direction` and indicate whether the anchor is a
    left-endpoint (`Beginning`) or a right-endpoing (`Ending`).
    * `IntervalEnding`, a type alias for `AnchoredInterval{T, S, Ending}`
    * `IntervalBeginning`, a type alias for `AnchoredInterval{T, S, Beginning}`
    * `HourEnding`, a type alias for `IntervalEnding{T, Hour}`
    * `HourBeginning`, a type alias for `IntervalBeginning{T, Hour}`
    * `HE` and `HB`, pseudoconstructors for `HourEnding` and `HourBeginning` that round the
      anchor up (`HE`) or down (`HB`) to the nearest hour
* `Inclusivity`, which represents whether an `AbstractInterval` is open, half-open, or
  closed
