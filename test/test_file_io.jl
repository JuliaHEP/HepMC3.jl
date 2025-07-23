@testset "ASCII File I/O Operations" begin
    @testset "Basic File Writing" begin
        # Create test event
        event = GenEvent()
        set_units!(event, :GeV, :mm)
        
        p1 = make_shared_particle(25.0, 15.0, 50.0, 60.0, 11, 1)
        vertex = make_shared_vertex()
        connect_particle_out(vertex, p1)
        attach_vertex_to_event(event, vertex)
        
        # Test file writing
        filename = tempname() * ".hepmc3"
        
        writer = HepMC3.create_writer_ascii(filename)
        @test writer != C_NULL
        
        write_success = HepMC3.writer_write_event(writer, event.cpp_object)
        @test write_success == true
        
        HepMC3.writer_close(writer)
        
        # Verify file exists and has content
        @test isfile(filename)
        @test filesize(filename) > 0
        
        # Clean up
        rm(filename)
    end
    
    @testset "File Reading" begin
        # Create and write test event
        event = create_event(123)
        set_units!(event, :GeV, :mm)
        
        # Add particles with known properties
        p1 = make_shared_particle(10.0, 20.0, 30.0, 40.0, 11, 1)  # electron
        p2 = make_shared_particle(-5.0, -10.0, -15.0, 20.0, -11, 1) # positron
        
        vertex = make_shared_vertex()
        connect_particle_out(vertex, p1)
        connect_particle_out(vertex, p2)
        attach_vertex_to_event(event, vertex)
        
        filename = tempname() * ".hepmc3"
        
        # Write event
        writer = HepMC3.create_writer_ascii(filename)
        HepMC3.writer_write_event(writer, event.cpp_object)
        HepMC3.writer_close(writer)
        
        # Read event back
        reader = HepMC3.create_reader_ascii(filename)
        @test reader != C_NULL
        
        read_event = HepMC3.GenEvent()
        read_success = HepMC3.reader_read_event(reader, read_event.cpp_object)
        @test read_success == true
        
        HepMC3.reader_close(reader)
        
        # Verify read event properties
        @test particles_size(read_event) == 2
        @test vertices_size(read_event) == 1
        @test event_number(read_event) == 123
        
        # Clean up
        rm(filename)
    end
    
    @testset "Round-trip Fidelity" begin
        # Create complex event (basic_tree structure)
        original_event = create_event(42)
        set_units!(original_event, :GeV, :mm)
        
        # Build structure
        p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
        p2 = make_shared_particle(0.750, -1.569, 32.191, 32.238, 1, 3)
        
        v1 = make_shared_vertex()
        connect_particle_in(v1, p1)
        connect_particle_out(v1, p2)
        attach_vertex_to_event(original_event, v1)
        
        original_particles = particles_size(original_event)
        original_vertices = vertices_size(original_event)
        original_event_num = event_number(original_event)
        
        filename = tempname() * ".hepmc3"
        
        # Write
        writer = HepMC3.create_writer_ascii(filename)
        HepMC3.writer_write_event(writer, original_event.cpp_object)
        HepMC3.writer_close(writer)
        
        # Read
        reader = HepMC3.create_reader_ascii(filename)
        read_event = HepMC3.GenEvent()
        HepMC3.reader_read_event(reader, read_event.cpp_object)
        HepMC3.reader_close(reader)
        
        # Compare
        @test particles_size(read_event) == original_particles
        @test vertices_size(read_event) == original_vertices
        @test event_number(read_event) == original_event_num
        
        # Clean up
        rm(filename)
    end
    
    @testset "Error Handling" begin
        # Test reading non-existent file
        reader = HepMC3.create_reader_ascii("nonexistent_file.hepmc3")
        # This should handle gracefully (might return null or fail gracefully)
        
        # Test writing to invalid path
        writer = HepMC3.create_writer_ascii("/invalid/path/file.hepmc3")
        # Should handle gracefully
    end
end