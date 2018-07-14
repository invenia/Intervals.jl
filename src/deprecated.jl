using Base: @deprecate

# BEGIN Intervals 0.1 deprecations

@deprecate less_than_disjoint(a, b) isless_disjoint(a, b) true
@deprecate greater_than_disjoint(a, b) isless_disjoint(b, a) true

# END Intervals 0.1 deprecations
