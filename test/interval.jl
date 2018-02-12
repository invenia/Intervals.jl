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

        @test Interval{Date}() ==
            Interval{Date}(Date(0), Date(0), Inclusivity(false, false))
        @test Interval{DateTime}() ==
            Interval{DateTime}(DateTime(0), DateTime(0), Inclusivity(false, false))
        @test Interval{ZonedDateTime}() == Interval{ZonedDateTime}(
            ZonedDateTime(0, tz"UTC"), ZonedDateTime(0, tz"UTC"), Inclusivity(false, false)
        )

        for (a, b, _) in test_values
            @test Interval(a, b) == Interval{typeof(a)}(a, b, Inclusivity(true, true))
            @test Interval(a, b, Inclusivity(true, false)) ==
                Interval{typeof(a)}(a, b, Inclusivity(true, false))
            @test Interval(b, a, Inclusivity(true, false)) ==
                Interval{typeof(a)}(a, b, Inclusivity(false, true))
        end
    end

    @testset "accessors" begin
        for (a, b, _) in test_values
            for i in 0:3
                inc = Inclusivity(i)
                interval = Interval(a, b, inc)

                @test first(interval) == a
                @test last(interval) == b
                @test span(interval) == b - a
                @test inclusivity(interval) == inc
            end
        end

        # DST transition
        firstpoint = ZonedDateTime(2018, 3, 11, 1, tz"America/Winnipeg")
        endpoint = ZonedDateTime(2018, 3, 11, 3, tz"America/Winnipeg")
        interval = Interval(firstpoint, endpoint)
        @test span(interval) == Hour(1)

        firstpoint = ZonedDateTime(2018, 11, 4, 0, tz"America/Winnipeg")
        endpoint = ZonedDateTime(2018, 11, 4, 2, tz"America/Winnipeg")
        interval = Interval(firstpoint, endpoint)
        @test span(interval) == Hour(3)
    end

    @testset "display" begin
        interval = Interval(1, 2, Inclusivity(false, false))
        @test string(interval) == "(1..2)"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == "Interval{$Int}(1, 2, Inclusivity(false, false))"

        interval = Interval('a', 'b', Inclusivity(false, true))
        @test string(interval) == "(a..b]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == "Interval{Char}('a', 'b', Inclusivity(false, true))"

        interval = Interval(Date(2012), Date(2013), Inclusivity(true, false))
        @test string(interval) == "[2012-01-01..2013-01-01)"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "Interval{Date}(2012-01-01, 2013-01-01, Inclusivity(true, false))"

        interval = Interval("a", "b", Inclusivity(true, true))
        @test string(interval) == "[a..b]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "Interval{String}(\"a\", \"b\", Inclusivity(true, true))"
    end

    @testset "equality" begin
        for (a, b, unit) in test_values
            for i in 0:3
                interval = Interval(a, b, Inclusivity(i))
                cp = copy(interval)
                diff_val = Interval(a - unit, b + unit, Inclusivity(i))
                greater_val = Interval(a + unit, b + unit, Inclusivity(i))
                diff_inc = Interval(a, b, Inclusivity(mod(i + 1, 4)))

                @test interval == cp
                @test interval != diff_val
                @test interval != diff_inc

                @test isequal(interval, cp)
                @test !isequal(interval, diff_val)
                @test !isequal(interval, diff_inc)

                @test hash(interval) == hash(cp)
                @test hash(interval) != hash(diff_val)
                @test hash(interval) != hash(diff_inc)

                @test !isless(interval, cp)
                @test !isless(interval, greater_val)    # Still overlap, so not fully less
                @test !isless(greater_val, interval)
                @test !isless(diff_val, interval)
                @test !isless(interval, diff_val)
            end
        end

        @test isless(Interval(2010, 2011), Interval(2012, 2013))
        @test !isless(Interval(2012, 2013), Interval(2010, 2011))

        @test isless(Interval(Date(2010), Date(2011)), Interval(Date(2012), Date(2013)))
        @test !isless(Interval(Date(2012), Date(2013)), Interval(Date(2010), Date(2011)))

        @test !isless(Interval(0, 10), Interval(10, 20))
        @test !isless(Interval(10, 20), Interval(0, 10))

        @test isless(
            Interval(0, 10, Inclusivity(true, false)),
            Interval(10, 20, Inclusivity(false, true)),
        )
        @test !isless(
            Interval(10, 20, Inclusivity(true, false)),
            Interval(0, 10, Inclusivity(false, true)),
        )
    end

    @testset "arithmetic" begin
        for (a, b, unit) in test_values
            for i in 0:3
                interval = Interval(a, b, Inclusivity(i))
                @test interval + unit == Interval(a + unit, b + unit, Inclusivity(i))
                @test unit + interval == Interval(a + unit, b + unit, Inclusivity(i))
                @test interval - unit == Interval(a - unit, b - unit, Inclusivity(i))
                @test_throws MethodError unit - interval
            end
        end

        # DST transition
        firstpoint = ZonedDateTime(2018, 3, 11, 1, tz"America/Winnipeg")
        endpoint = ZonedDateTime(2018, 3, 11, 3, tz"America/Winnipeg")
        interval = Interval(firstpoint, endpoint) + Hour(1)
        @test first(interval) == ZonedDateTime(2018, 3, 11, 3, tz"America/Winnipeg")
        @test last(interval) == ZonedDateTime(2018, 3, 11, 4, tz"America/Winnipeg")

        firstpoint = ZonedDateTime(2018, 11, 4, 0, tz"America/Winnipeg")
        endpoint = ZonedDateTime(2018, 11, 4, 2, tz"America/Winnipeg")
        interval = Interval(firstpoint, endpoint) + Hour(1)
        @test first(interval) == ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 1)
        @test last(interval) == ZonedDateTime(2018, 11, 4, 3, tz"America/Winnipeg")
    end

    @testset "isempty" begin
        for T in [Int32, Int64, Float64, Date, DateTime, ZonedDateTime]
            @test isempty(Interval{T}())
        end

        @test !isempty(Interval(0, 1, Inclusivity(false, false)))
        @test !isempty(Interval(0, 1, Inclusivity(false, true)))
        @test !isempty(Interval(0, 1, Inclusivity(true, false)))
        @test !isempty(Interval(0, 1, Inclusivity(true, true)))

        @test isempty(Interval(0, 0, Inclusivity(false, false)))
        @test isempty(Interval(0, 0, Inclusivity(false, true)))
        @test isempty(Interval(0, 0, Inclusivity(true, false)))
        @test !isempty(Interval(0, 0, Inclusivity(true, true)))

        # DST transition
        @test !isempty(
            Interval(
                ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 1),
                ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 2),
                Inclusivity(false, false),
            )
        )
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

            # But what if their inclusivities are different?
            expected = Interval(1, 10, Inclusivity(false, false))
            @test intersect(
                Interval(1, 10, Inclusivity(true, true)),
                Interval(1, 10, Inclusivity(false, false)),
            ) == expected
            @test intersect(
                Interval(1, 10, Inclusivity(true, false)),
                Interval(1, 10, Inclusivity(false, true)),
            ) == expected
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
end
