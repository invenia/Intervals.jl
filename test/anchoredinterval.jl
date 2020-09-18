using Intervals: Bounded, Ending, Beginning, canonicalize, isunbounded

@testset "AnchoredInterval" begin
    dt = DateTime(2016, 8, 11, 2)

    @testset "constructor" begin
        expected = AnchoredInterval{Hour(-1), DateTime, Open, Closed}(dt)
        @test AnchoredInterval{Hour(-1), DateTime}(dt) == expected
        @test AnchoredInterval{Hour(-1)}(dt) == expected
        @test HourEnding{DateTime}(dt) == expected
        @test HourEnding(dt) == expected
        @test HE(dt) == expected
        @test HE(dt - Minute(59)) == expected

        expected = AnchoredInterval{Hour(1), DateTime, Closed, Open}(dt)
        @test AnchoredInterval{Hour(1), DateTime}(dt) == expected
        @test AnchoredInterval{Hour(1)}(dt) == expected
        @test HourBeginning{DateTime}(dt) == expected
        @test HourBeginning(dt) == expected
        @test HB(dt) == expected
        @test HB(dt + Minute(59)) == expected

        # Lazy inclusivity constructor
        @test HourEnding{Closed, Open}(dt) == HourEnding{DateTime, Closed, Open}(dt)
        @test AnchoredInterval{Day(1), Open, Open}(dt) ==
            AnchoredInterval{Day(1), DateTime, Open, Open}(dt)

        # Unable to supply bounds with HE/HB as they are functions and not types
        @test_throws TypeError HE{Closed, Closed}(dt)
        @test_throws TypeError HB{Closed, Closed}(dt)

        # Non-period AnchoredIntervals
        @test AnchoredInterval{-10}(10) isa AnchoredInterval
        @test AnchoredInterval{25}('a') isa AnchoredInterval

        # Deprecated
        @test_deprecated AnchoredInterval{Hour(-1),DateTime,Open,Closed}(dt, Inclusivity(false, true))
        @test_throws ArgumentError AnchoredInterval{Hour(-1),DateTime,Open,Closed}(dt, Inclusivity(true, true))

        @test_deprecated AnchoredInterval{-1,Float64,Open,Closed}(0, Inclusivity(false, true))
        @test_throws ArgumentError AnchoredInterval{-1,Float64,Open,Closed}(0, Inclusivity(true, true))
        @test_throws MethodError AnchoredInterval{-1,Float64,Open,Closed}(nothing, Inclusivity(false, true))
    end

    @testset "zero-span" begin
        @test AnchoredInterval{0}(10) == 10 .. 10

        @test AnchoredInterval{+0.0}(0.0) == 0 .. 0
        @test AnchoredInterval{-0.0}(0.0) == 0 .. 0
        @test AnchoredInterval{0.0}(0.0) == 0 .. 0
    end

    @testset "infinite" begin
        x = 1  # Non-zero value representing any positive value

        # Note: Ideally the exception raised would always be `ArgumentError`.
        @testset "$inf" for (inf, Error) in zip((Inf, ∞), (ArgumentError, InfMinusInfError))
            interval = 0 .. inf
            @test AnchoredInterval{inf,Closed,Closed}(0.0) == interval
            # Not-possible: AnchoredInterval{-?,Closed,Closed}(inf)

            interval = -inf .. 0
            # Not-possible: AnchoredInterval{+?,Closed,Closed}(-inf)
            @test AnchoredInterval{-inf,Closed,Closed}(0.0) == interval

            interval = -inf .. inf
            @test_throws Error AnchoredInterval{inf,Closed,Closed}(-inf)
            @test_throws Error AnchoredInterval{-inf,Closed,Closed}(inf)

            interval = -inf .. -inf
            @test AnchoredInterval{+x,Closed,Closed}(-inf) == interval
            @test AnchoredInterval{-x,Closed,Closed}(-inf) == interval
            @test AnchoredInterval{0}(-inf) == interval

            interval = inf .. inf
            @test AnchoredInterval{+x,Closed,Closed}(inf) == interval
            @test AnchoredInterval{-x,Closed,Closed}(inf) == interval
            @test AnchoredInterval{0}(inf) == interval
        end
    end

    @testset "nan" begin
        # NaN cannot be used as an anchor or as the span
        @test_throws ArgumentError AnchoredInterval{-1.0,Float64,Closed,Closed}(NaN)
        @test_throws ArgumentError AnchoredInterval{1.0,Float64,Closed,Closed}(NaN)
        @test_throws ArgumentError AnchoredInterval{NaN,Float64,Closed,Closed}(0.0)
    end

    @testset "non-bounded" begin
        x = 1  # Non-zero value representing any positive value

        # Unbounded AnchoredIntervals are disallowed as most types have no span value that
        # actually represents the span of the interval
        @test_throws TypeError AnchoredInterval{+x,Int,Closed,Unbounded}(0)
        @test_throws TypeError AnchoredInterval{-x,Int,Unbounded,Closed}(0)
        @test_throws TypeError AnchoredInterval{0,Int,Unbounded,Unbounded}(0)

        @test_throws MethodError AnchoredInterval{+x,Int}(nothing)
        @test_throws MethodError AnchoredInterval{-x,Int}(nothing)
        @test_throws MethodError AnchoredInterval{0,Int}(nothing)

        @test_throws MethodError AnchoredInterval{+x,Nothing}(nothing)
        @test_throws MethodError AnchoredInterval{-x,Nothing}(nothing)
        @test_throws MethodError AnchoredInterval{0,Nothing}(nothing)
    end

    @testset "hash" begin
        # Need a complicated enough element type for this test to ever fail
        zdt = now(tz"Europe/London")
        a = HE(zdt)
        b = deepcopy(a)
        @test hash(a) == hash(b)
    end

    @testset "conversion" begin
        interval = AnchoredInterval{Hour(0)}(dt)
        @test convert(DateTime, interval) == dt

        he = HourEnding(dt)
        hb = HourBeginning(dt)

        # Note: When the deprecation is dropped remove the deprecated tests and uncomment
        # the DomainError tests
        @test (@test_deprecated convert(DateTime, he)) == anchor(he)
        @test (@test_deprecated convert(DateTime, hb)) == anchor(hb)
        # @test_throws DomainError convert(DateTime, he)
        # @test_throws DomainError convert(DateTime, hb)

        @test convert(Interval, he) == Interval{Open, Closed}(dt - Hour(1), dt)
        @test convert(Interval, hb) == Interval{Closed, Open}(dt, dt + Hour(1))
        @test convert(Interval, he) == Interval{Open, Closed}(dt - Hour(1), dt)
        @test convert(Interval, hb) == Interval{Closed, Open}(dt, dt + Hour(1))
        @test convert(Interval{DateTime}, he) == Interval{Open, Closed}(dt - Hour(1), dt)
        @test convert(Interval{DateTime}, hb) == Interval{Closed, Open}(dt, dt + Hour(1))

        @test convert(AnchoredInterval{Ending}, Interval(-Inf, 0)) == AnchoredInterval{-Inf,Float64,Closed,Closed}(0)
        @test_throws ArgumentError convert(AnchoredInterval{Beginning}, Interval(-Inf, 0))

        @test_throws ArgumentError convert(AnchoredInterval{Ending}, Interval(0, Inf))
        @test convert(AnchoredInterval{Beginning}, Interval(0, Inf)) == AnchoredInterval{Inf,Float64,Closed,Closed}(0)

        @test convert(AnchoredInterval{Ending}, Interval(-∞, 0)) == AnchoredInterval{-∞,Float64,Closed,Closed}(0)
        @test_throws InfMinusInfError convert(AnchoredInterval{Beginning}, Interval(-∞, 0))

        @test_throws InfMinusInfError convert(AnchoredInterval{Ending}, Interval(0, ∞))
        @test convert(AnchoredInterval{Beginning}, Interval(0, ∞)) == AnchoredInterval{∞,Float64,Closed,Closed}(0)

        @test_throws ArgumentError convert(AnchoredInterval{Ending}, Interval(nothing, 0))
        @test_throws ArgumentError convert(AnchoredInterval{Beginning}, Interval(nothing, 0))

        @test_throws ArgumentError convert(AnchoredInterval{Ending}, Interval(0, nothing))
        @test_throws ArgumentError convert(AnchoredInterval{Beginning}, Interval(0, nothing))
    end

    @testset "eltype" begin
        @test eltype(AnchoredInterval{-10}(10)) == Int
        @test eltype(AnchoredInterval{25}('a')) == Char
        @test eltype(AnchoredInterval{Day(1)}(today())) == Date
        @test eltype(AnchoredInterval{Day(1),DateTime}(today())) == DateTime
        @test eltype(HourEnding(now())) == DateTime
    end

    @testset "accessors" begin
        P = Minute(-15)
        interval = AnchoredInterval{P, Closed, Closed}(dt)

        @test first(interval) == DateTime(2016, 8, 11, 1, 45)
        @test last(interval) == dt
        @test minimum(interval) == first(interval)
        @test maximum(interval) == last(interval)
        @test bounds_types(interval) == (Closed, Closed)
        @test span(interval) == -P


        P = Day(1)
        interval = AnchoredInterval{P, Open, Open}(Date(dt))

        @test first(interval) == Date(2016, 8, 11)
        @test last(interval) == Date(2016, 8, 12)
        # throws domain error
        @test_throws DomainError minimum(interval, increment=Day(1)) == first(interval) + Day(1)
        @test_throws DomainError maximum(interval, increment=Day(1)) == last(interval) - Day(1)
        @test bounds_types(interval) == (Open, Open)
        @test span(interval) == P

        # DST transition
        endpoint = ZonedDateTime(2018, 3, 11, 3, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)

        startpoint = ZonedDateTime(2018, 3, 11, tz"America/Winnipeg")
        interval = AnchoredInterval{Day(1)}(startpoint)
        @test first(interval) == startpoint
        @test last(interval) == ZonedDateTime(2018, 3, 12, tz"America/Winnipeg")
        @test minimum(interval) == startpoint
        @test maximum(interval, increment=Hour(1)) == ZonedDateTime(2018, 3, 11, 23, tz"America/Winnipeg")
        @test span(interval) == Day(1)

        endpoint = ZonedDateTime(2018, 11, 4, 2, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)

        startpoint = ZonedDateTime(2018, 11, 4, tz"America/Winnipeg")
        interval = AnchoredInterval{Day(1)}(startpoint)
        @test first(interval) == startpoint
        @test last(interval) == ZonedDateTime(2018, 11, 5, tz"America/Winnipeg")
        @test minimum(interval) == startpoint
        @test maximum(interval, increment=Hour(1)) == ZonedDateTime(2018, 11, 4, 23, tz"America/Winnipeg")
        @test span(interval) == Day(1)

        endpoint = ZonedDateTime(2020, 3, 9, 2, tz"America/Winnipeg")
        interval = AnchoredInterval{Day(-1)}(endpoint)
        @test_throws NonExistentTimeError first(interval)
        @test_throws NonExistentTimeError minimum(interval, increment=Hour(1))
        @test last(interval) == endpoint
        @test maximum(interval) == endpoint
        @test span(interval) == Day(1)

        # Non-period AnchoredIntervals
        interval = AnchoredInterval{-10}(10)
        @test first(interval) == 0
        @test last(interval) == 10
        @test minimum(interval) == 1
        @test maximum(interval) == 10
        @test bounds_types(interval) == (Open, Closed)
        @test span(interval) == 10

        interval = AnchoredInterval{25}('a')
        @test first(interval) == 'a'
        @test last(interval) == 'z'
        @test minimum(interval) == 'a'
        @test maximum(interval, increment=1) == 'y'
        @test bounds_types(interval) == (Closed, Open)
        @test span(interval) == 25
    end

    @testset "display" begin
        # Notes on compatibility changes and when they can be updated:
        #
        # When the minimum version of TimeZones requires that `repr` is fixed
        # - `repr(ZonedDateTime(...))` and `$ZonedDateTime` can be changed to be hardcoded
        #
        # When dropping VERSION < v"1.2.0-DEV.29" (https://github.com/JuliaLang/julia/pull/30200)
        # - `repr(Date(...))` and `repr(DateTime(...))` can be converted to hardcode strings
        #
        # When dropping VERSION < v"1.2.0-DEV.223" (https://github.com/JuliaLang/julia/pull/30817)
        # - `repr(Period(...))`can be converted to hardcode strings

        where_lr = "where R<:$Bounded where L<:$Bounded"
        where_tlr = "$where_lr where T"

        if VERSION >= v"1.6.0-DEV.347"
            @test sprint(show, AnchoredInterval{Hour(-1)}) ==
                "HourEnding{T,L,R} $where_tlr"
            @test sprint(show, AnchoredInterval{Hour(1)}) ==
                "HourBeginning{T,L,R} $where_tlr"
        else
            @test sprint(show, AnchoredInterval{Hour(-1)}) ==
                "AnchoredInterval{$(repr(Hour(-1))),T,L,R} $where_tlr"
            @test sprint(show, AnchoredInterval{Hour(1)}) ==
                "AnchoredInterval{$(repr(Hour(1))),T,L,R} $where_tlr"
        end

        @test sprint(show, AnchoredInterval{Day(-1)}) ==
            "AnchoredInterval{$(repr(Day(-1))),T,L,R} $where_tlr"
        @test sprint(show, AnchoredInterval{Day(1)}) ==
            "AnchoredInterval{$(repr(Day(1))),T,L,R} $where_tlr"
        @test sprint(show, AnchoredInterval{Day(-1), DateTime}) ==
            "AnchoredInterval{$(repr(Day(-1))),DateTime,L,R} $where_lr"
        @test sprint(show, AnchoredInterval{Day(1), DateTime}) ==
            "AnchoredInterval{$(repr(Day(1))),DateTime,L,R} $where_lr"

        # Tuples contain fields: interval, printed, shown
        tests = [
            (
                HourEnding(dt),
                "(2016-08-11 HE02]",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourEnding{DateTime,Open,Closed}"
                    else
                        "AnchoredInterval{$(repr(Hour(-1))),DateTime,Open,Closed}"
                    end,
                    "($(repr(DateTime(2016, 8, 11, 2))))",
                ),
            ),
            (
                HourEnding{Closed, Open}(DateTime(2013, 2, 13)),
                "[2013-02-12 HE24)",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourEnding{DateTime,Closed,Open}"
                    else
                        "AnchoredInterval{$(repr(Hour(-1))),DateTime,Closed,Open}"
                    end,
                    "($(repr(DateTime(2013, 2, 13))))",
                ),
            ),
            (
                HourEnding(dt + Minute(15) + Second(30)),
                "(2016-08-11 HE02:15:30]",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourEnding{DateTime,Open,Closed}"
                    else
                        "AnchoredInterval{$(repr(Hour(-1))),DateTime,Open,Closed}"
                    end,
                    "($(repr(DateTime(2016, 8, 11, 2, 15, 30))))",
                ),
            ),
            (
                HourEnding(dt + Millisecond(2)),
                "(2016-08-11 HE02:00:00.002]",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourEnding{DateTime,Open,Closed}"
                    else
                        "AnchoredInterval{$(repr(Hour(-1))),DateTime,Open,Closed}"
                    end,
                    "($(repr(DateTime(2016, 8, 11, 2, 0, 0, 2))))",
                ),
            ),
            (
                HourEnding{Closed, Open}(DateTime(2013, 2, 13, 0, 1)),
                "[2013-02-13 HE00:01:00)",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourEnding{DateTime,Closed,Open}"
                    else
                        "AnchoredInterval{$(repr(Hour(-1))),DateTime,Closed,Open}"
                    end,
                    "($(repr(DateTime(2013, 2, 13, 0, 1))))",
                ),
            ),
            (
                HourBeginning(dt),
                "[2016-08-11 HB02)",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourBeginning{DateTime,Closed,Open}"
                    else
                        "AnchoredInterval{$(repr(Hour(1))),DateTime,Closed,Open}"
                    end,
                    "($(repr(DateTime(2016, 8, 11, 2))))",
                ),
            ),
            (
                HourBeginning{Open, Closed}(DateTime(2013, 2, 13)),
                "(2013-02-13 HB00]",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourBeginning{DateTime,Open,Closed}"
                    else
                        "AnchoredInterval{$(repr(Hour(1))),DateTime,Open,Closed}"
                    end,
                    "($(repr(DateTime(2013, 2, 13))))",
                ),
            ),
            (
                HourEnding(ZonedDateTime(dt, tz"America/Winnipeg")),
                "(2016-08-11 HE02-05:00]",
                string(
                    if VERSION >= v"1.6.0-DEV.347"
                        "HourEnding{$ZonedDateTime,Open,Closed}"
                    else
                        "AnchoredInterval{$(repr(Hour(-1))),$ZonedDateTime,Open,Closed}"
                    end,
                    "($(repr(ZonedDateTime(dt, tz"America/Winnipeg"))))",
                ),
            ),
            (
                AnchoredInterval{Year(-1)}(Date(dt)),
                "(YE 2016-08-11]",
                string(
                    "AnchoredInterval{$(repr(Year(-1))),Date,Open,Closed}",
                    "($(repr(Date(2016, 8, 11))))",
                ),
            ),
            (
                AnchoredInterval{Year(-1)}(ceil(Date(dt), Year)),
                "(YE 2017-01-01]",
                string(
                    "AnchoredInterval{$(repr(Year(-1))),Date,Open,Closed}",
                    "($(repr(Date(2017, 1, 1))))",
                ),
            ),
            (
                AnchoredInterval{Month(-1)}(dt),
                "(MoE 2016-08-11 02:00:00]",
                string(
                    "AnchoredInterval{$(repr(Month(-1))),DateTime,Open,Closed}",
                    "($(repr(DateTime(2016, 8, 11, 2, 0, 0))))",
                ),
            ),
            (
                AnchoredInterval{Month(-1)}(ceil(dt, Month)),
                "(MoE 2016-09-01]",
                string(
                    "AnchoredInterval{$(repr(Month(-1))),DateTime,Open,Closed}",
                    "($(repr(DateTime(2016, 9, 1))))",
                ),
            ),
            (
                AnchoredInterval{Day(-1)}(DateTime(dt)),
                "(DE 2016-08-11 02:00:00]",
                string(
                    "AnchoredInterval{$(repr(Day(-1))),DateTime,Open,Closed}",
                    "($(repr(DateTime(2016, 8, 11, 2))))",
                ),
            ),
            (
                AnchoredInterval{Day(-1)}(ceil(DateTime(dt), Day)),
                "(DE 2016-08-12]",
                string(
                    "AnchoredInterval{$(repr(Day(-1))),DateTime,Open,Closed}",
                    "($(repr(DateTime(2016, 8, 12))))",
                ),
            ),
            (
                # Date(dt) will truncate the DateTime to the nearest day
                AnchoredInterval{Day(-1)}(Date(dt)),
                "(DE 2016-08-11]",
                string(
                    "AnchoredInterval{$(repr(Day(-1))),Date,Open,Closed}",
                    "($(repr(Date(2016, 8, 11))))",
                ),
            ),
            (
                # Prevent confusion when dealing with time zones by ensuring
                # that the full date and time are displayed
                AnchoredInterval{Day(-1)}(
                    ceil(ZonedDateTime(dt, tz"America/Winnipeg"), Day)
                ),
                "(DE 2016-08-12 00:00:00-05:00]",
                string(
                    "AnchoredInterval{$(repr(Day(-1))),$ZonedDateTime,Open,Closed}",
                    "($(repr(ZonedDateTime(2016, 8, 12, tz"America/Winnipeg"))))",
                ),
            ),
            (
                AnchoredInterval{Minute(-5)}(dt),
                "(2016-08-11 5ME02:00]",
                string(
                    "AnchoredInterval{$(repr(Minute(-5))),DateTime,Open,Closed}",
                    "($(repr(DateTime(2016, 8, 11, 2))))",
                ),
            ),
            (
                AnchoredInterval{Second(-30)}(dt),
                "(2016-08-11 30SE02:00:00]",
                string(
                    "AnchoredInterval{$(repr(Second(-30))),DateTime,Open,Closed}",
                    "($(repr(DateTime(2016, 8, 11, 2))))",
                ),
            ),
            (
                AnchoredInterval{Millisecond(-10)}(dt),
                "(2016-08-11 10msE02:00:00.000]",
                string(
                    "AnchoredInterval{$(repr(Millisecond(-10))),DateTime,Open,Closed}",
                    "($(repr(DateTime(2016, 8, 11, 2))))",
                ),
           ),
        ]

        for (interval, printed, shown) in tests
            @test sprint(print, interval) == printed
            @test string(interval) == printed
            @test sprint(show, interval) == shown
            @test sprint(show, interval, context=:compact=>true) == printed
            @test repr(interval) == shown
        end

        interval = AnchoredInterval{Second(-10)}(Time(1, 0, 0))
        @test_nowarn string(interval)

        # Non-period AnchoredIntervals
        interval = AnchoredInterval{-10}(10)
        @test string(interval) == "(0 .. 10]"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) ==
            "AnchoredInterval{-10,$Int,Open,Closed}(10)"

        interval = AnchoredInterval{25}('a')
        @test string(interval) == "[a .. z)"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) ==
            "AnchoredInterval{25,Char,Closed,Open}('a')"
    end

    @testset "equality" begin
        he = HourEnding(dt)
        hb = HourBeginning(dt)
        me = AnchoredInterval{Minute(-1)}(dt)
        cpe = copy(he)
        cpb = copy(hb)

        @test he == cpe
        @test isequal(he, cpe)
        @test hash(he) == hash(cpe)

        @test he != hb
        @test !isequal(he, hb)
        @test hash(he) != hash(hb)

        @test he != me
        @test !isequal(he, me)
        @test hash(he) != hash(me)

        diff_inc = HourEnding{Closed, Closed}(dt)

        @test he != diff_inc
        @test !isequal(he, diff_inc)
        @test hash(he) != hash(diff_inc)

        # Overlap for an instant, so not disjoint
        @test isless(he, hb)
        @test !isless(hb, he)
        @test he < hb
        @test !(hb < he)
        @test !(he > hb)
        @test hb > he
        @test !(he ≪ hb)
        @test !(hb ≪ he)
        @test !(he ≫ hb)
        @test !(hb ≫ he)

        @test he ≪ he + Hour(1)
        @test hb ≪ hb + Hour(1)

        @test isless(diff_inc, diff_inc + Hour(2))
        @test isless(diff_inc, diff_inc + Hour(1))
        @test diff_inc < diff_inc + Hour(2)
        @test diff_inc < diff_inc + Hour(1)
        @test diff_inc ≪ diff_inc + Hour(2)
        @test !(diff_inc ≪ diff_inc + Hour(1))  # Overlap for an instant

        # DST transition
        hour1 = HourEnding(ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 1))
        hour2 = HourEnding(ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 2))
        @test hour1 != hour2
        @test !isequal(hour1, hour2)
        @test hash(hour1) != hash(hour2)
        @test hour1 ≪ hour2

        # Comparisons between AnchoredInterval{P, T} and T
        @test dt - Hour(2) < HourEnding(dt)
        @test dt - Hour(1) < HourEnding{Open, Open}(dt)
        @test !(dt - Hour(1) < HourEnding{Closed, Closed}(dt))
        @test !(dt - Minute(30) < HourEnding(dt))
        @test !(dt < HourEnding{Open, Open}(dt))
        @test !(dt < HourEnding{Closed, Closed}(dt))
        @test !(dt + Hour(1) < HourEnding(dt))

        @test !(HourEnding(dt) < dt - Hour(2))
        @test !(HourEnding{Open, Open}(dt) < dt - Hour(1))
        @test !(HourEnding{Closed, Closed}(dt) < dt - Hour(1))
        @test HourEnding(dt) < dt - Minute(30)
        @test !(HourEnding(dt) ≪ dt - Minute(30))
        @test HourEnding{Open, Open}(dt) < dt
        @test HourEnding{Closed, Closed}(dt) < dt
        @test !(HourEnding{Closed, Closed}(dt) ≪ dt)
        @test HourEnding(dt) < dt + Hour(1)
    end

    @testset "broadcasting" begin
        # Validate that an AnchoredInterval is treated as a scalar during broadcasting
        interval = HourEnding(DateTime(2016, 8, 11, 18))
        @test size(interval .== interval) == ()
    end

    @testset "sort" begin
        hb1 = HourBeginning(dt)
        he1 = HourEnding(dt)
        he2 = HourEnding(dt + Hour(1))
        he3 = HourEnding(dt + Hour(2))

        @test sort([hb1, he1, he2, he3]) == [he1, hb1, he2, he3]
        @test sort([hb1, he1, he2, he3]; rev=true) == [he3, he2, hb1, he1]
    end

    @testset "arithmetic" begin
        he = HourEnding(dt)
        hb = HourBeginning(dt)

        @test he + Hour(7) == HourEnding(dt + Hour(7))
        @test hb + Hour(7) == HourBeginning(dt + Hour(7))

        @test Month(1) + he == HourEnding(dt + Month(1))
        @test Month(1) + hb == HourBeginning(dt + Month(1))

        @test he - Day(2) == HourEnding(dt - Day(2))
        @test hb - Day(2) == HourBeginning(dt - Day(2))

        @test he + Minute(30) == HourEnding(dt + Minute(30))
        @test he - Minute(30) == HourEnding(dt - Minute(30))

        ai = AnchoredInterval{Minute(-60)}(dt)
        @test ai + Minute(30) == AnchoredInterval{Minute(-60)}(dt + Minute(30))
        @test ai - Minute(30) == AnchoredInterval{Minute(-60)}(dt - Minute(30))

        # Subtracting AnchoredInterval{P, T} from T doesn't make sense if T is a TimeType
        @test_throws MethodError Hour(1) - he
        @test_throws MethodError Hour(1) - hb

        # DST transition
        endpoint = ZonedDateTime(2018, 3, 11, 3, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)

        endpoint = ZonedDateTime(2018, 11, 4, 2, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)

        # Non-period AnchoredIntervals
        @test AnchoredInterval{10}('a') + 2 == AnchoredInterval{10}('c')
        @test AnchoredInterval{10}('d') - 2 == AnchoredInterval{10}('b')

        @test AnchoredInterval{-1}(20) + 2 == AnchoredInterval{-1}(22)
        @test AnchoredInterval{-1}(20) - 2 == AnchoredInterval{-1}(18)

        @test -AnchoredInterval{2}(10) == AnchoredInterval{-2}(-10) # -[10,12)==(-12,-10]
        @test -AnchoredInterval{-2}(10) == AnchoredInterval{2}(-10) # -(8,10]==[-10,-8)

        @test 15 - AnchoredInterval{-2}(10) == AnchoredInterval{2}(5)   # 15-(8,10]==[5,8)
        @test 15 - AnchoredInterval{2}(10) == AnchoredInterval{-2}(5)   # 15-[10,12)==(3,5]

        @test_throws MethodError -AnchoredInterval{10}('a')
        @test_throws MethodError -AnchoredInterval{-10}('z')

        @test_throws MethodError 10 - AnchoredInterval{10}('a')
        @test_throws MethodError 10 - AnchoredInterval{-10}('z')
    end

    @testset "range" begin
        @testset "StepRange" begin
            r = AnchoredInterval{-1}(1):1:AnchoredInterval{-1}(5)

            @test r isa StepRange
            @test first(r) == AnchoredInterval{-1}(1)
            @test step(r) == 1
            @test last(r) == AnchoredInterval{-1}(5)
        end

        @testset "StepRangeLen" begin
            r = AnchoredInterval{-1}(1):1:AnchoredInterval{-1}(5)
            r = r[1:5]

            # https://github.com/JuliaLang/julia/issues/33882
            @test r isa StepRangeLen
            @test first(r) == AnchoredInterval{-1}(1)
            @test step(r) == 1
            @test last(r) == AnchoredInterval{-1}(5)
        end

        @testset "hourly, implicit" begin
            r = HourEnding(dt):HourEnding(dt + Day(1))

            @test r isa StepRange
            @test eltype(r) === AnchoredInterval{Hour(-1), DateTime, Open, Closed}
            @test isconcretetype(eltype(r))
            @test length(r) == 25
            @test collect(r) == map(HourEnding, dt:Hour(1):dt + Day(1))
        end

        @testset "every 2 hours" begin
            r = HourEnding(dt):Hour(2):HourEnding(dt + Day(7))

            @test r isa StepRange
            @test eltype(r) === AnchoredInterval{Hour(-1), DateTime, Open, Closed}
            @test isconcretetype(eltype(r))
            @test length(r) == 12 * 7 + 1
            @test collect(r) == map(HourEnding, dt:Hour(2):dt + Day(7))
        end

        @testset "DST transition" begin
            spring = ZonedDateTime(2018, 3, 11, tz"America/Winnipeg")
            fall = ZonedDateTime(2018, 11, 4, tz"America/Winnipeg")
            r_spring = HourEnding(spring):HourEnding(spring + Day(1))
            r_fall = HourEnding(fall):Hour(1):HourEnding(fall + Day(1))

            @test r_spring isa StepRange
            @test eltype(r_spring) === AnchoredInterval{Hour(-1), ZonedDateTime, Open, Closed}
            @test isconcretetype(eltype(r_spring))
            @test length(r_spring) == 24
            @test collect(r_spring) == map(HourEnding, spring:Hour(1):spring + Day(1))

            @test r_fall isa StepRange
            @test eltype(r_fall) === AnchoredInterval{Hour(-1), ZonedDateTime, Open, Closed}
            @test isconcretetype(eltype(r_fall))
            @test length(r_fall) == 26
            @test collect(r_fall) == map(HourEnding, fall:Hour(1):fall + Day(1))
        end

        @testset "mixed bounds" begin
            r = AnchoredInterval{-1, Open, Closed}(3):2:AnchoredInterval{-1, Closed, Closed}(7)

            @test eltype(r) === AnchoredInterval{-1, Int}
            @test !isconcretetype(eltype(r))
            @test length(r) == 3
            @test collect(r) == [
                AnchoredInterval{-1, Open, Closed}(3),
                AnchoredInterval{-1, Open, Closed}(5),
                AnchoredInterval{-1, Open, Closed}(7),
            ]
        end
    end

    @testset "isempty" begin
        for P in [Year(1), Month(1), Day(1), Hour(1), Minute(1), Second(1)]
            for sign in [+, -]
                @test !isempty(AnchoredInterval{sign(P), Open, Open}(dt))
                @test !isempty(AnchoredInterval{sign(P), Open, Closed}(dt))
                @test !isempty(AnchoredInterval{sign(P), Closed, Open}(dt))
                @test !isempty(AnchoredInterval{sign(P), Closed, Closed}(dt))
            end
        end

        for P in [Year(0), Month(0), Day(0), Hour(0), Minute(0), Second(0)]
            @test isempty(AnchoredInterval{P, Open, Open}(dt))
            @test isempty(AnchoredInterval{P, Open, Closed}(dt))
            @test isempty(AnchoredInterval{P, Closed, Open}(dt))
            @test !isempty(AnchoredInterval{P, Closed, Closed}(dt))
        end
    end

    @testset "in" begin
        @test !in(dt + Hour(1), HourEnding(dt))
        @test in(dt, HourEnding(dt))
        @test !in(dt, HourEnding{Closed, Open}(dt))
        @test in(dt - Minute(30), HourEnding(dt))
        @test !in(dt - Hour(1), HourEnding(dt))
        @test in(dt - Hour(1), HourEnding{Closed, Open}(dt))
        @test !in(dt - Hour(2), HourEnding(dt))

        @test !in(dt - Hour(1), HourBeginning(dt))
        @test in(dt, HourBeginning(dt))
        @test !in(dt, HourBeginning{Open, Closed}(dt))
        @test in(dt + Minute(30), HourBeginning(dt))
        @test !in(dt + Hour(1), HourBeginning(dt))
        @test in(dt + Hour(1), HourBeginning{Open, Closed}(dt))
        @test !in(dt + Hour(2), HourBeginning(dt))

        zdt = ZonedDateTime(dt, tz"America/Winnipeg")
        @test in(ZonedDateTime(dt - Minute(30), tz"America/Winnipeg"), HourEnding(zdt))
        @test !in(ZonedDateTime(dt + Minute(30), tz"America/Winnipeg"), HourEnding(zdt))
        @test !in(ZonedDateTime(dt - Hour(1), tz"America/Winnipeg"), HourEnding(zdt))
        @test !in(ZonedDateTime(dt - Minute(30), tz"UTC"), HourEnding(zdt))
        @test in(ZonedDateTime(dt + Minute(270), tz"UTC"), HourEnding(zdt))
    end

    @testset "intersect" begin
        # Adjacent
        @test isempty(intersect(HourEnding(dt), HourEnding(dt + Hour(1))))

        # Single point overlap
        intersection = intersect(
            HourEnding{Closed, Closed}(dt),
            HourEnding{Closed, Closed}(dt + Hour(1)),
        )
        @test intersection == AnchoredInterval{Hour(0), Closed, Closed}(dt)
        @test intersection isa AnchoredInterval

        # Hour overlap
        he = HourEnding(dt)
        @test intersect(he, AnchoredInterval{Hour(-2)}(dt)) == he
        @test intersect(AnchoredInterval{Hour(-3)}(dt + Hour(1)), he) == he
        @test intersect(HourBeginning(dt - Hour(1)), he) ==
            HourBeginning{Open, Open}(dt - Hour(1))

        # Identical save for inclusivity
        expected = HourEnding{Open, Open}(dt)
        @test intersect(
            HourEnding{Open, Open}(dt),
            HourEnding{Closed, Closed}(dt),
        ) == expected
        @test intersect(
            HourEnding{Open, Closed}(dt),
            HourEnding{Closed, Open}(dt),
        ) == expected

        # This should probably be an AnchoredInterval{Hour(0)}, but it's not important
        @test intersect(HourEnding(dt), HourBeginning(dt)) ==
            AnchoredInterval{Hour(0), Closed, Closed}(dt)

        # Non-period AnchoredIntervals
        @test intersect(AnchoredInterval{-2}(3), AnchoredInterval{-2}(4)) ==
            AnchoredInterval{-1}(3)
    end

    @testset "canonicalize" begin
        for s in (1, -1)
            @test canonicalize(Day, Millisecond(s * 3600000)) == Hour(s * 1)
            @test canonicalize(Hour, Millisecond(s * 3600000)) == Hour(s * 1)
            @test canonicalize(Minute, Millisecond(s * 3600000)) == Minute(s * 60)
            @test canonicalize(Second, Millisecond(s * 3600000)) == Second(s * 3600)
            @test canonicalize(Millisecond, Millisecond(s * 3600000)) ==
                Millisecond(s * 3600000)
            @test canonicalize(Second, Millisecond(s * 3601000)) == Second(s * 3601)
            @test canonicalize(Millisecond, Millisecond(s * 3600001)) ==
                Millisecond(s * 3600001)
        end

        # Can't promote past 1 week, because who knows how many days/weeks are in a month?
        @test canonicalize(Year, Millisecond(2419200000)) == Week(4)
        @test canonicalize(Year, Millisecond(4233600000)) == Week(7)
    end

    @testset "astimezone" begin
        zdt = ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg")

        for tz in (tz"America/Winnipeg", tz"America/Regina", tz"UTC")
            # Note: We cannot test different bound types here as HE cannot specify them
            @test isequal(astimezone(HE(zdt), tz), HE(astimezone(zdt, tz)))

            for (L, R) in BOUND_PERMUTATIONS
                @test isequal(
                    astimezone(AnchoredInterval{Day(1), L, R}(zdt), tz),
                    AnchoredInterval{Day(1), L, R}(astimezone(zdt, tz)),
                )
            end
        end
    end

    @testset "timezone" begin
        zdt = ZonedDateTime(2013, 2, 13, 0, 30, tz"America/Winnipeg")
        ai = AnchoredInterval{Day(1)}(zdt)
        @test timezone(ai) == tz"America/Winnipeg"
    end

    @testset "legacy deserialization" begin
        # Serialized string generated on Intervals@1.2 with:
        # `julia --project -E 'using Serialization, Intervals; sprint(serialize, AnchoredInterval{-1,Int}(2, true, false))'`.
        buffer = IOBuffer(
            SERIALIZED_HEADER *
            "\x004\x10\x01\x10AnchoredInterval\x1f\v՞\x84\xec\xf7-`\x87\xbb" *
            "S\xe1Á\x88A\xd8\x01\tIntervalsD\x02\0\0\x001\xff\xff\xff\xff\0\b\xe14\x10" *
            "\x01\vInclusivity\x1f\v՞\x84\xec\xf7-`\x87\xbbS\xe1Á\x88A\xd8,\x02\0DML"
        )

        interval = deserialize(buffer)
        @test interval isa AnchoredInterval
        @test interval == AnchoredInterval{-1,Int,Closed,Open}(2)
    end
end
