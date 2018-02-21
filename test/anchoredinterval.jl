@testset "AnchoredInterval" begin
    dt = DateTime(2016, 8, 11, 2)

    @testset "constructor" begin
        expected = AnchoredInterval{Hour(-1), DateTime}(dt, Inclusivity(false, true))
        @test AnchoredInterval{Hour(-1), DateTime}(dt) == expected
        @test AnchoredInterval{Hour(-1), DateTime}(dt - Minute(59)) == expected
        @test AnchoredInterval{Hour(-1)}(dt) == expected
        @test AnchoredInterval{Hour(-1)}(dt - Minute(59)) == expected
        @test HourEnding{DateTime}(dt) == expected
        @test HourEnding{DateTime}(dt - Minute(59)) == expected
        @test HourEnding(dt) == expected
        @test HourEnding(dt - Minute(59)) == expected

        expected = AnchoredInterval{Hour(1), DateTime}(dt, Inclusivity(true, false))
        @test AnchoredInterval{Hour(1), DateTime}(dt) == expected
        @test AnchoredInterval{Hour(1), DateTime}(dt + Minute(59)) == expected
        @test AnchoredInterval{Hour(1)}(dt) == expected
        @test AnchoredInterval{Hour(1)}(dt + Minute(59)) == expected
        @test HourBeginning{DateTime}(dt) == expected
        @test HourBeginning{DateTime}(dt + Minute(59)) == expected
        @test HourBeginning(dt) == expected
        @test HourBeginning(dt + Minute(59)) == expected

        # Non-period AnchoredIntervals
        @test AnchoredInterval{-10}(10) isa AnchoredInterval
        @test AnchoredInterval{25}('a') isa AnchoredInterval
    end

    @testset "conversion" begin
        he = HourEnding(dt)
        hb = HourBeginning(dt)
        @test DateTime(he) == dt
        @test DateTime(hb) == dt
        @test Interval{DateTime}(he) == Interval(dt - Hour(1), dt, Inclusivity(false, true))
        @test Interval{DateTime}(hb) == Interval(dt, dt + Hour(1), Inclusivity(true, false))
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
        interval = AnchoredInterval{P}(dt, inc)

        @test first(interval) == DateTime(2016, 8, 11)
        @test last(interval) == DateTime(2016, 8, 12)
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
        @test sprint(show, HourEnding) == "HourEnding{T}"
        @test sprint(show, HourBeginning) == "HourBeginning{T}"
        @test sprint(show, AnchoredInterval{Hour(-1)}) == "HourEnding{T}"
        @test sprint(show, AnchoredInterval{Hour(1)}) == "HourBeginning{T}"

        @test sprint(show, HourEnding{DateTime}) == "HourEnding{DateTime}"
        @test sprint(show, HourBeginning{DateTime}) == "HourBeginning{DateTime}"
        @test sprint(show, AnchoredInterval{Hour(-1), DateTime}) == "HourEnding{DateTime}"
        @test sprint(show, AnchoredInterval{Hour(1), DateTime}) == "HourBeginning{DateTime}"

        @test sprint(show, AnchoredInterval{Day(-1)}) ==
            "PeriodIntervals.AnchoredInterval{-1 day,T} where T"
        @test sprint(show, AnchoredInterval{Day(1)}) ==
            "PeriodIntervals.AnchoredInterval{1 day,T} where T"
        @test sprint(show, AnchoredInterval{Day(-1), DateTime}) ==
            "AnchoredInterval{-1 day, DateTime}"
        @test sprint(show, AnchoredInterval{Day(1), DateTime}) ==
            "AnchoredInterval{1 day, DateTime}"

        interval = HourEnding(dt)
        @test string(interval) == "(2016-08-11 HE02]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "HourEnding{DateTime}(2016-08-11T02:00:00, Inclusivity(false, true))"

        interval = HourEnding(DateTime(2013, 2, 13), Inclusivity(true, false))
        @test string(interval) == "[2013-02-12 HE24)"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "HourEnding{DateTime}(2013-02-13T00:00:00, Inclusivity(true, false))"

        interval = HourBeginning(dt)
        @test string(interval) == "[2016-08-11 HB02)"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "HourBeginning{DateTime}(2016-08-11T02:00:00, Inclusivity(true, false))"

        interval = HourBeginning(DateTime(2013, 2, 13), Inclusivity(false, true))
        @test string(interval) == "(2013-02-13 HB00]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "HourBeginning{DateTime}(2013-02-13T00:00:00, Inclusivity(false, true))"

        interval = HourEnding(ZonedDateTime(dt, tz"America/Winnipeg"))
        @test string(interval) == "(2016-08-11 HE02-05:00]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == string(
            "HourEnding{$ZonedDateTime}(2016-08-11T02:00:00-05:00, ",
            "Inclusivity(false, true))",
        )

        interval = AnchoredInterval{Year(-1)}(Date(dt))
        @test string(interval) == "(YE2017]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "AnchoredInterval{-1 year, Date}(2017-01-01, Inclusivity(false, true))"

        interval = AnchoredInterval{Month(-1)}(dt)
        @test string(interval) == "(2016 MoE09]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == string(
            "AnchoredInterval{-1 month, DateTime}(2016-09-01T00:00:00, ",
            "Inclusivity(false, true))",
        )

        interval = AnchoredInterval{Day(-1)}(DateTime(dt))
        @test string(interval) == "(2016-08 DE12]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "AnchoredInterval{-1 day, DateTime}(2016-08-12T00:00:00, Inclusivity(false, true))"

        # Date(dt) will truncate the DateTime to the nearest day instead of rounding up
        interval = AnchoredInterval{Day(-1)}(Date(dt))
        @test string(interval) == "(2016-08 DE11]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "AnchoredInterval{-1 day, Date}(2016-08-11, Inclusivity(false, true))"

        interval = AnchoredInterval{Minute(-5)}(dt)
        @test string(interval) == "(2016-08-11 5ME02:00]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == string(
            "AnchoredInterval{-5 minutes, DateTime}(2016-08-11T02:00:00, ",
            "Inclusivity(false, true))",
        )

        interval = AnchoredInterval{Second(-30)}(dt)
        @test string(interval) == "(2016-08-11 30SE02:00:00]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) == string(
            "AnchoredInterval{-30 seconds, DateTime}(2016-08-11T02:00:00, ",
            "Inclusivity(false, true))",
        )

        # Non-period AnchoredIntervals
        interval = AnchoredInterval{-10}(10)
        @test string(interval) == "(0..10]"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "AnchoredInterval{-10, $Int}(10, Inclusivity(false, true))"

        interval = AnchoredInterval{25}('a')
        @test string(interval) == "[a..z)"
        @test sprint(showcompact, interval) == string(interval)
        @test sprint(show, interval) ==
            "AnchoredInterval{25, Char}('a', Inclusivity(true, false))"
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

        @test !isless(he, hb)
        @test !isless(hb, he)

        @test isless(he, he + Hour(1))
        @test isless(hb, hb + Hour(1))

        @test isless(diff_inc, diff_inc + Hour(2))
        @test !isless(diff_inc, diff_inc + Hour(1))     # Overlap for an instant

        # DST transition
        hour1 = HourEnding(ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 1))
        hour2 = HourEnding(ZonedDateTime(2018, 11, 4, 1, tz"America/Winnipeg", 2))
        @test hour1 != hour2
        @test !isequal(hour1, hour2)
        @test hash(hour1) != hash(hour2)
        @test isless(hour1, hour2)

        # Comparisons between AnchoredInterval{P, T} and T
        @test isless(dt - Hour(2), HourEnding(dt))
        @test isless(dt - Hour(1), HourEnding(dt, Inclusivity(false, false)))
        @test !isless(dt - Hour(1), HourEnding(dt, Inclusivity(true, true)))
        @test !isless(dt - Minute(30), HourEnding(dt))
        @test !isless(dt, HourEnding(dt, Inclusivity(false, false)))
        @test !isless(dt, HourEnding(dt, Inclusivity(true, true)))
        @test !isless(dt + Hour(1), HourEnding(dt))

        @test !isless(HourEnding(dt), dt - Hour(2))
        @test !isless(HourEnding(dt, Inclusivity(false, false)), dt - Hour(1))
        @test !isless(HourEnding(dt, Inclusivity(true, true)), dt - Hour(1))
        @test !isless(HourEnding(dt), dt - Minute(30))
        @test isless(HourEnding(dt, Inclusivity(false, false)), dt)
        @test !isless(HourEnding(dt, Inclusivity(true, true)), dt)
        @test isless(HourEnding(dt), dt + Hour(1))
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

        @test_throws MethodError Hour(1) - he
        @test_throws MethodError Hour(1) - hb

        # DST transition
        endpoint = ZonedDateTime(2018, 3, 11, 3, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)

        endpoint = ZonedDateTime(2018, 11, 4, 2, tz"America/Winnipeg")
        interval = AnchoredInterval{Hour(-2)}(endpoint)
        @test span(interval) == Hour(2)
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
        expected = Interval(dt, dt, Inclusivity(true, true))
        @test intersect(
            HourEnding(dt, Inclusivity(true, true)),
            HourEnding(dt + Hour(1), Inclusivity(true, true)),
        ) == expected

        # Hour overlap
        he = HourEnding(dt)
        @test intersect(he, AnchoredInterval{Hour(-2)}(dt)) == Interval{DateTime}(he)
        @test intersect(AnchoredInterval{Hour(-3)}(dt + Hour(1)), he) ==
            Interval{DateTime}(he)

        # Identical save for inclusivity
        expected = Interval(dt - Hour(1), dt, Inclusivity(false, false))
        @test intersect(
            HourEnding(dt, Inclusivity(false, false)),
            HourEnding(dt, Inclusivity(true, true)),
        ) == expected
        @test intersect(
            HourEnding(dt, Inclusivity(false, true)),
            HourEnding(dt, Inclusivity(true, false)),
        ) == expected
    end
end
