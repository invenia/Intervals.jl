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
end
