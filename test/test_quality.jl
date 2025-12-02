
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
        @test length(JET.get_reports(rep)) == 0
    end
end
