struct Direction{T} end
const Left = Direction{:Left}()
const Right = Direction{:Right}()

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

function Base.isless(a::LeftEndpoint{T}, b::LeftEndpoint{T}) where T
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && a.included && !b.included)
end

function Base.isless(a::RightEndpoint{T}, b::RightEndpoint{T}) where T
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !a.included && b.included)
end

function Base.isless(a::RightEndpoint{T}, b::LeftEndpoint{T}) where T
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !(a.included && b.included))
end

function Base.isless(a::LeftEndpoint{T}, b::RightEndpoint{T}) where T
    a.endpoint < b.endpoint
end

function Base.isless(a::T, b::LeftEndpoint{T}) where T
    a < b.endpoint || (a == b.endpoint && !b.included)
end

function Base.isless(a::T, b::RightEndpoint{T}) where T
    a < b.endpoint
end

function Base.isless(a::LeftEndpoint{T}, b::T) where T
    a.endpoint < b
end

function Base.isless(a::RightEndpoint{T}, b::T) where T
    a.endpoint < b || (a.endpoint == b && !a.included)
end
