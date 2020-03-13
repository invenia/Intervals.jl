@testset "plotting" begin
    possible_inclusivities = Iterators.product((true, false), (true, false))
    @testset "Interval{Float64} with inclusivity=$inc" for inc in possible_inclusivities
        intervals = [Interval(float(x), float(x + 0.5), inc...) for x in 1:11]
        @plottest plot(intervals, 1:11) "references/interval_$inc.png" false

        @testset "Make sure still looks same in scatter plot" begin
            # Earlier versions of this functionality showed only end-points if plotted in
            # scatter, but for intervals the connect-line is part of the "marker"
            @plottest scatter(intervals, 1:11) "references/interval_$inc.png" false
        end
    end

    @testset "DateTime intervals" begin
        start_dt = DateTime(2017,1,1,0,0,0)
        end_dt = DateTime(2017,1,1,10,30,0)
        datetimes = start_dt:Hour(1):end_dt

        @testset "Interval{DateTime}" begin
            date_intervals = [dt .. (dt + Hour(1)) for dt in datetimes]
            @plottest plot(date_intervals, 1:11) "references/interval_datetime.png" false
        end

        @testset "AnchoredInterval" begin
            @plottest plot(HE.(datetimes), 1:11) "references/HE.png" false
            @plottest plot(HB.(datetimes), 1:11) "references/HB.png" false
        end
    end
end
