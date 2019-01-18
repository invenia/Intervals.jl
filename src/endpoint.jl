struct Direction{T} end

const Left = Direction{:Left}()
const Right = Direction{:Right}()

const Beginning = Left
const Ending = Right

struct Endpoint{T, D}
    endpoint::T
    included::Bool

    function Endpoint{T, D}(ep::T, included::Bool) where {T, D}
        @assert D isa Direction
        new{T, D}(ep, included)
    end
end

const LeftEndpoint{T} = Endpoint{T, Left}
const RightEndpoint{T} = Endpoint{T, Right}

LeftEndpoint(ep::T, included::Bool) where T = LeftEndpoint{T}(ep, included)
RightEndpoint(ep::T, included::Bool) where T = RightEndpoint{T}(ep, included)

LeftEndpoint(i::AbstractInterval{T}) where T = LeftEndpoint{T}(first(i), first(inclusivity(i)))
RightEndpoint(i::AbstractInterval{T}) where T = RightEndpoint{T}(last(i), last(inclusivity(i)))

function Base.hash(x::Endpoint{T, D}, h::UInt) where {T, D}
    # Note: we shouldn't need to hash `T` as this is covered by the endpoint field.
    h = hash(:Endpoint, h)
    h = hash(D, h)
    h = hash(x.endpoint, h)
    h = hash(x.included, h)
    return h
end

# https://github.com/JuliaLang/julia/pull/26601
if VERSION >= v"0.7.0-DEV.4743"
    Base.broadcastable(e::Endpoint) = Ref(e)
end

"""
    ==(a::Endpoint, b::Endpoint) -> Bool

Determine if two endpoints are equal. When both endpoints are left or right then the points
and inclusiveness must be the same.

Checking the equality of left-endpoint and a right-endpoint is slightly more difficult. A
left-endpoint and a right-endpoint are only equal when they use the same point and are
both included. Note that left/right endpoints which are both not included are not equal
as the left-endpoint contains values below that point while the right-endpoint only contains
values that are above that point.

Visualizing two contiguous intervals can assist in understanding this logic:

    [x..y][y..z] -> RightEndpoint == LeftEndpoint
    [x..y)[y..z] -> RightEndpoint != LeftEndpoint
    [x..y](y..z] -> RightEndpoint != LeftEndpoint
    [x..y)(y..z] -> RightEndpoint != LeftEndpoint
"""
function Base.:(==)(a::Endpoint, b::Endpoint)
    a.endpoint == b.endpoint && a.included == b.included
end

function Base.:(==)(a::LeftEndpoint, b::RightEndpoint)
    a.endpoint == b.endpoint && a.included && b.included
end

function Base.:(==)(a::RightEndpoint, b::LeftEndpoint)
    b == a
end

function Base.isequal(a::Endpoint, b::Endpoint)
    isequal(a.endpoint, b.endpoint) && isequal(a.included, b.included)
end

function Base.isequal(a::LeftEndpoint, b::RightEndpoint)
    isequal(a.endpoint, b.endpoint) && a.included && b.included
end

function Base.isequal(a::RightEndpoint, b::LeftEndpoint)
    isequal(b, a)
end

function Base.isless(a::LeftEndpoint, b::LeftEndpoint)
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && a.included && !b.included)
end

function Base.isless(a::RightEndpoint, b::RightEndpoint)
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !a.included && b.included)
end

function Base.isless(a::LeftEndpoint, b::RightEndpoint)
    a.endpoint < b.endpoint
end

function Base.isless(a::RightEndpoint, b::LeftEndpoint)
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !(a.included && b.included))
end

# Comparisons between Scalars and Endpoints
Base.:(==)(a, b::Endpoint) = a == b.endpoint && b.included
Base.:(==)(a::Endpoint, b) = b == a

Base.isless(a, b::LeftEndpoint)  = a < b.endpoint || (a == b.endpoint && !b.included)
Base.isless(a, b::RightEndpoint) = a < b.endpoint
Base.isless(a::LeftEndpoint, b)  = a.endpoint < b
Base.isless(a::RightEndpoint, b) = a.endpoint < b || (a.endpoint == b && !a.included)
