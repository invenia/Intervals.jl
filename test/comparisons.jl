using Intervals: Beginning, Ending, LowerEndpoint, UpperEndpoint, contiguous, overlaps,
    isbounded, isunbounded

function unique_paired_permutation(v::Vector{T}) where T
    results = Tuple{T, T}[]
    for (i, j) in unique(sort([x, y]) for x in eachindex(v), y in eachindex(v))
        push!(results, (v[i], v[j]))
    end
    return results
end

const INTERVAL_TYPES = [Interval, AnchoredInterval{Ending}, AnchoredInterval{Beginning}]

# Defines what conversions are possible. Tests for invalid conversions will be skipped.
viable_convert(::Type{Interval}, interval::AbstractInterval) = true

function viable_convert(::Type{AnchoredInterval{Beginning}}, interval::AbstractInterval)
    return isbounded(interval) && isfinite(lowerbound(interval))
end

function viable_convert(::Type{AnchoredInterval{Ending}}, interval::AbstractInterval)
    return isbounded(interval) && isfinite(upperbound(interval))
end

@testset "comparisons: $A vs. $B" for (A, B) in unique_paired_permutation(INTERVAL_TYPES)

    # Compare two intervals which are non-overlapping:
    # Visualization of the finite case:
    #
    # [12]
    #     [45]
    @testset "non-overlapping" begin
        test_intervals = product(
            [
                Interval{Closed, Closed}(1, 2),
                Interval{Closed, Closed}(-Inf, 2),
                Interval{Closed, Closed}(-∞, 2),
                Interval{Unbounded,Closed}(nothing, 2),
            ],
            [
                Interval{Closed, Closed}(4, 5),
                Interval{Closed, Closed}(4, Inf),
                Interval{Closed, Closed}(4, ∞),
                Interval{Closed,Unbounded}(4, nothing),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()
            expected_xor = [earlier, later]

            @test earlier != later
            @test !isequal(earlier, later)
            @test !issetequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test isdisjoint(earlier, later)
            @test isdisjoint(later, earlier)

            @test !overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test_throws ArgumentError merge(earlier, later)
            @test superset(IntervalSet([earlier, later])) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(earlier, later)
            @test intersect(earlier, later) == expected_overlap
            @test_throws MethodError setdiff(earlier, later)
            @test_throws MethodError setdiff(later, earlier)
            @test_throws MethodError symdiff(earlier, later)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([earlier, later])
            @test union(IntervalSet([earlier, later])) == IntervalSet([earlier, later])

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(earlier) && isbounded(later)
                @test union([earlier], [later]) == [earlier, later]
                @test union(IntervalSet(earlier), IntervalSet(later)) == IntervalSet([earlier, later])

                @test intersect([earlier], [later]) == []
                @test intersect(IntervalSet(earlier), IntervalSet(later)) == IntervalSet()

                @test setdiff([earlier], [later]) == expected_xor[1:1]
                @test setdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor[1:1])

                @test setdiff([later], [earlier]) == expected_xor[2:2]
                @test setdiff(IntervalSet(later), IntervalSet(earlier)) == IntervalSet(expected_xor[2:2])

                @test symdiff([earlier], [later]) == expected_xor
                @test symdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor)
            end
        end
    end

    # Compare two intervals which "touch" but both intervals do not include that point:
    # Visualization of the finite case:
    #
    # (123)
    #   (345)
    @testset "touching open/open" begin
        test_intervals = product(
            [
                Interval{Open, Open}(1, 3),
                Interval{Open, Open}(-Inf, 3),
                Interval{Open, Open}(-∞, 3),
                Interval{Unbounded,Open}(nothing, 3),
            ],
            [
                Interval{Open, Open}(3, 5),
                Interval{Open, Open}(3, Inf),
                Interval{Open, Open}(3, ∞),
                Interval{Open,Unbounded}(3, nothing),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()
            expected_xor = [earlier, later]

            @test earlier != later
            @test !isequal(earlier, later)
            @test !issetequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test isdisjoint(earlier, later)
            @test isdisjoint(later, earlier)

            @test !overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test_throws ArgumentError merge(earlier, later)
            @test superset([earlier, later]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(earlier, later)
            @test intersect(earlier, later) == expected_overlap
            @test_throws MethodError setdiff(earlier, later)
            @test_throws MethodError setdiff(later, earlier)
            @test_throws MethodError symdiff(earlier, later)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([earlier, later])
            @test union(IntervalSet([earlier, later])) == IntervalSet([earlier, later])

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(earlier) && isbounded(later)
                @test union([earlier], [later]) == [earlier, later]
                @test union(IntervalSet(earlier), IntervalSet(later)) == IntervalSet([earlier, later])

                @test intersect([earlier], [later]) == []
                @test intersect(IntervalSet(earlier), IntervalSet(later)) == IntervalSet()

                @test setdiff([earlier], [later]) == expected_xor[1:1]
                @test setdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor[1:1])

                @test setdiff([later], [earlier]) == expected_xor[2:2]
                @test setdiff(IntervalSet(later), IntervalSet(earlier)) == IntervalSet(expected_xor[2:2])

                @test symdiff([earlier], [later]) == expected_xor
                @test symdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor)
            end
        end
    end

    # Compare two intervals which "touch" and the later interval includes that point:
    # Visualization of the finite case:
    #
    # (123)
    #   [345]
    @testset "touching open/closed" begin
         test_intervals = product(
            [
                Interval{Open, Open}(1, 3),
                Interval{Open, Open}(-Inf, 3),
                Interval{Open, Open}(-∞, 3),
                Interval{Unbounded,Open}(nothing, 3),
            ],
            [
                Interval{Closed, Closed}(3, 5),
                Interval{Closed, Closed}(3, Inf),
                Interval{Closed, Closed}(3, ∞),
                Interval{Closed,Unbounded}(3, nothing),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()
            expected_xor = [earlier, later]

            @test earlier != later
            @test !isequal(earlier, later)
            @test !issetequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test isdisjoint(earlier, later)
            @test isdisjoint(later, earlier)

            @test !overlaps(earlier, later)
            @test contiguous(earlier, later)
            @test merge(earlier, later) == expected_superset
            @test superset([earlier, later]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(earlier, later)
            @test intersect(earlier, later) == expected_overlap
            @test_throws MethodError setdiff(earlier, later)
            @test_throws MethodError setdiff(later, earlier)
            @test_throws MethodError symdiff(earlier, later)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([earlier, later])
            @test union(IntervalSet([earlier, later])) == IntervalSet([expected_superset])

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(earlier) && isbounded(later)
                @test union([earlier], [later]) == expected_xor != [expected_superset]
                @test union(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_superset)

                @test intersect([earlier], [later]) == []
                @test intersect(IntervalSet(earlier), IntervalSet(later)) == IntervalSet()

                @test setdiff([earlier], [later]) == expected_xor[1:1]
                @test setdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor[1:1])

                @test setdiff([later], [earlier]) == expected_xor[2:2]
                @test setdiff(IntervalSet(later), IntervalSet(earlier)) == IntervalSet(expected_xor[2:2])

                # TODO: Sometimes expected_xor would get mutated in this call
                @test symdiff([earlier], [later]) == expected_xor != union(IntervalSet(expected_xor))
                @test symdiff(IntervalSet(earlier), IntervalSet(later)) == union(IntervalSet(expected_xor))
            end
        end
    end


    # Compare two intervals which "touch" and the earlier interval includes that point:
    # Visualization of the finite case:
    #
    # [123]
    #   (345)
    @testset "touching closed/open" begin
        test_intervals = product(
            [
                Interval{Closed, Closed}(1, 3),
                Interval{Closed, Closed}(-Inf, 3),
                Interval{Closed, Closed}(-∞, 3),
                Interval{Unbounded,Closed}(nothing, 3),
            ],
            [
                Interval{Open, Open}(3, 5),
                Interval{Open, Open}(3, Inf),
                Interval{Open, Open}(3, ∞),
                Interval{Open,Unbounded}(3, nothing),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()
            expected_xor = [earlier, later]

            @test earlier != later
            @test !isequal(earlier, later)
            @test !issetequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test isdisjoint(earlier, later)
            @test isdisjoint(later, earlier)

            @test !overlaps(earlier, later)
            @test contiguous(earlier, later)
            @test merge(earlier, later) == expected_superset
            @test superset([earlier, later]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(earlier, later)
            @test intersect(earlier, later) == expected_overlap
            @test_throws MethodError setdiff(earlier, later)
            @test_throws MethodError setdiff(later, earlier)
            @test_throws MethodError symdiff(earlier, later)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([earlier, later])
            @test union(IntervalSet([earlier, later])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(earlier) && isbounded(later)
                @test union([earlier], [later]) == expected_xor != [expected_superset]
                @test union(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_superset)

                @test intersect([earlier], [later]) == []
                @test intersect(IntervalSet(earlier), IntervalSet(later)) == IntervalSet()

                @test setdiff([earlier], [later]) == expected_xor[1:1]
                @test setdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor[1:1])

                @test setdiff([later], [earlier]) == expected_xor[2:2]
                @test setdiff(IntervalSet(later), IntervalSet(earlier)) == IntervalSet(expected_xor[2:2])

                @test symdiff([earlier], [later]) == expected_xor != union(IntervalSet(expected_xor))
                @test symdiff(IntervalSet(earlier), IntervalSet(later)) == union(IntervalSet(expected_xor))
            end
        end
    end

    # Compare two intervals which "touch" and both intervals include that point:
    # Visualization of the finite case:
    #
    # [123]
    #   [345]
    @testset "touching closed/closed" begin
        test_intervals = product(
            [
                Interval{Closed, Closed}(1, 3),
                Interval{Closed, Closed}(-Inf, 3),
                Interval{Closed, Closed}(-∞, 3),
                Interval{Unbounded,Closed}(nothing, 3),
            ],
            [
                Interval{Closed, Closed}(3, 5),
                Interval{Closed, Closed}(3, Inf),
                Interval{Closed, Closed}(3, ∞),
                Interval{Closed,Unbounded}(3, nothing),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(b))
            expected_overlap = Interval{Closed, Closed}(upperbound(a), lowerbound(b))

            L, U = first(bounds_types(a)), last(bounds_types(b))
            expected_xor = [
                Interval{L, Open}(lowerbound(a), lowerbound(b)),
                Interval{Open, U}(upperbound(a), upperbound(b)),
            ]

            @test earlier != later
            @test !isequal(earlier, later)
            @test !issetequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test !(earlier ≪ later)
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test !isdisjoint(earlier, later)
            @test !isdisjoint(later, earlier)

            @test overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test merge(earlier, later) == expected_superset
            @test superset([earlier, later]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(earlier, later)
            @test intersect(earlier, later) == expected_overlap
            @test_throws MethodError setdiff(earlier, later)
            @test_throws MethodError setdiff(later, earlier)
            @test_throws MethodError symdiff(earlier, later)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([earlier, later])
            @test union(IntervalSet([earlier, later])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(earlier) && isbounded(later)
                # NOTE: expected_xor may have different bounds than [earlier, later]
                @test union([earlier], [later]) == [earlier, later] != [expected_superset]
                @test union(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_superset)

                @test intersect([earlier], [later]) == [] != [expected_overlap]
                @test intersect(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_overlap)

                @test setdiff([earlier], [later]) == [earlier] != expected_xor[1:1]
                @test setdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor[1:1])

                @test setdiff([later], [earlier]) == [later] != expected_xor[2:2]
                @test setdiff(IntervalSet(later), IntervalSet(earlier)) == IntervalSet(expected_xor[2:2])

                @test symdiff([earlier], [later]) == [earlier, later]
                @test symdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor)
            end
        end
    end

    # Compare two intervals which overlap
    # Visualization of the finite case:
    #
    # [1234]
    #  [2345]
    @testset "overlapping" begin
        test_intervals = product(
            [
                Interval{Closed, Closed}(1, 4),
                Interval{Closed, Closed}(-Inf, 4),
                Interval{Closed, Closed}(-∞, 4),
                Interval{Unbounded,Closed}(nothing, 4),
            ],
            [
                Interval{Closed, Closed}(2, 5),
                Interval{Closed, Closed}(2, Inf),
                Interval{Closed, Closed}(2, ∞),
                Interval{Closed,Unbounded}(2, nothing),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(b))
            expected_overlap = Interval(LowerEndpoint(b), UpperEndpoint(a))

            L, U = first(bounds_types(a)), last(bounds_types(b))
            expected_xor = [
                Interval{L, Open}(lowerbound(a), lowerbound(b)),
                Interval{Open, U}(upperbound(a), upperbound(b)),
            ]

            @test earlier != later
            @test !isequal(earlier, later)
            @test !issetequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test !(earlier ≪ later)
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test !isdisjoint(earlier, later)
            @test !isdisjoint(later, earlier)

            @test overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test merge(earlier, later) == expected_superset
            @test superset([earlier, later]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(earlier, later)
            @test intersect(earlier, later) == expected_overlap
            @test_throws MethodError setdiff(earlier, later)
            @test_throws MethodError setdiff(later, earlier)
            @test_throws MethodError symdiff(earlier, later)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([earlier, later])
            @test union(IntervalSet([earlier, later])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(earlier) && isbounded(later)
                # NOTE: expected_xor may have different bounds than [earlier, later]
                @test union([earlier], [later]) == [earlier, later] != [expected_superset]
                @test union(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_superset)

                @test intersect([earlier], [later]) == [] != [expected_overlap]
                @test intersect(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_overlap)

                @test setdiff([earlier], [later]) == [earlier] != expected_xor[1:1]
                @test setdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor[1:1])

                @test setdiff([later], [earlier]) == [later] != expected_xor[2:2]
                @test setdiff(IntervalSet(later), IntervalSet(earlier)) == IntervalSet(expected_xor[2:2])

                @test symdiff([earlier], [later]) == [earlier, later] != expected_xor
                @test symdiff(IntervalSet(earlier), IntervalSet(later)) == IntervalSet(expected_xor)
            end
        end
    end

    @testset "equal ()/()" begin
        test_intervals = (
            [
                Interval{Open, Open}(l, u),
                Interval{Open, Open}(l, u),
            ]
            for (l, u) in product((1, -Inf, -∞), (5, Inf, ∞))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_overlap = Interval(LowerEndpoint(b), UpperEndpoint(b))

            @test a == b
            @test isequal(a, b)
            @test issetequal(b, a)
            @test hash(a) == hash(b)

            @test !isless(a, b)
            @test !isless(a, b)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                @test union([a], [b]) == [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == []
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()

                @test setdiff([b], [a]) == []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == []
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()
            end
        end
    end

    @testset "equal [)/()" begin
        test_intervals = (
            [
                Interval{Closed, Open}(l, u),
                Interval{Open, Open}(l, u),
            ]
            for (l, u) in product((1, -Inf, -∞), (5, Inf, ∞))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_overlap = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_xor = [Interval{Closed, Closed}(lowerbound(a), lowerbound(a))]

            @test a != b
            @test !isequal(a, b)
            @test !issetequal(a, b)
            @test hash(a) != hash(b)

            @test isless(a, b)
            @test !isless(b, a)

            @test a < b
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            # TODO: will have to think carefully about the `expected_` variables
            # when we allow for unbounded values
            if isbounded(a) && isbounded(b)
                # NOTE: expected_xor may have different bounds than [a, b]
                @test union([a], [b]) == [a, b] != [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [] != [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != expected_xor[1:1]
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor[1:1])

                @test setdiff([b], [a]) == [b] != []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == [a, b] != expected_xor
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor)
            end
        end
    end

    @testset "equal (]/()" begin
        test_intervals = (
            [
                Interval{Open, Closed}(l, u),
                Interval{Open, Open}(l, u),
            ]
            for (l, u) in product((1, -Inf, -∞), (5, Inf, ∞))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_overlap = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_xor = [Interval{Closed, Closed}(upperbound(a), upperbound(a))]

            @test a != b
            @test !isequal(a, b)
            @test !issetequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            # TODO: will have to think carefully about the `expected_` variables
            # when we allow for unbounded values
            if isbounded(a) && isbounded(b)
                # NOTE: expected_xor may have different bounds than [a, b]
                @test union([a], [b]) == [a, b] != [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [] != [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != expected_xor[1:1]
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor[1:1])

                @test setdiff([b], [a]) == [b] != []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == [a, b] != expected_xor
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor)
            end
        end
    end

    @testset "equal []/()" begin
        test_intervals = (
            [
                Interval{Closed, Closed}(l, u),
                Interval{Open, Open}(l, u),
            ]
            # for (l, u) in product((1, -Inf, -∞), (5, Inf, ∞))
            for (l, u) in product((1,), (5,))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_overlap = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_xor = [
                Interval{Closed, Closed}(lowerbound(a), lowerbound(a)),
                Interval{Closed, Closed}(upperbound(a), upperbound(a)),
            ]

            @test a != b
            @test !isequal(a, b)
            @test !issetequal(a, b)
            @test hash(a) != hash(b)

            @test isless(a, b)
            @test !isless(b, a)

            @test a < b
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            # TODO: will have to think carefully about the `expected_` variables
            # when we allow for unbounded values
            if isbounded(a) && isbounded(b)
                # NOTE: expected_xor may have different bounds than [a, b]
                @test union([a], [b]) == [a, b] != [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [] != [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != expected_xor
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor)

                @test setdiff([b], [a]) == [b] != []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == [a, b] != expected_xor
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor)
            end
        end
    end

    @testset "equal [)/[]" begin
        test_intervals = (
            [
                Interval{Closed, Open}(l, u),
                Interval{Closed, Closed}(l, u),
            ]
            for (l, u) in product((1, -Inf, -∞), (5, Inf, ∞))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_overlap = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_xor = [
                Interval{Closed, Closed}(upperbound(b), upperbound(b)),
            ]

            @test a != b
            @test !isequal(a, b)
            @test !issetequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test !issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                # NOTE: expected_xor may have different bounds than [a, b]
                @test union([a], [b]) == [a, b] != [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [] != [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != []
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()

                @test setdiff([b], [a]) == [b] != expected_xor[1:1]
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet(expected_xor[1:1])

                @test symdiff([a], [b]) == [a, b] != expected_xor
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor)
            end
        end
    end

    @testset "equal (]/[]" begin
        test_intervals = (
            [
                Interval{Open, Closed}(l, u),
                Interval{Closed, Closed}(l, u),
            ]
            for (l, u) in product((1, -Inf, -∞), (5, Inf, ∞))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_overlap = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_xor = [
                Interval{Closed, Closed}(lowerbound(b), lowerbound(b)),
            ]

            @test a != b
            @test !isequal(a, b)
            @test !issetequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test isless(b, a)

            @test !(a < b)
            @test b < a

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test !issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)
            @test intersect([a], [b]) != [expected_overlap]
            @test_broken intersect(IntervalSet([a, b])) == IntervalSet(expected_overlap) # Internal type issue

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                # NOTE: expected_xor may have different bounds than [a, b]
                @test union([a], [b]) == [a, b] != [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [] != [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != []
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()

                @test setdiff([b], [a]) == [b] != expected_xor[1:1]
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet(expected_xor[1:1])

                @test symdiff([a], [b]) == [a, b] != expected_xor
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor)
            end
        end
    end

    @testset "equal []/[]" begin
        test_intervals = (
            [
                Interval{Closed, Closed}(l, u),
                Interval{Closed, Closed}(l, u),
            ]
            for (l, u) in product((1, -Inf, -∞), (5, Inf, ∞))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_overlap = Interval(LowerEndpoint(a), UpperEndpoint(a))

            @test a == b
            @test isequal(a, b)
            @test issetequal(a, b)
            @test hash(a) == hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                @test union([a], [b]) == [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == []
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()

                @test setdiff([b], [a]) == []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == []
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()
            end
        end
    end

    @testset "equal [/(" begin
        test_intervals = (
            [
                Interval{Closed,Unbounded}(l, u),
                Interval{Open,Unbounded}(l, u),
            ]
            for (l, u) in product((1, -Inf, -∞), (nothing,))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_overlap = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_xor = [Interval{Closed, Open}(lowerbound(a), lowerbound(a))]

            @test a != b
            @test !isequal(a, b)
            @test !issetequal(a, b)
            @test hash(a) != hash(b)

            @test isless(a, b)
            @test !isless(b, a)

            @test a < b
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                @test union([a], [b]) == [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != expected_xor[1:1]
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor[1:1])

                @test setdiff([b], [a]) == []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == []
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()
            end
        end
    end

    @testset "equal ]/)" begin
        test_intervals = (
            [
                Interval{Unbounded,Closed}(l, u),
                Interval{Unbounded,Open}(l, u),
            ]
            for (l, u) in product((nothing,), (5, Inf, ∞))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(a), UpperEndpoint(a))
            expected_overlap = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_xor = [Interval{Open, Closed}(upperbound(a), upperbound(a))]

            @test a != b
            @test !isequal(a, b)
            @test !issetequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                @test union([a], [b]) == [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != expected_xor[1:1]
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor[1:1])

                @test setdiff([b], [a]) == []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == []
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()
            end
        end
    end

    @testset "equal unbounded" begin
        test_intervals = (
            [
                Interval{Int,Unbounded,Unbounded}(nothing, nothing),
                Interval{Int,Unbounded,Unbounded}(nothing, nothing),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LowerEndpoint(b), UpperEndpoint(b))
            expected_overlap = Interval(LowerEndpoint(a), UpperEndpoint(a))

            @test a == b
            @test isequal(a, b)
            @test issetequal(a, b)
            @test hash(a) == hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b]) == [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                @test union([a], [b]) == [expected_superset]
                @test union(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == []
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()

                @test setdiff([b], [a]) == []
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

                @test symdiff([a], [b]) == []
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()
            end
        end
    end

    @testset "equal -0.0/0.0" begin
        # Skip tests when we're comparing ending and beginning anchored intervals
        if Set((A, B)) != Set((AnchoredInterval{Ending}, AnchoredInterval{Beginning}))
            a = convert(A, Interval(0.0, -0.0))
            b = convert(B, Interval(-0.0, 0.0))
            expected_superset = Interval(0.0, 0.0)
            expected_overlap = Interval(0.0, 0.0)

            @test a == b
            @test !isequal(a, b)
            @test issetequal(a, b)
            @test hash(a) != hash(b)

            # All other comparison should still work as expected
            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test issubset(b, a)

            @test !isdisjoint(a, b)
            @test !isdisjoint(b, a)

            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test merge(a, b) == expected_superset
            @test superset([a, b]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b])
            @test union([a], [b]) == [a, b] != [expected_superset]
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            @test intersect([a], [b]) == [] != [expected_overlap]
            @test intersect(IntervalSet([a, b])) == IntervalSet(expected_overlap)

            @test setdiff([a], [b]) == [a] != []
            @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()

            @test setdiff([b], [a]) == [b] != []
            @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet()

            @test symdiff([a], [b]) == [a, b] != []
            @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()
        end
    end

    # Compare two intervals where the lowerbound interval is contained by the second
    # Visualization of the finite case:
    #
    #  [234]
    # [12345]
    @testset "containing" begin
        test_intervals = product(
            [
                Interval{Closed, Closed}(2, 4),
            ],
            [
                Interval{Closed, Closed}(1, 5),
                Interval{Closed, Closed}(1, Inf),
                Interval{Closed, Closed}(1, ∞),
                Interval{Closed, Closed}(-Inf, 5),
                Interval{Closed, Closed}(-∞, 5),
                Interval{Closed, Closed}(-Inf, Inf),
                Interval{Closed, Closed}(-∞, ∞),
                Interval{Closed, Unbounded}(1, nothing),
                Interval{Closed, Unbounded}(-Inf, nothing),
                Interval{Closed, Unbounded}(-∞, nothing),
                Interval{Unbounded, Closed}(nothing, 5),
                Interval{Unbounded, Closed}(nothing, Inf),
                Interval{Unbounded, Closed}(nothing, ∞),
                Interval{Unbounded, Unbounded}(nothing, nothing),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            smaller = convert(A, a)
            larger = convert(B, b)
            expected_superset = Interval(larger)
            expected_overlap = Interval(smaller)

            L, U = bounds_types(larger)
            expected_xor = [
                Interval{L, Open}(lowerbound(larger), lowerbound(smaller)),
                Interval{Open, U}(upperbound(smaller), upperbound(larger)),
            ]

            @test smaller != larger
            @test !isequal(smaller, larger)
            @test !issetequal(smaller, larger)
            @test hash(smaller) != hash(larger)

            @test !isless(smaller, larger)
            @test isless(larger, smaller)

            @test !(smaller < larger)
            @test larger < smaller

            @test !(smaller ≪ larger)
            @test !(larger ≪ smaller)

            @test issubset(smaller, larger)
            @test !issubset(larger, smaller)

            @test !isdisjoint(smaller, larger)
            @test !isdisjoint(larger, smaller)

            @test overlaps(smaller, larger)
            @test !contiguous(smaller, larger)
            @test merge(a, b) == expected_superset
            @test superset([smaller, larger]) == expected_superset

            # Intervals acting as sets. Functions should return a single interval
            @test_throws MethodError union(a, b)
            @test intersect(a, b) == expected_overlap
            @test_throws MethodError setdiff(a, b)
            @test_throws MethodError setdiff(b, a)
            @test_throws MethodError symdiff(a, b)

            # Using a vector of intervals as sets
            @test_throws ArgumentError union([a, b])
            @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

            # TODO: These functions should be compatible with unbounded intervals
            if isbounded(a) && isbounded(b)
                # NOTE: expected_xor may have different bounds than [a, b]
                @test union([a], [b]) == [a, b] != [expected_superset]
                @test union(IntervalSet([a, b])) == IntervalSet(expected_superset)

                @test intersect([a], [b]) == [] != [expected_overlap]
                @test intersect(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_overlap)

                @test setdiff([a], [b]) == [a] != []
                @test setdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet()

                @test setdiff([b], [a]) == [b] != expected_xor[1:2]
                @test setdiff(IntervalSet(b), IntervalSet(a)) == IntervalSet(expected_xor[1:2])

                @test symdiff([a], [b]) == [a, b] != expected_xor
                @test symdiff(IntervalSet(a), IntervalSet(b)) == IntervalSet(expected_xor)
            end
        end
    end
end
