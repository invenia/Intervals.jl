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
            @test a..b == Interval(a, b)
            @test Interval(a, b) == Interval{typeof(a)}(a, b, Inclusivity(true, true))
            @test Interval(a, b, true, false) ==
                Interval{typeof(a)}(a, b, Inclusivity(true, false))
            @test Interval{typeof(a)}(a, b, true, false) ==
                Interval{typeof(a)}(a, b, Inclusivity(true, false))
            @test Interval(a, b, Inclusivity(true, false)) ==
                Interval{typeof(a)}(a, b, Inclusivity(true, false))
            @test Interval(b, a, Inclusivity(true, false)) ==
                Interval{typeof(a)}(a, b, Inclusivity(false, true))
        end
    end

    @testset "conversion" begin
        @test_throws DomainError Int(Interval(10, 10, Inclusivity(false, false)))
        @test_throws DomainError Int(Interval(10, 10, Inclusivity(false, true)))
        @test_throws DomainError Int(Interval(10, 10, Inclusivity(true, false)))
        @test Int(Interval(10, 10, Inclusivity(true, true))) == 10
        @test_throws DomainError Int(Interval(10, 11, Inclusivity(true, true)))

        for T in (Date, DateTime)
            dt = T(2013, 2, 13)
            @test_throws DomainError T(Interval(dt, dt, Inclusivity(false, false)))
            @test_throws DomainError T(Interval(dt, dt, Inclusivity(false, true)))
            @test_throws DomainError T(Interval(dt, dt, Inclusivity(true, false)))
            @test T(Interval(dt, dt, Inclusivity(true, true))) == dt
            @test_throws DomainError T(Interval(dt, dt + Day(1), Inclusivity(true, true)))
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
                @test isclosed(interval) == (first(inc) && last(inc))
                @test isopen(interval) == !(first(inc) || last(inc))
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
        @test string(interval) == "(1 .. 2)"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == "Interval{$Int}(1, 2, Inclusivity(false, false))"

        interval = Interval('a', 'b', Inclusivity(false, true))
        @test string(interval) == "(a .. b]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == "Interval{Char}('a', 'b', Inclusivity(false, true))"

        interval = Interval(Date(2012), Date(2013), Inclusivity(true, false))
        @test string(interval) == "[2012-01-01 .. 2013-01-01)"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "Interval{Date}(2012-01-01, 2013-01-01, Inclusivity(true, false))"

        interval = Interval("a", "b", Inclusivity(true, true))
        @test string(interval) == "[a .. b]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "Interval{String}(\"a\", \"b\", Inclusivity(true, true))"
    end

    @testset "equality" begin
        for (a, b, unit) in test_values
            for i in 0:3
                interval = Interval(a, b, Inclusivity(i))
                cp = copy(interval)
                lesser_val = Interval(a - unit, b + unit, Inclusivity(i))
                greater_val = Interval(a + unit, b + unit, Inclusivity(i))
                diff_inc = Interval(a, b, Inclusivity(mod(i + 1, 4)))

                @test interval == cp
                @test interval != lesser_val
                @test interval != diff_inc

                @test isequal(interval, cp)
                @test !isequal(interval, lesser_val)
                @test !isequal(interval, diff_inc)

                @test hash(interval) == hash(cp)
                @test hash(interval) != hash(lesser_val)
                @test hash(interval) != hash(diff_inc)

                @test !(interval < cp)
                @test !(interval ≪ cp)
                @test !(interval > cp)
                @test !(interval ≫ cp)
                @test interval < greater_val
                @test !(interval ≪ greater_val)     # Still overlap, so not disjoint
                @test !(interval > greater_val)
                @test !(interval ≫ greater_val)
                @test !(greater_val < interval)
                @test !(greater_val ≪ interval)     # Still overlap, so not disjoint
                @test greater_val > interval
                @test !(greater_val ≫ interval)     # Still overlap, so not disjoint
                @test lesser_val < interval
                @test !(lesser_val ≪ interval)
                @test !(lesser_val > interval)
                @test !(lesser_val ≫ interval)
                @test !(interval < lesser_val)
                @test !(interval ≪ lesser_val)
                @test interval > lesser_val
                @test !(interval ≫ lesser_val)      # Still overlap, so not disjoint
            end
        end

        @test Interval(2010, 2011) ≪ Interval(2012, 2013)
        @test !(Interval(2012, 2013) ≪ Interval(2010, 2011))

        @test Interval(Date(2010), Date(2011)) ≪ Interval(Date(2012), Date(2013))
        @test !(Interval(Date(2012), Date(2013)) ≪ Interval(Date(2010), Date(2011)))

        @test !(Interval(0, 10) ≪ Interval(10, 20))
        @test !(Interval(10, 20) ≪ Interval(0, 10))

        @test Interval(0, 10, Inclusivity(true, false)) ≪
            Interval(10, 20, Inclusivity(false, true))
        @test !(
            Interval(10, 20, Inclusivity(true, false)) ≪
            Interval(0, 10, Inclusivity(false, true))
        )

        # Comparisons between Interval{T} and T
        @test 5 < Interval(10, 20)
        @test 5 ≪ Interval(10, 20)
        @test !(5 > Interval(10, 20))
        @test !(5 ≫ Interval(10, 20))

        @test 10 < Interval(10, 20, Inclusivity(false, false))
        @test 10 ≪ Interval(10, 20, Inclusivity(false, false))
        @test !(10 > Interval(10, 20, Inclusivity(false, false)))
        @test !(10 ≫ Interval(10, 20, Inclusivity(false, false)))

        @test !(10 < Interval(10, 20))
        @test !(10 ≪ Interval(10, 20))
        @test !(10 > Interval(10, 20))
        @test !(10 ≫ Interval(10, 20))

        @test !(15 < Interval(10, 20))
        @test !(15 ≪ Interval(10, 20))
        @test 15 > Interval(10, 20)
        @test !(15 ≫ Interval(10, 20))

        @test !(20 < Interval(10, 20))
        @test !(20 ≪ Interval(10, 20))
        @test 20 > Interval(10, 20)
        @test !(20 ≫ Interval(10, 20))

        @test !(20 < Interval(10, 20, Inclusivity(false, false)))
        @test !(20 ≪ Interval(10, 20, Inclusivity(false, false)))
        @test 20 > Interval(10, 20, Inclusivity(false, false))
        @test 20 ≫ Interval(10, 20, Inclusivity(false, false))

        @test !(25 < Interval(10, 20))
        @test !(25 ≪ Interval(10, 20))
        @test 25 > Interval(10, 20)
        @test 25 ≫ Interval(10, 20)

        @test !(Interval(10, 20) < 5)
        @test !(Interval(10, 20, Inclusivity(false, false)) < 10)
        @test !(Interval(10, 20) < 10)
        @test !(Interval(10, 20) ≪ 10)
        @test Interval(10, 20) < 15
        @test !(Interval(10, 20) ≪ 15)
        @test Interval(10, 20) < 20
        @test !(Interval(10, 20) ≪ 20)
        @test Interval(10, 20, Inclusivity(false, false)) < 20
        @test Interval(10, 20) < 25

        @test Date(2013) < Interval(Date(2014), Date(2016))
        @test Date(2014) < Interval(Date(2014), Date(2016), false, false)
        @test !(Date(2014) < Interval(Date(2014), Date(2016)))
        @test !(Date(2014) < Interval(Date(2014), Date(2016)))
        @test !(Date(2015) < Interval(Date(2014), Date(2016)))
        @test !(Date(2016) < Interval(Date(2014), Date(2016)))
        @test !(Date(2016) < Interval(Date(2014), Date(2016), false, false))
        @test !(Date(2017) < Interval(Date(2014), Date(2016)))

        @test !(Interval(Date(2014), Date(2016)) < Date(2013))
        @test !(Interval(Date(2014), Date(2016), false, false) < Date(2014))
        @test !(Interval(Date(2014), Date(2016)) < Date(2014))
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2014))
        @test Interval(Date(2014), Date(2016)) < Date(2015)
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2015))
        @test Interval(Date(2014), Date(2016)) < Date(2016)
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2016))
        @test Interval(Date(2014), Date(2016), false, false) < Date(2016)
        @test Interval(Date(2014), Date(2016), false, false) ≪ Date(2016)
        @test Interval(Date(2014), Date(2016)) < Date(2017)
    end

    @testset "arithmetic" begin
        for (a, b, unit) in test_values
            for i in 0:3
                inc = Inclusivity(i)
                interval = Interval(a, b, inc)
                @test interval + unit == Interval(a + unit, b + unit, inc)
                @test unit + interval == Interval(a + unit, b + unit, inc)
                @test interval - unit == Interval(a - unit, b - unit, inc)

                if a isa Number
                    @test -interval == Interval(-b, -a, last(inc), first(inc))
                    @test unit - interval == Interval(unit-b, unit-a, last(inc), first(inc))
                else
                    @test_throws MethodError -interval
                    @test_throws MethodError unit - interval
                end
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

    @testset "issubset" begin
        @test 0..10 ⊆ 0..10
        @test 0..10 ⊇ 0..10
        @test Interval(0, 10, false, false) ⊆ 0..10
        @test Interval(0, 10, false, false) ⊉ 0..10
        @test 0..10 ⊈ Interval(0, 10, false, false)
        @test 0..10 ⊇ Interval(0, 10, false, false)
        @test 1..9 ⊆ 0..10
        @test 1..9 ⊉ 0..10
        @test 0..10 ⊈ 1..9
        @test 0..10 ⊇ 1..9
        @test 1..11 ⊈ 0..10
        @test 1..11 ⊉ 0..10
        @test -1..9 ⊈ 0..10
        @test -1..9 ⊉ 0..10
        @test 20..30 ⊈ 0..10
        @test 20..30 ⊉ 0..10
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

    @testset "astimezone" begin
        zdt1 = ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg")
        zdt2 = ZonedDateTime(2016, 8, 11, 21, tz"America/Winnipeg")

        for inclusivity in Inclusivity.(0:3)
            for tz in (tz"America/Winnipeg", tz"America/Regina", tz"UTC")
                @test isequal(
                    astimezone(Interval(zdt1, zdt2, inclusivity), tz),
                    Interval(astimezone(zdt1, tz), astimezone(zdt2, tz), inclusivity),
                )
            end
        end
    end
end
