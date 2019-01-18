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

    @testset "$Endpoint <= Scalar" for Endpoint in (LeftEndpoint, RightEndpoint)
        @test Endpoint(1, false) <= 2.0
        @test Endpoint(1, true) <= 2.0

        @test (Endpoint(1, false) <= 1.0) == (Endpoint === RightEndpoint)
        @test Endpoint(1, true) <= 1.0

        @test !(Endpoint(1, false) <= 0.0)
        @test !(Endpoint(1, true) <= 0.0)
    end

    @testset "Scalar < $Endpoint" for Endpoint in (LeftEndpoint, RightEndpoint)
        @test 0 < Endpoint(1.0, false)
        @test 0 < Endpoint(1.0, true)

        @test (1 < Endpoint(1.0, false)) == (Endpoint === LeftEndpoint)
        @test !(1 < Endpoint(1.0, true))

        @test !(2 < Endpoint(1.0, false))
        @test !(2 < Endpoint(1.0, true))
    end

    @testset "Scalar <= $Endpoint" for Endpoint in (LeftEndpoint, RightEndpoint)
        @test 0 <= Endpoint(1.0, false)
        @test 0 <= Endpoint(1.0, true)

        @test (1 <= Endpoint(1.0, false)) == (Endpoint === LeftEndpoint)
        @test 1 <= Endpoint(1.0, true)

        @test !(2 <= Endpoint(1.0, false))
        @test !(2 <= Endpoint(1.0, true))
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

    @testset "$Endpoint == Scalar" for Endpoint in (LeftEndpoint, RightEndpoint)
        @test Endpoint(0, false) != 1.0
        @test Endpoint(0, true) != 1.0

        @test Endpoint(1, false) != 1.0
        @test Endpoint(1, true) == 1.0

        @test Endpoint(2, false) != 1.0
        @test Endpoint(2, true) != 1.0
    end

    @testset "Scalar == $Endpoint" for Endpoint in (LeftEndpoint, RightEndpoint)
        @test 1.0 != Endpoint(0, false)
        @test 1.0 != Endpoint(0, true)

        @test 1.0 != Endpoint(1, false)
        @test 1.0 == Endpoint(1, true)

        @test 1.0 != Endpoint(2, false)
        @test 1.0 != Endpoint(2, true)

        # Verify that Endpoint is treated as a scalar during broadcast
        result = 1.0 .== [Endpoint(1, false), Endpoint(1, true)]
        @test result == [false, true]
    end

    @testset "isequal" begin
        @test isequal(LeftEndpoint(0.0, true), LeftEndpoint(0.0, true))
        @test isequal(LeftEndpoint(0.0, false), LeftEndpoint(0.0, false))
        @test !isequal(LeftEndpoint(-0.0, true), LeftEndpoint(0.0, false))
        @test !isequal(LeftEndpoint(-0.0, false), LeftEndpoint(0.0, true))
        @test !isequal(LeftEndpoint(-0.0, true), LeftEndpoint(0.0, true))
        @test !isequal(LeftEndpoint(-0.0, false), LeftEndpoint(0.0, false))

        @test isequal(RightEndpoint(0.0, true), LeftEndpoint(0.0, true))
        @test !isequal(LeftEndpoint(-0.0, true), RightEndpoint(0.0, false))
        @test !isequal(RightEndpoint(-0.0, false), LeftEndpoint(0.0, true))
        @test !isequal(LeftEndpoint(-0.0, true), RightEndpoint(0.0, true))
    end

    @testset "hash" begin
        # Need a complicated enough element type for this test to possibly fail. Using a
        # ZonedDateTime with a VariableTimeZone should do the trick.
        a = now(tz"Europe/London")
        b = deepcopy(a)
        @test hash(a) == hash(b)  # Double check

        @test hash(LeftEndpoint(a, false)) == hash(LeftEndpoint(b, false))
        @test hash(LeftEndpoint(a, true)) != hash(LeftEndpoint(b, false))
        @test hash(LeftEndpoint(a, false)) != hash(LeftEndpoint(b, true))
        @test hash(LeftEndpoint(a, true)) == hash(LeftEndpoint(b, true))

        @test hash(RightEndpoint(a, false)) == hash(RightEndpoint(b, false))
        @test hash(RightEndpoint(a, true)) != hash(RightEndpoint(b, false))
        @test hash(RightEndpoint(a, false)) != hash(RightEndpoint(b, true))
        @test hash(RightEndpoint(a, true)) == hash(RightEndpoint(b, true))

        @test hash(LeftEndpoint(a, false)) != hash(RightEndpoint(b, false))
        @test hash(LeftEndpoint(a, true)) != hash(RightEndpoint(b, false))
        @test hash(LeftEndpoint(a, false)) != hash(RightEndpoint(b, true))
        @test hash(LeftEndpoint(a, true)) != hash(RightEndpoint(b, true))
    end
end
