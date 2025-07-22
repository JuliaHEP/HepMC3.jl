# Save as: test_clean_interface.jl
println("=== Test with Clean Interface (No Conflicts) ===")

using HepMC3

try
    println("Testing direct C++ functions...")
    
    # These should now work - calling C++ functions directly
    vertex_ptr = HepMC3.create_shared_vertex()
    println("✅ Vertex created: ", vertex_ptr)
    
    # Create particle
    p_momentum = HepMC3.FourVector(10.0, 20.0, 30.0, 50.0)
    particle_ptr = HepMC3.create_shared_particle(p_momentum.cpp_object, 11, 1)
    println("✅ Particle created: ", particle_ptr)
    
    # Connect them
    HepMC3.add_shared_particle_out(vertex_ptr, particle_ptr)
    println("✅ Particle connected to vertex")
    
    # Create event and add vertex
    event = create_event(999)  # This convenience function is safe
    HepMC3.add_shared_vertex_to_event(event.cpp_object, vertex_ptr)
    println("✅ Vertex added to event")
    
    println("\nEvent summary:")
    println("  Number: ", event_number(event))
    println("  Particles: ", particles_size(event))
    println("  Vertices: ", vertices_size(event))
    
    # Test convenience functions with different names
    println("\nTesting convenience functions...")
    vertex2 = make_shared_vertex()
    particle2 = make_shared_particle(5.0, 10.0, 15.0, 25.0, -11, 1)
    connect_particle_out(vertex2, particle2)
    attach_vertex_to_event(event, vertex2)
    
    println("✅ Convenience functions work!")
    println("Final event - Particles: ", particles_size(event), " Vertices: ", vertices_size(event))
    
catch e
    println("❌ Error: ", e)
    println("Stacktrace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end