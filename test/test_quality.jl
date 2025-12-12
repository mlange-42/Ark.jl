
# These tests are too slow
if RUN_JET
    using Aqua
    @testset "Aqua tests" begin
        Aqua.test_all(Ark, deps_compat=false)
        Aqua.test_deps_compat(Ark, check_extras=false)
    end

    @testset "JET tests" begin
        rep = JET.report_package(Ark, target_modules=[Ark])
        println(rep)

        reports = JET.get_reports(rep)
        filtered = filter(
            r ->
                !occursin(
                    "ArgumentError: either components to add or to remove must be given for exchange_components!",
                    sprint(show, r)), reports)

        @test length(filtered) == 0
    end
end
