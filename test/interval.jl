@testset "Interval" begin
    test_values = [
        (-10, 1000, 1),
        (0.0, 1, 0.01),  # Use different types to test promotion
        ('a', 'z', 1),
        (Date(2013, 2, 13), Date(2013, 3, 13), Day(1)),
        (DateTime(2016, 8, 11, 0, 30), DateTime(2016, 8, 11, 1), Millisecond(1)),

        # Infinite endpoints
        (-Inf, 10, 1),
        (10, Inf, 1),
        (-Inf, Inf, 1),
        (-Inf, 1.0, 0.01),
        (0.0, Inf, 0.01),

        # Using Infinity.jl
        (-∞, 10, 1),
        (10, ∞, 1),
        (-∞, ∞, 1),
        (-∞, 1.0, 0.01),
        (-∞, Date(2013, 3, 13), Day(1)),
        (Date(2013, 2, 13), ∞, Day(1)),
        (-∞, DateTime(2016, 8, 11, 1), Millisecond(1)),
        (DateTime(2016, 8, 11, 0, 30), ∞, Millisecond(1)),
        (-∞, Time(1), Millisecond(1)),
        (Time(1), ∞, Millisecond(1)),
    ]

    @testset "constructor" begin
        for T in [Int32, Int64, Float64]
            @test Interval{T}() == Interval{T, Open, Open}(zero(T), zero(T))
        end

        @test Interval{Date}() == Interval{Date, Open, Open}(Date(0), Date(0))
        @test Interval{DateTime}() == Interval{DateTime, Open, Open}(
            DateTime(0), DateTime(0)
        )
        @test Interval{ZonedDateTime}() == Interval{ZonedDateTime, Open, Open}(
            ZonedDateTime(0, tz"UTC"), ZonedDateTime(0, tz"UTC")
        )

        @test Interval(nothing, nothing) == Interval{Nothing, Unbounded, Unbounded}(nothing, nothing)
        @test_throws MethodError Interval{Nothing, Open, Unbounded}(nothing, nothing)
        @test_throws MethodError Interval{Nothing, Unbounded, Closed}(nothing, nothing)

        for (a, b, _) in test_values
            T = promote_type(typeof(a), typeof(b))

            @test a..b == Interval(a, b)
            @test Interval(a, b) == Interval{T, Closed, Closed}(a, b)
            @test Interval{T}(a, b) == Interval{T, Closed, Closed}(a, b)
            @test Interval{Open, Closed}(a, b) == Interval{T, Open, Closed}(a, b)
            @test Interval(LeftEndpoint{Closed}(a), RightEndpoint{Closed}(b)) ==
                Interval{T, Closed, Closed}(a, b)

            @test Interval(a, nothing) == Interval{T, Closed, Unbounded}(a, nothing)
            @test Interval(nothing, b) == Interval{T, Unbounded, Closed}(nothing, b)
            @test Interval{T}(a, nothing) == Interval{T, Closed, Unbounded}(a, nothing)
            @test Interval{T}(nothing, b) == Interval{T, Unbounded, Closed}(nothing, b)
            @test Interval{T}(nothing, nothing) == Interval{T, Unbounded, Unbounded}(nothing, nothing)
            @test Interval{Open, Unbounded}(a, nothing) == Interval{T, Open, Unbounded}(a, nothing)
            @test Interval{Unbounded, Open}(nothing, b) == Interval{T, Unbounded, Open}(nothing, b)
        end

        # If we aren't careful in how we define our Interval constructors we could end up
        # causing a StackOverflow
        @test_throws MethodError Interval{Int, Unbounded, Closed}(1, 2)
        @test_throws MethodError Interval{Int, Closed, Unbounded}(1, 2)
        @test_throws MethodError Interval{Int, Unbounded, Unbounded}(1, 2)

        # Deprecated
        @test_deprecated Interval{DateTime,Open,Closed}(DateTime(0), DateTime(0), Inclusivity(false, true))
        @test_throws ArgumentError Interval{DateTime,Open,Closed}(DateTime(0), DateTime(0), Inclusivity(true, true))

        @test_deprecated Interval{Float64,Open,Closed}(0, 0, Inclusivity(false, true))
        @test_throws ArgumentError Interval{Float64,Open,Closed}(0, 0, Inclusivity(true, true))
        @test_throws MethodError Interval{Float64,Unbounded,Closed}(nothing, 0, Inclusivity(true, true))
        @test_throws MethodError Interval{Float64,Open,Unbounded}(0, nothing, Inclusivity(false, true))
        @test_throws ArgumentError Interval{Nothing,Unbounded,Unbounded}(nothing, nothing, Inclusivity(false, false))
    end

    @testset "non-ordered" begin
        @test_throws ArgumentError Interval(NaN, NaN)
        @test_throws ArgumentError Interval(NaN, Inf)
        @test_throws ArgumentError Interval(-Inf, NaN)
        # @test_throws ArgumentError Interval(Inf, -Inf)  # Would result in a NaN span

        @test_throws ArgumentError Interval{Float64, Open, Unbounded}(NaN, nothing)
        @test_throws ArgumentError Interval{Float64, Unbounded, Closed}(nothing, NaN)
    end

    @testset "hash" begin
        # Need a complicated enough element type for this test to ever fail
        zdt = now(tz"Europe/London")
        a = Interval(zdt, zdt)
        b = deepcopy(a)
        @test hash(a) == hash(b)
    end

    @testset "conversion" begin
        @test_throws DomainError convert(Int, Interval{Open, Open}(10, 10))
        @test_throws DomainError convert(Int, Interval{Open, Closed}(10, 10))
        @test_throws DomainError convert(Int, Interval{Closed, Open}(10, 10))
        @test convert(Int, Interval{Closed, Closed}(10, 10)) == 10
        @test_throws DomainError convert(Int, Interval{Closed, Closed}(10, 11))

        for T in (Date, DateTime)
            dt = T(2013, 2, 13)
            @test_throws DomainError convert(T, Interval{Open, Open}(dt, dt))
            @test_throws DomainError convert(T, Interval{Open, Closed}(dt, dt))
            @test_throws DomainError convert(T, Interval{Closed, Open}(dt, dt))
            @test convert(T, Interval{Closed, Closed}(dt, dt)) == dt
            @test_throws DomainError convert(T, Interval{Closed, Closed}(dt, dt + Day(1)))
        end
    end

    @testset "eltype" begin
        @test eltype(Interval(1,2)) == Int
        @test eltype(Interval{Float64}(1,2)) == Float64
    end

    @testset "accessors" begin
        for (a, b, p) in test_values
            for (L, R) in BOUND_PERMUTATIONS
                interval = Interval{L, R}(a, b)

                @test first(interval) == a
                @test last(interval) == b
                # the value we compare to min/max depends on if the bound is open/closed
                min_comp = a in interval ? first(interval) : first(interval) + p
                max_comp = b in interval ? last(interval) : last(interval) - p
                @test minimum(interval; increment=p) == min_comp
                @test maximum(interval; increment=p) == max_comp
                @test span(interval) == b - a
                @test isclosed(interval) == (L === Closed && R === Closed)
                @test isopen(interval) == (L === Open && R === Open)
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
        interval = Interval{Open, Open}(1, 2)
        @test string(interval) == "(1 .. 2)"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) == "Interval{$Int,Open,Open}(1, 2)"

        interval = Interval{Open, Closed}('a', 'b')
        @test string(interval) == "(a .. b]"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) == "Interval{Char,Open,Closed}('a', 'b')"

        interval = Interval{Closed, Open}(Date(2012), Date(2013))
        shown = string(
            "Interval{Date,Closed,Open}(",
            sprint(show, Date(2012, 1, 1)),
            ", ",
            sprint(show, Date(2013, 1, 1)),
            ")",
        )

        @test string(interval) == "[2012-01-01 .. 2013-01-01)"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) == shown

        interval = Interval{Closed, Closed}("a", "b")
        @test string(interval) == "[a .. b]"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) ==
            "Interval{String,Closed,Closed}(\"a\", \"b\")"
    end

    @testset "equality" begin
        for (a, b, unit) in test_values
            for (L, R) in BOUND_PERMUTATIONS
                interval = Interval{L, R}(a, b)
                cp = copy(interval)
                lesser_val = Interval{L, R}(a - unit, b - unit)
                greater_val = Interval{L, R}(a + unit, b + unit)

                L′ = L === Closed ? Open : Closed
                R′ = R === Closed ? Open : Closed
                diff_inc = Interval{L′, R′}(a, b)

                @test interval == cp
                @test isequal(interval, cp)
                @test hash(interval) == hash(cp)

                @test interval != diff_inc
                @test !isequal(interval, diff_inc)
                @test hash(interval) != hash(diff_inc)

                if !isinf(a) || !isinf(b)
                    @test interval != lesser_val
                    @test !isequal(interval, lesser_val)
                    @test hash(interval) != hash(lesser_val)
                else
                    @test interval == lesser_val
                    @test isequal(interval, lesser_val)
                    @test hash(interval) == hash(lesser_val)
                end

                @test !isless(interval, cp)
                @test !(interval < cp)
                @test !(interval ≪ cp)
                @test !(interval > cp)
                @test !(interval ≫ cp)

                @test isless(interval, greater_val) || isinf(a)
                @test interval < greater_val || isinf(a)
                @test !(interval ≪ greater_val)     # Still overlap, so not disjoint
                @test !(interval > greater_val)
                @test !(interval ≫ greater_val)

                @test !isless(greater_val, interval)
                @test !(greater_val < interval)
                @test !(greater_val ≪ interval)     # Still overlap, so not disjoint
                @test greater_val > interval || isinf(a)
                @test !(greater_val ≫ interval)     # Still overlap, so not disjoint

                @test isless(lesser_val, interval) || isinf(a)
                @test lesser_val < interval || isinf(a)
                @test !(lesser_val ≪ interval)
                @test !(lesser_val > interval)
                @test !(lesser_val ≫ interval)

                @test !isless(interval, lesser_val)
                @test !(interval < lesser_val)
                @test !(interval ≪ lesser_val)
                @test interval > lesser_val || isinf(a)
                @test !(interval ≫ lesser_val)      # Still overlap, so not disjoint
            end
        end

        @test Interval(2010, 2011) ≪ Interval(2012, 2013)
        @test !(Interval(2012, 2013) ≪ Interval(2010, 2011))

        @test Interval(Date(2010), Date(2011)) ≪ Interval(Date(2012), Date(2013))
        @test !(Interval(Date(2012), Date(2013)) ≪ Interval(Date(2010), Date(2011)))

        @test !(Interval(0, 10) ≪ Interval(10, 20))
        @test !(Interval(10, 20) ≪ Interval(0, 10))

        @test Interval{Closed, Open}(0, 10) ≪
            Interval{Open, Closed}(10, 20)
        @test !(
            Interval{Closed, Open}(10, 20) ≪
            Interval{Open, Closed}(0, 10)
        )

        # Comparisons between Interval{T} and T
        @test isless(5, Interval(10, 20))
        @test 5 < Interval(10, 20)
        @test 5 ≪ Interval(10, 20)
        @test !(5 > Interval(10, 20))
        @test !(5 ≫ Interval(10, 20))

        @test isless(10, Interval{Open, Open}(10, 20))
        @test 10 < Interval{Open, Open}(10, 20)
        @test 10 ≪ Interval{Open, Open}(10, 20)
        @test !(10 > Interval{Open, Open}(10, 20))
        @test !(10 ≫ Interval{Open, Open}(10, 20))

        @test !isless(10, Interval(10, 20))
        @test !(10 < Interval(10, 20))
        @test !(10 ≪ Interval(10, 20))
        @test !(10 > Interval(10, 20))
        @test !(10 ≫ Interval(10, 20))

        @test !isless(15, Interval(10, 20))
        @test !(15 < Interval(10, 20))
        @test !(15 ≪ Interval(10, 20))
        @test 15 > Interval(10, 20)
        @test !(15 ≫ Interval(10, 20))

        @test !isless(20, Interval(10, 20))
        @test !(20 < Interval(10, 20))
        @test !(20 ≪ Interval(10, 20))
        @test 20 > Interval(10, 20)
        @test !(20 ≫ Interval(10, 20))

        @test !isless(20, Interval{Open, Open}(10, 20))
        @test !(20 < Interval{Open, Open}(10, 20))
        @test !(20 ≪ Interval{Open, Open}(10, 20))
        @test 20 > Interval{Open, Open}(10, 20)
        @test 20 ≫ Interval{Open, Open}(10, 20)

        @test !isless(25, Interval(10, 20))
        @test !(25 < Interval(10, 20))
        @test !(25 ≪ Interval(10, 20))
        @test 25 > Interval(10, 20)
        @test 25 ≫ Interval(10, 20)

        @test !isless(Interval(10, 20), 5)
        @test !(Interval(10, 20) < 5)
        @test !isless(Interval{Open, Open}(10, 20), 10)
        @test !(Interval{Open, Open}(10, 20) < 10)
        @test !isless(Interval(10, 20), 10)
        @test !(Interval(10, 20) < 10)
        @test !(Interval(10, 20) ≪ 10)
        @test isless(Interval(10, 20), 15)
        @test Interval(10, 20) < 15
        @test !(Interval(10, 20) ≪ 15)
        @test isless(Interval(10, 20), 20)
        @test Interval(10, 20) < 20
        @test !(Interval(10, 20) ≪ 20)
        @test isless(Interval{Open, Open}(10, 20), 20)
        @test Interval{Open, Open}(10, 20) < 20
        @test isless(Interval(10, 20), 25)
        @test Interval(10, 20) < 25

        for lt in (isless, <)
            @test lt(Date(2013), Interval(Date(2014), Date(2016)))
            @test lt(Date(2014), Interval{Open, Open}(Date(2014), Date(2016)))
            @test !lt(Date(2014), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2014), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2015), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2016), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2016), Interval{Open, Open}(Date(2014), Date(2016)))
            @test !lt(Date(2017), Interval(Date(2014), Date(2016)))
        end

        @test !isless(Interval(Date(2014), Date(2016)), Date(2013))
        @test !(Interval(Date(2014), Date(2016)) < Date(2013))
        @test !isless(Interval{Open, Open}(Date(2014), Date(2016)), Date(2014))
        @test !(Interval{Open, Open}(Date(2014), Date(2016)) < Date(2014))
        @test !isless(Interval(Date(2014), Date(2016)), Date(2014))
        @test !(Interval(Date(2014), Date(2016)) < Date(2014))
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2014))
        @test isless(Interval(Date(2014), Date(2016)), Date(2015))
        @test Interval(Date(2014), Date(2016)) < Date(2015)
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2015))
        @test isless(Interval(Date(2014), Date(2016)), Date(2016))
        @test Interval(Date(2014), Date(2016)) < Date(2016)
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2016))
        @test isless(Interval{Open, Open}(Date(2014), Date(2016)), Date(2016))
        @test Interval{Open, Open}(Date(2014), Date(2016)) < Date(2016)
        @test Interval{Open, Open}(Date(2014), Date(2016)) ≪ Date(2016)
        @test isless(Interval(Date(2014), Date(2016)), Date(2017))
        @test Interval(Date(2014), Date(2016)) < Date(2017)
    end

    @testset "broadcasting" begin
        # Validate that an Interval is treated as a scalar during broadcasting
        interval = Interval(DateTime(2016, 8, 11, 17), DateTime(2016, 8, 11, 18))
        @test size(interval .== interval) == ()
    end

    @testset "sort" begin
        i1 = 1 .. 10
        i2 = Interval{Open, Open}(1, 10)
        i3 = 2 .. 11
        i4 = -Inf .. Inf

        @test sort([i1, i2, i3, i4]) == [i4, i1, i2, i3]
        @test sort([i1, i2, i3, i4]; rev=true) == [i3, i2, i1, i4]
    end

    @testset "arithmetic" begin
        for (a, b, unit) in test_values
            for (L, R) in BOUND_PERMUTATIONS
                interval = Interval{L, R}(a, b)
                @test interval + unit == Interval{L, R}(a + unit, b + unit)
                @test unit + interval == Interval{L, R}(a + unit, b + unit)
                @test interval - unit == Interval{L, R}(a - unit, b - unit)

                if a isa Number && b isa Number
                    @test -interval == Interval{R, L}(-b, -a)
                    @test unit - interval == Interval{R, L}(unit - b, unit - a)
                else
                    @test_throws MethodError -interval
                    @test_throws MethodError unit - interval
                end
            end

            @test_throws MethodError Interval(a, b) + Interval(a, b)
            @test_throws MethodError Interval(a, b) - Interval(a, b)
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

        @test !isempty(Interval{Open, Open}(0, 1))
        @test !isempty(Interval{Open, Closed}(0, 1))
        @test !isempty(Interval{Closed, Open}(0, 1))
        @test !isempty(Interval{Closed, Closed}(0, 1))

        @test isempty(Interval{Open, Open}(0, 0))
        @test isempty(Interval{Open, Closed}(0, 0))
        @test isempty(Interval{Closed, Open}(0, 0))
        @test !isempty(Interval{Closed, Closed}(0, 0))

        # DST transition
        @test !isempty(
            Interval{Open,Open}(
                ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 1),
                ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 2),
            )
        )
    end

    @testset "in" begin
        for (a, b, unit) in test_values
            interval = Interval(a, b)
            @test  in(a, interval)
            @test  in(a + unit, interval)
            @test !in(a - unit, interval) || isinf(a)
            @test  in(b, interval)
            @test  in(b - unit, interval)
            @test !in(b + unit, interval) || isinf(b)

            interval = Interval{Closed, Open}(a, b)
            @test  in(a, interval)
            @test  in(a + unit, interval)
            @test !in(a - unit, interval) || isinf(a)
            @test !in(b, interval)
            @test  in(b - unit, interval) || isinf(b)
            @test !in(b + unit, interval)

            interval = Interval{Open, Closed}(a, b)
            @test !in(a, interval)
            @test  in(a + unit, interval) || isinf(a)
            @test !in(a - unit, interval)
            @test  in(b, interval)
            @test  in(b - unit, interval)
            @test !in(b + unit, interval) || isinf(b)

            interval = Interval{Open, Open}(a, b)
            @test !in(a, interval)
            @test  in(a + unit, interval) || isinf(a)
            @test !in(a - unit, interval) || isinf(a)
            @test !in(b, interval)
            @test  in(b - unit, interval) || isinf(b)
            @test !in(b + unit, interval) || isinf(b)

            @test_throws ArgumentError (in(Interval(a, b), Interval(a, b)))
        end
    end

    @testset "issubset" begin
        @test 0..10 ⊆ 0..10
        @test 0..10 ⊇ 0..10
        @test Interval{Open, Open}(0, 10) ⊆ 0..10
        @test Interval{Open, Open}(0, 10) ⊉ 0..10
        @test 0..10 ⊈ Interval{Open, Open}(0, 10)
        @test 0..10 ⊇ Interval{Open, Open}(0, 10)
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
            a = Interval{Closed, Closed}(-10, 5)
            b = Interval{Closed, Closed}(-2, 10)
            @test intersect(a, b) == Interval{Closed, Closed}(-2, 5)
            @test intersect(b, a) == intersect(a, b)

            a = Interval{Closed, Open}(-10, 5)
            b = Interval{Closed, Closed}(-2, 10)
            @test intersect(a, b) == Interval{Closed, Open}(-2, 5)
            @test intersect(b, a) == intersect(a, b)

            a = Interval{Closed, Closed}(-10, 5)
            b = Interval{Open, Closed}(-2, 10)
            @test intersect(a, b) == Interval{Open, Closed}(-2, 5)
            @test intersect(b, a) == intersect(a, b)

            a = Interval{Closed, Open}(-10, 5)
            b = Interval{Open, Closed}(-2, 10)
            @test intersect(a, b) == Interval{Open, Open}(-2, 5)
            @test intersect(b, a) == intersect(a, b)
        end

        @testset "adjacent" begin
            a = Interval{Closed, Closed}(-10, 0)
            b = Interval{Closed, Closed}(0, 10)
            @test intersect(a, b) == Interval{Closed, Closed}(0, 0)
            @test intersect(b, a) == intersect(a, b)

            a = Interval{Closed, Open}(-10, 0)
            b = Interval{Closed, Closed}(0, 10)
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))

            a = Interval{Closed, Closed}(-10, 0)
            b = Interval{Open, Closed}(0, 10)
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))

            a = Interval{Closed, Open}(-10, 0)
            b = Interval{Open, Closed}(0, 10)
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))
        end

        @testset "identical" begin
            for (L, R) in BOUND_PERMUTATIONS
                x = Interval{L, R}(1, 10)
                @test intersect(x, x) == x
            end

            x = Interval{Open, Open}(0, 0)
            @test intersect(x, x) == x
            @test isempty(intersect(x, x))

            # But what if their inclusivities are different?
            expected = Interval{Open, Open}(1, 10)
            @test intersect(
                Interval{Closed, Closed}(1, 10),
                Interval{Open, Open}(1, 10),
            ) == expected
            @test intersect(
                Interval{Closed, Open}(1, 10),
                Interval{Open, Closed}(1, 10),
            ) == expected
        end

        @testset "disjoint" begin
            for (L, R) in BOUND_PERMUTATIONS
                a = Interval{L, R}(-100, -1)
                b = Interval{L, R}(1, 100)
                @test isempty(intersect(a, b))
                @test isempty(intersect(b, a))
            end
        end
    end

    @testset "astimezone" begin
        zdt1 = ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg")
        zdt2 = ZonedDateTime(2016, 8, 11, 21, tz"America/Winnipeg")

        for (L, R) in BOUND_PERMUTATIONS
            for tz in (tz"America/Winnipeg", tz"America/Regina", tz"UTC")
                @test isequal(
                    astimezone(Interval{L, R}(zdt1, zdt2), tz),
                    Interval{L, R}(astimezone(zdt1, tz), astimezone(zdt2, tz)),
                )
            end
        end
    end

    @testset "timezone" begin
        @testset "basic" begin
            zdt1 = ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg")
            zdt2 = ZonedDateTime(2016, 8, 11, 21, tz"America/Winnipeg")
            @test timezone(Interval(zdt1, zdt2)) == tz"America/Winnipeg"
        end

        @testset "multiple timezones" begin
            zdt1 = ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg")
            zdt2 = ZonedDateTime(2016, 8, 11, 21, tz"Europe/London")
            @test_throws ArgumentError timezone(Interval(zdt1, zdt2))
        end
    end

    @testset "merge" begin
        a = Interval(-100, -1)
        b = Interval(-3, 10)

        @test merge(a, b) == Interval(-100, 10)
        @test merge(b, a) == Interval(-100, 10)

        b = Interval(1, 10)
        @test_throws ArgumentError merge(a, b)

        a = Interval{Open, Open}(-100, -1)
        b = Interval{Closed, Closed}(-2, 10)
        @test merge(a, b) == Interval{Open, Closed}(-100, 10)

        a = Interval{Closed, Open}(-100, -1)
        b = Interval{Open, Open}(-2, 10)
        @test merge(a, b) == Interval{Closed, Open}(-100, 10)
    end

    @testset "union" begin
        intervals = [
            Interval{Open, Open}(-100, -1),
            Interval{Open, Open}(-10, -1),
            Interval{Open, Open}(10, 15),
            Interval{Open, Open}(13, 20),
        ]
        expected = [
            Interval{Open, Open}(-100, -1),
            Interval{Open, Open}(10, 20),
        ]
        @test union(intervals) == expected

        # Ordering
        intervals = [
            Interval{Open, Open}(-100, -1),
            Interval{Open, Open}(10, 15),
            Interval{Open, Open}(-10, -1),
            Interval{Open, Open}(13, 20),
        ]
        @test union(intervals) == expected
        @test intervals == [
            Interval{Open, Open}(-100, -1),
            Interval{Open, Open}(10, 15),
            Interval{Open, Open}(-10, -1),
            Interval{Open, Open}(13, 20),
        ]
        @test union!(intervals) == expected
        @test intervals == expected

        # Mixing bounds
        intervals = [
            Interval{Open, Open}(-100, -1),
            Interval{Closed, Closed}(-10, -1)
        ]
        @test union(intervals) == [Interval{Open, Closed}(-100, -1)]
    end

    @testset "legacy deserialization" begin
        # Serialized string generated on Intervals@1.2 with:
        # `julia --project -E 'using Serialization, Intervals; sprint(serialize, Interval(1, 2, true, false))'`.
        buffer = IOBuffer(
            SERIALIZED_HEADER *
            "\x004\x10\x01\bInterval\x1f\v՞\x84\xec\xf7-`\x87\xbbS\xe1Á\x88A\xd8\x01\t" *
            "IntervalsD\x01\0\0\0\0\b\xe0\xe14\x10\x01\vInclusivity\x1f\v՞\x84\xec\xf7" *
            "-`\x87\xbbS\xe1Á\x88A\xd8,\x02\0DML"
        )

        interval = deserialize(buffer)
        @test interval isa Interval
        @test interval == Interval{Closed,Open}(1, 2)
    end

    @testset "parse" begin
        @testset "double-dot" begin
            @test parse(Interval{Int}, "[1..2]") == Interval{Closed,Closed}(1, 2)
            @test parse(Interval{Int}, "(1..2]") == Interval{Open,Closed}(1, 2)
            @test parse(Interval{Int}, "[1..2)") == Interval{Closed,Open}(1, 2)
            @test parse(Interval{Int}, "(1..2)") == Interval{Open,Open}(1, 2)
        end

        @testset "comma" begin
            @test parse(Interval{Int}, "[1,2]") == Interval{Closed,Closed}(1, 2)
            @test parse(Interval{Int}, "(1,2]") == Interval{Open,Closed}(1, 2)
            @test parse(Interval{Int}, "[1,2)") == Interval{Closed,Open}(1, 2)
            @test parse(Interval{Int}, "(1,2)") == Interval{Open,Open}(1, 2)
        end

        @testset "entire string" begin
            @test_throws ArgumentError parse(Interval{Int}, "a[1,2]")
            @test_throws ArgumentError parse(Interval{Int}, "[1,2]b")
        end

        @testset "unbounded" begin
            @test parse(Interval{Nothing}, "[,]") == Interval{Unbounded,Unbounded}(nothing, nothing)
            @test parse(Interval{Nothing}, "(,]") == Interval{Unbounded,Unbounded}(nothing, nothing)
            @test parse(Interval{Nothing}, "[,)") == Interval{Unbounded,Unbounded}(nothing, nothing)
            @test parse(Interval{Nothing}, "(,)") == Interval{Unbounded,Unbounded}(nothing, nothing)
        end

        @testset "space" begin
            @test parse(Interval{Int}, "[1 .. 2)") == Interval{Closed,Open}(1, 2)
            @test parse(Interval{Int}, "(1 .. )") == Interval{Open,Unbounded}(1, nothing)
            @test parse(Interval{Int}, "( .. 2)") == Interval{Unbounded,Open}(nothing, 2)
            @test parse(Interval{Int}, "( .. )") == Interval{Unbounded,Unbounded}(nothing, nothing)

            # TODO: Should probably not be allowed
            @test parse(Interval{Int}, "[ 1..2]") == 1 .. 2
            @test parse(Interval{Int}, "[1..2 ]") == 1 .. 2
            @test parse(Interval{Int}, "[1  ..2]") == 1 .. 2
            @test parse(Interval{Int}, "[1..  2]") == 1 .. 2

            @test parse(Interval{Int}, "[1, 2)") == Interval{Closed,Open}(1, 2)
            @test parse(Interval{Int}, "(1, )") == Interval{Open,Unbounded}(1, nothing)
            @test parse(Interval{Int}, "(, 2)") == Interval{Unbounded,Open}(nothing, 2)
            @test parse(Interval{Int}, "(, )") == Interval{Unbounded,Unbounded}(nothing, nothing)

            # TODO: Should probably not be allowed
            @test parse(Interval{Int}, "[ 1,2]") == 1 .. 2
            @test parse(Interval{Int}, "[1,2 ]") == 1 .. 2
            @test parse(Interval{Int}, "[1  ,2]") == 1 .. 2
            @test parse(Interval{Int}, "[1,  2]") == 1 .. 2
            @test parse(Interval{Int}, "[1 ,2]") == 1 .. 2
            @test parse(Interval{Int}, "[1 , 2]") == 1 .. 2
        end

        @testset "custom parser" begin
            parser = (T, str) -> parse(T, str, dateformat"yyyy/mm/dd")
            @test_throws ArgumentError parse(Interval{Date}, "[2000/1/2,2001/2/3]")
            @test parse(Interval{Date}, "[2000/1/2,2001/2/3]", element_parser=parser) ==
                Date(2000, 1, 2) .. Date(2001, 2, 3)
        end

        @testset "quoting" begin
            parser = (T, str) -> str
            @test_throws ArgumentError parse(Interval{String}, "[a,b,c,d]", element_parser=parser)
            @test parse(Interval{String}, "[\"a,b\",\"c,d\"]", element_parser=parser) ==
                Interval("a,b", "c,d")

            @test_throws ArgumentError parse(Interval{String}, "[a..b..c..d]", element_parser=parser)
            @test parse(Interval{String}, "[\"a..b\"..\"c..d\"]", element_parser=parser) ==
                Interval("a..b", "c..d")

            @test_throws ArgumentError parse(Interval{Interval{Int}}, "[[1..2]..[3..4]]")
            @test parse(Interval{Interval{Int}}, "[\"[1..2]\"..\"[3..4]\"]") ==
                (1 .. 2) .. (3 .. 4)
        end

        # Ensure format used by LibPQ can be successfully parsed
        @testset "libpq" begin
            parse(Interval{Int}, "[\"1\",\"\")") == Interval(1, nothing)
        end

        @testset "test values" begin
            function parser(::Type{Char}, str)
                @assert length(str) == 1
                return first(str)
            end
            parser(::Type{T}, str) where T = parse(T, str)

            for (left, right, _) in test_values, (lb, rb) in product(('[', '('), (']', ')'))
                T = promote_type(typeof(left), typeof(right))

                str = "$lb$left .. $right$rb"
                L = lb == '[' ? Closed : Open
                R = rb == ']' ? Closed : Open

                result = parse(Interval{T}, str, element_parser=parser)
                @test result == Interval{T,L,R}(left, right)
            end
        end
    end
end
