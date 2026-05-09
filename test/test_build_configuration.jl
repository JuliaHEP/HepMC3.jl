@testset "Build Configuration" begin
    package_root = dirname(@__DIR__)
    deps_build = joinpath(package_root, "deps", "build.jl")
    generated_header = joinpath(package_root, "gen", "cpp", "jlHepMC3.h")

    @test isfile(deps_build)
    @test filesize(generated_header) > 0

    build_script = read(deps_build, String)
    @test occursin("gen", build_script)
    @test occursin("build.jl", build_script)
end
