@testset "arrow" begin
    zdt_start = ZonedDateTime(2016, 8, 11, 1, tz"America/Winnipeg")
    zdt_end = ZonedDateTime(2016, 8, 12, 0, tz"America/Winnipeg")
    table = (time = HE.(zdt_start:Hour(1):zdt_end), val = rand(24))

    # Just test that we can save and load our table type without the time column being
    # converted to a NamedTuple
    mktempdir() do d
        file = joinpath(d, "data.arrow")
        Arrow.write(file, table)
        loaded = Arrow.Table(file)
        @test loaded.time == table.time
        @test loaded.val ≈ table.val
    end
end
