using Intervals
using InvertedIndices
using Random
using StableRNGs

@testset "Set operations" begin
    area(x::Interval) = last(x) - first(x)
    # not `mapreduce` fails here for empty vectors
    area(x::AbstractVector{<:AbstractInterval{T}}) where T = reduce(+, map(area, x), init = zero(T))
    area(x) = isempty(x) ? 0 : error("Undefined area for object of type $(typeof(x))")
    myunion(x::Interval) = x
    myunion(x::AbstractVector{<:Interval}) = union(x)

    function testsets(a, b)
        @test area((a ∪ b)) ≤ area(myunion(a)) + area(myunion(b))
        @test area(setdiff(a, b)) ≤ area(myunion(a))
        @test area((a ∩ b)) + area(symdiff(a, b)) == area(union(a,b))
        @test a ⊆ (a ∪ b)
        @test !issetequal(a, setdiff(a, b))
        @test issetequal(a, a)
        @test isdisjoint(setdiff(a, b), b)
        @test !isdisjoint(a, a)
        
        intersections = find_intersections(a, b)
        a, b = vcat.((a,b))
        # verify that all indices returned in `find_intersections` correspond to sets
        # in b that overlap with the given set in a
        @test all(ix -> isempty(ix[2]) || !isempty(intersect(a[ix[1]], b[ix[2]])), 
                  enumerate(intersections))

        # verify that all indices not returned in `find_intersections` correspond to
        # sets in b that do not overlap with the given set in akk
        @test all(ix -> isempty(intersect(a[ix[1]], b[Not(ix[2])])), 
                  enumerate(intersections))
    end

    # verify empty interval set
    @test isempty(union(Interval[]))
    
    # a few taylored interval sets
    a = [Interval(i, i+3) for i in 1:5:15]
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
    starts = rand(rng, 1:100_000, 25)
    a = Interval.(starts, starts .+ rand(rng, 1:10_000, 25))
    b = a .+ (round.(Int, area.(a) .* (2.0.*rand(rng, length(a)) .- 1.0)))
    @test all(first.(a) .∈ a)
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    randint(x::Interval) = randint(first(x), last(x))
    randint(a,b) = Interval{Int, rand((Closed, Open)), rand((Closed, Open))}(a,b)
    a = randint.(starts, starts .+ rand(rng, 1:10_000, 25))
    b = randint.(a .+ (round.(Int, area.(a) .* (2.0.*rand(rng, length(a)) .- 1.0))))
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    leftint(a,b) = Interval{Int, Closed, Open}(a, b)
    leftint(a::Interval) = Interval{Int, Closed, Open}(first(a), last(a))
    a = leftint.(starts, starts .+ rand(rng, 1:10_000, 25))
    b = leftint.(a .+ (round.(Int, area.(a) .* (2.0.*rand(rng, length(a)) .- 1.0))))
    @test Intervals.endpoint_tracking(a, b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a[1], b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a, b[1]) isa Intervals.TrackStatically
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    rightint(a,b) = Interval{Int, Open, Closed}(a, b)
    rightint(a::Interval) = Interval{Int, Open, Closed}(first(a), last(a))
    a = rightint.(starts, starts .+ rand(rng, 1:10_000, 25))
    b = rightint.(a .+ (round.(Int, area.(a) .* (2.0.*rand(rng, length(a)) .- 1.0))))
    @test Intervals.endpoint_tracking(a, b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a[1], b) isa Intervals.TrackStatically
    @test Intervals.endpoint_tracking(a, b[1]) isa Intervals.TrackStatically
    testsets(a, b)
    testsets(a[1], b)
    testsets(a, b[1])

    a = leftint.(starts, starts .+ rand(rng, 1:10_000, 25))
    b = leftint.(a .+ (round.(Int, area.(a) .* (2.0.*rand(rng, length(a)) .- 1.0))))
    testsets(a, randint.(b))
    testsets(a[1], randint.(b))
    testsets(a, leftint(b[1]))
    testsets(a, rightint.(b))
    testsets(a[1], rightint.(b))
    testsets(a, rightint(b[1]))
end
