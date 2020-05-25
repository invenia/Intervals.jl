struct Direction{T} end

const Left = Direction{:Left}()
const Right = Direction{:Right}()

const Beginning = Left
const Ending = Right

struct Endpoint{T, D}
    endpoint::Union{T, Nothing}
    included::Bool

    function Endpoint{T, D}(ep::Union{T, Nothing}, included::Bool) where {T, D}
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

Base.broadcastable(e::Endpoint) = Ref(e)

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
    if isnothing(a.endpoint) && isnothing(b.endpoint)
        return false
    end
    return a.endpoint < b.endpoint || (a.endpoint == b.endpoint && a.included && !b.included)
end

function Base.isless(a::RightEndpoint, b::RightEndpoint)
    if isnothing(a.endpoint) && isnothing(b.endpoint)
        return false
    end
    return a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !a.included && b.included)
end

function Base.isless(a::LeftEndpoint, b::RightEndpoint)
    if isnothing(a.endpoint) && isnothing(b.endpoint)
        return false
    end
    return a.endpoint < b.endpoint
end

function Base.isless(a::RightEndpoint, b::LeftEndpoint)
    if isnothing(a.endpoint) || isnothing(b.endpoint)
        return false
    else
        return a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !(a.included && b.included))
    end
end

# Comparisons between Scalars and Endpoints
function Base.:(==)(a, b::Endpoint)
    a == b.endpoint && b.included
end
Base.:(==)(a::Endpoint, b) = b == a

Base.isless(a::Endpoint, b::Endpoint) = isnothing(a) && isnothing(b) ? false : a < b
function Base.isless(a, b::LeftEndpoint)
    # If the left endpoint is unbounded, then there can be no value less than the endpoint
    if isnothing(b.endpoint)
        return false
    else
        return a < b.endpoint || (a == b.endpoint && !b.included)
    end
end
# If the right endpoint is unbounded, then it is always greater than any other value
Base.isless(a, b::RightEndpoint) = isnothing(b.endpoint) ? true : a < b.endpoint
# If the left endpoint is unbounded, then it is always less than any other value
Base.isless(a::LeftEndpoint, b) = isnothing(a.endpoint) ? true : a.endpoint < b
function Base.isless(a::RightEndpoint, b)
    # If the right endpoint is unbounded, then there can be no value greater than the
    # endpoint
    if isnothing(a.endpoint)
        return false
    else
        return a.endpoint < b || (a.endpoint == b && !a.included)
    end
end
