@testset "Event Creation and Management" begin
    @testset "Clean Event Creation" begin
        # Test clean interface
        event1 = GenEvent()
        @test event1 isa GenEvent
        
        # Test with clean units
        event2 = GenEvent()
        set_units!(event2, :GeV, :mm)
        @test event2 isa GenEvent
        
        # Test with constants
        event3 = GenEvent()
        set_units!(event3, GeV, mm)
        @test event3 isa GenEvent
        
        # Test with event number
        event4 = create_event(42)
        @test event_number(event4) == 42
    end
    
    @testset "Event Building" begin
        event = GenEvent()
        set_units!(event, :GeV, :mm)
        
        # Create particles
        p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # proton
        p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)    # electron
        
        # Create vertex
        vertex = make_shared_vertex()
        connect_particle_in(vertex, p1)
        connect_particle_out(vertex, p2)
        
        # Add to event
        attach_vertex_to_event(event, vertex)
        
        # Test event properties
        @test particles_size(event) == 2
        @test vertices_size(event) == 1
    end
    
    @testset "Complex Event Structure" begin
        # Replicate the basic_tree example structure
        event = create_event(999)
        set_units!(event, :GeV, :mm)
        
        # Build the exact structure from basic_tree
        p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
        p2 = make_shared_particle(0.750, -1.569, 32.191, 32.238, 1, 3)
        p3 = make_shared_particle(0.0, 0.0, -7000.0, 7000.0, 2212, 3)
        p4 = make_shared_particle(-3.047, -19.0, -54.629, 57.920, -2, 3)
        
        # Create vertices
        v1 = make_shared_vertex()
        connect_particle_in(v1, p1)
        connect_particle_out(v1, p2)
        set_vertex_status!(v1, 4)
        attach_vertex_to_event(event, v1)
        
        v2 = make_shared_vertex()
        connect_particle_in(v2, p3)
        connect_particle_out(v2, p4)
        attach_vertex_to_event(event, v2)
        
        v3 = make_shared_vertex()
        connect_particle_in(v3, p2)
        connect_particle_in(v3, p4)
        
        p5 = make_shared_particle(-3.813, 0.113, -1.833, 4.233, 22, 1)
        p6 = make_shared_particle(1.517, -20.68, -20.605, 85.925, -24, 3)
        
        connect_particle_out(v3, p5)
        connect_particle_out(v3, p6)
        attach_vertex_to_event(event, v3)
        
        v4 = make_shared_vertex()
        connect_particle_in(v4, p6)
        
        p7 = make_shared_particle(-2.445, 28.816, 6.082, 29.552, 1, 1)
        p8 = make_shared_particle(3.962, -49.498, -26.687, 56.373, -2, 1)
        
        connect_particle_out(v4, p7)
        connect_particle_out(v4, p8)
        attach_vertex_to_event(event, v4)
        
        # Test final structure
        @test particles_size(event) == 8
        @test vertices_size(event) == 4
        @test event_number(event) == 999
    end
end