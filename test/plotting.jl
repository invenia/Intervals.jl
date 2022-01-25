# Keeping these dependencies separate as the are slow to load
using Plots
using VisualRegressionTests

@testset "plotting" begin
    @testset "Interval{Float64,$L,$R}" for (L, R) in BOUND_PERMUTATIONS
        intervals = [Interval{L,R}(float(x), float(x + 0.5)) for x in 1:11]
        plot_file = "interval_$(lowercase("$(L)_$(R)")).png"
        @plottest plot(intervals, 1:11) "references/$plot_file" false 0.01

        @testset "scatter" begin
            # Earlier versions of this functionality showed only end-points if plotted in
            # scatter, but for intervals the connect-line is part of the "marker"
            @plottest scatter(intervals, 1:11) "references/$plot_file" false 0.01
        end
    end

    @testset "DateTime intervals" begin
        start_dt = DateTime(2017, 1 ,1, 0, 0)
        end_dt = DateTime(2017, 1, 1, 10, 30)
        datetimes = start_dt:Hour(1):end_dt

        @testset "Interval{DateTime}" begin
            date_intervals = [dt .. (dt + Hour(1)) for dt in datetimes]
            @plottest plot(date_intervals, 1:11) "references/interval_datetime.png" false 0.01
        end

        @testset "AnchoredInterval" begin
            @plottest plot(HE.(datetimes), 1:11) "references/HE.png" false 0.01
            @plottest plot(HB.(datetimes), 1:11) "references/HB.png" false 0.01
        end
    end
end
