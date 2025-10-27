
# These tests are too slow
if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    using Aqua
    @testset "Aqua tests" begin
        Aqua.test_all(Ark, deps_compat=false)
        Aqua.test_deps_compat(Ark, check_extras=false)
    end

    using JET
    @testset "JET tests" begin
        rep = JET.report_package(Ark, target_modules = [Ark,])
        @test length(JET.get_reports(rep)) == 0
    end
end

