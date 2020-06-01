using Intervals: Ending, Beginning, overlaps, contiguous, RightEndpoint, LeftEndpoint

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
    # Visualization:
    #
    # [12]
    #     [45]
    @testset "non-overlapping" begin
        earlier = convert(A, Interval(1, 2, true, true))
        later = convert(B, Interval(4, 5, true, true))

        expected_superset = Interval(1, 5, true, true)
        expected_overlap = Interval{Int}()

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

    # Compare two intervals which "touch" but both intervals do not include that point:
    # Visualization:
    #
    # (123)
    #   (345)
    @testset "touching open/open" begin
        earlier = convert(A, Interval(1, 3, false, false))
        later = convert(B, Interval(3, 5, false, false))

        expected_superset = Interval(1, 5, false, false)
        expected_overlap = Interval{Int}()

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

    # Compare two intervals which "touch" and the later interval includes that point:
    # Visualization:
    #
    # (123)
    #   [345]
    @testset "touching open/closed" begin
        earlier = convert(A, Interval(1, 3, false, false))
        later = convert(B, Interval(3, 5, true, true))

        expected_superset = Interval(1, 5, false, true)
        expected_overlap = Interval{Int}()

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

    # Compare two intervals which "touch" and the earlier interval includes that point:
    # Visualization:
    #
    # [123]
    #   (345)
    @testset "touching closed/open" begin
        earlier = convert(A, Interval(1, 3, true, true))
        later = convert(B, Interval(3, 5, false, false))

        expected_superset = Interval(1, 5, true, false)
        expected_overlap = Interval{Int}()

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

    # Compare two intervals which "touch" and both intervals include that point:
    # Visualization:
    #
    # [123]
    #   [345]
    @testset "touching closed/closed" begin
        earlier = convert(A, Interval(1, 3, true, true))
        later = convert(B, Interval(3, 5, true, true))

        expected_superset = Interval(1, 5, true, true)
        expected_overlap = Interval(3, 3, true, true)

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

    # Compare two intervals which overlap
    # Visualization:
    #
    # [1234]
    #  [2345]
    @testset "overlapping" begin
        earlier = convert(A, Interval(1, 4, true, true))
        later = convert(B, Interval(2, 5, true, true))

        expected_superset = Interval(1, 5, true, true)
        expected_overlap = Interval(2, 4, true, true)

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

    @testset "equal ()/()" begin
        a = convert(A, Interval(1, 5, false, false))
        b = convert(B, Interval(1, 5, false, false))

        expected_superset = Interval(1, 5, false, false)
        expected_overlap = Interval(1, 5, false, false)

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

    @testset "equal [)/()" begin
        a = convert(A, Interval(1, 5, true, false))
        b = convert(B, Interval(1, 5, false, false))

        expected_superset = Interval(1, 5, true, false)
        expected_overlap = Interval(1, 5, false, false)

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

    @testset "equal (]/()" begin
        a = convert(A, Interval(1, 5, false, true))
        b = convert(B, Interval(1, 5, false, false))

        expected_superset = Interval(1, 5, false, true)
        expected_overlap = Interval(1, 5, false, false)

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

    @testset "equal []/()" begin
        a = convert(A, Interval(1, 5, true, true))
        b = convert(B, Interval(1, 5, false, false))

        expected_superset = Interval(1, 5, true, true)
        expected_overlap = Interval(1, 5, false, false)

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

    @testset "equal [)/[]" begin
        a = convert(A, Interval(1, 5, true, false))
        b = convert(B, Interval(1, 5, true, true))

        expected_superset = Interval(1, 5, true, true)
        expected_overlap = Interval(1, 5, true, false)

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

    @testset "equal (]/[]" begin
        a = convert(A, Interval(1, 5, false, true))
        b = convert(B, Interval(1, 5, true, true))

        expected_superset = Interval(1, 5, true, true)
        expected_overlap = Interval(1, 5, false, true)

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

    @testset "equal []/[]" begin
        a = convert(A, Interval(1, 5, true, true))
        b = convert(B, Interval(1, 5, true, true))

        expected_superset = Interval(1, 5, true, true)
        expected_overlap = Interval(1, 5, true, true)

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
    # Visualization:
    #
    #  [234]
    # [12345]
    @testset "containing" begin
        smaller = convert(A, Interval(2, 4, true, true))
        larger = convert(B, Interval(1, 5, true, true))

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
