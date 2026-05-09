using Pkg
Pkg.instantiate()
using CxxWrap
using HepMC3_jll
using WrapIt: wrapit

#---Build the wrapper library----------------------------------------------------------------------
builddir = joinpath(@__DIR__, "build")
sourcedir = @__DIR__
cd(@__DIR__)
mkpath(builddir)

if Sys.isapple()
    ENV["SDKROOT"]=readchomp(`xcrun --sdk macosx --show-sdk-path`)
end

cxxwrap_prefix = CxxWrap.prefix_path()
hepmc3_prefix = HepMC3_jll.artifact_dir
julia_prefix = dirname(Sys.BINDIR)

#---Generate the wrapper code----------------------------------------------------------------------
updatemode = "--update" in ARGS
generatemode = "--generate" in ARGS
updatemode && println("Update mode")
wit = joinpath(@__DIR__, "HepMC3.wit")
witin = joinpath(@__DIR__, "HepMC3.wit.in")
open(wit, "w") do f
    for l in eachline(witin)
        println(f, replace(l, "@HepMC3_INCLUDE_DIR@" => "$hepmc3_prefix/include",
                             "@Julia_INCLUDE_DIR@" => "$julia_prefix/include/julia",
                             "@JlCxx_INCLUDE_DIR@" => "$cxxwrap_prefix/include",
                             "@CxxWrap_VERSION@" => "$(pkgversion(CxxWrap))"))
    end
end

generated_entrypoint = joinpath(@__DIR__, "cpp", "jlHepMC3.cxx")
generated_header = joinpath(@__DIR__, "cpp", "jlHepMC3.h")
generated_sources_ready =
    isfile(generated_entrypoint) && isfile(generated_header) && filesize(generated_header) > 0

if generatemode || updatemode || !generated_sources_ready
    rc = wrapit(wit; force=true, update=updatemode, verbosity=1, returncode=true)
    if !isnothing(rc) && rc != 0
        println(stderr, "Failed to produce wrapper code with WrapIt. Exited with code ", rc, ".")
        exit(rc)
    end
else
    println("Using checked-in WrapIt-generated sources. Pass --generate or --update to regenerate them.")
end

cd(builddir)
run(`cmake -DCMAKE_BUILD_TYPE=Release
           -DCMAKE_CXX_STANDARD=17
           -DCMAKE_PREFIX_PATH=$cxxwrap_prefix\;$hepmc3_prefix  $sourcedir`)
run(`cmake --build . --config Release --parallel 8`)
