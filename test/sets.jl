using Intervals
using InvertedIndices

@testset "Set operations"
    area(x::Interval) = last(x) - first(x)
    area(x::AbstractVector{<:Interval{T}}) where T = reduce(+, map(area, x), init = zero(T))
    myunion(x::Interval) = x
    myunion(x::AbstractVector{<:Interval}) = union(x)

    function testsets(a, b)
        @test area((a ∪ b)) ≤ area(myunion(a)) + area(myunion(b))
        @test area(setdiff(a, b)) ≤ area(myunion(a))
        @test area((a ∩ b)) + area(symdiff(a, b)) ==
            area(union(a,b))
        @test a ⊆ (a ∪ b)
        @test !issetequal(a, setdiff(a, b))
        @test issetequal(a, a)
        @test isdisjoint(setdiff(a, b), b)
        @test !isdisjoint(a, a)
        
        intersections = intersectmap!(a, b)
        @test all((x, i) -> !isempty(intersect(a[i], b[x])), intersections)
        @test all((x, i) -> isempty(intersect(a[i], b[Not(x)])), intersections)
    end

    # verify empty interval set
    @test isempty(union(Interval[]))
    
    translate(x, by) = Interval(first(x) + by, last(x) + by)

    # a few taylored interval sets
    intervals = [Interval(i, i+3) for i in 1:5:15]
    intervals = [intervals; translate.(intervals, 1:2:5)]
    @test all(start.(intervals) .∈ Ref(intervals))
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
    @test all(start.(intervals) .∈ Ref(intervals))
    testsets(intervals[1:25], intervals[26:end])
    testsets(intervals[1], intervals[26:end])
    testsets(intervals[1:25], intervals[26])
end
