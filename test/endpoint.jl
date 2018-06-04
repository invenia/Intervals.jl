using Intervals: LeftEndpoint, RightEndpoint

@testset "Endpoint" begin
    @testset "LeftEndpoint < LeftEndpoint" begin
        @test LeftEndpoint(1, false) < LeftEndpoint(2.0, false)
        @test LeftEndpoint(1, true) < LeftEndpoint(2.0, false)
        @test LeftEndpoint(1, false) < LeftEndpoint(2.0, true)
        @test LeftEndpoint(1, true) < LeftEndpoint(2.0, true)

        @test !(LeftEndpoint(1, false) < LeftEndpoint(1.0, false))
        @test LeftEndpoint(1, true) < LeftEndpoint(1.0, false)
        @test !(LeftEndpoint(1, false) < LeftEndpoint(1.0, true))
        @test !(LeftEndpoint(1, true) < LeftEndpoint(1.0, true))

        @test !(LeftEndpoint(2, false) < LeftEndpoint(1.0, false))
        @test !(LeftEndpoint(2, true) < LeftEndpoint(1.0, false))
        @test !(LeftEndpoint(2, false) < LeftEndpoint(1.0, true))
        @test !(LeftEndpoint(2, true) < LeftEndpoint(1.0, true))
    end

    @testset "LeftEndpoint <= LeftEndpoint" begin
        @test LeftEndpoint(1, false) <= LeftEndpoint(2.0, false)
        @test LeftEndpoint(1, true) <= LeftEndpoint(2.0, false)
        @test LeftEndpoint(1, false) <= LeftEndpoint(2.0, true)
        @test LeftEndpoint(1, true) <= LeftEndpoint(2.0, true)

        @test LeftEndpoint(1, false) <= LeftEndpoint(1.0, false)
        @test LeftEndpoint(1, true) <= LeftEndpoint(1.0, false)
        @test !(LeftEndpoint(1, false) <= LeftEndpoint(1.0, true))
        @test LeftEndpoint(1, true) <= LeftEndpoint(1.0, true)

        @test !(LeftEndpoint(2, false) <= LeftEndpoint(1.0, false))
        @test !(LeftEndpoint(2, true) <= LeftEndpoint(1.0, false))
        @test !(LeftEndpoint(2, false) <= LeftEndpoint(1.0, true))
        @test !(LeftEndpoint(2, true) <= LeftEndpoint(1.0, true))
    end

    @testset "RightEndpoint < RightEndpoint" begin
        @test RightEndpoint(1, false) < RightEndpoint(2.0, false)
        @test RightEndpoint(1, true) < RightEndpoint(2.0, false)
        @test RightEndpoint(1, false) < RightEndpoint(2.0, true)
        @test RightEndpoint(1, true) < RightEndpoint(2.0, true)

        @test !(RightEndpoint(1, false) < RightEndpoint(1.0, false))
        @test !(RightEndpoint(1, true) < RightEndpoint(1.0, false))
        @test RightEndpoint(1, false) < RightEndpoint(1.0, true)
        @test !(RightEndpoint(1, true) < RightEndpoint(1.0, true))

        @test !(RightEndpoint(2, false) < RightEndpoint(1.0, false))
        @test !(RightEndpoint(2, true) < RightEndpoint(1.0, false))
        @test !(RightEndpoint(2, false) < RightEndpoint(1.0, true))
        @test !(RightEndpoint(2, true) < RightEndpoint(1.0, true))
    end

    @testset "RightEndpoint <= RightEndpoint" begin
        @test RightEndpoint(1, false) <= RightEndpoint(2.0, false)
        @test RightEndpoint(1, true) <= RightEndpoint(2.0, false)
        @test RightEndpoint(1, false) <= RightEndpoint(2.0, true)
        @test RightEndpoint(1, true) <= RightEndpoint(2.0, true)

        @test RightEndpoint(1, false) <= RightEndpoint(1.0, false)
        @test !(RightEndpoint(1, true) <= RightEndpoint(1.0, false))
        @test RightEndpoint(1, false) <= RightEndpoint(1.0, true)
        @test RightEndpoint(1, true) <= RightEndpoint(1.0, true)

        @test !(RightEndpoint(2, false) <= RightEndpoint(1.0, false))
        @test !(RightEndpoint(2, true) <= RightEndpoint(1.0, false))
        @test !(RightEndpoint(2, false) <= RightEndpoint(1.0, true))
        @test !(RightEndpoint(2, true) <= RightEndpoint(1.0, true))
    end

    @testset "LeftEndpoint < RightEndpoint" begin
        @test LeftEndpoint(1, false) < RightEndpoint(2.0, false)
        @test LeftEndpoint(1, true) < RightEndpoint(2.0, false)
        @test LeftEndpoint(1, false) < RightEndpoint(2.0, true)
        @test LeftEndpoint(1, true) < RightEndpoint(2.0, true)

        @test !(LeftEndpoint(1, false) < RightEndpoint(1.0, false))
        @test !(LeftEndpoint(1, true) < RightEndpoint(1.0, false))
        @test !(LeftEndpoint(1, false) < RightEndpoint(1.0, true))
        @test !(LeftEndpoint(1, true) < RightEndpoint(1.0, true))

        @test !(LeftEndpoint(2, false) < RightEndpoint(1.0, false))
        @test !(LeftEndpoint(2, true) < RightEndpoint(1.0, false))
        @test !(LeftEndpoint(2, false) < RightEndpoint(1.0, true))
        @test !(LeftEndpoint(2, true) < RightEndpoint(1.0, true))
    end

    @testset "LeftEndpoint <= RightEndpoint" begin
        @test LeftEndpoint(1, false) <= RightEndpoint(2.0, false)
        @test LeftEndpoint(1, true) <= RightEndpoint(2.0, false)
        @test LeftEndpoint(1, false) <= RightEndpoint(2.0, true)
        @test LeftEndpoint(1, true) <= RightEndpoint(2.0, true)

        @test !(LeftEndpoint(1, false) <= RightEndpoint(1.0, false))
        @test !(LeftEndpoint(1, true) <= RightEndpoint(1.0, false))
        @test !(LeftEndpoint(1, false) <= RightEndpoint(1.0, true))
        @test LeftEndpoint(1, true) <= RightEndpoint(1.0, true)

        @test !(LeftEndpoint(2, false) <= RightEndpoint(1.0, false))
        @test !(LeftEndpoint(2, true) <= RightEndpoint(1.0, false))
        @test !(LeftEndpoint(2, false) <= RightEndpoint(1.0, true))
        @test !(LeftEndpoint(2, true) <= RightEndpoint(1.0, true))
    end

    @testset "RightEndpoint < LeftEndpoint" begin
        @test RightEndpoint(1, false) < LeftEndpoint(2.0, false)
        @test RightEndpoint(1, true) < LeftEndpoint(2.0, false)
        @test RightEndpoint(1, false) < LeftEndpoint(2.0, true)
        @test RightEndpoint(1, true) < LeftEndpoint(2.0, true)

        @test RightEndpoint(1, false) < LeftEndpoint(1.0, false)
        @test RightEndpoint(1, true) < LeftEndpoint(1.0, false)
        @test RightEndpoint(1, false) < LeftEndpoint(1.0, true)
        @test !(RightEndpoint(1, true) < LeftEndpoint(1.0, true))

        @test !(RightEndpoint(2, false) < LeftEndpoint(1.0, false))
        @test !(RightEndpoint(2, true) < LeftEndpoint(1.0, false))
        @test !(RightEndpoint(2, false) < LeftEndpoint(1.0, true))
        @test !(RightEndpoint(2, true) < LeftEndpoint(1.0, true))
    end

    @testset "RightEndpoint <= LeftEndpoint" begin
        @test RightEndpoint(1, false) <= LeftEndpoint(2.0, false)
        @test RightEndpoint(1, true) <= LeftEndpoint(2.0, false)
        @test RightEndpoint(1, false) <= LeftEndpoint(2.0, true)
        @test RightEndpoint(1, true) <= LeftEndpoint(2.0, true)

        @test RightEndpoint(1, false) <= LeftEndpoint(1.0, false)
        @test RightEndpoint(1, true) <= LeftEndpoint(1.0, false)
        @test RightEndpoint(1, false) <= LeftEndpoint(1.0, true)
        @test RightEndpoint(1, true) <= LeftEndpoint(1.0, true)

        @test !(RightEndpoint(2, false) <= LeftEndpoint(1.0, false))
        @test !(RightEndpoint(2, true) <= LeftEndpoint(1.0, false))
        @test !(RightEndpoint(2, false) <= LeftEndpoint(1.0, true))
        @test !(RightEndpoint(2, true) <= LeftEndpoint(1.0, true))
    end

    @testset "$Endpoint < Scalar" for Endpoint in (LeftEndpoint, RightEndpoint)
        @test Endpoint(1, false) < 2.0
        @test Endpoint(1, true) < 2.0

        @test (Endpoint(1, false) < 1.0) == (Endpoint === RightEndpoint)
        @test !(Endpoint(1, true) < 1.0)

        @test !(Endpoint(1, false) < 0.0)
        @test !(Endpoint(1, true) < 0.0)
    end

    @testset "Scalar < $Endpoint" for Endpoint in (LeftEndpoint, RightEndpoint)
        @test 0 < Endpoint(1.0, false)
        @test 0 < Endpoint(1.0, true)

        @test (1 < Endpoint(1.0, false)) == (Endpoint === LeftEndpoint)
        @test !(1 < Endpoint(1.0, true))

        @test !(2 < Endpoint(1.0, false))
        @test !(2 < Endpoint(1.0, true))
    end

    @testset "LeftEndpoint == LeftEndpoint" begin
        @test LeftEndpoint(1, false) != LeftEndpoint(2.0, false)
        @test LeftEndpoint(1, true) != LeftEndpoint(2.0, false)
        @test LeftEndpoint(1, false) != LeftEndpoint(2.0, true)
        @test LeftEndpoint(1, true) != LeftEndpoint(2.0, true)

        @test LeftEndpoint(1, false) == LeftEndpoint(1.0, false)
        @test LeftEndpoint(1, true) != LeftEndpoint(1.0, false)
        @test LeftEndpoint(1, false) != LeftEndpoint(1.0, true)
        @test LeftEndpoint(1, true) == LeftEndpoint(1.0, true)
    end

    @testset "RightEndpoint == RightEndpoint" begin
        @test RightEndpoint(1, false) != RightEndpoint(2.0, false)
        @test RightEndpoint(1, true) != RightEndpoint(2.0, false)
        @test RightEndpoint(1, false) != RightEndpoint(2.0, true)
        @test RightEndpoint(1, true) != RightEndpoint(2.0, true)

        @test RightEndpoint(1, false) == RightEndpoint(1.0, false)
        @test RightEndpoint(1, true) != RightEndpoint(1.0, false)
        @test RightEndpoint(1, false) != RightEndpoint(1.0, true)
        @test RightEndpoint(1, true) == RightEndpoint(1.0, true)
    end

    @testset "LeftEndpoint == RightEndpoint" begin
        @test LeftEndpoint(1, false) != RightEndpoint(2.0, false)
        @test LeftEndpoint(1, true) != RightEndpoint(2.0, false)
        @test LeftEndpoint(1, false) != RightEndpoint(2.0, true)
        @test LeftEndpoint(1, true) != RightEndpoint(2.0, true)

        @test LeftEndpoint(1, false) != RightEndpoint(1.0, false)
        @test LeftEndpoint(1, true) != RightEndpoint(1.0, false)
        @test LeftEndpoint(1, false) != RightEndpoint(1.0, true)
        @test LeftEndpoint(1, true) == RightEndpoint(1.0, true)
    end

    @testset "RightEndpoint == LeftEndpoint" begin
        @test RightEndpoint(1, false) != LeftEndpoint(2.0, false)
        @test RightEndpoint(1, true) != LeftEndpoint(2.0, false)
        @test RightEndpoint(1, false) != LeftEndpoint(2.0, true)
        @test RightEndpoint(1, true) != LeftEndpoint(2.0, true)

        @test RightEndpoint(1, false) != LeftEndpoint(1.0, false)
        @test RightEndpoint(1, true) != LeftEndpoint(1.0, false)
        @test RightEndpoint(1, false) != LeftEndpoint(1.0, true)
        @test RightEndpoint(1, true) == LeftEndpoint(1.0, true)
    end
end
