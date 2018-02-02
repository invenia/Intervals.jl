using Base.Dates: Day, Millisecond

@testset "Interval" begin
    test_values = [
        (-10, 1000, 1),
        ('a', 'z', 1),
        (Date(2013, 2, 13), Date(2013, 3, 13), Day(1)),
        (DateTime(2016, 8, 11, 0, 30), DateTime(2016, 8, 11, 1), Millisecond(1))
    ]

    @testset "constructor" begin
        for T in [Int32, Int64, Float64]
            @test Interval{T}() == Interval{T}(zero(T), zero(T), Inclusivity(false, false))
        end

        @test Interval{Date}() == Interval{Date}(Date(0),Date(0), Inclusivity(false, false))

        for (a, b, _) in test_values
            @test Interval(a, b) == Interval{typeof(a)}(a, b, Inclusivity(true, true))
            @test Interval(a, b, Inclusivity(true, false)) ==
                Interval{typeof(a)}(a, b, Inclusivity(true, false))
            @test Interval(b, a, Inclusivity(true, false)) ==
                Interval{typeof(a)}(a, b, Inclusivity(false, true))
        end
    end

    @testset "isempty" begin
        @test !isempty(Interval(0, 1, Inclusivity(false, false)))
        @test !isempty(Interval(0, 1, Inclusivity(false, true)))
        @test !isempty(Interval(0, 1, Inclusivity(true, false)))
        @test !isempty(Interval(0, 1, Inclusivity(true, true)))

        @test isempty(Interval(0, 0, Inclusivity(false, false)))
        @test isempty(Interval(0, 0, Inclusivity(false, true)))
        @test isempty(Interval(0, 0, Inclusivity(true, false)))
        @test !isempty(Interval(0, 0, Inclusivity(true, true)))
    end

    @testset "in" begin
        for (a, b, unit) in test_values
            interval = Interval(a, b)
            @test in(a, interval)
            @test in(a + unit, interval)
            @test !in(a - unit, interval)
            @test in(b, interval)
            @test in(b - unit, interval)
            @test !in(b + unit, interval)

            interval = Interval(a, b, Inclusivity(true, false))
            @test in(a, interval)
            @test in(a + unit, interval)
            @test !in(a - unit, interval)
            @test !in(b, interval)
            @test in(b - unit, interval)
            @test !in(b + unit, interval)

            interval = Interval(a, b, Inclusivity(false, true))
            @test !in(a, interval)
            @test in(a + unit, interval)
            @test !in(a - unit, interval)
            @test in(b, interval)
            @test in(b - unit, interval)
            @test !in(b + unit, interval)

            interval = Interval(a, b, Inclusivity(false, false))
            @test !in(a, interval)
            @test in(a + unit, interval)
            @test !in(a - unit, interval)
            @test !in(b, interval)
            @test in(b - unit, interval)
            @test !in(b + unit, interval)
        end
    end

    @testset "intersect" begin
        @testset "overlapping" begin
            a = Interval(-10, 5, Inclusivity(true, true))
            b = Interval(-2, 10, Inclusivity(true, true))
            @test intersect(a, b) == Interval(-2, 5, Inclusivity(true, true))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 5, Inclusivity(true, false))
            b = Interval(-2, 10, Inclusivity(true, true))
            @test intersect(a, b) == Interval(-2, 5, Inclusivity(true, false))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 5, Inclusivity(true, true))
            b = Interval(-2, 10, Inclusivity(false, true))
            @test intersect(a, b) == Interval(-2, 5, Inclusivity(false, true))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 5, Inclusivity(true, false))
            b = Interval(-2, 10, Inclusivity(false, true))
            @test intersect(a, b) == Interval(-2, 5, Inclusivity(false, false))
            @test intersect(b, a) == intersect(a, b)
        end

        @testset "adjacent" begin
            a = Interval(-10, 0, Inclusivity(true, true))
            b = Interval(0, 10, Inclusivity(true, true))
            @test intersect(a, b) == Interval(0, 0, Inclusivity(true, true))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 0, Inclusivity(true, false))
            b = Interval(0, 10, Inclusivity(true, true))
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))

            a = Interval(-10, 0, Inclusivity(true, true))
            b = Interval(0, 10, Inclusivity(false, true))
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))

            a = Interval(-10, 0, Inclusivity(true, false))
            b = Interval(0, 10, Inclusivity(false, true))
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))
        end

        @testset "identical" begin
            for inclusivity in Inclusivity.(0:3)
                x = Interval(1, 10, inclusivity)
                @test intersect(x, x) == x
            end

            x = Interval(0, 0, Inclusivity(false, false))
            @test intersect(x, x) == x
            @test isempty(intersect(x, x))
        end

        @testset "disjoint" begin
            for inclusivity in Inclusivity.(0:3)
                a = Interval(-100, -1, inclusivity)
                b = Interval(1, 100, inclusivity)
                @test isempty(intersect(a, b))
                @test isempty(intersect(b, a))
            end
        end
    end

    @testset "string" begin
        @test string(Interval(1, 2, Inclusivity(false, false))) == "(1, 2)"
        @test string(Interval('a', 'b', Inclusivity(false, true))) == "(a, b]"
        @test string(Interval(Date(2012), Date(2013), Inclusivity(true, false))) ==
            "[2012-01-01, 2013-01-01)"
        @test string(Interval("a", "b", Inclusivity(true, true))) == "[a, b]"
    end
end
