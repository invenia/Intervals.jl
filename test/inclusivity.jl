@testset "Inclusivity" begin
    @testset "constructor" begin
        for (s, f) in [(false, false), (false, true), (true, false), (true, true)]
            inc = Inclusivity(s, f)
            @test (first(inc), last(inc)) == (s, f)
        end

        @test Inclusivity(0) == Inclusivity(false, false)
        @test Inclusivity(1) == Inclusivity(true, false)
        @test Inclusivity(2) == Inclusivity(false, true)
        @test Inclusivity(3) == Inclusivity(true, true)
    end

    @testset "accessors" begin
        inc = Inclusivity(false, false)
        @test !first(inc)
        @test !last(inc)
        @test isopen(inc)
        @test !isclosed(inc)

        inc = Inclusivity(false, true)
        @test !first(inc)
        @test last(inc)
        @test !isopen(inc)
        @test !isclosed(inc)

        inc = Inclusivity(true, true)
        @test first(inc)
        @test last(inc)
        @test !isopen(inc)
        @test isclosed(inc)
    end

    @testset "convert" begin
        for i in 0:3
            for T in [UInt8, UInt32, Int32, Int64]
                @test convert(T, Inclusivity(i)) == T(i)
            end
        end
    end

    @testset "equality" begin
        inc = Inclusivity(false, true)
        cp = copy(inc)
        diff = Inclusivity(true, false)
        @test isequal(inc, cp)
        @test hash(inc) == hash(cp)
        @test !isequal(inc, diff)
        @test hash(inc) != hash(diff)

        # Verify that Inclusivity is treated as a scalar during broadcast
        @test size(Inclusivity(false, true) .== Inclusivity(false, true)) == ()
    end

    @testset "display" begin
        inc = Inclusivity(false, false)
        @test string(inc) == "Inclusivity (Open)"
        @test sprint(show, inc, context=:compact=>true) == string(inc)
        @test sprint(show, inc) == "Inclusivity(false, false)"

        inc = Inclusivity(false, true)
        @test string(inc) == "Inclusivity (Right]"
        @test sprint(show, inc, context=:compact=>true) == string(inc)
        @test sprint(show, inc) == "Inclusivity(false, true)"

        inc = Inclusivity(true, false)
        @test string(inc) == "Inclusivity [Left)"
        @test sprint(show, inc, context=:compact=>true) == string(inc)
        @test sprint(show, inc) == "Inclusivity(true, false)"

        inc = Inclusivity(true, true)
        @test string(inc) == "Inclusivity [Closed]"
        @test sprint(show, inc, context=:compact=>true) == string(inc)
        @test sprint(show, inc) == "Inclusivity(true, true)"
    end

    @testset "isless" begin
        @test isless(Inclusivity(0), Inclusivity(1))
        @test isless(Inclusivity(1), Inclusivity(2))
        @test isless(Inclusivity(2), Inclusivity(3))
        @test !isless(Inclusivity(0), Inclusivity(0))
        @test !isless(Inclusivity(1), Inclusivity(0))
    end

    @testset "sort" begin
        @test sort(map(Inclusivity, 0:3)) == map(Inclusivity, 0:3)
        @test sort(map(Inclusivity, 3:-1:0)) == map(Inclusivity, 0:3)
    end
end
