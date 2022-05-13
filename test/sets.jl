using Intervals
using InvertedIndices
using Random
using StableRNGs

@testset "Set operations" begin
    area(x::Interval) = last(x) - first(x)
    # note: `mapreduce` fails here for empty vectors
    area(x::AbstractVector{<:AbstractInterval{T}}) where T = mapreduce(area, +, x, init=zero(T))
    area(x) = isempty(x) ? 0 : error("Undefined area for object of type $(typeof(x))")
    myunion(x::Interval) = x
    myunion(x::AbstractVector{<:Interval}) = union(x)

    rand_bound_type(rng) = rand(rng, (Closed, Open))

    function testsets(a, b)
        @test area(a ∪ b) ≤ area(myunion(a)) + area(myunion(b))
        @test area(setdiff(a, b)) ≤ area(myunion(a))
        @test area(a ∩ b) + area(symdiff(a, b)) == area(union(a,b))
        @test a ⊆ (a ∪ b)
        @test !issetequal(a, setdiff(a, b))
        @test issetequal(a, a)
        @test isdisjoint(setdiff(a, b), b)
        @test !isdisjoint(a, a)
        
        intersections = find_intersections(a, b)
        a, b = vcat(a), vcat(b)  # Always make `a` / `b` vectors

        # verify that all indices returned in `find_intersections` correspond to sets
        # in b that overlap with the given set in a
        @test all(enumerate(intersections)) do (i, x)
            isempty(x) || !isempty(intersect(a[i], b[x]))
        end

        # verify that all indices not returned in `find_intersections` correspond to
        # sets in b that do not overlap with the given set in akk
        @test all(enumerate(intersections)) do (i, x)
            isempty(intersect(a[i], b[Not(x)]))
        end
    end

    # verify empty interval set
    @test isempty(union(Interval[]))
    
    # a few taylored interval sets
    a = [Interval(i, i + 3) for i in 1:5:15]
    b = a .+ (1:2:5)
    @test all(first.(a) .∈ a)
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    # verify that `last` need not be ordered
    intervals = [Interval(0, 5), Interval(0, 3)]
    @test superset(union(intervals)) == Interval(0, 5)

    # try out some more involved (random) intervals
    rng = StableRNG(2020_10_21)
    n = 25
    starts = rand(rng, 1:100_000, n)
    ends = starts .+ rand(rng, 1:10_000, n)
    offsets = round.(Int, (ends .- starts) .* (2 .* rand(rng, n) .- 1))

    a = Interval.(starts, ends)
    b = Interval.(starts .+ offsets, ends .+ offsets)
    @test all(first.(a) .∈ a)
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    a = Interval{rand_bound_type(rng), rand_bound_type(rng)}.(starts, ends)
    b = Interval{rand_bound_type(rng), rand_bound_type(rng)}.(starts .+ offsets, ends .+ offsets)
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    a = Interval{Closed, Open}.(starts, ends)
    b = Interval{Closed, Open}.(starts .+ offsets, ends .+ offsets)
    @test Intervals.endpoint_tracking(a, b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a[1], b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a, b[1]) isa Intervals.TrackStatically
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    a = Interval{Open, Closed}.(starts, ends)
    b = Interval{Open, Closed}.(starts .+ offsets, ends .+ offsets)
    @test Intervals.endpoint_tracking(a, b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a[1], b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a, b[1]) isa Intervals.TrackStatically
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    randint(x::Interval) = Interval{rand_bound_type(rng), rand_bound_type(rng)}(first(x), last(x))
    leftint(x::Interval) = Interval{Closed, Open}(first(x), last(x))
    rightint(x::Interval) = Interval{Open, Closed}(first(x), last(x))

    a = Interval{Closed, Open}.(starts, ends)
    b = Interval{Closed, Open}.(starts .+ offsets, ends .+ offsets)
    testsets(a, randint.(b))
    testsets(a[1], randint.(b))
    testsets(a, leftint(b[1]))
    testsets(a, rightint.(b))
    testsets(a[1], rightint.(b))
    testsets(a, rightint(b[1]))
end
