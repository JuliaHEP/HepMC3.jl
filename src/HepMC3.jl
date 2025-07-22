__precompile__(false) 
module HepMC3
using CxxWrap
using HepMC3_jll
using Libdl
import Base: length, getindex, iterate, close

# Load both the manual wrapper AND the generated bindings
const gendir = normpath(joinpath(@__DIR__, "../gen"))
const libpath = joinpath(gendir, "build/lib", "libHepMC3Wrap.$(Libdl.dlext)")

if !isfile(libpath)
    error("Wrapper library not found. Please build the package first.")
end

# Load the wrapper module - this includes BOTH manual and generated code
@wrapmodule(()->libpath)

function __init__()
    @initcxx
end

# Include the generated exports - this is crucial!
const generated_exports = joinpath(gendir, "jl/src/HepMC3-export.jl")
if isfile(generated_exports)
    include(generated_exports)
end

# Include extras for better Julia interface
const extras_file = joinpath(gendir, "jl/HepMC3-extras.jl") 
if isfile(extras_file)
    include(extras_file)
end

include("HepMC3Utils.jl")
include("HepMC3Interface.jl")

end # module