using Intervals: canonicalize

@testset "AnchoredInterval" begin
    dt = DateTime(2016, 8, 11, 2)

    @testset "constructor" begin
        expected = AnchoredInterval{Hour(-1), DateTime}(dt, Inclusivity(false, true))
        @test AnchoredInterval{Hour(-1), DateTime}(dt) == expected
        @test AnchoredInterval{Hour(-1)}(dt) == expected
        @test HourEnding{DateTime}(dt) == expected
        @test HourEnding(dt) == expected
        @test HE(dt) == expected
        @test HE(dt - Minute(59)) == expected

        expected = AnchoredInterval{Hour(1), DateTime}(dt, Inclusivity(true, false))
        @test AnchoredInterval{Hour(1), DateTime}(dt) == expected
        @test AnchoredInterval{Hour(1)}(dt) == expected
        @test HourBeginning{DateTime}(dt) == expected
        @test HourBeginning(dt) == expected
        @test HB(dt) == expected
        @test HB(dt + Minute(59)) == expected

        # Lazy inclusivity constructor
        @test HourEnding{DateTime}(dt, true, false) ==
            HourEnding{DateTime}(dt, Inclusivity(true, false))
        @test HourEnding(dt, true, false) == HourEnding(dt, Inclusivity(true, false))
        @test AnchoredInterval{Day(1), DateTime}(dt, false, false) ==
            AnchoredInterval{Day(1), DateTime}(dt, Inclusivity(false, false))
        @test AnchoredInterval{Day(1)}(dt, false, false) ==
            AnchoredInterval{Day(1)}(dt, Inclusivity(false, false))
        @test HE(dt, true, true) == HourEnding(dt, Inclusivity(true, true))
        @test HB(dt, true, true) == HourBeginning(dt, Inclusivity(true, true))

        # Non-period AnchoredIntervals
        @test AnchoredInterval{-10}(10) isa AnchoredInterval
        @test AnchoredInterval{25}('a') isa AnchoredInterval
    end

    @testset "non-ordered" begin
        ending = AnchoredInterval{-Inf}(Inf)
        @test isequal(first(ending), NaN)
        @test isequal(last(ending), Inf)
        @test ending == ending
        @test isequal(ending, ending)

        beginning = AnchoredInterval{Inf}(-Inf)
        @test isequal(first(beginning), -Inf)
        @test isequal(last(beginning), NaN)
        @test beginning == beginning
        @test isequal(beginning, beginning)
    end

    @testset "hash" begin
        # Need a complicated enough element type for this test to ever fail
        zdt = now(tz"Europe/London")
        a = HE(zdt)
        b = deepcopy(a)
        @test hash(a) == hash(b)
    end

    @testset "conversion" begin
        he = HourEnding(dt)
        hb = HourBeginning(dt)
        @test convert(DateTime, he) == dt
        @test convert(DateTime, hb) == dt
        @test convert(Interval, he) == Interval(dt - Hour(1), dt, Inclusivity(false, true))
        @test convert(Interval, hb) == Interval(dt, dt + Hour(1), Inclusivity(true, false))
        @test convert(Interval, he) == Interval(dt - Hour(1), dt, Inclusivity(false, true))
        @test convert(Interval, hb) == Interval(dt, dt + Hour(1), Inclusivity(true, false))
        @test convert(Interval{DateTime}, he) == Interval(dt - Hour(1), dt, Inclusivity(false, true))
        @test convert(Interval{DateTime}, hb) == Interval(dt, dt + Hour(1), Inclusivity(true, false))
    end

    @testset "eltype" begin
        @test eltype(AnchoredInterval{-10}(10)) == Int
        @test eltype(AnchoredInterval{25}('a')) == Char
        @test eltype(AnchoredInterval{Day(1)}(today())) == Date
        @test eltype(AnchoredInterval{Day(1),DateTime}(today())) == DateTime
        @test eltype(HourEnding(now())) == DateTime
    end

    @testset "accessors" begin
        inc = Inclusivity(true, true)
        P = Minute(-15)
        interval = AnchoredInterval{P}(dt, inc)

        @test first(interval) == DateTime(2016, 8, 11, 1, 45)
        @test last(interval) == dt
        @test span(interval) == -P
        @test inclusivity(interval) == inc

        inc = Inclusivity(false, false)
        P = Day(1)
        interval = AnchoredInterval{P}(Date(dt), inc)

        @test first(interval) == Date(2016, 8, 11)
        @test last(interval) == Date(2016, 8, 12)
        @test span(interval) == P
        @test inclusivity(interval) == inc

        # DST transition
        endpoint = ZonedDateTime(2018, 3, 11, 3, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)

        startpoint = ZonedDateTime(2018, 3, 11, tz"America/Winnipeg")
        interval = AnchoredInterval{Day(1)}(startpoint)
        @test first(interval) == startpoint
        @test last(interval) == ZonedDateTime(2018, 3, 12, tz"America/Winnipeg")
        @test span(interval) == Day(1)

        endpoint = ZonedDateTime(2018, 11, 4, 2, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)

        startpoint = ZonedDateTime(2018, 11, 4, tz"America/Winnipeg")
        interval = AnchoredInterval{Day(1)}(startpoint)
        @test first(interval) == startpoint
        @test last(interval) == ZonedDateTime(2018, 11, 5, tz"America/Winnipeg")
        @test span(interval) == Day(1)

        # Non-period AnchoredIntervals
        interval = AnchoredInterval{-10}(10)
        @test first(interval) == 0
        @test last(interval) == 10
        @test inclusivity(interval) == Inclusivity(false, true)
        @test span(interval) == 10

        interval = AnchoredInterval{25}('a')
        @test first(interval) == 'a'
        @test last(interval) == 'z'
        @test inclusivity(interval) == Inclusivity(true, false)
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

        @test sprint(show, AnchoredInterval{Hour(-1)}) ==
            mod_prefix * "AnchoredInterval{$(repr(Hour(-1))),T} where T"
        @test sprint(show, AnchoredInterval{Hour(1)}) ==
            mod_prefix * "AnchoredInterval{$(repr(Hour(1))),T} where T"

        @test sprint(show, AnchoredInterval{Day(-1)}) ==
            mod_prefix * "AnchoredInterval{$(repr(Day(-1))),T} where T"
        @test sprint(show, AnchoredInterval{Day(1)}) ==
            mod_prefix * "AnchoredInterval{$(repr(Day(1))),T} where T"
        @test sprint(show, AnchoredInterval{Day(-1), DateTime}) ==
            mod_prefix * "AnchoredInterval{$(repr(Day(-1))),DateTime}"
        @test sprint(show, AnchoredInterval{Day(1), DateTime}) ==
            mod_prefix * "AnchoredInterval{$(repr(Day(1))),DateTime}"

        # Tuples contain fields: interval, printed, shown
        tests = [
            (
                HourEnding(dt),
                "(2016-08-11 HE02]",
                string(
                    "AnchoredInterval{$(repr(Hour(-1))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2))), Inclusivity(false, true))",
                ),
            ),
            (
                HourEnding(DateTime(2013, 2, 13), Inclusivity(true, false)),
                "[2013-02-12 HE24)",
                string(
                    "AnchoredInterval{$(repr(Hour(-1))),DateTime}",
                    "($(repr(DateTime(2013, 2, 13))), Inclusivity(true, false))",
                ),
            ),
            (
                HourEnding(dt + Minute(15) + Second(30)),
                "(2016-08-11 HE02:15:30]",
                string(
                    "AnchoredInterval{$(repr(Hour(-1))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2, 15, 30))), Inclusivity(false, true))",
                ),
            ),
            (
                HourEnding(dt + Millisecond(2)),
                "(2016-08-11 HE02:00:00.002]",
                string(
                    "AnchoredInterval{$(repr(Hour(-1))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2, 0, 0, 2))), Inclusivity(false, true))",
                ),
            ),
            (
                HourEnding(DateTime(2013, 2, 13, 0, 1), Inclusivity(true, false)),
                "[2013-02-13 HE00:01:00)",
                string(
                    "AnchoredInterval{$(repr(Hour(-1))),DateTime}",
                    "($(repr(DateTime(2013, 2, 13, 0, 1))), Inclusivity(true, false))",
                ),
            ),
            (
                HourBeginning(dt),
                "[2016-08-11 HB02)",
                string(
                    "AnchoredInterval{$(repr(Hour(1))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2))), Inclusivity(true, false))",
                ),
            ),
            (
                HourBeginning(DateTime(2013, 2, 13), Inclusivity(false, true)),
                "(2013-02-13 HB00]",
                string(
                    "AnchoredInterval{$(repr(Hour(1))),DateTime}",
                    "($(repr(DateTime(2013, 2, 13))), Inclusivity(false, true))",
                ),
            ),
            (
                HourEnding(ZonedDateTime(dt, tz"America/Winnipeg")),
                "(2016-08-11 HE02-05:00]",
                string(
                    "AnchoredInterval{$(repr(Hour(-1))),$ZonedDateTime}",
                    "($(repr(ZonedDateTime(dt, tz"America/Winnipeg"))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Year(-1)}(Date(dt)),
                "(YE 2016-08-11]",
                string(
                    "AnchoredInterval{$(repr(Year(-1))),Date}",
                    "($(repr(Date(2016, 8, 11))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Year(-1)}(ceil(Date(dt), Year)),
                "(YE 2017-01-01]",
                string(
                    "AnchoredInterval{$(repr(Year(-1))),Date}",
                    "($(repr(Date(2017, 1, 1))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Month(-1)}(dt),
                "(MoE 2016-08-11 02:00:00]",
                string(
                    "AnchoredInterval{$(repr(Month(-1))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2, 0, 0))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Month(-1)}(ceil(dt, Month)),
                "(MoE 2016-09-01]",
                string(
                    "AnchoredInterval{$(repr(Month(-1))),DateTime}",
                    "($(repr(DateTime(2016, 9, 1))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Day(-1)}(DateTime(dt)),
                "(DE 2016-08-11 02:00:00]",
                string(
                    "AnchoredInterval{$(repr(Day(-1))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Day(-1)}(ceil(DateTime(dt), Day)),
                "(DE 2016-08-12]",
                string(
                    "AnchoredInterval{$(repr(Day(-1))),DateTime}",
                    "($(repr(DateTime(2016, 8, 12))), Inclusivity(false, true))",
                ),
            ),
            (
                # Date(dt) will truncate the DateTime to the nearest day
                AnchoredInterval{Day(-1)}(Date(dt)),
                "(DE 2016-08-11]",
                string(
                    "AnchoredInterval{$(repr(Day(-1))),Date}",
                    "($(repr(Date(2016, 8, 11))), Inclusivity(false, true))",
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
                    "AnchoredInterval{$(repr(Day(-1))),$ZonedDateTime}",
                    "($(repr(ZonedDateTime(2016, 8, 12, tz"America/Winnipeg"))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Minute(-5)}(dt),
                "(2016-08-11 5ME02:00]",
                string(
                    "AnchoredInterval{$(repr(Minute(-5))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Second(-30)}(dt),
                "(2016-08-11 30SE02:00:00]",
                string(
                    "AnchoredInterval{$(repr(Second(-30))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2))), Inclusivity(false, true))",
                ),
            ),
            (
                AnchoredInterval{Millisecond(-10)}(dt),
                "(2016-08-11 10msE02:00:00.000]",
                string(
                    "AnchoredInterval{$(repr(Millisecond(-10))),DateTime}",
                    "($(repr(DateTime(2016, 8, 11, 2))), Inclusivity(false, true))",
                ),
           ),
        ]

        for (interval, printed, shown) in tests
            shown = mod_prefix * shown

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
            mod_prefix * "AnchoredInterval{-10,$Int}(10, Inclusivity(false, true))"

        interval = AnchoredInterval{25}('a')
        @test string(interval) == "[a .. z)"
        @test sprint(show, interval, context=:compact=>true) == string(interval)
        @test sprint(show, interval) ==
            mod_prefix * "AnchoredInterval{25,Char}('a', Inclusivity(true, false))"
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

        diff_inc = HourEnding(dt, Inclusivity(true, true))

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
        @test dt - Hour(1) < HourEnding(dt, Inclusivity(false, false))
        @test !(dt - Hour(1) < HourEnding(dt, Inclusivity(true, true)))
        @test !(dt - Minute(30) < HourEnding(dt))
        @test !(dt < HourEnding(dt, Inclusivity(false, false)))
        @test !(dt < HourEnding(dt, Inclusivity(true, true)))
        @test !(dt + Hour(1) < HourEnding(dt))

        @test !(HourEnding(dt) < dt - Hour(2))
        @test !(HourEnding(dt, Inclusivity(false, false)) < dt - Hour(1))
        @test !(HourEnding(dt, Inclusivity(true, true)) < dt - Hour(1))
        @test HourEnding(dt) < dt - Minute(30)
        @test !(HourEnding(dt) ≪ dt - Minute(30))
        @test HourEnding(dt, Inclusivity(false, false)) < dt
        @test HourEnding(dt, Inclusivity(true, true)) < dt
        @test !(HourEnding(dt, Inclusivity(true, true)) ≪ dt)
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
        r1 = HourEnding(dt):HourEnding(dt + Day(1))
        r2 = HourEnding(dt):Hour(2):HourEnding(dt + Day(7))

        @test r1 isa StepRange
        @test length(r1) == 25
        @test collect(r1) == map(HourEnding, dt:Hour(1):dt + Day(1))

        @test r2 isa StepRange
        @test length(r2) == 12 * 7 + 1
        @test collect(r2) == map(HourEnding, dt:Hour(2):dt + Day(7))

        # DST transition
        spring = ZonedDateTime(2018, 3, 11, tz"America/Winnipeg")
        fall = ZonedDateTime(2018, 11, 4, tz"America/Winnipeg")
        r3 = HourEnding(spring):HourEnding(spring + Day(1))
        r4 = HourEnding(fall):Hour(1):HourEnding(fall + Day(1))

        @test r3 isa StepRange
        @test length(r3) == 24
        @test collect(r3) == map(HourEnding, spring:Hour(1):spring + Day(1))

        @test r4 isa StepRange
        @test length(r4) == 26
        @test collect(r4) == map(HourEnding, fall:Hour(1):fall + Day(1))

        r5 = AnchoredInterval{-1}(3, false, true):2:AnchoredInterval{-1}(7, true, true)
        @test length(r5) == 3
        @test collect(r5) == [
            AnchoredInterval{-1}(3, false, true),
            AnchoredInterval{-1}(5, false, true),
            AnchoredInterval{-1}(7, false, true),
        ]
    end

    @testset "isempty" begin
        for P in [Year(1), Month(1), Day(1), Hour(1), Minute(1), Second(1)]
            for sign in [+, -]
                @test !isempty(AnchoredInterval{sign(P)}(dt, Inclusivity(false, false)))
                @test !isempty(AnchoredInterval{sign(P)}(dt, Inclusivity(false, true)))
                @test !isempty(AnchoredInterval{sign(P)}(dt, Inclusivity(true, false)))
                @test !isempty(AnchoredInterval{sign(P)}(dt, Inclusivity(true, true)))
            end
        end

        for P in [Year(0), Month(0), Day(0), Hour(0), Minute(0), Second(0)]
            @test isempty(AnchoredInterval{P}(dt, Inclusivity(false, false)))
            @test isempty(AnchoredInterval{P}(dt, Inclusivity(false, true)))
            @test isempty(AnchoredInterval{P}(dt, Inclusivity(true, false)))
            @test !isempty(AnchoredInterval{P}(dt, Inclusivity(true, true)))
        end
    end

    @testset "in" begin
        @test !in(dt + Hour(1), HourEnding(dt))
        @test in(dt, HourEnding(dt))
        @test !in(dt, HourEnding(dt, Inclusivity(true, false)))
        @test in(dt - Minute(30), HourEnding(dt))
        @test !in(dt - Hour(1), HourEnding(dt))
        @test in(dt - Hour(1), HourEnding(dt, Inclusivity(true, false)))
        @test !in(dt - Hour(2), HourEnding(dt))

        @test !in(dt - Hour(1), HourBeginning(dt))
        @test in(dt, HourBeginning(dt))
        @test !in(dt, HourBeginning(dt, Inclusivity(false, true)))
        @test in(dt + Minute(30), HourBeginning(dt))
        @test !in(dt + Hour(1), HourBeginning(dt))
        @test in(dt + Hour(1), HourBeginning(dt, Inclusivity(false, true)))
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
        expected = AnchoredInterval{Hour(0)}(dt, Inclusivity(true, true))
        @test intersect(
            HourEnding(dt, Inclusivity(true, true)),
            HourEnding(dt + Hour(1), Inclusivity(true, true)),
        ) == expected

        # Hour overlap
        he = HourEnding(dt)
        @test intersect(he, AnchoredInterval{Hour(-2)}(dt)) == he
        @test intersect(AnchoredInterval{Hour(-3)}(dt + Hour(1)), he) == he
        @test intersect(HourBeginning(dt - Hour(1)), he) ==
            HourBeginning(dt - Hour(1), Inclusivity(false, false))

        # Identical save for inclusivity
        expected = HourEnding(dt, Inclusivity(false, false))
        @test intersect(
            HourEnding(dt, Inclusivity(false, false)),
            HourEnding(dt, Inclusivity(true, true)),
        ) == expected
        @test intersect(
            HourEnding(dt, Inclusivity(false, true)),
            HourEnding(dt, Inclusivity(true, false)),
        ) == expected

        # This should probably be an AnchoredInterval{Hour(0)}, but it's not important
        @test intersect(HourEnding(dt), HourBeginning(dt)) ==
            AnchoredInterval{Hour(0)}(dt, Inclusivity(true, true))

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

        for inclusivity in Inclusivity.(0:3)
            for tz in (tz"America/Winnipeg", tz"America/Regina", tz"UTC")
                @test isequal(
                    astimezone(HE(zdt, inclusivity), tz),
                    HE(astimezone(zdt, tz), inclusivity),
                )

                @test isequal(
                    astimezone(AnchoredInterval{Day(1)}(zdt, inclusivity), tz),
                    AnchoredInterval{Day(1)}(astimezone(zdt, tz), inclusivity),
                )
            end
        end
    end
end
