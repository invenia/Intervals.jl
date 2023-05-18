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
            @test Interval{T}() == Interval{T}(zero(T), zero(T), (Open, Open))
        end

        @test Interval{Date}() == Interval{Date}(Date(0), Date(0), (Open, Open))
        @test Interval{DateTime}() == Interval{DateTime}(DateTime(0), DateTime(0), (Open, Open))
        @test Interval{ZonedDateTime}() == Interval{ZonedDateTime}(
            ZonedDateTime(0, tz"UTC"), ZonedDateTime(0, tz"UTC"), (Open, Open)
        )

        @test Interval(nothing, nothing) == Interval{Nothing}(nothing, nothing, (Unbounded, Unbounded))
        @test_throws ArgumentError Interval{Nothing}(nothing, nothing, (Open, Unbounded))
        @test_throws ArgumentError Interval{Nothing}(nothing, nothing, (Unbounded, Closed))

        for (a, b, _) in test_values
            T = promote_type(typeof(a), typeof(b))

            @test a..b == Interval(a, b)
            @test Interval(a, b) == Interval{T}(a, b)
            @test Interval{T}(a, b) == Interval{T}(a, b)
            @test Interval(a, b, (Open, Closed)) == Interval{T}(a, b, 0x02)
            @test Interval(LeftEndpoint{Closed}(a), RightEndpoint{Closed}(b)) == Interval{T}(a, b)

            @test Interval(a, nothing) == Interval{T}(a, nothing, (Closed, Unbounded))
            @test Interval(nothing, b) == Interval{T}(nothing, b, (Unbounded, Closed))
            @test Interval{T}(a, nothing) == Interval{T}(a, nothing, (Closed, Unbounded))
            @test Interval{T}(nothing, b) == Interval{T}(nothing, b, (Unbounded, Closed))
            @test Interval{T}(nothing, nothing) == Interval{T}(nothing, nothing, (Unbounded, Unbounded))
        end

        # Deprecated
        #= This will conflict with PR #214

        @test_deprecated Interval{DateTime,Open,Closed}(DateTime(0), DateTime(0), Inclusivity(false, true))
        @test_throws ArgumentError Interval{DateTime,Open,Closed}(DateTime(0), DateTime(0), Inclusivity(true, true))

        @test_deprecated Interval{Float64,Open,Closed}(0, 0, Inclusivity(false, true))
        @test_throws ArgumentError Interval{Float64,Open,Closed}(0, 0, Inclusivity(true, true))
        @test_throws MethodError Interval{Float64,Unbounded,Closed}(nothing, 0, Inclusivity(true, true))
        @test_throws MethodError Interval{Float64,Open,Unbounded}(0, nothing, Inclusivity(false, true))
        @test_throws ArgumentError Interval{Nothing,Unbounded,Unbounded}(nothing, nothing, Inclusivity(false, false))
        =#
    end

    @testset "non-ordered" begin
        @test_throws ArgumentError Interval(NaN, NaN)
        @test_throws ArgumentError Interval(NaN, Inf)
        @test_throws ArgumentError Interval(-Inf, NaN)
    end

    @testset "hash" begin
        # Need a complicated enough element type for this test to ever fail
        zdt = now(tz"Europe/London")
        a = Interval(zdt, zdt)
        b = deepcopy(a)
        @test hash(a) == hash(b)
    end

    @testset "conversion" begin
        @test_throws DomainError convert(Int, Interval(10, 10, 0x00))
        @test_throws DomainError convert(Int, Interval(10, 10, 0x02))
        @test_throws DomainError convert(Int, Interval(10, 10, 0x01))
        @test convert(Int, Interval(10, 10)) == 10
        @test_throws DomainError convert(Int, Interval(10, 11))

        for T in (Date, DateTime)
            dt = T(2013, 2, 13)
            @test_throws DomainError convert(T, Interval(dt, dt, 0x00))
            @test_throws DomainError convert(T, Interval(dt, dt, 0x02))
            @test_throws DomainError convert(T, Interval(dt, dt, 0x01))
            @test convert(T, Interval(dt, dt)) == dt
            @test_throws DomainError convert(T, Interval(dt, dt + Day(1), (Closed, Closed)))
        end
    end

    @testset "eltype" begin
        @test eltype(Interval(1,2)) == Int
        @test eltype(Interval{Float64}(1,2)) == Float64
    end

    @testset "accessors" begin
        for (a, b, _) in test_values
            for (L, R) in BOUND_PERMUTATIONS
                interval = Interval(a, b, (L, R))
                @test first(interval) == a
                @test last(interval) == b
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

    @testset "maximum/minimum" begin
        # Helper functions that manage the value we should be expecting from min and max.
        function _min_val_helper(interval, a, unit)
            t = eltype(interval)
            # If the interal is empty, min is nothing
            isempty(interval) && return nothing

            # If a is in the interval, it is closed/unbounded and min is the first value.
            # If a is nothing then it is unbounded and min is typemin(T)
            a === nothing && return typemin(t)
            a ∈ interval && return first(interval)

            # From this point on, b ∉ interval so the bound is Open
            # Also, if a is infinite we return typemin
            # If it's an abstractfloat, we can't return just typemin since typemin IS Inf and
            # since the bound is open at this point, Inf ∉ interval So we return the one after INF
            !Intervals.isfinite(a) && t <: AbstractFloat && return nextfloat(a)
            !Intervals.isfinite(a) && return typemin(t)

            f = first(interval)
            nv = if t <: AbstractFloat && unit === nothing
                nextfloat(f)
            else
                f + unit
            end

            nv ∈ interval && return nv

            # If we get to this point, the min/max functions throw a DomainError
            # Since we want our tests to be predictable, we will not throw an error in this helper.
        end

        function _max_val_helper(interval, b, unit)
            t = eltype(interval)
            # If the interal is empty, min is nothing
            isempty(interval) && return nothing

            # If a is in the interval, it is closed/unbounded and min is the first value.
            # If a is nothing then it is unbounded and min is typemin(T)
            b === nothing && return typemax(t)
            b ∈ interval && return last(interval)

            # From this point on, b ∉ interval so the bound is Open
            # Also, if a is infinite we return typemin
            # If it's an abstractfloat, we can't return just typemin since typemin IS Inf and
            # since the bound is open at this point, Inf ∉ interval So we return the one after INF
            !isfinite(b) && t <: AbstractFloat && return prevfloat(b)
            !isfinite(b) && return typemax(t)

            l = last(interval)
            nv = if t <: AbstractFloat && unit === nothing
                prevfloat(l)
            else
                l - unit
            end

            nv ∈ interval && return nv

            # If we get to this point, the min/max functions throw a DomainError
            # Since we want our tests to be predictable, we will not throw an error in this helper.
        end
        @testset "bounded intervals" begin
            bounded_test_vals = [
                #test nextfloat and prevfloat
                (-10.0, 10.0, nothing),
                (-Inf, Inf, nothing),

                ('c', 'x', 2),
                (Date(2004, 2, 13), Date(2020, 3, 13), Day(1)),
            ]
            for (a, b, unit) in append!(bounded_test_vals, test_values)
                for (L, R) in BOUND_PERMUTATIONS
                    interval = Interval(a, b, (L, R))

                    mi = _min_val_helper(interval, a, unit)
                    ma = _max_val_helper(interval, b, unit)

                    @test minimum(interval; increment=unit) == mi
                    @test maximum(interval; increment=unit) == ma
                end
            end
        end

        @testset "unbounded intervals ($interval, $unit)" for (interval, unit) in [
                # one side unbounded with different types
                (Interval(-10, nothing, (Open,Unbounded)), 1),
                (Interval(nothing, 1.0, (Unbounded,Closed)), 0.01),
                (Interval(nothing, 'z', (Unbounded,Open)), 1),
                (Interval(Date(2013, 2, 13), nothing, (Closed,Unbounded)), Day(1)),
                (Interval(DateTime(2016, 8, 11, 0, 30), nothing, (Open,Unbounded)), Millisecond(1)),
                # both sides unbounded different types
                (Interval{Int}(nothing, nothing), 1),
                (Interval{Float64}(nothing, nothing), 0.01),
                (Interval{Char}(nothing , nothing), 1),
                (Interval{Day}(nothing, nothing), Day(1)),
                (Interval{DateTime}(nothing, nothing), Millisecond(1)),
                # test adding eps() with unbounded
                (Interval(-10.0, nothing, (Open,Unbounded)), nothing),
                (Interval(nothing, 10.0, (Unbounded,Open)), nothing),
                # test infinity
                (Interval(-Inf, nothing, (Open,Unbounded)), nothing),
                (Interval(nothing, Inf, (Unbounded,Open)), nothing),
            ]
            
            a, b = first(interval), last(interval)

            mi = _min_val_helper(interval, a, unit)
            ma = _max_val_helper(interval, b, unit)

            @test minimum(interval; increment=unit) == mi
            @test maximum(interval; increment=unit) == ma
            @test_throws DomainError span(interval)
        end
        
        @testset "bounds errors in min/max ($interval, $unit)" for (interval, unit) in [
                # empty intervals
                (Interval(-10, -10, (Open, Open)), 1),
                (Interval(0.0, 0.0, (Open, Open)), 60),
                (Interval(Date(2013, 2, 13), Date(2013, 2, 13), (Open, Open)), Day(1)),
                (Interval(DateTime(2016, 8, 11, 0, 30), DateTime(2016, 8, 11, 0, 30), (Open, Open)), Day(1)),
                # increment too large
                (Interval(-10, 15, (Open, Open)), 60),
                (Interval(0.0, 25, (Open, Open)), 60.0),
                (Interval(Date(2013, 2, 13), Date(2013, 2, 14), (Open, Open)), Day(5)),
                (Interval(DateTime(2016, 8, 11, 0, 30), DateTime(2016, 8, 11, 5, 30), (Open, Open)), Day(5)),
            ]
            
            @test_throws BoundsError minimum(interval; increment=unit)
            @test_throws BoundsError maximum(interval; increment=unit)
        end
    end
    @testset "display" begin
        interval = Interval(1, 2, (Open, Open))
        @test string(interval) == "(1 .. 2)"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) == "Interval{$Int}(1, 2, (Open, Open))"

        interval = Interval('a', 'b', (Open, Closed))
        @test string(interval) == "(a .. b]"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) == "Interval{Char}('a', 'b', (Open, Closed))"

        interval = Interval(Date(2012), Date(2013), (Closed, Open))

        shown = string(
            "Interval{Date}",
            "(",
            sprint(show, Date(2012, 1, 1)),
            ", ",
            sprint(show, Date(2013, 1, 1)),
            ", ",
            "(Closed, Open)",
            ")",
        )

        @test string(interval) == "[2012-01-01 .. 2013-01-01)"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) == shown

        interval = Interval("a", "b", (Closed, Closed))
        @test string(interval) == "[a .. b]"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) == "Interval{String}(\"a\", \"b\", (Closed, Closed))"
    end

    @testset "equality" begin
        for (a, b, unit) in test_values
            for (L, R) in BOUND_PERMUTATIONS
                interval = Interval(a, b, (L, R))
                cp = copy(interval)
                lesser_val = Interval(a - unit, b - unit, (L, R))
                greater_val = Interval(a + unit, b + unit, (L, R))

                L′ = L === Closed ? Open : Closed
                R′ = R === Closed ? Open : Closed
                diff_inc = Interval(a, b, (L′, R′))

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

        @test Interval(0, 10, (Closed, Open)) ≪
            Interval(10, 20, (Open, Closed))
        @test !(
            Interval(10, 20, (Closed, Open)) ≪
            Interval(0, 10, (Open, Closed))
        )

        # Comparisons between Interval{T} and T
        @test isless(5, Interval(10, 20))
        @test 5 < Interval(10, 20)
        @test 5 ≪ Interval(10, 20)
        @test !(5 > Interval(10, 20))
        @test !(5 ≫ Interval(10, 20))

        @test isless(10, Interval(10, 20, (Open, Open)))
        @test 10 < Interval(10, 20, (Open, Open))
        @test 10 ≪ Interval(10, 20, (Open, Open))
        @test !(10 > Interval(10, 20, (Open, Open)))
        @test !(10 ≫ Interval(10, 20, (Open, Open)))

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

        @test !isless(20, Interval(10, 20, (Open, Open)))
        @test !(20 < Interval(10, 20, (Open, Open)))
        @test !(20 ≪ Interval(10, 20, (Open, Open)))
        @test 20 > Interval(10, 20, (Open, Open))
        @test 20 ≫ Interval(10, 20, (Open, Open))

        @test !isless(25, Interval(10, 20))
        @test !(25 < Interval(10, 20))
        @test !(25 ≪ Interval(10, 20))
        @test 25 > Interval(10, 20)
        @test 25 ≫ Interval(10, 20)

        @test !isless(Interval(10, 20), 5)
        @test !(Interval(10, 20) < 5)
        @test !isless(Interval(10, 20, (Open, Open)), 10)
        @test !(Interval(10, 20, (Open, Open)) < 10)
        @test !isless(Interval(10, 20), 10)
        @test !(Interval(10, 20) < 10)
        @test !(Interval(10, 20) ≪ 10)
        @test isless(Interval(10, 20), 15)
        @test Interval(10, 20) < 15
        @test !(Interval(10, 20) ≪ 15)
        @test isless(Interval(10, 20), 20)
        @test Interval(10, 20) < 20
        @test !(Interval(10, 20) ≪ 20)
        @test isless(Interval(10, 20, (Open, Open)), 20)
        @test Interval(10, 20, (Open, Open)) < 20
        @test isless(Interval(10, 20), 25)
        @test Interval(10, 20) < 25

        for lt in (isless, <)
            @test lt(Date(2013), Interval(Date(2014), Date(2016)))
            @test lt(Date(2014), Interval(Date(2014), Date(2016), (Open, Open)))
            @test !lt(Date(2014), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2014), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2015), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2016), Interval(Date(2014), Date(2016)))
            @test !lt(Date(2016), Interval(Date(2014), Date(2016), (Open, Open)))
            @test !lt(Date(2017), Interval(Date(2014), Date(2016)))
        end

        @test !isless(Interval(Date(2014), Date(2016)), Date(2013))
        @test !(Interval(Date(2014), Date(2016)) < Date(2013))
        @test !isless(Interval(Date(2014), Date(2016), (Open, Open)), Date(2014))
        @test !(Interval(Date(2014), Date(2016), (Open, Open)) < Date(2014))
        @test !isless(Interval(Date(2014), Date(2016)), Date(2014))
        @test !(Interval(Date(2014), Date(2016)) < Date(2014))
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2014))
        @test isless(Interval(Date(2014), Date(2016)), Date(2015))
        @test Interval(Date(2014), Date(2016)) < Date(2015)
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2015))
        @test isless(Interval(Date(2014), Date(2016)), Date(2016))
        @test Interval(Date(2014), Date(2016)) < Date(2016)
        @test !(Interval(Date(2014), Date(2016)) ≪ Date(2016))
        @test isless(Interval(Date(2014), Date(2016), (Open, Open)), Date(2016))
        @test Interval(Date(2014), Date(2016), (Open, Open)) < Date(2016)
        @test Interval(Date(2014), Date(2016), (Open, Open)) ≪ Date(2016)
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
        i2 = Interval(1, 10, (Open, Open))
        i3 = 2 .. 11
        i4 = -Inf .. Inf

        @test sort([i1, i2, i3, i4]) == [i4, i1, i2, i3]
        @test sort([i1, i2, i3, i4]; rev=true) == [i3, i2, i1, i4]
    end

    @testset "arithmetic" begin
        for (a, b, unit) in test_values
            for (L, R) in BOUND_PERMUTATIONS
                interval = Interval(a, b, (L, R))
                @test interval + unit == Interval(a + unit, b + unit, (L, R))
                @test unit + interval == Interval(a + unit, b + unit, (L, R))
                @test interval - unit == Interval(a - unit, b - unit, (L, R))

                if a isa Number && b isa Number
                    @test -interval == Interval(-b, -a, (L, R))
                    @test unit - interval == Interval(unit - b, unit - a, (L, R))
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

        @test !isempty(Interval(0, 1, (Open, Open)))
        @test !isempty(Interval(0, 1, (Open, Closed)))
        @test !isempty(Interval(0, 1, (Closed, Open)))
        @test !isempty(Interval(0, 1, (Closed, Closed)))

        @test isempty(Interval(0, 0, (Open, Open)))
        @test isempty(Interval(0, 0, (Open, Closed)))
        @test isempty(Interval(0, 0, (Closed, Open)))
        @test !isempty(Interval(0, 0, (Closed, Closed)))

        # DST transition
        @test !isempty(
            Interval(
                ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 1),
                ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 2),
                (Open, Open),
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

            interval = Interval(a, b, (Closed, Open))
            @test  in(a, interval)
            @test  in(a + unit, interval)
            @test !in(a - unit, interval) || isinf(a)
            @test !in(b, interval)
            @test  in(b - unit, interval) || isinf(b)
            @test !in(b + unit, interval)

            interval = Interval(a, b, (Open, Closed))
            @test !in(a, interval)
            @test  in(a + unit, interval) || isinf(a)
            @test !in(a - unit, interval)
            @test  in(b, interval)
            @test  in(b - unit, interval)
            @test !in(b + unit, interval) || isinf(b)

            interval = Interval(a, b, (Open, Open))
            @test !in(a, interval)
            @test  in(a + unit, interval) || isinf(a)
            @test !in(a - unit, interval) || isinf(a)
            @test !in(b, interval)
            @test  in(b - unit, interval) || isinf(b)
            @test !in(b + unit, interval) || isinf(b)

            # As an Interval instance is itself a collection one could expect this to return
            # `true`. The correct check in this case is `issubset`.
            @test_throws ArgumentError (in(Interval(a, b), Interval(a, b)))
        end
    end

    @testset "issubset" begin
        @test 0..10 ⊆ 0..10
        @test 0..10 ⊇ 0..10
        @test Interval(0, 10, (Open, Open)) ⊆ 0..10
        @test Interval(0, 10, (Open, Open)) ⊉ 0..10
        @test 0..10 ⊈ Interval(0, 10, (Open, Open))
        @test 0..10 ⊇ Interval(0, 10, (Open, Open))
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
            a = Interval(-10, 5, (Closed, Closed))
            b = Interval(-2, 10, (Closed, Closed))
            @test intersect(a, b) == Interval(-2, 5, (Closed, Closed))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 5, (Closed, Open))
            b = Interval(-2, 10, (Closed, Closed))
            @test intersect(a, b) == Interval(-2, 5, (Closed, Open))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 5, (Closed, Closed))
            b = Interval(-2, 10, (Open, Closed))
            @test intersect(a, b) == Interval(-2, 5, (Open, Closed))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 5, (Closed, Open))
            b = Interval(-2, 10, (Open, Closed))
            @test intersect(a, b) == Interval(-2, 5, (Open, Open))
            @test intersect(b, a) == intersect(a, b)
        end

        @testset "adjacent" begin
            a = Interval(-10, 0, (Closed, Closed))
            b = Interval(0, 10, (Closed, Closed))
            @test intersect(a, b) == Interval(0, 0, (Closed, Closed))
            @test intersect(b, a) == intersect(a, b)

            a = Interval(-10, 0, (Closed, Open))
            b = Interval(0, 10, (Closed, Closed))
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))

            a = Interval(-10, 0, (Closed, Closed))
            b = Interval(0, 10, (Open, Closed))
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))

            a = Interval(-10, 0, (Closed, Open))
            b = Interval(0, 10, (Open, Closed))
            @test isempty(intersect(a, b))
            @test isempty(intersect(b, a))
        end

        @testset "identical" begin
            for (L, R) in BOUND_PERMUTATIONS
                x = Interval(1, 10, (L, R))
                @test intersect(x, x) == x
            end

            x = Interval(0, 0, (Open, Open))
            @test intersect(x, x) == x
            @test isempty(intersect(x, x))

            # But what if their inclusivities are different?
            expected = Interval(1, 10, (Open, Open))
            @test intersect(
                Interval(1, 10, (Closed, Closed)),
                Interval(1, 10, (Open, Open)),
            ) == expected
            @test intersect(
                Interval(1, 10, (Closed, Open)),
                Interval(1, 10, (Open, Closed)),
            ) == expected
        end

        @testset "disjoint" begin
            for (L, R) in BOUND_PERMUTATIONS
                a = Interval(-100, -1, (L, R))
                b = Interval(1, 100, (L, R))
                @test isempty(intersect(a, b))
                @test isempty(intersect(b, a))
            end
        end
    end

    @testset "astimezone" begin
        zdt1 = ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg")
        zdt2 = ZonedDateTime(2016, 8, 11, 21, tz"America/Winnipeg")
        utcdt1 = UTCDateTime(zdt1)
        utcdt2 = UTCDateTime(zdt2)

        for (L, R) in BOUND_PERMUTATIONS
            for tz in (tz"America/Winnipeg", tz"America/Regina", tz"UTC")
                @test isequal(
                    astimezone(Interval(zdt1, zdt2, (L, R)), tz),
                    Interval(astimezone(zdt1, tz), astimezone(zdt2, tz), (L, R)),
                )
                @test isequal(
                    astimezone(Interval(utcdt1, utcdt2, (L, R)), tz),
                    Interval(astimezone(utcdt1, tz), astimezone(utcdt2, tz), (L, R)),
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

        @testset "utc" begin
            utcdt1 = UTCDateTime(2013, 2, 13, 0, 30)
            utcdt2 = UTCDateTime(2016, 8, 11, 21)
            @test timezone(Interval(utcdt1, utcdt2)) == tz"UTC"
        end
    end

    @testset "merge" begin
        a = Interval(-100, -1)
        b = Interval(-3, 10)

        @test merge(a, b) == Interval(-100, 10)
        @test merge(b, a) == Interval(-100, 10)

        b = Interval(1, 10)
        @test_throws ArgumentError merge(a, b)

        a = Interval(-100, -1, (Open, Open))
        b = Interval(-2, 10, (Closed, Closed))
        @test merge(a, b) == Interval(-100, 10, (Open, Closed))

        a = Interval(-100, -1, (Closed, Open))
        b = Interval(-2, 10, (Open, Open))
        @test merge(a, b) == Interval(-100, 10, (Closed, Open))
    end

    #= These will conflict with PR 214
    @testset "union" begin
        intervals = [
            Interval(-100, -1, (Open, Open)),
            Interval(-10, -1, (Open, Open)),
            Interval(10, 15, (Open, Open)),
            Interval(13, 20, (Open, Open)),
        ]
        expected = [
            Interval(-100, -1, (Open, Open)),
            Interval(10, 20, (Open, Open)),
        ]
        @test union(intervals) == expected

        # Ordering
        intervals = [
            Interval(-100, -1, (Open, Open)),
            Interval(10, 15, (Open, Open)),
            Interval(-10, -1, (Open, Open)),
            Interval(13, 20, (Open, Open)),
        ]
        @test union(intervals) == expected
        @test intervals == [
            Interval(-100, -1, (Open, Open)),
            Interval(10, 15, (Open, Open)),
            Interval(-10, -1, (Open, Open)),
            Interval(13, 20, (Open, Open)),
        ]

        @test union!(intervals) == expected
        @test intervals == expected

        # Mixing bounds
        intervals = [
            Interval(-100, -1, (Open, Open)),
            Interval(-10, -1, (Closed, Closed))
        ]
        @test union(intervals) == [Interval(-100, -1, (Open, Closed))]
    end
    =#

    #= Conflicts with PR 214
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
        @test interval == Interval{Closed, Open}(1, 2)
    end
    =#

    @testset "parse" begin
        @testset "double-dot" begin
            @test parse(Interval{Int}, "[1..2]") == Interval(1, 2, (Closed, Closed))
            @test parse(Interval{Int}, "(1..2]") == Interval(1, 2, (Open, Closed))
            @test parse(Interval{Int}, "[1..2)") == Interval(1, 2, (Closed, Open))
            @test parse(Interval{Int}, "(1..2)") == Interval(1, 2, (Open, Open))
        end

        @testset "comma" begin
            @test parse(Interval{Int}, "[1,2]") == Interval(1, 2, (Closed, Closed))
            @test parse(Interval{Int}, "(1,2]") == Interval(1, 2, (Open, Closed))
            @test parse(Interval{Int}, "[1,2)") == Interval(1, 2, (Closed, Open))
            @test parse(Interval{Int}, "(1,2)") == Interval(1, 2, (Open, Open))
        end

        @testset "entire string" begin
            @test_throws ArgumentError parse(Interval{Int}, "a[1,2]")
            @test_throws ArgumentError parse(Interval{Int}, "[1,2]b")
        end

        @testset "unbounded" begin
            @test parse(Interval{Nothing}, "[,]") == Interval(nothing, nothing, (Unbounded,Unbounded))
            @test parse(Interval{Nothing}, "(,]") == Interval(nothing, nothing, (Unbounded,Unbounded))
            @test parse(Interval{Nothing}, "[,)") == Interval(nothing, nothing, (Unbounded,Unbounded))
            @test parse(Interval{Nothing}, "(,)") == Interval(nothing, nothing, (Unbounded,Unbounded))
        end

        @testset "space" begin
            @test parse(Interval{Int}, "[1 .. 2)") == Interval(1, 2, (Closed, Open))
            @test parse(Interval{Int}, "(1 .. )") == Interval(1, nothing, (Open,Unbounded))
            @test parse(Interval{Int}, "( .. 2)") == Interval(nothing, 2, (Unbounded,Open))
            @test parse(Interval{Int}, "( .. )") == Interval(nothing, nothing, (Unbounded,Unbounded))

            # TODO: Should probably not be allowed
            @test parse(Interval{Int}, "[ 1..2]") == 1 .. 2
            @test parse(Interval{Int}, "[1..2 ]") == 1 .. 2
            @test parse(Interval{Int}, "[1  ..2]") == 1 .. 2
            @test parse(Interval{Int}, "[1..  2]") == 1 .. 2

            @test parse(Interval{Int}, "[1, 2)") == Interval(1, 2, (Closed, Open))
            @test parse(Interval{Int}, "(1, )") == Interval(1, nothing, (Open,Unbounded))
            @test parse(Interval{Int}, "(, 2)") == Interval(nothing, 2, (Unbounded,Open))
            @test parse(Interval{Int}, "(, )") == Interval(nothing, nothing, (Unbounded,Unbounded))

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

            # NOTE: All of these error now because we test `isfinite` on `==` which fails for eltypes of String and Interval.
            @test_throws ArgumentError parse(Interval{String}, "[a,b,c,d]", element_parser=parser)
            @test parse(Interval{String}, "[\"a,b\",\"c,d\"]", element_parser=parser) == 
                Interval("a,b", "c,d", (Closed, Closed))

            @test_throws ArgumentError parse(Interval{String}, "[a..b..c..d]", element_parser=parser)
            @test parse(Interval{String}, "[\"a..b\"..\"c..d\"]", element_parser=parser) == 
                Interval("a..b", "c..d", (Closed, Closed))

            @test_throws ArgumentError parse(Interval{Interval{Int}}, "[[1..2]..[3..4]]")
            @test parse(Interval{Interval{Int}}, "[\"[1..2]\"..\"[3..4]\"]") == Interval{Interval{Int}}(
                Interval{Int}(1, 2, (Closed, Closed)),
                Interval{Int}(3, 4, (Closed, Closed)),
                (Closed, Closed),
            )
        end

        # Ensure format used by LibPQ can be successfully parsed
        @testset "libpq" begin
            parse(Interval{Int}, "[\"1\",\"2\")") == Interval(1, 2, (Closed, Open))
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
                @test result == Interval{T}(left, right, (L, R))
            end
        end
    end

    @testset "floor" begin
        # `on` keyword is required
        @test_throws UndefKeywordError floor(Interval(0.0, 1.0))

        # only :left and :right are supported
        @test_throws MethodError floor(Interval(0.0, 1.0); on=:nothing)

        @test floor(Interval(0.0, 1.0); on=:left) == Interval(0.0, 1.0)
        @test floor(Interval(0.5, 1.0); on=:left) == Interval(0.0, 0.5)
        @test floor(Interval(0.0, 1.5); on=:left) == Interval(0.0, 1.5)
        @test floor(Interval(0.5, 1.5); on=:left) == Interval(0.0, 1.0)

        @test floor(Interval(0.0, 1.0); on=:right) == Interval(0.0, 1.0)
        @test floor(Interval(0.5, 1.0); on=:right) == Interval(0.5, 1.0)
        @test floor(Interval(0.0, 1.5); on=:right) == Interval(-0.5, 1.0)
        @test floor(Interval(0.5, 1.5); on=:right) == Interval(0.0, 1.0)

        # :anchor is only usable with AnchoredIntervals
        @test_throws ArgumentError floor(Interval(0.0, 1.0); on=:anchor)

        # Test supplying a period to floor to
        interval = Interval(DateTime(2011, 2, 1, 6), DateTime(2011, 2, 2, 18))
        expected = Interval(DateTime(2011, 2, 1), DateTime(2011, 2, 2, 12))
        @test_throws UndefKeywordError floor(interval, Day)
        @test floor(interval, Day; on=:left) == expected
        @test floor(interval, Day(1); on=:left) == expected

        expected = Interval(DateTime(2011, 1, 31, 12), DateTime(2011, 2, 2))
        @test floor(interval, Day; on=:right) == expected
        @test floor(interval, Day(1); on=:right) == expected

        # Test unbounded intervals
        # @test floor(Interval{Closed, Unbounded}(0.0, nothing); on=:left) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test floor(Interval{Closed, Unbounded}(0.5, nothing); on=:left) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test floor(Interval{Unbounded, Closed}(nothing, 1.0); on=:left) == Interval{Unbounded, Closed}(nothing, 1.0)
        # @test floor(Interval{Unbounded, Closed}(nothing, 1.5); on=:left) == Interval{Unbounded, Closed}(nothing, 1.5)
        # @test floor(Interval{Unbounded, Unbounded}(nothing, nothing); on=:left) == Interval{Unbounded, Unbounded}(nothing, nothing)

        # @test floor(Interval{Closed, Unbounded}(0.0, nothing); on=:right) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test floor(Interval{Closed, Unbounded}(0.5, nothing); on=:right) == Interval{Closed, Unbounded}(0.5, nothing)
        # @test floor(Interval{Unbounded, Closed}(nothing, 1.0); on=:right) == Interval{Unbounded, Closed}(nothing, 1.0)
        # @test floor(Interval{Unbounded, Closed}(nothing, 1.5); on=:right) == Interval{Unbounded, Closed}(nothing, 1.0)
        # @test floor(Interval{Unbounded, Unbounded}(nothing, nothing); on=:right) == Interval{Unbounded, Unbounded}(nothing, nothing)
    end

    @testset "ceil" begin
        # `on` keyword is required
        @test_throws UndefKeywordError ceil(Interval(0.0, 1.0))

        # only :left and :right are supported
        @test_throws MethodError ceil(Interval(0.0, 1.0); on=:nothing)

        @test ceil(Interval(0.0, 1.0); on=:left) == Interval(0.0, 1.0)
        @test ceil(Interval(0.5, 1.0); on=:left) == Interval(1.0, 1.5)
        @test ceil(Interval(0.0, 1.5); on=:left) == Interval(0.0, 1.5)
        @test ceil(Interval(0.5, 1.5); on=:left) == Interval(1.0, 2.0)

        @test ceil(Interval(0.0, 1.0); on=:right) == Interval(0.0, 1.0)
        @test ceil(Interval(0.5, 1.0); on=:right) == Interval(0.5, 1.0)
        @test ceil(Interval(0.0, 1.5); on=:right) == Interval(0.5, 2.0)
        @test ceil(Interval(0.5, 1.5); on=:right) == Interval(1.0, 2.0)

        # :anchor is only usable with AnchoredIntervals
        @test_throws ArgumentError ceil(Interval(0.0, 1.0); on=:anchor)

        # Test supplying a period to ceil to
        interval = Interval(DateTime(2011, 2, 1, 6), DateTime(2011, 2, 2, 18))
        expected = Interval(DateTime(2011, 2, 2), DateTime(2011, 2, 3, 12))
        @test_throws UndefKeywordError ceil(interval, Day)
        @test ceil(interval, Day; on=:left) == expected
        @test ceil(interval, Day(1); on=:left) == expected

        expected = Interval(DateTime(2011, 2, 1, 12), DateTime(2011, 2, 3))
        @test ceil(interval, Day; on=:right) == expected
        @test ceil(interval, Day(1); on=:right) == expected

        # Test unbounded intervals
        # @test ceil(Interval{Closed, Unbounded}(0.0, nothing); on=:left) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test ceil(Interval{Closed, Unbounded}(0.5, nothing); on=:left) == Interval{Closed, Unbounded}(1.0, nothing)
        # @test ceil(Interval{Unbounded, Closed}(nothing, 1.0); on=:left) == Interval{Unbounded, Closed}(nothing, 1.0)
        # @test ceil(Interval{Unbounded, Closed}(nothing, 1.5); on=:left) == Interval{Unbounded, Closed}(nothing, 1.5)
        # @test ceil(Interval{Unbounded, Unbounded}(nothing, nothing); on=:left) == Interval{Unbounded, Unbounded}(nothing, nothing)

        # @test ceil(Interval{Closed, Unbounded}(0.0, nothing); on=:right) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test ceil(Interval{Closed, Unbounded}(0.5, nothing); on=:right) == Interval{Closed, Unbounded}(0.5, nothing)
        # @test ceil(Interval{Unbounded, Closed}(nothing, 1.0); on=:right) == Interval{Unbounded, Closed}(nothing, 1.0)
        # @test ceil(Interval{Unbounded, Closed}(nothing, 1.5); on=:right) == Interval{Unbounded, Closed}(nothing, 2.0)
        # @test ceil(Interval{Unbounded, Unbounded}(nothing, nothing); on=:right) == Interval{Unbounded, Unbounded}(nothing, nothing)
    end

    @testset "round" begin
        # `on` keyword is required
        @test_throws UndefKeywordError round(Interval(0.0, 1.0))

        # only :left and :right are supported
        @test_throws MethodError round(Interval(0.0, 1.0); on=:nothing)

        @test round(Interval(0.0, 1.0); on=:left) == Interval(0.0, 1.0)
        @test round(Interval(0.5, 1.0); on=:left) == Interval(0.0, 0.5)
        @test round(Interval(0.0, 1.5); on=:left) == Interval(0.0, 1.5)
        @test round(Interval(0.5, 1.5); on=:left) == Interval(0.0, 1.0)

        @test round(Interval(0.0, 1.0); on=:right) == Interval(0.0, 1.0)
        @test round(Interval(0.5, 1.0); on=:right) == Interval(0.5, 1.0)
        @test round(Interval(0.0, 1.5); on=:right) == Interval(0.5, 2.0)
        @test round(Interval(0.5, 1.5); on=:right) == Interval(1.0, 2.0)

        # :anchor is only usable with AnchoredIntervals
        @test_throws ArgumentError round(Interval(0.0, 1.0); on=:anchor)

        # Test supplying a period to round to
        interval = Interval(DateTime(2011, 2, 1, 6), DateTime(2011, 2, 2, 18))
        expected = Interval(DateTime(2011, 2, 1), DateTime(2011, 2, 2, 12))
        @test_throws UndefKeywordError round(interval, Day)
        @test round(interval, Day; on=:left) == expected
        @test round(interval, Day(1); on=:left) == expected

        expected = Interval(DateTime(2011, 2, 1, 12), DateTime(2011, 2, 3))
        @test_throws UndefKeywordError round(interval, Day)
        @test round(interval, Day; on=:right) == expected
        @test round(interval, Day(1); on=:right) == expected

        # Test unbounded intervals
        # @test round(Interval{Closed, Unbounded}(0.0, nothing); on=:left) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test round(Interval{Closed, Unbounded}(0.5, nothing); on=:left) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test round(Interval{Unbounded, Closed}(nothing, 1.0); on=:left) == Interval{Unbounded, Closed}(nothing, 1.0)
        # @test round(Interval{Unbounded, Closed}(nothing, 1.5); on=:left) == Interval{Unbounded, Closed}(nothing, 1.5)
        # @test round(Interval{Unbounded, Unbounded}(nothing, nothing); on=:left) == Interval{Unbounded, Unbounded}(nothing, nothing)

        # @test round(Interval{Closed, Unbounded}(0.0, nothing); on=:right) == Interval{Closed, Unbounded}(0.0, nothing)
        # @test round(Interval{Closed, Unbounded}(0.5, nothing); on=:right) == Interval{Closed, Unbounded}(0.5, nothing)
        # @test round(Interval{Unbounded, Closed}(nothing, 1.0); on=:right) == Interval{Unbounded, Closed}(nothing, 1.0)
        # @test round(Interval{Unbounded, Closed}(nothing, 1.5); on=:right) == Interval{Unbounded, Closed}(nothing, 2.0)
        # @test round(Interval{Unbounded, Unbounded}(nothing, nothing); on=:right) == Interval{Unbounded, Unbounded}(nothing, nothing)
    end
end
