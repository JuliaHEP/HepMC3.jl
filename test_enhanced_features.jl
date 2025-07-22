# Save as: test_enhanced_features.jl
println("=== Testing Enhanced Manual Wrapper Features ===")

using HepMC3

try
    # Create event
    event = create_event(999)
    HepMC3.set_units(event, HepMC3.var"HepMC3!Units!GEV", HepMC3.var"HepMC3!Units!MM")
    
    # Create particles and vertex
    p1 = make_shared_particle(1.0, 2.0, 3.0, 5.0, 11, 1)
    vertex = make_shared_vertex()
    connect_particle_out(vertex, p1)
    
    # Test vertex status
    set_vertex_status!(vertex, 4)
    println("✅ Vertex status set")
    
    # Add vertex to event
    attach_vertex_to_event(event, vertex)
    
    # Test position shift
    shift_position!(event, 5.0, 5.0, 5.0, 5.0)
    println("✅ Event position shifted")
    
    # Test PDF info
    pdf_info = add_pdf_info!(event, 1, 2, 0.1, 0.2, 100.0, 0.5, 0.6, 1, 2)
    println("✅ PDF info added")
    
    # Test cross section
    cross_section = add_cross_section!(event, 1.23, 0.45)
    println("✅ Cross section added")
    
    # Test heavy ion info
    heavy_ion = add_heavy_ion!(event, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0.1, 2.3, 4.5, 6.7)
    println("✅ Heavy ion info added")
    
    # Test particle attributes
    attr = add_particle_attribute!(p1, "tool", 42)
    println("✅ Particle attribute added")
    
    println("\n🎉 All enhanced features working!")
    
catch e
    println("❌ Error: ", e)
end