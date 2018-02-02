# PeriodIntervals

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/PeriodIntervals.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/PeriodIntervals.jl/latest)
[![Build Status](https://travis-ci.org/invenia/PeriodIntervals.jl.svg?branch=master)](https://travis-ci.org/invenia/PeriodIntervals.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/invenia/PeriodIntervals.jl?svg=true)](https://ci.appveyor.com/project/invenia/PeriodIntervals-jl)
[![CodeCov](https://codecov.io/gh/invenia/PeriodIntervals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/PeriodIntervals.jl)

Defines `AbstractInterval` and its subtypes:
* `Interval{T}`, which represents a non-iterable range between two values of type `T`
* `PeriodBeginning{P, T}`, which represents a non-iterable range of total duration `P`,
  starting at a value of type `T`
* `PeriodEnding{P, T}`, which represents a non-iterable range of total duration `P`, ending
  at a value of type `T`

Also defines `Inclusivity`, which represents whether an `AbstractInterval` is open, closed,
or partially open.
