using Base: @deprecate, depwarn
import Dates: Date, DateTime

# BEGIN Intervals 2.X.Y deprecations

import Base: first, last
@deprecate LeftEndpoint(args...) LowerEndpoint(args...)
@deprecate RightEndpoint(args...) UpperEndpoint(args...)
@deprecate first(x::AbstractInterval) lowerbound(x)
@deprecate last(x::AbstractInterval) upperbound(x)

# END Intervals 2.X.Y deprecations
