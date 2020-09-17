# Declare a new `isfinite` function to avoid type piracy. This new function works with
# `Char` and `Period` as well as other types.
isfinite(x) = iszero(x - x)
isfinite(x::Real) = Base.isfinite(x)
