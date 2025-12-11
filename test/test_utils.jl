# The serialization header can change between Julia versions. When the header does change
# then we can expect the "legacy deserialization" testset to fail and we'll need to
# conditionally set the value of the header here.
const SERIALIZED_HEADER = "7JL\n\x04\0\0"  # Header for Julia 1.5+

# Declare a new `isnan` and `isinf` functions to avoid type piracy. These new function work
# with `Char` and `Period` types as well as other types.
# Note: A generic `isfinite` is declared in Intervals.
isnan(x) = (x != x)::Bool
isnan(x::Real) = Base.isnan(x)

isinf(x) = !isnan(x) && !isfinite(x)
isinf(x::Real) = Base.isinf(x)

# Suppress deprecation warnings for tests validating the deprecated behaviour

union(x::AbstractVector{<:AbstractInterval}) = @test_deprecated Base.union(x)
union(args...) = Base.union(args...)

union!(x::AbstractVector{<:AbstractInterval}) = @test_deprecated Base.union!(x)
union!(args...) = Base.union!(args...)

superset(x::AbstractVector{<:AbstractInterval}) = @test_deprecated Intervals.superset(x)
superset(args...) = Intervals.superset(args...)
