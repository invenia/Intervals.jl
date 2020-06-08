using Intervals: LeftEndpoint, RightEndpoint

@testset "Endpoint" begin
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
            @test !(LeftEndpoint{Unbounded}(1) < LeftEndpoint{Unbounded}(2.0))
            @test LeftEndpoint{Unbounded}(1) < LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Unbounded}(1) < LeftEndpoint{Closed}(2.0)
            @test !(LeftEndpoint{Open}(1) < LeftEndpoint{Unbounded}(2.0))
            @test !(LeftEndpoint{Closed}(1) < LeftEndpoint{Unbounded}(2.0))

            @test !(LeftEndpoint{Unbounded}(1) < LeftEndpoint{Unbounded}(1.0))
            @test LeftEndpoint{Unbounded}(1) < LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(1) < LeftEndpoint{Closed}(1.0)
            @test !(LeftEndpoint{Open}(1) < LeftEndpoint{Unbounded}(1.0))
            @test !(LeftEndpoint{Closed}(1) < LeftEndpoint{Unbounded}(1.0))

            @test !(LeftEndpoint{Unbounded}(2) < LeftEndpoint{Unbounded}(1.0))
            @test LeftEndpoint{Unbounded}(2) < LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(2) < LeftEndpoint{Closed}(1.0)
            @test !(LeftEndpoint{Open}(2) < LeftEndpoint{Unbounded}(1.0))
            @test !(LeftEndpoint{Closed}(2) < LeftEndpoint{Unbounded}(1.0))
        end

        @testset "LeftEndpoint <= LeftEndpoint" begin
            @test LeftEndpoint{Unbounded}(1) <= LeftEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Unbounded}(1) <= LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Unbounded}(1) <= LeftEndpoint{Closed}(2.0)
            @test !(LeftEndpoint{Open}(1) <= LeftEndpoint{Unbounded}(2.0))
            @test !(LeftEndpoint{Closed}(1) <= LeftEndpoint{Unbounded}(2.0))

            @test LeftEndpoint{Unbounded}(1) <= LeftEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(1) <= LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(1) <= LeftEndpoint{Closed}(1.0)
            @test !(LeftEndpoint{Open}(1) <= LeftEndpoint{Unbounded}(1.0))
            @test !(LeftEndpoint{Closed}(1) <= LeftEndpoint{Unbounded}(1.0))

            @test LeftEndpoint{Unbounded}(2) <= LeftEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(2) <= LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(2) <= LeftEndpoint{Closed}(1.0)
            @test !(LeftEndpoint{Open}(2) <= LeftEndpoint{Unbounded}(1.0))
            @test !(LeftEndpoint{Closed}(2) <= LeftEndpoint{Unbounded}(1.0))
        end

        @testset "RightEndpoint < RightEndpoint" begin
            @test !(RightEndpoint{Unbounded}(1) < RightEndpoint{Unbounded}(2.0))
            @test !(RightEndpoint{Unbounded}(1) < RightEndpoint{Open}(2.0))
            @test !(RightEndpoint{Unbounded}(1) < RightEndpoint{Closed}(2.0))
            @test RightEndpoint{Open}(1) < RightEndpoint{Unbounded}(2.0)
            @test RightEndpoint{Closed}(1) < RightEndpoint{Unbounded}(2.0)

            @test !(RightEndpoint{Unbounded}(1) < RightEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Unbounded}(1) < RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(1) < RightEndpoint{Closed}(1.0))
            @test RightEndpoint{Open}(1) < RightEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Closed}(1) < RightEndpoint{Unbounded}(1.0)

            @test !(RightEndpoint{Unbounded}(2) < RightEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Unbounded}(2) < RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(2) < RightEndpoint{Closed}(1.0))
            @test RightEndpoint{Open}(2) < RightEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Closed}(2) < RightEndpoint{Unbounded}(1.0)
        end

        @testset "RightEndpoint <= RightEndpoint" begin
            @test RightEndpoint{Unbounded}(1) <= RightEndpoint{Unbounded}(2.0)
            @test !(RightEndpoint{Unbounded}(1) <= RightEndpoint{Open}(2.0))
            @test !(RightEndpoint{Unbounded}(1) <= RightEndpoint{Closed}(2.0))
            @test RightEndpoint{Open}(1) <= RightEndpoint{Unbounded}(2.0)
            @test RightEndpoint{Closed}(1) <= RightEndpoint{Unbounded}(2.0)

            @test RightEndpoint{Unbounded}(1) <= RightEndpoint{Unbounded}(1.0)
            @test !(RightEndpoint{Unbounded}(1) <= RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(1) <= RightEndpoint{Closed}(1.0))
            @test RightEndpoint{Open}(1) <= RightEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Closed}(1) <= RightEndpoint{Unbounded}(1.0)

            @test RightEndpoint{Unbounded}(2) <= RightEndpoint{Unbounded}(1.0)
            @test !(RightEndpoint{Unbounded}(2) <= RightEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(2) <= RightEndpoint{Closed}(1.0))
            @test RightEndpoint{Open}(2) <= RightEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Closed}(2) <= RightEndpoint{Unbounded}(1.0)
        end

        @testset "LeftEndpoint < RightEndpoint" begin
            @test LeftEndpoint{Unbounded}(1) < RightEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Unbounded}(1) < RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Unbounded}(1) < RightEndpoint{Closed}(2.0)
            @test LeftEndpoint{Open}(1) < RightEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Closed}(1) < RightEndpoint{Unbounded}(2.0)

            @test LeftEndpoint{Unbounded}(1) < RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(1) < RightEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(1) < RightEndpoint{Closed}(1.0)
            @test LeftEndpoint{Open}(1) < RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Closed}(1) < RightEndpoint{Unbounded}(1.0)

            @test LeftEndpoint{Unbounded}(2) < RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(2) < RightEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(2) < RightEndpoint{Closed}(1.0)
            @test LeftEndpoint{Open}(2) < RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Closed}(2) < RightEndpoint{Unbounded}(1.0)
        end

        @testset "LeftEndpoint <= RightEndpoint" begin
            @test LeftEndpoint{Unbounded}(1) <= RightEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Unbounded}(1) <= RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Unbounded}(1) <= RightEndpoint{Closed}(2.0)
            @test LeftEndpoint{Open}(1) <= RightEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Closed}(1) <= RightEndpoint{Unbounded}(2.0)

            @test LeftEndpoint{Unbounded}(1) <= RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(1) <= RightEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(1) <= RightEndpoint{Closed}(1.0)
            @test LeftEndpoint{Open}(1) <= RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Closed}(1) <= RightEndpoint{Unbounded}(1.0)

            @test LeftEndpoint{Unbounded}(2) <= RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(2) <= RightEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(2) <= RightEndpoint{Closed}(1.0)
            @test LeftEndpoint{Open}(2) <= RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Closed}(2) <= RightEndpoint{Unbounded}(1.0)
        end

        @testset "RightEndpoint < LeftEndpoint" begin
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Unbounded}(2.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Open}(2.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Closed}(2.0))
            @test !(RightEndpoint{Open}(1) < LeftEndpoint{Unbounded}(2.0))
            @test !(RightEndpoint{Closed}(1) < LeftEndpoint{Unbounded}(2.0))

            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Open}(1) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Closed}(1) < LeftEndpoint{Unbounded}(1.0))

            @test !(RightEndpoint{Unbounded}(2) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Unbounded}(2) < LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(2) < LeftEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Open}(2) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Closed}(2) < LeftEndpoint{Unbounded}(1.0))
        end

        @testset "RightEndpoint <= LeftEndpoint" begin
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Unbounded}(2.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Open}(2.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Closed}(2.0))
            @test !(RightEndpoint{Open}(1) < LeftEndpoint{Unbounded}(2.0))
            @test !(RightEndpoint{Closed}(1) < LeftEndpoint{Unbounded}(2.0))

            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(1) < LeftEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Open}(1) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Closed}(1) < LeftEndpoint{Unbounded}(1.0))

            @test !(RightEndpoint{Unbounded}(2) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Unbounded}(2) < LeftEndpoint{Open}(1.0))
            @test !(RightEndpoint{Unbounded}(2) < LeftEndpoint{Closed}(1.0))
            @test !(RightEndpoint{Open}(2) < LeftEndpoint{Unbounded}(1.0))
            @test !(RightEndpoint{Closed}(2) < LeftEndpoint{Unbounded}(1.0))
        end

        @testset "LeftEndpoint < Scalar" begin
            @test LeftEndpoint{Unbounded}(0) < -Inf
            @test LeftEndpoint{Unbounded}(0) < Inf
        end

         @testset "LeftEndpoint <= Scalar" begin
            @test LeftEndpoint{Unbounded}(0) <= -Inf
            @test LeftEndpoint{Unbounded}(0) <= Inf
        end

        @testset "RightEndpoint < Scalar" begin
            @test !(RightEndpoint{Unbounded}(0) < -Inf)
            @test !(RightEndpoint{Unbounded}(0) < Inf)
        end

        @testset "RightEndpoint <= Scalar" begin
            @test !(RightEndpoint{Unbounded}(0) <= -Inf)
            @test !(RightEndpoint{Unbounded}(0) <= Inf)
        end

        @testset "Scalar < LeftEndpoint" begin
            @test !(-Inf < LeftEndpoint{Unbounded}(0))
            @test !(Inf < LeftEndpoint{Unbounded}(0))
        end

        @testset "Scalar <= LeftEndpoint" begin
            @test !(-Inf <= LeftEndpoint{Unbounded}(0))
            @test !(Inf <= LeftEndpoint{Unbounded}(0))
        end

        @testset "Scalar < RightEndpoint" begin
            @test -Inf < RightEndpoint{Unbounded}(0)
            @test Inf < RightEndpoint{Unbounded}(0)
        end

        @testset "Scalar < RightEndpoint" begin
            @test -Inf <= RightEndpoint{Unbounded}(0)
            @test Inf <= RightEndpoint{Unbounded}(0)
        end

        @testset "LeftEndpoint == LeftEndpoint" begin
            @test LeftEndpoint{Unbounded}(1) == LeftEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Unbounded}(1) != LeftEndpoint{Open}(2.0)
            @test LeftEndpoint{Unbounded}(1) != LeftEndpoint{Closed}(2.0)
            @test LeftEndpoint{Open}(1) != LeftEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Closed}(1) != LeftEndpoint{Unbounded}(2.0)

            @test LeftEndpoint{Unbounded}(1) == LeftEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(1) != LeftEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(1) != LeftEndpoint{Closed}(1.0)
            @test LeftEndpoint{Open}(1) != LeftEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Closed}(1) != LeftEndpoint{Unbounded}(1.0)
        end

        @testset "RightEndpoint == RightEndpoint" begin
            @test RightEndpoint{Unbounded}(1) == RightEndpoint{Unbounded}(2.0)
            @test RightEndpoint{Unbounded}(1) != RightEndpoint{Open}(2.0)
            @test RightEndpoint{Unbounded}(1) != RightEndpoint{Closed}(2.0)
            @test RightEndpoint{Open}(1) != RightEndpoint{Unbounded}(2.0)
            @test RightEndpoint{Closed}(1) != RightEndpoint{Unbounded}(2.0)

            @test RightEndpoint{Unbounded}(1) == RightEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Unbounded}(1) != RightEndpoint{Open}(1.0)
            @test RightEndpoint{Unbounded}(1) != RightEndpoint{Closed}(1.0)
            @test RightEndpoint{Open}(1) != RightEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Closed}(1) != RightEndpoint{Unbounded}(1.0)
        end

        @testset "LeftEndpoint == RightEndpoint" begin
            @test LeftEndpoint{Unbounded}(1) != RightEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Unbounded}(1) != RightEndpoint{Open}(2.0)
            @test LeftEndpoint{Unbounded}(1) != RightEndpoint{Closed}(2.0)
            @test LeftEndpoint{Open}(1) != RightEndpoint{Unbounded}(2.0)
            @test LeftEndpoint{Closed}(1) != RightEndpoint{Unbounded}(2.0)

            @test LeftEndpoint{Unbounded}(1) != RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Unbounded}(1) != RightEndpoint{Open}(1.0)
            @test LeftEndpoint{Unbounded}(1) != RightEndpoint{Closed}(1.0)
            @test LeftEndpoint{Open}(1) != RightEndpoint{Unbounded}(1.0)
            @test LeftEndpoint{Closed}(1) != RightEndpoint{Unbounded}(1.0)
        end

        @testset "RightEndpoint == LeftEndpoint" begin
            @test RightEndpoint{Unbounded}(1) != LeftEndpoint{Unbounded}(2.0)
            @test RightEndpoint{Unbounded}(1) != LeftEndpoint{Open}(2.0)
            @test RightEndpoint{Unbounded}(1) != LeftEndpoint{Closed}(2.0)
            @test RightEndpoint{Open}(1) != LeftEndpoint{Unbounded}(2.0)
            @test RightEndpoint{Closed}(1) != LeftEndpoint{Unbounded}(2.0)

            @test RightEndpoint{Unbounded}(1) != LeftEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Unbounded}(1) != LeftEndpoint{Open}(1.0)
            @test RightEndpoint{Unbounded}(1) != LeftEndpoint{Closed}(1.0)
            @test RightEndpoint{Open}(1) != LeftEndpoint{Unbounded}(1.0)
            @test RightEndpoint{Closed}(1) != LeftEndpoint{Unbounded}(1.0)
        end

        @testset "isequal" begin
            @test isequal(LeftEndpoint{Unbounded}(0.0), LeftEndpoint{Unbounded}(0.0))
            @test !isequal(LeftEndpoint{Unbounded}(-0.0), LeftEndpoint{Open}(0.0))
            @test !isequal(LeftEndpoint{Unbounded}(-0.0), LeftEndpoint{Closed}(0.0))
            @test !isequal(LeftEndpoint{Open}(0.0), LeftEndpoint{Unbounded}(-0.0))
            @test !isequal(LeftEndpoint{Closed}(0.0), LeftEndpoint{Unbounded}(-0.0))

            @test !isequal(RightEndpoint{Unbounded}(0.0), LeftEndpoint{Unbounded}(0.0))
            @test !isequal(LeftEndpoint{Unbounded}(0.0), RightEndpoint{Unbounded}(0.0))
        end

         @testset "hash" begin
            a = now(tz"Europe/London")
            b = deepcopy(a)
            @test hash(a) == hash(b)  # Double check

            @test hash(LeftEndpoint{Unbounded}(a)) == hash(LeftEndpoint{Unbounded}(b))
            @test hash(LeftEndpoint{Unbounded}(a)) != hash(LeftEndpoint{Open}(b))
            @test hash(LeftEndpoint{Unbounded}(a)) != hash(LeftEndpoint{Closed}(b))
            @test hash(LeftEndpoint{Open}(a)) != hash(LeftEndpoint{Unbounded}(b))
            @test hash(LeftEndpoint{Closed}(a)) != hash(LeftEndpoint{Unbounded}(b))

            @test hash(RightEndpoint{Unbounded}(a)) == hash(RightEndpoint{Unbounded}(b))
            @test hash(RightEndpoint{Unbounded}(a)) != hash(RightEndpoint{Open}(b))
            @test hash(RightEndpoint{Unbounded}(a)) != hash(RightEndpoint{Closed}(b))
            @test hash(RightEndpoint{Open}(a)) != hash(RightEndpoint{Unbounded}(b))
            @test hash(RightEndpoint{Closed}(a)) != hash(RightEndpoint{Unbounded}(b))

            @test hash(LeftEndpoint{Unbounded}(a)) != hash(RightEndpoint{Unbounded}(b))
            @test hash(LeftEndpoint{Unbounded}(a)) != hash(RightEndpoint{Open}(b))
            @test hash(LeftEndpoint{Unbounded}(a)) != hash(RightEndpoint{Closed}(b))
            @test hash(LeftEndpoint{Open}(a)) != hash(RightEndpoint{Unbounded}(b))
            @test hash(LeftEndpoint{Closed}(a)) != hash(RightEndpoint{Unbounded}(b))
        end
    end

    @testset "broadcast" begin
        test = [
            LeftEndpoint{Open}(0),
            LeftEndpoint{Closed}(0),
            LeftEndpoint{Unbounded}(0),
            RightEndpoint{Open}(0),
            RightEndpoint{Closed}(0),
            RightEndpoint{Unbounded}(0),
        ]

        # Verify that Endpoint is treated as a scalar during broadcast
        result = test .== 0
        @test result == [false, true, false, false, true, false]
    end
end
