@testset "Endpoint" begin
    @testset "constructors" begin
        for D in (Lower, Upper)
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
        @testset "LowerEndpoint < LowerEndpoint" begin
            @test LowerEndpoint{Open}(1) < LowerEndpoint{Open}(2.0)
            @test LowerEndpoint{Closed}(1) < LowerEndpoint{Open}(2.0)
            @test LowerEndpoint{Open}(1) < LowerEndpoint{Closed}(2.0)
            @test LowerEndpoint{Closed}(1) < LowerEndpoint{Closed}(2.0)

            @test !(LowerEndpoint{Open}(1) < LowerEndpoint{Open}(1.0))
            @test LowerEndpoint{Closed}(1) < LowerEndpoint{Open}(1.0)
            @test !(LowerEndpoint{Open}(1) < LowerEndpoint{Closed}(1.0))
            @test !(LowerEndpoint{Closed}(1) < LowerEndpoint{Closed}(1.0))

            @test !(LowerEndpoint{Open}(2) < LowerEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Closed}(2) < LowerEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Open}(2) < LowerEndpoint{Closed}(1.0))
            @test !(LowerEndpoint{Closed}(2) < LowerEndpoint{Closed}(1.0))
        end

        @testset "LowerEndpoint <= LowerEndpoint" begin
            @test LowerEndpoint{Open}(1) <= LowerEndpoint{Open}(2.0)
            @test LowerEndpoint{Closed}(1) <= LowerEndpoint{Open}(2.0)
            @test LowerEndpoint{Open}(1) <= LowerEndpoint{Closed}(2.0)
            @test LowerEndpoint{Closed}(1) <= LowerEndpoint{Closed}(2.0)

            @test LowerEndpoint{Open}(1) <= LowerEndpoint{Open}(1.0)
            @test LowerEndpoint{Closed}(1) <= LowerEndpoint{Open}(1.0)
            @test !(LowerEndpoint{Open}(1) <= LowerEndpoint{Closed}(1.0))
            @test LowerEndpoint{Closed}(1) <= LowerEndpoint{Closed}(1.0)

            @test !(LowerEndpoint{Open}(2) <= LowerEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Closed}(2) <= LowerEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Open}(2) <= LowerEndpoint{Closed}(1.0))
            @test !(LowerEndpoint{Closed}(2) <= LowerEndpoint{Closed}(1.0))
        end

        @testset "UpperEndpoint < UpperEndpoint" begin
            @test UpperEndpoint{Open}(1) < UpperEndpoint{Open}(2.0)
            @test UpperEndpoint{Closed}(1) < UpperEndpoint{Open}(2.0)
            @test UpperEndpoint{Open}(1) < UpperEndpoint{Closed}(2.0)
            @test UpperEndpoint{Closed}(1) < UpperEndpoint{Closed}(2.0)

            @test !(UpperEndpoint{Open}(1) < UpperEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Closed}(1) < UpperEndpoint{Open}(1.0))
            @test UpperEndpoint{Open}(1) < UpperEndpoint{Closed}(1.0)
            @test !(UpperEndpoint{Closed}(1) < UpperEndpoint{Closed}(1.0))

            @test !(UpperEndpoint{Open}(2) < UpperEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Closed}(2) < UpperEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Open}(2) < UpperEndpoint{Closed}(1.0))
            @test !(UpperEndpoint{Closed}(2) < UpperEndpoint{Closed}(1.0))
        end

        @testset "UpperEndpoint <= UpperEndpoint" begin
            @test UpperEndpoint{Open}(1) <= UpperEndpoint{Open}(2.0)
            @test UpperEndpoint{Closed}(1) <= UpperEndpoint{Open}(2.0)
            @test UpperEndpoint{Open}(1) <= UpperEndpoint{Closed}(2.0)
            @test UpperEndpoint{Closed}(1) <= UpperEndpoint{Closed}(2.0)

            @test UpperEndpoint{Open}(1) <= UpperEndpoint{Open}(1.0)
            @test !(UpperEndpoint{Closed}(1) <= UpperEndpoint{Open}(1.0))
            @test UpperEndpoint{Open}(1) <= UpperEndpoint{Closed}(1.0)
            @test UpperEndpoint{Closed}(1) <= UpperEndpoint{Closed}(1.0)

            @test !(UpperEndpoint{Open}(2) <= UpperEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Closed}(2) <= UpperEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Open}(2) <= UpperEndpoint{Closed}(1.0))
            @test !(UpperEndpoint{Closed}(2) <= UpperEndpoint{Closed}(1.0))
        end

        @testset "LowerEndpoint < UpperEndpoint" begin
            @test LowerEndpoint{Open}(1) < UpperEndpoint{Open}(2.0)
            @test LowerEndpoint{Closed}(1) < UpperEndpoint{Open}(2.0)
            @test LowerEndpoint{Open}(1) < UpperEndpoint{Closed}(2.0)
            @test LowerEndpoint{Closed}(1) < UpperEndpoint{Closed}(2.0)

            @test !(LowerEndpoint{Open}(1) < UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Closed}(1) < UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Open}(1) < UpperEndpoint{Closed}(1.0))
            @test !(LowerEndpoint{Closed}(1) < UpperEndpoint{Closed}(1.0))

            @test !(LowerEndpoint{Open}(2) < UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Closed}(2) < UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Open}(2) < UpperEndpoint{Closed}(1.0))
            @test !(LowerEndpoint{Closed}(2) < UpperEndpoint{Closed}(1.0))
        end

        @testset "LowerEndpoint <= UpperEndpoint" begin
            @test LowerEndpoint{Open}(1) <= UpperEndpoint{Open}(2.0)
            @test LowerEndpoint{Closed}(1) <= UpperEndpoint{Open}(2.0)
            @test LowerEndpoint{Open}(1) <= UpperEndpoint{Closed}(2.0)
            @test LowerEndpoint{Closed}(1) <= UpperEndpoint{Closed}(2.0)

            @test !(LowerEndpoint{Open}(1) <= UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Closed}(1) <= UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Open}(1) <= UpperEndpoint{Closed}(1.0))
            @test LowerEndpoint{Closed}(1) <= UpperEndpoint{Closed}(1.0)

            @test !(LowerEndpoint{Open}(2) <= UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Closed}(2) <= UpperEndpoint{Open}(1.0))
            @test !(LowerEndpoint{Open}(2) <= UpperEndpoint{Closed}(1.0))
            @test !(LowerEndpoint{Closed}(2) <= UpperEndpoint{Closed}(1.0))
        end

        @testset "UpperEndpoint < LowerEndpoint" begin
            @test UpperEndpoint{Open}(1) < LowerEndpoint{Open}(2.0)
            @test UpperEndpoint{Closed}(1) < LowerEndpoint{Open}(2.0)
            @test UpperEndpoint{Open}(1) < LowerEndpoint{Closed}(2.0)
            @test UpperEndpoint{Closed}(1) < LowerEndpoint{Closed}(2.0)

            @test UpperEndpoint{Open}(1) < LowerEndpoint{Open}(1.0)
            @test UpperEndpoint{Closed}(1) < LowerEndpoint{Open}(1.0)
            @test UpperEndpoint{Open}(1) < LowerEndpoint{Closed}(1.0)
            @test !(UpperEndpoint{Closed}(1) < LowerEndpoint{Closed}(1.0))

            @test !(UpperEndpoint{Open}(2) < LowerEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Closed}(2) < LowerEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Open}(2) < LowerEndpoint{Closed}(1.0))
            @test !(UpperEndpoint{Closed}(2) < LowerEndpoint{Closed}(1.0))
        end

        @testset "UpperEndpoint <= LowerEndpoint" begin
            @test UpperEndpoint{Open}(1) <= LowerEndpoint{Open}(2.0)
            @test UpperEndpoint{Closed}(1) <= LowerEndpoint{Open}(2.0)
            @test UpperEndpoint{Open}(1) <= LowerEndpoint{Closed}(2.0)
            @test UpperEndpoint{Closed}(1) <= LowerEndpoint{Closed}(2.0)

            @test UpperEndpoint{Open}(1) <= LowerEndpoint{Open}(1.0)
            @test UpperEndpoint{Closed}(1) <= LowerEndpoint{Open}(1.0)
            @test UpperEndpoint{Open}(1) <= LowerEndpoint{Closed}(1.0)
            @test UpperEndpoint{Closed}(1) <= LowerEndpoint{Closed}(1.0)

            @test !(UpperEndpoint{Open}(2) <= LowerEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Closed}(2) <= LowerEndpoint{Open}(1.0))
            @test !(UpperEndpoint{Open}(2) <= LowerEndpoint{Closed}(1.0))
            @test !(UpperEndpoint{Closed}(2) <= LowerEndpoint{Closed}(1.0))
        end

        @testset "$T < Scalar" for T in (LowerEndpoint, UpperEndpoint)
            @test T{Open}(1) < 2.0
            @test T{Closed}(1) < 2.0

            @test (T{Open}(1) < 1.0) == (T === UpperEndpoint)
            @test !(T{Closed}(1) < 1.0)

            @test !(T{Open}(1) < 0.0)
            @test !(T{Closed}(1) < 0.0)
        end

        @testset "$T <= Scalar" for T in (LowerEndpoint, UpperEndpoint)
            @test T{Open}(1) <= 2.0
            @test T{Closed}(1) <= 2.0

            @test (T{Open}(1) <= 1.0) == (T === UpperEndpoint)
            @test T{Closed}(1) <= 1.0

            @test !(T{Open}(1) <= 0.0)
            @test !(T{Closed}(1) <= 0.0)
        end

        @testset "Scalar < $T" for T in (LowerEndpoint, UpperEndpoint)
            @test 0 < T{Open}(1.0)
            @test 0 < T{Closed}(1.0)

            @test (1 < T{Open}(1.0)) == (T === LowerEndpoint)
            @test !(1 < T{Closed}(1.0))

            @test !(2 < T{Open}(1.0))
            @test !(2 < T{Closed}(1.0))
        end

        @testset "Scalar <= $T" for T in (LowerEndpoint, UpperEndpoint)
            @test 0 <= T{Open}(1.0)
            @test 0 <= T{Closed}(1.0)

            @test (1 <= T{Open}(1.0)) == (T === LowerEndpoint)
            @test 1 <= T{Closed}(1.0)

            @test !(2 <= T{Open}(1.0))
            @test !(2 <= T{Closed}(1.0))
        end

        @testset "LowerEndpoint == LowerEndpoint" begin
            @test LowerEndpoint{Open}(1) != LowerEndpoint{Open}(2.0)
            @test LowerEndpoint{Closed}(1) != LowerEndpoint{Open}(2.0)
            @test LowerEndpoint{Open}(1) != LowerEndpoint{Closed}(2.0)
            @test LowerEndpoint{Closed}(1) != LowerEndpoint{Closed}(2.0)

            @test LowerEndpoint{Open}(1) == LowerEndpoint{Open}(1.0)
            @test LowerEndpoint{Closed}(1) != LowerEndpoint{Open}(1.0)
            @test LowerEndpoint{Open}(1) != LowerEndpoint{Closed}(1.0)
            @test LowerEndpoint{Closed}(1) == LowerEndpoint{Closed}(1.0)
        end

        @testset "UpperEndpoint == UpperEndpoint" begin
            @test UpperEndpoint{Open}(1) != UpperEndpoint{Open}(2.0)
            @test UpperEndpoint{Closed}(1) != UpperEndpoint{Open}(2.0)
            @test UpperEndpoint{Open}(1) != UpperEndpoint{Closed}(2.0)
            @test UpperEndpoint{Closed}(1) != UpperEndpoint{Closed}(2.0)

            @test UpperEndpoint{Open}(1) == UpperEndpoint{Open}(1.0)
            @test UpperEndpoint{Closed}(1) != UpperEndpoint{Open}(1.0)
            @test UpperEndpoint{Open}(1) != UpperEndpoint{Closed}(1.0)
            @test UpperEndpoint{Closed}(1) == UpperEndpoint{Closed}(1.0)
        end

        @testset "LowerEndpoint == UpperEndpoint" begin
            @test LowerEndpoint{Open}(1) != UpperEndpoint{Open}(2.0)
            @test LowerEndpoint{Closed}(1) != UpperEndpoint{Open}(2.0)
            @test LowerEndpoint{Open}(1) != UpperEndpoint{Closed}(2.0)
            @test LowerEndpoint{Closed}(1) != UpperEndpoint{Closed}(2.0)

            @test LowerEndpoint{Open}(1) != UpperEndpoint{Open}(1.0)
            @test LowerEndpoint{Closed}(1) != UpperEndpoint{Open}(1.0)
            @test LowerEndpoint{Open}(1) != UpperEndpoint{Closed}(1.0)
            @test LowerEndpoint{Closed}(1) == UpperEndpoint{Closed}(1.0)
        end

        @testset "UpperEndpoint == LowerEndpoint" begin
            @test UpperEndpoint{Open}(1) != LowerEndpoint{Open}(2.0)
            @test UpperEndpoint{Closed}(1) != LowerEndpoint{Open}(2.0)
            @test UpperEndpoint{Open}(1) != LowerEndpoint{Closed}(2.0)
            @test UpperEndpoint{Closed}(1) != LowerEndpoint{Closed}(2.0)

            @test UpperEndpoint{Open}(1) != LowerEndpoint{Open}(1.0)
            @test UpperEndpoint{Closed}(1) != LowerEndpoint{Open}(1.0)
            @test UpperEndpoint{Open}(1) != LowerEndpoint{Closed}(1.0)
            @test UpperEndpoint{Closed}(1) == LowerEndpoint{Closed}(1.0)
        end

        @testset "$T == Scalar" for T in (LowerEndpoint, UpperEndpoint)
            @test T{Open}(0) != 1.0
            @test T{Closed}(0) != 1.0

            @test T{Open}(1) != 1.0
            @test T{Closed}(1) == 1.0

            @test T{Open}(2) != 1.0
            @test T{Closed}(2) != 1.0
        end

        @testset "Scalar == $T" for T in (LowerEndpoint, UpperEndpoint)
            @test 1.0 != T{Open}(0)
            @test 1.0 != T{Closed}(0)

            @test 1.0 != T{Open}(1)
            @test 1.0 == T{Closed}(1)

            @test 1.0 != T{Open}(2)
            @test 1.0 != T{Closed}(2)
        end

        @testset "isequal" begin
            @test isequal(LowerEndpoint{Closed}(0.0), LowerEndpoint{Closed}(0.0))
            @test isequal(LowerEndpoint{Open}(0.0), LowerEndpoint{Open}(0.0))
            @test !isequal(LowerEndpoint{Closed}(-0.0), LowerEndpoint{Open}(0.0))
            @test !isequal(LowerEndpoint{Open}(-0.0), LowerEndpoint{Closed}(0.0))
            @test !isequal(LowerEndpoint{Closed}(-0.0), LowerEndpoint{Closed}(0.0))
            @test !isequal(LowerEndpoint{Open}(-0.0), LowerEndpoint{Open}(0.0))

            @test isequal(UpperEndpoint{Closed}(0.0), LowerEndpoint{Closed}(0.0))
            @test !isequal(LowerEndpoint{Closed}(-0.0), UpperEndpoint{Open}(0.0))
            @test !isequal(UpperEndpoint{Open}(-0.0), LowerEndpoint{Closed}(0.0))
            @test !isequal(LowerEndpoint{Closed}(-0.0), UpperEndpoint{Closed}(0.0))
        end

        @testset "hash" begin
            # Need a complicated enough element type for this test to possibly fail. Using a
            # ZonedDateTime with a VariableTimeZone should do the trick.
            a = now(tz"Europe/London")
            b = deepcopy(a)
            @test hash(a) == hash(b)  # Double check

            @test hash(LowerEndpoint{Open}(a)) == hash(LowerEndpoint{Open}(b))
            @test hash(LowerEndpoint{Closed}(a)) != hash(LowerEndpoint{Open}(b))
            @test hash(LowerEndpoint{Open}(a)) != hash(LowerEndpoint{Closed}(b))
            @test hash(LowerEndpoint{Closed}(a)) == hash(LowerEndpoint{Closed}(b))

            @test hash(UpperEndpoint{Open}(a)) == hash(UpperEndpoint{Open}(b))
            @test hash(UpperEndpoint{Closed}(a)) != hash(UpperEndpoint{Open}(b))
            @test hash(UpperEndpoint{Open}(a)) != hash(UpperEndpoint{Closed}(b))
            @test hash(UpperEndpoint{Closed}(a)) == hash(UpperEndpoint{Closed}(b))

            @test hash(LowerEndpoint{Open}(a)) != hash(UpperEndpoint{Open}(b))
            @test hash(LowerEndpoint{Closed}(a)) != hash(UpperEndpoint{Open}(b))
            @test hash(LowerEndpoint{Open}(a)) != hash(UpperEndpoint{Closed}(b))
            @test hash(LowerEndpoint{Closed}(a)) != hash(UpperEndpoint{Closed}(b))
        end
    end

    # Note: The value for unbounded endpoints is irrelevant
    @testset "unbounded" begin
        @testset "LowerEndpoint < LowerEndpoint" begin
            @test !(LowerEndpoint{Unbounded}(nothing) < LowerEndpoint{Unbounded}(nothing))
            @test LowerEndpoint{Unbounded}(nothing) < LowerEndpoint{Open}(0.0)
            @test LowerEndpoint{Unbounded}(nothing) < LowerEndpoint{Closed}(0.0)
            @test !(LowerEndpoint{Open}(0) < LowerEndpoint{Unbounded}(nothing))
            @test !(LowerEndpoint{Closed}(0) < LowerEndpoint{Unbounded}(nothing))
        end

        @testset "LowerEndpoint <= LowerEndpoint" begin
            @test LowerEndpoint{Unbounded}(nothing) <= LowerEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Unbounded}(nothing) <= LowerEndpoint{Open}(0.0)
            @test LowerEndpoint{Unbounded}(nothing) <= LowerEndpoint{Closed}(0.0)
            @test !(LowerEndpoint{Open}(0) <= LowerEndpoint{Unbounded}(nothing))
            @test !(LowerEndpoint{Closed}(0) <= LowerEndpoint{Unbounded}(nothing))
        end

        @testset "UpperEndpoint < UpperEndpoint" begin
            @test !(UpperEndpoint{Unbounded}(nothing) < UpperEndpoint{Unbounded}(nothing))
            @test !(UpperEndpoint{Unbounded}(nothing) < UpperEndpoint{Open}(0.0))
            @test !(UpperEndpoint{Unbounded}(nothing) < UpperEndpoint{Closed}(0.0))
            @test UpperEndpoint{Open}(0) < UpperEndpoint{Unbounded}(nothing)
            @test UpperEndpoint{Closed}(0) < UpperEndpoint{Unbounded}(nothing)
        end

        @testset "UpperEndpoint <= UpperEndpoint" begin
            @test UpperEndpoint{Unbounded}(nothing) <= UpperEndpoint{Unbounded}(nothing)
            @test !(UpperEndpoint{Unbounded}(nothing) <= UpperEndpoint{Open}(0.0))
            @test !(UpperEndpoint{Unbounded}(nothing) <= UpperEndpoint{Closed}(0.0))
            @test UpperEndpoint{Open}(0) <= UpperEndpoint{Unbounded}(nothing)
            @test UpperEndpoint{Closed}(0) <= UpperEndpoint{Unbounded}(nothing)
        end

        @testset "LowerEndpoint < UpperEndpoint" begin
            @test LowerEndpoint{Unbounded}(nothing) < UpperEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Unbounded}(nothing) < UpperEndpoint{Open}(0.0)
            @test LowerEndpoint{Unbounded}(nothing) < UpperEndpoint{Closed}(0.0)
            @test LowerEndpoint{Open}(0) < UpperEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Closed}(0) < UpperEndpoint{Unbounded}(nothing)
        end

        @testset "LowerEndpoint <= UpperEndpoint" begin
            @test LowerEndpoint{Unbounded}(nothing) <= UpperEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Unbounded}(nothing) <= UpperEndpoint{Open}(0.0)
            @test LowerEndpoint{Unbounded}(nothing) <= UpperEndpoint{Closed}(0.0)
            @test LowerEndpoint{Open}(0) <= UpperEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Closed}(0) <= UpperEndpoint{Unbounded}(nothing)
        end

        @testset "UpperEndpoint < LowerEndpoint" begin
            @test !(UpperEndpoint{Unbounded}(nothing) < LowerEndpoint{Unbounded}(nothing))
            @test !(UpperEndpoint{Unbounded}(nothing) < LowerEndpoint{Open}(0.0))
            @test !(UpperEndpoint{Unbounded}(nothing) < LowerEndpoint{Closed}(0.0))
            @test !(UpperEndpoint{Open}(0) < LowerEndpoint{Unbounded}(nothing))
            @test !(UpperEndpoint{Closed}(0) < LowerEndpoint{Unbounded}(nothing))
        end

        @testset "UpperEndpoint <= LowerEndpoint" begin
            @test !(UpperEndpoint{Unbounded}(nothing) < LowerEndpoint{Unbounded}(nothing))
            @test !(UpperEndpoint{Unbounded}(nothing) < LowerEndpoint{Open}(0.0))
            @test !(UpperEndpoint{Unbounded}(nothing) < LowerEndpoint{Closed}(0.0))
            @test !(UpperEndpoint{Open}(0) < LowerEndpoint{Unbounded}(nothing))
            @test !(UpperEndpoint{Closed}(0) < LowerEndpoint{Unbounded}(nothing))
        end

        @testset "LowerEndpoint < Scalar" begin
            @test LowerEndpoint{Unbounded}(nothing) < -Inf
            @test LowerEndpoint{Unbounded}(nothing) < Inf
        end

         @testset "LowerEndpoint <= Scalar" begin
            @test LowerEndpoint{Unbounded}(nothing) <= -Inf
            @test LowerEndpoint{Unbounded}(nothing) <= Inf
        end

        @testset "UpperEndpoint < Scalar" begin
            @test !(UpperEndpoint{Unbounded}(nothing) < -Inf)
            @test !(UpperEndpoint{Unbounded}(nothing) < Inf)
        end

        @testset "UpperEndpoint <= Scalar" begin
            @test !(UpperEndpoint{Unbounded}(nothing) <= -Inf)
            @test !(UpperEndpoint{Unbounded}(nothing) <= Inf)
        end

        @testset "Scalar < LowerEndpoint" begin
            @test !(-Inf < LowerEndpoint{Unbounded}(nothing))
            @test !(Inf < LowerEndpoint{Unbounded}(nothing))
        end

        @testset "Scalar <= LowerEndpoint" begin
            @test !(-Inf <= LowerEndpoint{Unbounded}(nothing))
            @test !(Inf <= LowerEndpoint{Unbounded}(nothing))
        end

        @testset "Scalar < UpperEndpoint" begin
            @test -Inf < UpperEndpoint{Unbounded}(nothing)
            @test Inf < UpperEndpoint{Unbounded}(nothing)
        end

        @testset "Scalar < UpperEndpoint" begin
            @test -Inf <= UpperEndpoint{Unbounded}(nothing)
            @test Inf <= UpperEndpoint{Unbounded}(nothing)
        end

        @testset "LowerEndpoint == LowerEndpoint" begin
            @test LowerEndpoint{Unbounded}(nothing) == LowerEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Unbounded}(nothing) != LowerEndpoint{Open}(0.0)
            @test LowerEndpoint{Unbounded}(nothing) != LowerEndpoint{Closed}(0.0)
            @test LowerEndpoint{Open}(0) != LowerEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Closed}(0) != LowerEndpoint{Unbounded}(nothing)
        end

        @testset "UpperEndpoint == UpperEndpoint" begin
            @test UpperEndpoint{Unbounded}(nothing) == UpperEndpoint{Unbounded}(nothing)
            @test UpperEndpoint{Unbounded}(nothing) != UpperEndpoint{Open}(0.0)
            @test UpperEndpoint{Unbounded}(nothing) != UpperEndpoint{Closed}(0.0)
            @test UpperEndpoint{Open}(0) != UpperEndpoint{Unbounded}(nothing)
            @test UpperEndpoint{Closed}(0) != UpperEndpoint{Unbounded}(nothing)
        end

        @testset "LowerEndpoint == UpperEndpoint" begin
            @test LowerEndpoint{Unbounded}(nothing) != UpperEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Unbounded}(nothing) != UpperEndpoint{Open}(0.0)
            @test LowerEndpoint{Unbounded}(nothing) != UpperEndpoint{Closed}(0.0)
            @test LowerEndpoint{Open}(0) != UpperEndpoint{Unbounded}(nothing)
            @test LowerEndpoint{Closed}(0) != UpperEndpoint{Unbounded}(nothing)
        end

        @testset "UpperEndpoint == LowerEndpoint" begin
            @test UpperEndpoint{Unbounded}(nothing) != LowerEndpoint{Unbounded}(nothing)
            @test UpperEndpoint{Unbounded}(nothing) != LowerEndpoint{Open}(0.0)
            @test UpperEndpoint{Unbounded}(nothing) != LowerEndpoint{Closed}(0.0)
            @test UpperEndpoint{Open}(0) != LowerEndpoint{Unbounded}(nothing)
            @test UpperEndpoint{Closed}(0) != LowerEndpoint{Unbounded}(nothing)
        end

        @testset "isequal" begin
            T = Float64

            @test isequal(LowerEndpoint{T,Unbounded}(nothing), LowerEndpoint{T,Unbounded}(nothing))
            @test !isequal(LowerEndpoint{T,Unbounded}(nothing), LowerEndpoint{T,Open}(0.0))
            @test !isequal(LowerEndpoint{T,Unbounded}(nothing), LowerEndpoint{T,Closed}(0.0))
            @test !isequal(LowerEndpoint{T,Open}(-0.0), LowerEndpoint{T,Unbounded}(nothing))
            @test !isequal(LowerEndpoint{T,Closed}(-0.0), LowerEndpoint{T,Unbounded}(nothing))

            @test !isequal(UpperEndpoint{Unbounded}(nothing), LowerEndpoint{Unbounded}(nothing))
            @test !isequal(LowerEndpoint{Unbounded}(nothing), UpperEndpoint{Unbounded}(nothing))
        end

         @testset "hash" begin
            # Note: Unbounded endpoints should ignore the value
            T = Int

            lower_unbounded = LowerEndpoint{T,Unbounded}(nothing)
            @test hash(lower_unbounded) == hash(LowerEndpoint{T,Unbounded}(nothing))
            @test hash(lower_unbounded) != hash(LowerEndpoint{Unbounded}(nothing))
            @test hash(lower_unbounded) != hash(LowerEndpoint{Open}(lower_unbounded.endpoint))
            @test hash(lower_unbounded) != hash(LowerEndpoint{Closed}(lower_unbounded.endpoint))

            upper_unbounded = UpperEndpoint{T,Unbounded}(nothing)
            @test hash(upper_unbounded) == hash(UpperEndpoint{T,Unbounded}(nothing))
            @test hash(upper_unbounded) != hash(UpperEndpoint{Unbounded}(nothing))
            @test hash(upper_unbounded) != hash(UpperEndpoint{Open}(upper_unbounded.endpoint))
            @test hash(upper_unbounded) != hash(UpperEndpoint{Closed}(upper_unbounded.endpoint))

            @test hash(LowerEndpoint{T,Unbounded}(nothing)) != hash(UpperEndpoint{T,Unbounded}(nothing))
            @test hash(LowerEndpoint{T,Unbounded}(nothing)) != hash(UpperEndpoint{T,Open}(0))
            @test hash(LowerEndpoint{T,Unbounded}(nothing)) != hash(UpperEndpoint{T,Closed}(0))
            @test hash(LowerEndpoint{T,Open}(0)) != hash(UpperEndpoint{T,Unbounded}(nothing))
            @test hash(LowerEndpoint{T,Closed}(0)) != hash(UpperEndpoint{T,Unbounded}(nothing))
        end
    end

    @testset "broadcast" begin
        test = [
            LowerEndpoint{Open}(0),
            LowerEndpoint{Closed}(0),
            LowerEndpoint{Unbounded}(nothing),
            UpperEndpoint{Open}(0),
            UpperEndpoint{Closed}(0),
            UpperEndpoint{Unbounded}(nothing),
        ]

        # Verify that Endpoint is treated as a scalar during broadcast
        result = test .== 0
        @test result == [false, true, false, false, true, false]
    end
end
