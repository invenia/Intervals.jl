using Intervals
using InvertedIndices
using Random
using StableRNGs

using Intervals: TrackEachEndpoint, TrackLeftOpen, TrackRightOpen, endpoint_tracking,
    find_intersections

@testset "Endpoint Tracking" begin
    @test endpoint_tracking(
        Interval{Int, Open, Closed},
        Interval{Float64, Open, Closed},
    ) == TrackLeftOpen{Float64}()

    @test endpoint_tracking(
        Interval{Int, Closed, Open},
        Interval{Float64, Closed, Open},
    ) == TrackRightOpen{Float64}()

    # Fallback tracking for all other bound combinations
    @test endpoint_tracking(
        Interval{Int, Closed, Closed},
        Interval{Float64, Closed, Closed},
    ) == TrackEachEndpoint()
end

@testset "Set operations" begin
    area(x::Interval) = last(x) - first(x)
    # note: `mapreduce` fails here for empty vectors
    area(x::AbstractVector{<:AbstractInterval{T}}) where T = mapreduce(area, +, x, init=zero(T))
    area(x::IntervalSet) = area(x.items)
    area(x) = isempty(x) ? 0 : error("Undefined area for object of type $(typeof(x))")
    myunion(x::Interval) = x
    myunion(x::AbstractVector{<:Interval}) = union(x)
    myunion(x::IntervalSet) = union(x)

    rand_bound_type(rng) = rand(rng, (Closed, Open))

    # verify case where we interpret array as a set of elements (rather than an
    # interval-bound point set)
    @test intersect([1..2, 2..3, 3..4, 4..5], [2..3, 3..4]) == [2..3, 3..4]

    # verify that elements are in / subsets of interval sets
    @test 2 ∈ IntervalSet([1..3, 5..10])
    @test 0 ∉ IntervalSet([1..3, 5..10])
    @test 4 ∉ IntervalSet([1..3, 5..10])
    @test 11 ∉ IntervalSet([1..3, 5..10])
    @test issubset(2, IntervalSet([1..3, 5..10]))
    @test !issubset(0, IntervalSet([1..3, 5..10]))
    @test !issubset(4, IntervalSet([1..3, 5..10]))
    @test !issubset(11, IntervalSet([1..3, 5..10]))
    @test issubset(2, IntervalSet([1.0 .. 3.0, 5.0 .. 10.0]))
    @test issubset(2 .. 4, IntervalSet([1 .. 5, 7 .. 9]))
    @test !issubset(2 .. 4, IntervalSet([1 ..3, 5 .. 10]))
    @test issubset(IntervalSet([1 .. 3, 5 .. 10]), 1 .. 20)
    @test !issubset(IntervalSet([1 .. 3, 5 .. 10]), 1 .. 9)

    function testsets(a, b)
        @test area(a ∪ b) ≤ area(myunion(a)) + area(myunion(b))
        @test area(setdiff(a, b)) ≤ area(myunion(a))
        @test area(a ∩ b) + area(symdiff(a, b)) == area(union(a,b))
        @test a ⊆ (a ∪ b)
        @test !issetequal(a, setdiff(a, b))
        @test issetequal(a, a)
        @test isdisjoint(setdiff(a, b), b)
        @test !isdisjoint(a, a)

        intersections = find_intersections(convert(Array, a), convert(Array, b))

        # verify that all indices returned in `find_intersections` correspond to sets
        # in b that overlap with the given set in a
        @test all(enumerate(intersections)) do (i, x)
            isempty(x) || !isempty(intersect(IntervalSet(a.items[i]), IntervalSet(b.items[x])))
        end

        # verify that all indices not returned in `find_intersections` correspond to
        # sets in b that do not overlap with the given set in akk
        @test all(enumerate(intersections)) do (i, x)
            isempty(intersect(IntervalSet(a.items[i]), IntervalSet(b.items[Not(x)])))
        end
    end

    # verify empty interval set
    @test isempty(union(Interval[]))

    # a few taylored interval sets
    a = IntervalSet([Interval(i, i + 3) for i in 1:5:15])
    b = IntervalSet(a.items .+ (1:2:5))
    @test all(x -> first(x) ∈ a, a.items)
    testsets(a, b)
    testsets(IntervalSet(a.items[1]), b)
    testsets(a, IntervalSet(b.items[1]))

    # verify that `last` need not be ordered
    intervals = IntervalSet([Interval(0, 5), Interval(0, 3)])
    @test superset(union(intervals)) == Interval(0, 5)

    # try out some more involved (random) intervals
    rng = StableRNG(2020_10_21)
    n = 25
    starts = rand(rng, 1:100_000, n)
    ends = starts .+ rand(rng, 1:10_000, n)
    offsets = round.(Int, (ends .- starts) .* (2 .* rand(rng, n) .- 1))

    a = IntervalSet(Interval.(starts, ends))
    b = IntervalSet(Interval.(starts .+ offsets, ends .+ offsets))
    @test all(x -> first(x) ∈ a, a.items)
    testsets(a, b)
    testsets(IntervalSet(first(a.items)), b)
    testsets(a, IntervalSet(first(b.items)))

    a = IntervalSet(Interval{rand_bound_type(rng), rand_bound_type(rng)}.(starts, ends))
    b = IntervalSet(Interval{rand_bound_type(rng), rand_bound_type(rng)}.(starts .+ offsets, ends .+ offsets))
    testsets(a, b)
    testsets(IntervalSet(first(a.items)), b)
    testsets(a, IntervalSet(first(b.items)))

    a = IntervalSet(Interval{Closed, Open}.(starts, ends))
    b = IntervalSet(Interval{Closed, Open}.(starts .+ offsets, ends .+ offsets))
    @test Intervals.endpoint_tracking(a, b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(IntervalSet(first(a.items)), b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a, IntervalSet(first(b.items))) isa Intervals.TrackStatically
    testsets(a, b)
    testsets(IntervalSet(first(a.items)), b)
    testsets(a, IntervalSet(first(b.items)))

    a = IntervalSet(Interval{Open, Closed}.(starts, ends))
    b = IntervalSet(Interval{Open, Closed}.(starts .+ offsets, ends .+ offsets))
    @test Intervals.endpoint_tracking(a, b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(IntervalSet(first(a.items)), b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a, IntervalSet(first(b.items))) isa Intervals.TrackStatically
    testsets(a, b)
    testsets(IntervalSet(first(a.items)), b)
    testsets(a, IntervalSet(first(b.items)))

    randint(x::Interval) = Interval{rand_bound_type(rng), rand_bound_type(rng)}(first(x), last(x))
    leftint(x::Interval) = Interval{Closed, Open}(first(x), last(x))
    rightint(x::Interval) = Interval{Open, Closed}(first(x), last(x))

    a = IntervalSet(Interval{Closed, Open}.(starts, ends))
    b = IntervalSet(Interval{Closed, Open}.(starts .+ offsets, ends .+ offsets))
    testsets(a, IntervalSet(randint.(b.items)))
    testsets(IntervalSet(first(a.items)), IntervalSet(randint.(b.items)))
    testsets(a, IntervalSet(leftint.(first(b.items))))
    testsets(a, IntervalSet(rightint.(b.items)))
    testsets(IntervalSet(first(a.items)), IntervalSet(rightint.(b.items)))
    testsets(a, IntervalSet(rightint.(first(b.items))))
end
