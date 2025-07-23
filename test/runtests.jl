using Test
using HepMC3

# Test organization
const TEST_FILES = [
    "test_fourvector.jl",
    "test_particles.jl", 
    "test_vertices.jl",
    "test_events.jl",
    "test_file_io.jl",
    "test_units.jl",
    "test_attributes.jl",
    "test_manual_wrappers.jl",
    "test_physics_examples.jl",
    "test_navigation.jl"
]

@testset "HepMC3.jl Complete Test Suite" begin
    for test_file in TEST_FILES
        @testset "$(test_file)" begin
            include(test_file)
        end
    end
end