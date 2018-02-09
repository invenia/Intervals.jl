@testset "Inclusivity" begin
    @testset "constructor" begin
        for (s, f) in [(false, false), (false, true), (true, false), (true, true)]
            inc = Inclusivity(s, f)
            @test (start(inc), finish(inc)) == (s, f)
        end

        @test Inclusivity(0) == Inclusivity(false, false)
        @test Inclusivity(1) == Inclusivity(true, false)
        @test Inclusivity(2) == Inclusivity(false, true)
        @test Inclusivity(3) == Inclusivity(true, true)
    end

    @testset "convert" begin
        for i in 0:3
            for T in [UInt8, UInt32, Int32, Int64]
                @test convert(T, Inclusivity(i)) == T(i)
            end
        end
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
