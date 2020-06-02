using Intervals: Ending, Beginning, overlaps, contiguous, RightEndpoint, LeftEndpoint
using Base.Iterators: product

function unique_paired_permutation(v::Vector{T}) where T
    results = Tuple{T, T}[]
    for (i, j) in unique(sort([x, y]) for x in eachindex(v), y in eachindex(v))
        push!(results, (v[i], v[j]))
    end
    return results
end

const INTERVAL_TYPES = [Interval, AnchoredInterval{Ending}, AnchoredInterval{Beginning}]

@testset "comparisons: $A vs. $B" for (A, B) in unique_paired_permutation(INTERVAL_TYPES)

    # Compare two intervals which are non-overlapping:
    # Visualization of the finite case:
    #
    # [12]
    #     [45]
    @testset "non-overlapping" begin
        test_intervals = product(
            [
                Interval(1, 2, true, true),
                Interval(-Inf, 2, true, true),
            ],
            [
                Interval(4, 5, true, true),
                Interval(4, Inf, true, true),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(1, 3, false, false),
                Interval(-Inf, 3, false, false),
            ],
            [
                Interval(3, 5, false, false),
                Interval(3, Inf, false, false),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(1, 3, false, false),
                Interval(-Inf, 3, false, false),
            ],
            [
                Interval(3, 5, true, true),
                Interval(3, Inf, true, true),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(1, 3, true, true),
                Interval(-Inf, 3, true, true),
            ],
            [
                Interval(3, 5, false, false),
                Interval(3, Inf, false, false),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(1, 3, true, true),
                Interval(-Inf, 3, true, true),
            ],
            [
                Interval(3, 5, true, true),
                Interval(3, Inf, true, true),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

            earlier = convert(A, a)
            later = convert(B, b)
            expected_superset = Interval(LeftEndpoint(a), RightEndpoint(b))
            expected_overlap = Interval(last(a), first(b), true, true)

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
                Interval(1, 4, true, true),
                Interval(-Inf, 4, true, true),
            ],
            [
                Interval(2, 5, true, true),
                Interval(2, Inf, true, true),
            ],
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(l, u, false, false),
                Interval(l, u, false, false),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            A == AnchoredInterval{Ending} && !isfinite(last(a)) && continue
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(l, u, true, false),
                Interval(l, u, false, false),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            A == AnchoredInterval{Ending} && !isfinite(last(a)) && continue
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(l, u, false, true),
                Interval(l, u, false, false),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            A == AnchoredInterval{Ending} && !isfinite(last(a)) && continue
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(l, u, true, true),
                Interval(l, u, false, false),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            A == AnchoredInterval{Ending} && !isfinite(last(a)) && continue
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(l, u, true, false),
                Interval(l, u, true, true),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            A == AnchoredInterval{Ending} && !isfinite(last(a)) && continue
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(l, u, false, true),
                Interval(l, u, true, true),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            A == AnchoredInterval{Ending} && !isfinite(last(a)) && continue
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(l, u, true, true),
                Interval(l, u, true, true),
            ]
            for (l, u) in product((1, -Inf), (5, Inf))
        )

        @testset "$a vs. $b" for (a, b) in test_intervals
            A == AnchoredInterval{Beginning} && !isfinite(first(a)) && continue
            A == AnchoredInterval{Ending} && !isfinite(last(a)) && continue
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
                Interval(2, 4, true, true),
            ],
            [
                Interval(1, 5, true, true),
                Interval(1, Inf, true, true),
                Interval(-Inf, 5, true, true),
                Interval(-Inf, Inf, true, true),
            ],
        )

        @testset "$a vs $b" for (a, b) in test_intervals
            B == AnchoredInterval{Beginning} && !isfinite(first(b)) && continue
            B == AnchoredInterval{Ending} && !isfinite(last(b)) && continue

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
