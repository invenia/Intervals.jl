using Intervals: Beginning, Ending, LeftEndpoint, RightEndpoint, contiguous, overlaps,
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
    return isbounded(interval) && isfinite(first(interval))
end

function viable_convert(::Type{AnchoredInterval{Ending}}, interval::AbstractInterval)
    return isbounded(interval) && isfinite(last(interval))
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
                Interval{Unbounded,Closed}(nothing, 2),
                Interval{Closed, Closed}(-∞, 2),
            ],
            [
                Interval{Closed, Closed}(4, 5),
                Interval{Closed, Closed}(4, Inf),
                Interval{Closed,Unbounded}(4, nothing),
                Interval{Closed, Closed}(4, ∞),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()

            @test earlier != later
            @test !isequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test intersect(earlier, later) == expected_overlap
            @test_throws ArgumentError merge(earlier, later)
            @test union([earlier, later]) == [earlier, later]
            @test !overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test superset([earlier, later]) == expected_superset
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
                Interval{Unbounded,Open}(nothing, 3),
                Interval{Open, Open}(-∞, 3),
            ],
            [
                Interval{Open, Open}(3, 5),
                Interval{Open, Open}(3, Inf),
                Interval{Open,Unbounded}(3, nothing),
                Interval{Open, Open}(3, ∞),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()

            @test earlier != later
            @test !isequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test intersect(earlier, later) == expected_overlap
            @test_throws ArgumentError merge(earlier, later)
            @test union([earlier, later]) == [earlier, later]
            @test !overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test superset([earlier, later]) == expected_superset
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
                Interval{Unbounded,Open}(nothing, 3),
                Interval{Open, Open}(-∞, 3),
            ],
            [
                Interval{Closed, Closed}(3, 5),
                Interval{Closed, Closed}(3, Inf),
                Interval{Closed,Unbounded}(3, nothing),
                Interval{Closed, Closed}(3, ∞),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()

            @test earlier != later
            @test !isequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test intersect(earlier, later) == expected_overlap
            @test merge(earlier, later) == expected_superset
            @test union([earlier, later]) == [expected_superset]
            @test !overlaps(earlier, later)
            @test contiguous(earlier, later)
            @test superset([earlier, later]) == expected_superset
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
                Interval{Unbounded,Closed}(nothing, 3),
                Interval{Closed, Closed}(-∞, 3),
            ],
            [
                Interval{Open, Open}(3, 5),
                Interval{Open, Open}(3, Inf),
                Interval{Open,Unbounded}(3, nothing),
                Interval{Open, Open}(3, ∞),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(b))
            expected_overlap = Interval{promote_type(eltype(a), eltype(b))}()

            @test earlier != later
            @test !isequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test earlier ≪ later
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test intersect(earlier, later) == expected_overlap
            @test merge(earlier, later) == expected_superset
            @test union([earlier, later]) == [expected_superset]
            @test !overlaps(earlier, later)
            @test contiguous(earlier, later)
            @test superset([earlier, later]) == expected_superset
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
                Interval{Unbounded,Closed}(nothing, 3),
                Interval{Closed, Closed}(-∞, 3),
            ],
            [
                Interval{Closed, Closed}(3, 5),
                Interval{Closed, Closed}(3, Inf),
                Interval{Closed,Unbounded}(3, nothing),
                Interval{Closed, Closed}(3, ∞),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(b))
            expected_overlap = Interval{Closed, Closed}(last(a), first(b))

            @test earlier != later
            @test !isequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test !(earlier ≪ later)
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test intersect(earlier, later) == expected_overlap
            @test merge(earlier, later) == expected_superset
            @test union([earlier, later]) == [expected_superset]
            @test overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test superset([earlier, later]) == expected_superset
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
                Interval{Unbounded,Closed}(nothing, 4),
                Interval{Closed, Closed}(-∞, 4),
            ],
            [
                Interval{Closed, Closed}(2, 5),
                Interval{Closed, Closed}(2, Inf),
                Interval{Closed,Unbounded}(2, nothing),
                Interval{Closed, Closed}(2, ∞),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(b))
            expected_overlap = Interval(LeftEndpoint(b), RightEndpoint(a))

            @test earlier != later
            @test !isequal(earlier, later)
            @test hash(earlier) != hash(later)

            @test isless(earlier, later)
            @test !isless(later, earlier)

            @test earlier < later
            @test !(later < earlier)

            @test !(earlier ≪ later)
            @test !(later ≪ earlier)

            @test !issubset(earlier, later)
            @test !issubset(later, earlier)

            @test intersect(earlier, later) == expected_overlap
            @test merge(earlier, later) == expected_superset
            @test union([earlier, later]) == [expected_superset]
            @test overlaps(earlier, later)
            @test !contiguous(earlier, later)
            @test superset([earlier, later]) == expected_superset
        end
    end

    @testset "equal ()/()" begin
        test_intervals = (
            [
                Interval{Open, Open}(l, u),
                Interval{Open, Open}(l, u),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(a))
            expected_overlap = Interval(LeftEndpoint(b), RightEndpoint(b))

            @test a == b
            @test isequal(a, b)
            @test hash(a) == hash(b)

            @test !isless(a, b)
            @test !isless(a, b)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal [)/()" begin
        test_intervals = (
            [
                Interval{Closed, Open}(l, u),
                Interval{Open, Open}(l, u),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(a))
            expected_overlap = Interval(LeftEndpoint(b), RightEndpoint(b))

            @test a != b
            @test !isequal(a, b)
            @test hash(a) != hash(b)

            @test isless(a, b)
            @test !isless(b, a)

            @test a < b
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal (]/()" begin
        test_intervals = (
            [
                Interval{Open, Closed}(l, u),
                Interval{Open, Open}(l, u),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(a))
            expected_overlap = Interval(LeftEndpoint(b), RightEndpoint(b))

            @test a != b
            @test !isequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal []/()" begin
        test_intervals = (
            [
                Interval{Closed, Closed}(l, u),
                Interval{Open, Open}(l, u),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(a))
            expected_overlap = Interval(LeftEndpoint(b), RightEndpoint(b))

            @test a != b
            @test !isequal(a, b)
            @test hash(a) != hash(b)

            @test isless(a, b)
            @test !isless(b, a)

            @test a < b
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal [)/[]" begin
        test_intervals = (
            [
                Interval{Closed, Open}(l, u),
                Interval{Closed, Closed}(l, u),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(b), RightEndpoint(b))
            expected_overlap = Interval(LeftEndpoint(a), RightEndpoint(a))

            @test a != b
            @test !isequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test !issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal (]/[]" begin
        test_intervals = (
            [
                Interval{Open, Closed}(l, u),
                Interval{Closed, Closed}(l, u),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(b), RightEndpoint(b))
            expected_overlap = Interval(LeftEndpoint(a), RightEndpoint(a))

            @test a != b
            @test !isequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test isless(b, a)

            @test !(a < b)
            @test b < a

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test !issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal []/[]" begin
        test_intervals = (
            [
                Interval{Closed, Closed}(l, u),
                Interval{Closed, Closed}(l, u),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(b), RightEndpoint(b))
            expected_overlap = Interval(LeftEndpoint(a), RightEndpoint(a))

            @test a == b
            @test isequal(a, b)
            @test hash(a) == hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal [/(" begin
        test_intervals = (
            [
                Interval{Closed,Unbounded}(l, u),
                Interval{Open,Unbounded}(l, u),
            ]
            for (l, u) in product((1, -Inf), (nothing,))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(a))
            expected_overlap = Interval(LeftEndpoint(b), RightEndpoint(b))

            @test a != b
            @test !isequal(a, b)
            @test hash(a) != hash(b)

            @test isless(a, b)
            @test !isless(b, a)

            @test a < b
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    @testset "equal ]/)" begin
        test_intervals = (
            [
                Interval{Unbounded,Closed}(l, u),
                Interval{Unbounded,Open}(l, u),
            ]
            for (l, u) in product((nothing,), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            a = convert(A, a)
            b = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(a))
            expected_overlap = Interval(LeftEndpoint(b), RightEndpoint(b))

            @test a != b
            @test !isequal(a, b)
            @test hash(a) != hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test !issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
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
            expected_superset = Interval(LeftEndpoint(b), RightEndpoint(b))
            expected_overlap = Interval(LeftEndpoint(a), RightEndpoint(a))

            @test a == b
            @test isequal(a, b)
            @test hash(a) == hash(b)

            @test !isless(a, b)
            @test !isless(b, a)

            @test !(a < b)
            @test !(b < a)

            @test !(a ≪ b)
            @test !(b ≪ a)

            @test issubset(a, b)
            @test issubset(b, a)

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
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

            @test intersect(a, b) == expected_overlap
            @test merge(a, b) == expected_superset
            @test union([a, b]) == [expected_superset]
            @test overlaps(a, b)
            @test !contiguous(a, b)
            @test superset([a, b]) == expected_superset
        end
    end

    # Compare two intervals where the first interval is contained by the second
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
                Interval{Closed, Unbounded}(1, nothing),
                Interval{Closed, Unbounded}(-Inf, nothing),
                Interval{Unbounded, Closed}(nothing, 5),
                Interval{Unbounded, Closed}(nothing, Inf),
                Interval{Unbounded, Unbounded}(nothing, nothing),
                Interval{Closed, Closed}(-∞, ∞),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            viable_convert(A, a) || continue
            viable_convert(B, b) || continue

            smaller = convert(A, a)
            larger = convert(B, b)
            expected_superset = Interval(larger)
            expected_overlap = Interval(smaller)

            @test smaller != larger
            @test !isequal(smaller, larger)
            @test hash(smaller) != hash(larger)

            @test !isless(smaller, larger)
            @test isless(larger, smaller)

            @test !(smaller < larger)
            @test larger < smaller

            @test !(smaller ≪ larger)
            @test !(larger ≪ smaller)

            @test issubset(smaller, larger)
            @test !issubset(larger, smaller)

            @test intersect(smaller, larger) == expected_overlap
            @test merge(smaller, larger) == expected_superset
            @test union([smaller, larger]) == [expected_superset]
            @test overlaps(smaller, larger)
            @test !contiguous(smaller, larger)
            @test superset([smaller, larger]) == expected_superset
        end
    end
end
