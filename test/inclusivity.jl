@testset "Inclusivity" begin
    @testset "constructor" begin
        for (start, finish) in [(false, false), (false, true), (true, false), (true, true)]
            inc = S3DB.Inclusivity(start, finish)
            @test (inc.start, inc.finish) == (start, finish)
        end

        @test S3DB.Inclusivity(0) == S3DB.Inclusivity(false, false)
        @test S3DB.Inclusivity(1) == S3DB.Inclusivity(true, false)
        @test S3DB.Inclusivity(2) == S3DB.Inclusivity(false, true)
        @test S3DB.Inclusivity(3) == S3DB.Inclusivity(true, true)
    end

    @testset "convert" begin
        for i in 0:3
            for T in [UInt8, UInt32, Int32, Int64]
                @test convert(T, S3DB.Inclusivity(i)) == T(i)
            end
        end
    end

    @testset "isless" begin
        @test isless(S3DB.Inclusivity(0), S3DB.Inclusivity(1))
        @test isless(S3DB.Inclusivity(1), S3DB.Inclusivity(2))
        @test isless(S3DB.Inclusivity(2), S3DB.Inclusivity(3))
        @test !isless(S3DB.Inclusivity(0), S3DB.Inclusivity(0))
        @test !isless(S3DB.Inclusivity(1), S3DB.Inclusivity(0))
    end

    @testset "sort" begin
        @test sort(map(S3DB.Inclusivity, 0:3)) == map(S3DB.Inclusivity, 0:3)
        @test sort(map(S3DB.Inclusivity, 3:-1:0)) == map(S3DB.Inclusivity, 0:3)
    end
end
