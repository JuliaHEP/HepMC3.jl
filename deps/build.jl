package_root = dirname(@__DIR__)
build_script = joinpath(package_root, "gen", "build.jl")

run(`$(Base.julia_cmd()) --project=$package_root $build_script`)
