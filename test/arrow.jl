@testset "Arrow support" begin
    @testset "Interval (concrete)" begin
        col = [Interval{Closed,Unbounded}(1, nothing)]

        table = (; col)
        t = Arrow.Table(Arrow.tobuffer(table))

        @test eltype(t.col) == Interval{Int, Closed, Unbounded}
        @test t.col == col
    end

    @testset "Interval (non-concrete)" begin
        col = [
            Interval{Closed, Closed}(1, 2),
            Interval{Closed, Open}(2, 3),
            Interval{Unbounded, Open}(nothing, 4),
        ]

        table = (; col)
        t = Arrow.Table(Arrow.tobuffer(table))

        @test eltype(t.col) == Interval{Int}
        @test t.col == col
    end

    @testset "AnchoredInterval" begin
        zdt_start = ZonedDateTime(2016, 8, 11, 1, tz"America/Winnipeg")
        zdt_end = ZonedDateTime(2016, 8, 12, 0, tz"America/Winnipeg")
        col = HE.(zdt_start:Hour(1):zdt_end)

        table = (; col)
        t = Arrow.Table(Arrow.tobuffer(table))

        # Arrow.jl converts all Period types into Second
        @test_broken eltype(t.col) == HourEnding{ZonedDateTime, Open, Closed}
        @test t.col == col
    end
end
