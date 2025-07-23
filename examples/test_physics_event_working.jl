# Save as: test_physics_event_working.jl
println("=== Creating a Complete Particle Physics Event (Working) ===")

using HepMC3

try
    # Create a proton-proton collision event at 14 TeV (LHC energy)
    event = create_event(1)
    println("✅ Event created: ", event)
    
    # Set units (GeV and mm)
    set_units(event, HepMC3.var"HepMC3!Units!GEV", HepMC3.var"HepMC3!Units!MM")
    println("✅ Units set to GeV and mm")
    
    # Create beam particles (7 TeV protons) 
    p1_momentum = HepMC3.FourVector(0.0, 0.0, 7000.0, 7000.0)
    p2_momentum = HepMC3.FourVector(0.0, 0.0, -7000.0, 7000.0)
    
    # Extract raw pointers using .cpp_object
    p1_momentum_ptr = p1_momentum.cpp_object
    p2_momentum_ptr = p2_momentum.cpp_object
    
    # Use manual wrapper functions with raw pointers
    p1_ptr = HepMC3.create_shared_particle(p1_momentum_ptr, 2212, -1)  # incoming proton 1
    p2_ptr = HepMC3.create_shared_particle(p2_momentum_ptr, 2212, -1)  # incoming proton 2
    println("✅ Beam protons created using manual wrappers")
    
    # Create collision vertex using manual wrapper
    collision_vertex_ptr = HepMC3.create_shared_vertex()
    println("✅ Collision vertex created using manual wrapper")
    
    # Add incoming protons to collision vertex using manual functions
    HepMC3.add_shared_particle_in(collision_vertex_ptr, p1_ptr)
    HepMC3.add_shared_particle_in(collision_vertex_ptr, p2_ptr)
    println("✅ Incoming protons added to collision vertex")
    
    # Create outgoing particles using manual wrappers
    z_momentum = HepMC3.FourVector(50.0, 30.0, 100.0, 200.0)
    z_momentum_ptr = z_momentum.cpp_object
    z_boson_ptr = HepMC3.create_shared_particle(z_momentum_ptr, 23, 2)  # Z boson, intermediate
    
    electron_momentum = HepMC3.FourVector(25.0, 15.0, 50.0, 60.0)
    electron_momentum_ptr = electron_momentum.cpp_object
    electron_ptr = HepMC3.create_shared_particle(electron_momentum_ptr, 11, 1)   # electron, final
    
    positron_momentum = HepMC3.FourVector(25.0, 15.0, 50.0, 60.0)
    positron_momentum_ptr = positron_momentum.cpp_object
    positron_ptr = HepMC3.create_shared_particle(positron_momentum_ptr, -11, 1)  # positron, final
    
    println("✅ Outgoing particles created using manual wrappers")
    
    # Add Z boson as outgoing from collision
    HepMC3.add_shared_particle_out(collision_vertex_ptr, z_boson_ptr)
    
    # Create decay vertex for Z boson
    decay_vertex_ptr = HepMC3.create_shared_vertex()
    
    # Connect Z boson to its decay
    HepMC3.add_shared_particle_in(decay_vertex_ptr, z_boson_ptr)
    HepMC3.add_shared_particle_out(decay_vertex_ptr, electron_ptr)
    HepMC3.add_shared_particle_out(decay_vertex_ptr, positron_ptr)
    
    println("✅ Z boson decay vertex created")
    
    # Add vertices to event using manual functions
    # Extract event pointer using .cpp_object
    event_ptr = event.cpp_object
    HepMC3.add_shared_vertex_to_event(event_ptr, collision_vertex_ptr)
    HepMC3.add_shared_vertex_to_event(event_ptr, decay_vertex_ptr)
    
    println("✅ Vertices added to event")
    
    # Display event summary (using regular methods)
    println("\n=== EVENT SUMMARY ===")
    println("Event number: ", event_number(event))
    println("Number of particles: ", particles_size(event))
    println("Number of vertices: ", vertices_size(event))
    
    # Test some physics calculations using the momentum objects
    z_mass = sqrt(e(z_momentum)^2 - px(z_momentum)^2 - py(z_momentum)^2 - pz(z_momentum)^2)
    println("Z boson invariant mass: ", z_mass, " GeV")
    
    electron_pt = sqrt(px(electron_momentum)^2 + py(electron_momentum)^2)
    println("Electron transverse momentum: ", electron_pt, " GeV")
    
    println("\n🎉 Complete particle physics event created successfully!")
    
    # Test file I/O if available
    println("\n=== TESTING FILE I/O ===")
    try
        # Test creating ASCII writer
        writer_ptr = HepMC3.create_writer_ascii("test_output.hepmc3")
        println("✅ ASCII writer created")
        
        # Write the event
        success = HepMC3.writer_write_event(writer_ptr, event_ptr)
        println("✅ Event written to file: ", success)
        
        # Test creating ASCII reader
        reader_ptr = HepMC3.create_reader_ascii("test_output.hepmc3")
        println("✅ ASCII reader created")
        
        # Create new event for reading
        read_event = HepMC3.GenEvent()
        read_event_ptr = read_event.cpp_object
        
        # Read the event back
        read_success = HepMC3.reader_read_event(reader_ptr, read_event_ptr)
        println("✅ Event read from file: ", read_success)
        println("   Read event number: ", event_number(read_event))
        println("   Read particles: ", particles_size(read_event))
        println("   Read vertices: ", vertices_size(read_event))
        
    catch e
        println("⚠️  File I/O test failed: ", e)
    end
    
catch e
    println("❌ Error creating physics event: ", e)
    println("Stacktrace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end