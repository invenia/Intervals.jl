# PeriodIntervals

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/PeriodIntervals.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/PeriodIntervals.jl/latest)
[![Build Status](https://travis-ci.org/invenia/PeriodIntervals.jl.svg?branch=master)](https://travis-ci.org/invenia/PeriodIntervals.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/invenia/PeriodIntervals.jl?svg=true)](https://ci.appveyor.com/project/invenia/PeriodIntervals-jl)
[![CodeCov](https://codecov.io/gh/invenia/PeriodIntervals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/PeriodIntervals.jl)

This package defines:
* `AbstractInterval`, along with its subtypes:
  * `Interval{T}`, which represents a non-iterable range between two endpoints of type `T`
  * `AnchoredInterval{P, T}`, which represents a non-iterable range defined by a single
    value `anchor::T` and the value type `P` which represents the size of the range
    * `HourEnding`, a type alias for `AnchoredInterval{Hour(-1)}`
    * `HourBeginning`, a type alias for `AnchoredInterval{Hour(1)}`
* `Inclusivity`, which represents whether an `AbstractInterval` is open, half-open, or
  closed

**TODO:** Rename this package, because "PeriodIntervals" no longer fits.
