
# These tests are too slow
if "CI" in keys(ENV)
    using Aqua
    @testset "Aqua tests" begin
        Aqua.test_all(Ark, deps_compat=false)
        Aqua.test_deps_compat(Ark, check_extras=false)
    end

    using JET
    @testset "JET tests" begin
        rep = JET.report_package(Ark, target_defined_modules = true)
        @test length(JET.get_reports(rep)) == 0
    end
end

