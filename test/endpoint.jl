using Intervals: Endpoint, Left, Right, LeftEndpoint, RightEndpoint

@testset "Endpoint" begin
    @testset "constructors" begin
        for D in (Left, Right)
            @test Endpoint{Int, D, Closed}(0).endpoint == 0
            @test Endpoint{Int, D, Open}(0).endpoint == 0
            @test Endpoint{Int, D, Unbounded}(nothing).endpoint isa Int

            @test_throws MethodError Endpoint{Int, D, Closed}(nothing)
            @test_throws MethodError Endpoint{Int, D, Open}(nothing)
            @test_throws MethodError Endpoint{Int, D, Unbounded}(0)

            @test_throws MethodError Endpoint{Nothing, D, Closed}(nothing)
            @test_throws MethodError Endpoint{Nothing, D, Open}(nothing)
            @test Endpoint{Nothing, D, Unbounded}(nothing).endpoint === nothing

            @test Endpoint{Int, D, Closed}(0.0).endpoint == 0
            @test Endpoint{Int, D, Open}(0.0).endpoint == 0
            @test_throws MethodError Endpoint{Int, D, Unbounded}(0.0)
        end
    end

    @testset "bounded" begin
        @testset "LeftEndpoint < LeftEndpoint" begin
            @test LeftEndpoint{Open}(1) < LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Closed}(1) < LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Open}(1) < LeftEndpoint{Closed}(2.0)
            @test LeftEndpoint{Closed}(1) < LeftEndpoint{Closed}(2.0)

            @test !(LeftEndpoint{Open}(1) < LeftEndpoint{Open}(1.0))
            @test LeftEndpoint{Closed}(1) < LeftEndpoint{Open}(1.0)
            @test !(LeftEndpoint{Open}(1) < LeftEndpoint{Closed}(1.0))
            @test !(LeftEndpoint{Closed}(1) < LeftEndpoint{Closed}(1.0))

            @test !(LeftEndpoint{Open}(2) < LeftEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Closed}(2) < LeftEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Open}(2) < LeftEndpoint{Closed}(1.0))
            @test !(LeftEndpoint{Closed}(2) < LeftEndpoint{Closed}(1.0))
        end

        @testset "LeftEndpoint <= LeftEndpoint" begin
            @test LeftEndpoint{Open}(1) <= LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Closed}(1) <= LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Open}(1) <= LeftEndpoint{Closed}(2.0)
            @test LeftEndpoint{Closed}(1) <= LeftEndpoint{Closed}(2.0)

            @test LeftEndpoint{Open}(1) <= LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Closed}(1) <= LeftEndpoint{Open}(1.0)
            @test !(LeftEndpoint{Open}(1) <= LeftEndpoint{Closed}(1.0))
            @test LeftEndpoint{Closed}(1) <= LeftEndpoint{Closed}(1.0)

            @test !(LeftEndpoint{Open}(2) <= LeftEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Closed}(2) <= LeftEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Open}(2) <= LeftEndpoint{Closed}(1.0))
            @test !(LeftEndpoint{Closed}(2) <= LeftEndpoint{Closed}(1.0))
        end

        @testset "RightEndpoint < RightEndpoint" begin
            @test RightEndpoint{Open}(1) < RightEndpoint{Open}(2.0)
            @test RightEndpoint{Closed}(1) < RightEndpoint{Open}(2.0)
            @test RightEndpoint{Open}(1) < RightEndpoint{Closed}(2.0)
            @test RightEndpoint{Closed}(1) < RightEndpoint{Closed}(2.0)

            @test !(RightEndpoint{Open}(1) < RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Closed}(1) < RightEndpoint{Open}(1.0))
            @test RightEndpoint{Open}(1) < RightEndpoint{Closed}(1.0)
            @test !(RightEndpoint{Closed}(1) < RightEndpoint{Closed}(1.0))

            @test !(RightEndpoint{Open}(2) < RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Closed}(2) < RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Open}(2) < RightEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Closed}(2) < RightEndpoint{Closed}(1.0))
        end

        @testset "RightEndpoint <= RightEndpoint" begin
            @test RightEndpoint{Open}(1) <= RightEndpoint{Open}(2.0)
            @test RightEndpoint{Closed}(1) <= RightEndpoint{Open}(2.0)
            @test RightEndpoint{Open}(1) <= RightEndpoint{Closed}(2.0)
            @test RightEndpoint{Closed}(1) <= RightEndpoint{Closed}(2.0)

            @test RightEndpoint{Open}(1) <= RightEndpoint{Open}(1.0)
            @test !(RightEndpoint{Closed}(1) <= RightEndpoint{Open}(1.0))
            @test RightEndpoint{Open}(1) <= RightEndpoint{Closed}(1.0)
            @test RightEndpoint{Closed}(1) <= RightEndpoint{Closed}(1.0)

            @test !(RightEndpoint{Open}(2) <= RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Closed}(2) <= RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Open}(2) <= RightEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Closed}(2) <= RightEndpoint{Closed}(1.0))
        end

        @testset "LeftEndpoint < RightEndpoint" begin
            @test LeftEndpoint{Open}(1) < RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Closed}(1) < RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Open}(1) < RightEndpoint{Closed}(2.0)
            @test LeftEndpoint{Closed}(1) < RightEndpoint{Closed}(2.0)

            @test !(LeftEndpoint{Open}(1) < RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Closed}(1) < RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Open}(1) < RightEndpoint{Closed}(1.0))
            @test !(LeftEndpoint{Closed}(1) < RightEndpoint{Closed}(1.0))

            @test !(LeftEndpoint{Open}(2) < RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Closed}(2) < RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Open}(2) < RightEndpoint{Closed}(1.0))
            @test !(LeftEndpoint{Closed}(2) < RightEndpoint{Closed}(1.0))
        end

        @testset "LeftEndpoint <= RightEndpoint" begin
            @test LeftEndpoint{Open}(1) <= RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Closed}(1) <= RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Open}(1) <= RightEndpoint{Closed}(2.0)
            @test LeftEndpoint{Closed}(1) <= RightEndpoint{Closed}(2.0)

            @test !(LeftEndpoint{Open}(1) <= RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Closed}(1) <= RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Open}(1) <= RightEndpoint{Closed}(1.0))
            @test LeftEndpoint{Closed}(1) <= RightEndpoint{Closed}(1.0)

            @test !(LeftEndpoint{Open}(2) <= RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Closed}(2) <= RightEndpoint{Open}(1.0))
            @test !(LeftEndpoint{Open}(2) <= RightEndpoint{Closed}(1.0))
            @test !(LeftEndpoint{Closed}(2) <= RightEndpoint{Closed}(1.0))
        end

        @testset "RightEndpoint < LeftEndpoint" begin
            @test RightEndpoint{Open}(1) < LeftEndpoint{Open}(2.0)
            @test RightEndpoint{Closed}(1) < LeftEndpoint{Open}(2.0)
            @test RightEndpoint{Open}(1) < LeftEndpoint{Closed}(2.0)
            @test RightEndpoint{Closed}(1) < LeftEndpoint{Closed}(2.0)

            @test RightEndpoint{Open}(1) < LeftEndpoint{Open}(1.0)
            @test RightEndpoint{Closed}(1) < LeftEndpoint{Open}(1.0)
            @test RightEndpoint{Open}(1) < LeftEndpoint{Closed}(1.0)
            @test !(RightEndpoint{Closed}(1) < LeftEndpoint{Closed}(1.0))

            @test !(RightEndpoint{Open}(2) < LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Closed}(2) < LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Open}(2) < LeftEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Closed}(2) < LeftEndpoint{Closed}(1.0))
        end

        @testset "RightEndpoint <= LeftEndpoint" begin
            @test RightEndpoint{Open}(1) <= LeftEndpoint{Open}(2.0)
            @test RightEndpoint{Closed}(1) <= LeftEndpoint{Open}(2.0)
            @test RightEndpoint{Open}(1) <= LeftEndpoint{Closed}(2.0)
            @test RightEndpoint{Closed}(1) <= LeftEndpoint{Closed}(2.0)

            @test RightEndpoint{Open}(1) <= LeftEndpoint{Open}(1.0)
            @test RightEndpoint{Closed}(1) <= LeftEndpoint{Open}(1.0)
            @test RightEndpoint{Open}(1) <= LeftEndpoint{Closed}(1.0)
            @test RightEndpoint{Closed}(1) <= LeftEndpoint{Closed}(1.0)

            @test !(RightEndpoint{Open}(2) <= LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Closed}(2) <= LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Open}(2) <= LeftEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Closed}(2) <= LeftEndpoint{Closed}(1.0))
        end

        @testset "$T < Scalar" for T in (LeftEndpoint, RightEndpoint)
            @test T{Open}(1) < 2.0
            @test T{Closed}(1) < 2.0

            @test (T{Open}(1) < 1.0) == (T === RightEndpoint)
            @test !(T{Closed}(1) < 1.0)

            @test !(T{Open}(1) < 0.0)
            @test !(T{Closed}(1) < 0.0)
        end

        @testset "$T <= Scalar" for T in (LeftEndpoint, RightEndpoint)
            @test T{Open}(1) <= 2.0
            @test T{Closed}(1) <= 2.0

            @test (T{Open}(1) <= 1.0) == (T === RightEndpoint)
            @test T{Closed}(1) <= 1.0

            @test !(T{Open}(1) <= 0.0)
            @test !(T{Closed}(1) <= 0.0)
        end

        @testset "Scalar < $T" for T in (LeftEndpoint, RightEndpoint)
            @test 0 < T{Open}(1.0)
            @test 0 < T{Closed}(1.0)

            @test (1 < T{Open}(1.0)) == (T === LeftEndpoint)
            @test !(1 < T{Closed}(1.0))

            @test !(2 < T{Open}(1.0))
            @test !(2 < T{Closed}(1.0))
        end

        @testset "Scalar <= $T" for T in (LeftEndpoint, RightEndpoint)
            @test 0 <= T{Open}(1.0)
            @test 0 <= T{Closed}(1.0)

            @test (1 <= T{Open}(1.0)) == (T === LeftEndpoint)
            @test 1 <= T{Closed}(1.0)

            @test !(2 <= T{Open}(1.0))
            @test !(2 <= T{Closed}(1.0))
        end

        @testset "LeftEndpoint == LeftEndpoint" begin
            @test LeftEndpoint{Open}(1) != LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Closed}(1) != LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Open}(1) != LeftEndpoint{Closed}(2.0)
            @test LeftEndpoint{Closed}(1) != LeftEndpoint{Closed}(2.0)

            @test LeftEndpoint{Open}(1) == LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Closed}(1) != LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Open}(1) != LeftEndpoint{Closed}(1.0)
            @test LeftEndpoint{Closed}(1) == LeftEndpoint{Closed}(1.0)
        end

        @testset "RightEndpoint == RightEndpoint" begin
            @test RightEndpoint{Open}(1) != RightEndpoint{Open}(2.0)
            @test RightEndpoint{Closed}(1) != RightEndpoint{Open}(2.0)
            @test RightEndpoint{Open}(1) != RightEndpoint{Closed}(2.0)
            @test RightEndpoint{Closed}(1) != RightEndpoint{Closed}(2.0)

            @test RightEndpoint{Open}(1) == RightEndpoint{Open}(1.0)
            @test RightEndpoint{Closed}(1) != RightEndpoint{Open}(1.0)
            @test RightEndpoint{Open}(1) != RightEndpoint{Closed}(1.0)
            @test RightEndpoint{Closed}(1) == RightEndpoint{Closed}(1.0)
        end

        @testset "LeftEndpoint == RightEndpoint" begin
            @test LeftEndpoint{Open}(1) != RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Closed}(1) != RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Open}(1) != RightEndpoint{Closed}(2.0)
            @test LeftEndpoint{Closed}(1) != RightEndpoint{Closed}(2.0)

            @test LeftEndpoint{Open}(1) != RightEndpoint{Open}(1.0)
            @test LeftEndpoint{Closed}(1) != RightEndpoint{Open}(1.0)
            @test LeftEndpoint{Open}(1) != RightEndpoint{Closed}(1.0)
            @test LeftEndpoint{Closed}(1) == RightEndpoint{Closed}(1.0)
        end

        @testset "RightEndpoint == LeftEndpoint" begin
            @test RightEndpoint{Open}(1) != LeftEndpoint{Open}(2.0)
            @test RightEndpoint{Closed}(1) != LeftEndpoint{Open}(2.0)
            @test RightEndpoint{Open}(1) != LeftEndpoint{Closed}(2.0)
            @test RightEndpoint{Closed}(1) != LeftEndpoint{Closed}(2.0)

            @test RightEndpoint{Open}(1) != LeftEndpoint{Open}(1.0)
            @test RightEndpoint{Closed}(1) != LeftEndpoint{Open}(1.0)
            @test RightEndpoint{Open}(1) != LeftEndpoint{Closed}(1.0)
            @test RightEndpoint{Closed}(1) == LeftEndpoint{Closed}(1.0)
        end

        @testset "$T == Scalar" for T in (LeftEndpoint, RightEndpoint)
            @test T{Open}(0) != 1.0
            @test T{Closed}(0) != 1.0

            @test T{Open}(1) != 1.0
            @test T{Closed}(1) == 1.0

            @test T{Open}(2) != 1.0
            @test T{Closed}(2) != 1.0
        end

        @testset "Scalar == $T" for T in (LeftEndpoint, RightEndpoint)
            @test 1.0 != T{Open}(0)
            @test 1.0 != T{Closed}(0)

            @test 1.0 != T{Open}(1)
            @test 1.0 == T{Closed}(1)

            @test 1.0 != T{Open}(2)
            @test 1.0 != T{Closed}(2)
        end

        @testset "isequal" begin
            @test isequal(LeftEndpoint{Closed}(0.0), LeftEndpoint{Closed}(0.0))
            @test isequal(LeftEndpoint{Open}(0.0), LeftEndpoint{Open}(0.0))
            @test !isequal(LeftEndpoint{Closed}(-0.0), LeftEndpoint{Open}(0.0))
            @test !isequal(LeftEndpoint{Open}(-0.0), LeftEndpoint{Closed}(0.0))
            @test !isequal(LeftEndpoint{Closed}(-0.0), LeftEndpoint{Closed}(0.0))
            @test !isequal(LeftEndpoint{Open}(-0.0), LeftEndpoint{Open}(0.0))

            @test isequal(RightEndpoint{Closed}(0.0), LeftEndpoint{Closed}(0.0))
            @test !isequal(LeftEndpoint{Closed}(-0.0), RightEndpoint{Open}(0.0))
            @test !isequal(RightEndpoint{Open}(-0.0), LeftEndpoint{Closed}(0.0))
            @test !isequal(LeftEndpoint{Closed}(-0.0), RightEndpoint{Closed}(0.0))
        end

        @testset "hash" begin
            # Need a complicated enough element type for this test to possibly fail. Using a
            # ZonedDateTime with a VariableTimeZone should do the trick.
            a = now(tz"Europe/London")
            b = deepcopy(a)
            @test hash(a) == hash(b)  # Double check

            @test hash(LeftEndpoint{Open}(a)) == hash(LeftEndpoint{Open}(b))
            @test hash(LeftEndpoint{Closed}(a)) != hash(LeftEndpoint{Open}(b))
            @test hash(LeftEndpoint{Open}(a)) != hash(LeftEndpoint{Closed}(b))
            @test hash(LeftEndpoint{Closed}(a)) == hash(LeftEndpoint{Closed}(b))

            @test hash(RightEndpoint{Open}(a)) == hash(RightEndpoint{Open}(b))
            @test hash(RightEndpoint{Closed}(a)) != hash(RightEndpoint{Open}(b))
            @test hash(RightEndpoint{Open}(a)) != hash(RightEndpoint{Closed}(b))
            @test hash(RightEndpoint{Closed}(a)) == hash(RightEndpoint{Closed}(b))

            @test hash(LeftEndpoint{Open}(a)) != hash(RightEndpoint{Open}(b))
            @test hash(LeftEndpoint{Closed}(a)) != hash(RightEndpoint{Open}(b))
            @test hash(LeftEndpoint{Open}(a)) != hash(RightEndpoint{Closed}(b))
            @test hash(LeftEndpoint{Closed}(a)) != hash(RightEndpoint{Closed}(b))
        end
    end

    # Note: The value for unbounded endpoints is irrelevant
    @testset "unbounded" begin
        @testset "LeftEndpoint < LeftEndpoint" begin
            @test !(LeftEndpoint{Unbounded}(nothing) < LeftEndpoint{Unbounded}(nothing))
            @test LeftEndpoint{Unbounded}(nothing) < LeftEndpoint{Open}(0.0)
            @test LeftEndpoint{Unbounded}(nothing) < LeftEndpoint{Closed}(0.0)
            @test !(LeftEndpoint{Open}(0) < LeftEndpoint{Unbounded}(nothing))
            @test !(LeftEndpoint{Closed}(0) < LeftEndpoint{Unbounded}(nothing))
        end

        @testset "LeftEndpoint <= LeftEndpoint" begin
            @test LeftEndpoint{Unbounded}(nothing) <= LeftEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Unbounded}(nothing) <= LeftEndpoint{Open}(0.0)
            @test LeftEndpoint{Unbounded}(nothing) <= LeftEndpoint{Closed}(0.0)
            @test !(LeftEndpoint{Open}(0) <= LeftEndpoint{Unbounded}(nothing))
            @test !(LeftEndpoint{Closed}(0) <= LeftEndpoint{Unbounded}(nothing))
        end

        @testset "RightEndpoint < RightEndpoint" begin
            @test !(RightEndpoint{Unbounded}(nothing) < RightEndpoint{Unbounded}(nothing))
            @test !(RightEndpoint{Unbounded}(nothing) < RightEndpoint{Open}(0.0))
            @test !(RightEndpoint{Unbounded}(nothing) < RightEndpoint{Closed}(0.0))
            @test RightEndpoint{Open}(0) < RightEndpoint{Unbounded}(nothing)
            @test RightEndpoint{Closed}(0) < RightEndpoint{Unbounded}(nothing)
        end

        @testset "RightEndpoint <= RightEndpoint" begin
            @test RightEndpoint{Unbounded}(nothing) <= RightEndpoint{Unbounded}(nothing)
            @test !(RightEndpoint{Unbounded}(nothing) <= RightEndpoint{Open}(0.0))
            @test !(RightEndpoint{Unbounded}(nothing) <= RightEndpoint{Closed}(0.0))
            @test RightEndpoint{Open}(0) <= RightEndpoint{Unbounded}(nothing)
            @test RightEndpoint{Closed}(0) <= RightEndpoint{Unbounded}(nothing)
        end

        @testset "LeftEndpoint < RightEndpoint" begin
            @test LeftEndpoint{Unbounded}(nothing) < RightEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Unbounded}(nothing) < RightEndpoint{Open}(0.0)
            @test LeftEndpoint{Unbounded}(nothing) < RightEndpoint{Closed}(0.0)
            @test LeftEndpoint{Open}(0) < RightEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Closed}(0) < RightEndpoint{Unbounded}(nothing)
        end

        @testset "LeftEndpoint <= RightEndpoint" begin
            @test LeftEndpoint{Unbounded}(nothing) <= RightEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Unbounded}(nothing) <= RightEndpoint{Open}(0.0)
            @test LeftEndpoint{Unbounded}(nothing) <= RightEndpoint{Closed}(0.0)
            @test LeftEndpoint{Open}(0) <= RightEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Closed}(0) <= RightEndpoint{Unbounded}(nothing)
        end

        @testset "RightEndpoint < LeftEndpoint" begin
            @test !(RightEndpoint{Unbounded}(nothing) < LeftEndpoint{Unbounded}(nothing))
            @test !(RightEndpoint{Unbounded}(nothing) < LeftEndpoint{Open}(0.0))
            @test !(RightEndpoint{Unbounded}(nothing) < LeftEndpoint{Closed}(0.0))
            @test !(RightEndpoint{Open}(0) < LeftEndpoint{Unbounded}(nothing))
            @test !(RightEndpoint{Closed}(0) < LeftEndpoint{Unbounded}(nothing))
        end

        @testset "RightEndpoint <= LeftEndpoint" begin
            @test !(RightEndpoint{Unbounded}(nothing) < LeftEndpoint{Unbounded}(nothing))
            @test !(RightEndpoint{Unbounded}(nothing) < LeftEndpoint{Open}(0.0))
            @test !(RightEndpoint{Unbounded}(nothing) < LeftEndpoint{Closed}(0.0))
            @test !(RightEndpoint{Open}(0) < LeftEndpoint{Unbounded}(nothing))
            @test !(RightEndpoint{Closed}(0) < LeftEndpoint{Unbounded}(nothing))
        end

        @testset "LeftEndpoint < Scalar" begin
            @test LeftEndpoint{Unbounded}(nothing) < -Inf
            @test LeftEndpoint{Unbounded}(nothing) < Inf
        end

         @testset "LeftEndpoint <= Scalar" begin
            @test LeftEndpoint{Unbounded}(nothing) <= -Inf
            @test LeftEndpoint{Unbounded}(nothing) <= Inf
        end

        @testset "RightEndpoint < Scalar" begin
            @test !(RightEndpoint{Unbounded}(nothing) < -Inf)
            @test !(RightEndpoint{Unbounded}(nothing) < Inf)
        end

        @testset "RightEndpoint <= Scalar" begin
            @test !(RightEndpoint{Unbounded}(nothing) <= -Inf)
            @test !(RightEndpoint{Unbounded}(nothing) <= Inf)
        end

        @testset "Scalar < LeftEndpoint" begin
            @test !(-Inf < LeftEndpoint{Unbounded}(nothing))
            @test !(Inf < LeftEndpoint{Unbounded}(nothing))
        end

        @testset "Scalar <= LeftEndpoint" begin
            @test !(-Inf <= LeftEndpoint{Unbounded}(nothing))
            @test !(Inf <= LeftEndpoint{Unbounded}(nothing))
        end

        @testset "Scalar < RightEndpoint" begin
            @test -Inf < RightEndpoint{Unbounded}(nothing)
            @test Inf < RightEndpoint{Unbounded}(nothing)
        end

        @testset "Scalar < RightEndpoint" begin
            @test -Inf <= RightEndpoint{Unbounded}(nothing)
            @test Inf <= RightEndpoint{Unbounded}(nothing)
        end

        @testset "LeftEndpoint == LeftEndpoint" begin
            @test LeftEndpoint{Unbounded}(nothing) == LeftEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Unbounded}(nothing) != LeftEndpoint{Open}(0.0)
            @test LeftEndpoint{Unbounded}(nothing) != LeftEndpoint{Closed}(0.0)
            @test LeftEndpoint{Open}(0) != LeftEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Closed}(0) != LeftEndpoint{Unbounded}(nothing)
        end

        @testset "RightEndpoint == RightEndpoint" begin
            @test RightEndpoint{Unbounded}(nothing) == RightEndpoint{Unbounded}(nothing)
            @test RightEndpoint{Unbounded}(nothing) != RightEndpoint{Open}(0.0)
            @test RightEndpoint{Unbounded}(nothing) != RightEndpoint{Closed}(0.0)
            @test RightEndpoint{Open}(0) != RightEndpoint{Unbounded}(nothing)
            @test RightEndpoint{Closed}(0) != RightEndpoint{Unbounded}(nothing)
        end

        @testset "LeftEndpoint == RightEndpoint" begin
            @test LeftEndpoint{Unbounded}(nothing) != RightEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Unbounded}(nothing) != RightEndpoint{Open}(0.0)
            @test LeftEndpoint{Unbounded}(nothing) != RightEndpoint{Closed}(0.0)
            @test LeftEndpoint{Open}(0) != RightEndpoint{Unbounded}(nothing)
            @test LeftEndpoint{Closed}(0) != RightEndpoint{Unbounded}(nothing)
        end

        @testset "RightEndpoint == LeftEndpoint" begin
            @test RightEndpoint{Unbounded}(nothing) != LeftEndpoint{Unbounded}(nothing)
            @test RightEndpoint{Unbounded}(nothing) != LeftEndpoint{Open}(0.0)
            @test RightEndpoint{Unbounded}(nothing) != LeftEndpoint{Closed}(0.0)
            @test RightEndpoint{Open}(0) != LeftEndpoint{Unbounded}(nothing)
            @test RightEndpoint{Closed}(0) != LeftEndpoint{Unbounded}(nothing)
        end

        @testset "isequal" begin
            T = Float64

            @test isequal(LeftEndpoint{T,Unbounded}(nothing), LeftEndpoint{T,Unbounded}(nothing))
            @test !isequal(LeftEndpoint{T,Unbounded}(nothing), LeftEndpoint{T,Open}(0.0))
            @test !isequal(LeftEndpoint{T,Unbounded}(nothing), LeftEndpoint{T,Closed}(0.0))
            @test !isequal(LeftEndpoint{T,Open}(-0.0), LeftEndpoint{T,Unbounded}(nothing))
            @test !isequal(LeftEndpoint{T,Closed}(-0.0), LeftEndpoint{T,Unbounded}(nothing))

            @test !isequal(RightEndpoint{Unbounded}(nothing), LeftEndpoint{Unbounded}(nothing))
            @test !isequal(LeftEndpoint{Unbounded}(nothing), RightEndpoint{Unbounded}(nothing))
        end

         @testset "hash" begin
            # Note: Unbounded endpoints should ignore the value
            T = Int

            left_unbounded = LeftEndpoint{T,Unbounded}(nothing)
            @test hash(left_unbounded) == hash(LeftEndpoint{T,Unbounded}(nothing))
            @test hash(left_unbounded) != hash(LeftEndpoint{Unbounded}(nothing))
            @test hash(left_unbounded) != hash(LeftEndpoint{Open}(left_unbounded.endpoint))
            @test hash(left_unbounded) != hash(LeftEndpoint{Closed}(left_unbounded.endpoint))

            right_unbounded = RightEndpoint{T,Unbounded}(nothing)
            @test hash(right_unbounded) == hash(RightEndpoint{T,Unbounded}(nothing))
            @test hash(right_unbounded) != hash(RightEndpoint{Unbounded}(nothing))
            @test hash(right_unbounded) != hash(RightEndpoint{Open}(right_unbounded.endpoint))
            @test hash(right_unbounded) != hash(RightEndpoint{Closed}(right_unbounded.endpoint))

            @test hash(LeftEndpoint{T,Unbounded}(nothing)) != hash(RightEndpoint{T,Unbounded}(nothing))
            @test hash(LeftEndpoint{T,Unbounded}(nothing)) != hash(RightEndpoint{T,Open}(0))
            @test hash(LeftEndpoint{T,Unbounded}(nothing)) != hash(RightEndpoint{T,Closed}(0))
            @test hash(LeftEndpoint{T,Open}(0)) != hash(RightEndpoint{T,Unbounded}(nothing))
            @test hash(LeftEndpoint{T,Closed}(0)) != hash(RightEndpoint{T,Unbounded}(nothing))
        end
    end

    @testset "broadcast" begin
        test = [
            LeftEndpoint{Open}(0),
            LeftEndpoint{Closed}(0),
            LeftEndpoint{Unbounded}(nothing),
            RightEndpoint{Open}(0),
            RightEndpoint{Closed}(0),
            RightEndpoint{Unbounded}(nothing),
        ]

        # Verify that Endpoint is treated as a scalar during broadcast
        result = test .== 0
        @test result == [false, true, false, false, true, false]
    end
end
