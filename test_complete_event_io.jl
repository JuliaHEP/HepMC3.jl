# Save as: test_direct_calls.jl
println("=== Direct Function Calls Test ===")

using HepMC3

try
    # Create event
    event = HepMC3.GenEvent()
    HepMC3.set_event_number(event, 123)
    HepMC3.set_units(event, HepMC3.var"HepMC3!Units!GEV", HepMC3.var"HepMC3!Units!MM")
    
    # Create particles using direct calls to manual wrappers
    p1_momentum = HepMC3.FourVector(0.0, 0.0, 100.0, 100.0)
    p1 = HepMC3.create_shared_particle(p1_momentum.cpp_object, 2212, -1)
    
    p2_momentum = HepMC3.FourVector(10.0, 20.0, 30.0, 50.0)
    p2 = HepMC3.create_shared_particle(p2_momentum.cpp_object, 11, 1)
    
    # Create vertex using direct call (this should not cause stack overflow)
    vertex = HepMC3.create_shared_vertex()
    
    println("✅ Created particles and vertex successfully!")
    
    # Continue with the rest...
    HepMC3.add_shared_particle_in(vertex, p1)
    HepMC3.add_shared_particle_out(vertex, p2)
    HepMC3.add_shared_vertex_to_event(event.cpp_object, vertex)
    
    println("✅ Event built successfully:")
    println("  Particles: ", HepMC3.particles_size(event))
    println("  Vertices: ", HepMC3.vertices_size(event))
    
catch e
    println("❌ Error: ", e)
end