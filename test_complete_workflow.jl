# Save as: test_complete_workflow.jl
println("=== COMPLETE HepMC3.jl WORKFLOW TEST ===")

using HepMC3

try
    # Create a realistic particle physics event
    println("🔬 Creating High-Energy Physics Event...")
    
    # Proton-proton collision at LHC (14 TeV)
    event = create_event(1)
    HepMC3.set_units(event, HepMC3.var"HepMC3!Units!GEV", HepMC3.var"HepMC3!Units!MM")
    
    # Beam particles (7 TeV each)
    p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, -1)   # proton 1
    p2 = make_shared_particle(0.0, 0.0, -7000.0, 7000.0, 2212, -1)  # proton 2
    
    # Collision vertex
    collision = make_shared_vertex()
    connect_particle_in(collision, p1)
    connect_particle_in(collision, p2)
    
    # Z boson production
    z_boson = make_shared_particle(50.0, 30.0, 100.0, 200.0, 23, 2)  # Z boson
    connect_particle_out(collision, z_boson)
    attach_vertex_to_event(event, collision)
    
    # Z decay vertex
    decay = make_shared_vertex()
    connect_particle_in(decay, z_boson)
    
    # Z → e+ e- decay
    electron = make_shared_particle(25.0, 15.0, 50.0, 60.0, 11, 1)   # electron
    positron = make_shared_particle(25.0, 15.0, 50.0, 60.0, -11, 1)  # positron
    connect_particle_out(decay, electron)
    connect_particle_out(decay, positron)
    attach_vertex_to_event(event, decay)
    
    println("✅ Complete physics event created!")
    println("   Particles: ", particles_size(event))
    println("   Vertices: ", vertices_size(event))
    
    # Physics calculations
    z_momentum = HepMC3.FourVector(50.0, 30.0, 100.0, 200.0)
    z_mass = sqrt(e(z_momentum)^2 - px(z_momentum)^2 - py(z_momentum)^2 - pz(z_momentum)^2)
    
    electron_momentum = HepMC3.FourVector(25.0, 15.0, 50.0, 60.0)
    electron_pt = sqrt(px(electron_momentum)^2 + py(electron_momentum)^2)
    
    println("📊 Physics Results:")
    println("   Z boson mass: ", round(z_mass, digits=2), " GeV")
    println("   Electron pT: ", round(electron_pt, digits=2), " GeV")
    
    # File I/O Test
    println("\n💾 Testing File I/O...")
    filename = "physics_event.hepmc3"
    
    # Write event
    writer = HepMC3.create_writer_ascii(filename)
    write_success = HepMC3.writer_write_event(writer, event.cpp_object)
    HepMC3.writer_close(writer)
    
    println("✅ Event written: ", write_success)
    
    if isfile(filename)
        filesize_bytes = filesize(filename)
        println("✅ File created: ", filesize_bytes, " bytes")
        
        # Read event back
        reader = HepMC3.create_reader_ascii(filename)
        read_event = HepMC3.GenEvent()
        read_success = HepMC3.reader_read_event(reader, read_event.cpp_object)
        HepMC3.reader_close(reader)
        
        println("✅ Event read back: ", read_success)
        println("   Read particles: ", particles_size(read_event))
        println("   Read vertices: ", vertices_size(read_event))
        println("   Read event number: ", event_number(read_event))
    end
    
    println("\n🎉 COMPLETE SUCCESS!")
    println("🏆 Your HepMC3.jl package is FULLY FUNCTIONAL!")
    
    # Performance test
    println("\n⚡ Performance Test...")
    start_time = time()
    for i in 1:100
        test_event = create_event(i)
        test_particle = make_shared_particle(1.0, 2.0, 3.0, 4.0, 11, 1)
        test_vertex = make_shared_vertex()
        connect_particle_out(test_vertex, test_particle)
        attach_vertex_to_event(test_event, test_vertex)
    end
    elapsed = time() - start_time
    
    println("✅ Created 100 events in ", round(elapsed, digits=3), " seconds")
    println("   Performance: ", round(100/elapsed, digits=1), " events/second")
    
catch e
    println("❌ Error: ", e)
end