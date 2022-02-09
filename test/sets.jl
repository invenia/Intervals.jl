using Intervals
using InvertedIndices
using Random

@testset "Set operations" begin
    area(x::Interval) = last(x) - first(x)
    area(x::AbstractVector{<:AbstractInterval{T}}) where T = reduce(+, map(area, x), init = zero(T))
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
        
        intersections = find_intersections(copy(a), b)
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
    intervals = [Interval(i, i+3) for i in 1:5:15]
    intervals = [intervals; intervals .+ (1:2:5)]
    @test all(first.(intervals) .∈ intervals)
    testsets(intervals[1:3], intervals[4:end])
    testsets(intervals[1], intervals[4:end])
    testsets(intervals[1:3], intervals[4])

    # verify that `last` need not be ordered
    intervals = [Interval(0, 5), Interval(0, 3)]
    @test superset(union(intervals)) == Interval(0, 5)

    # try out some more involved (random) intervals
    Random.seed!(2020_10_21)
    starts = rand(1:100_000, 25)
    intervals = Interval.(starts, starts .+ rand(1:10_000, 25))
    intervals = [intervals; translate.(intervals, round.(Int, area.(intervals) .*
                                       (2.0.*rand(length(intervals)) .- 1.0)))]
    a, b = intervals[1:25], intervals[26:end]
    @test all(first.(intervals) .∈ intervals)
    testsets(intervals[1:25], intervals[26:end])
    testsets(intervals[1], intervals[26:end])
    testsets(intervals[1:25], intervals[26])

    randint(a,b) = Interval{Int, Intervals.bound_type(rand(Bool)), Intervals.bound_type(rand(Bool))}(a,b)
    randint(a::Interval) = Interval{Int, Intervals.bound_type(rand(Bool)), Intervals.bound_type(rand(Bool))}(first(a), last(a))
    intervals = randint.(starts, starts .+ rand(1:10_000, 25))
    intervals = [intervals; randint.(translate.(intervals, round.(Int, area.(intervals) .*
                                                (2.0.*rand(length(intervals)) .- 1.0))))]
    testsets(intervals[1:25], intervals[26:end])
    testsets(intervals[1], intervals[26:end])
    testsets(intervals[1:25], intervals[26])

    leftint(a,b) = Interval{Int, Closed, Open}(a, b)
    leftint(a::Interval) = Interval{Int, Closed, Open}(first(a), last(a))
    intervals = leftint.(starts, starts .+ rand(1:10_000, 25))
    intervals = [intervals; leftint.(translate.(intervals, round.(Int, area.(intervals) .*
                                                (2.0.*rand(length(intervals)) .- 1.0))))]
    testsets(intervals[1:25], intervals[26:end])
    testsets(intervals[1], intervals[26:end])
    testsets(intervals[1:25], intervals[26])

    rightint(a,b) = Interval{Int, Open, Closed}(a, b)
    rightint(a::Interval) = Interval{Int, Open, Closed}(first(a), last(a))
    intervals = rightint.(starts, starts .+ rand(1:10_000, 25))
    intervals = [intervals; rightint.(translate.(intervals, round.(Int, area.(intervals) .*
                                                (2.0.*rand(length(intervals)) .- 1.0))))]
    testsets(intervals[1:25], intervals[26:end])
    testsets(intervals[1], intervals[26:end])
    testsets(intervals[1:25], intervals[26])

    intervals = leftint.(starts, starts .+ rand(1:10_000, 25))
    intervals = [intervals; leftint.(translate.(intervals, round.(Int, area.(intervals) .*
                                                (2.0.*rand(length(intervals)) .- 1.0))))]
    testsets(intervals[1:25], randint.(intervals[26:end]))
    testsets(intervals[1], randint.(intervals[26:end]))
    testsets(intervals[1:25], leftint(intervals[26]))
    testsets(intervals[1:25], rightint.(intervals[26:end]))
    testsets(intervals[1], rightint.(intervals[26:end]))
    testsets(intervals[1:25], rightint(intervals[26]))
end
