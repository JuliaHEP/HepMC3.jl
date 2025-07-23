@testset "Manual Wrapper Functions" begin
    @testset "Shared Pointer Operations" begin
        # Test particle creation
        p1 = make_shared_particle(1.0, 2.0, 3.0, 5.0, 11, 1)
        @test p1 != C_NULL
        
        # Test vertex creation
        v1 = make_shared_vertex()
        @test v1 != C_NULL
        
        # Test connections
        connect_particle_out(v1, p1)
        
        # Test event attachment
        event = create_event(1)
        attach_vertex_to_event(event, v1)
        
        @test particles_size(event) == 1
        @test vertices_size(event) == 1
    end
    
    @testset "Event Manipulation" begin
        event = GenEvent()
        set_units!(event, :GeV, :mm)
        
        p1 = make_shared_particle(10.0, 20.0, 30.0, 40.0, 11, 1)
        vertex = make_shared_vertex()
        connect_particle_out(vertex, p1)
        attach_vertex_to_event(event, vertex)
        
        # Test position shift
        shift_position!(event, 5.0, 5.0, 5.0, 5.0)
        
        # Test particle removal
        initial_count = particles_size(event)
        remove_particle!(event, p1)
        final_count = particles_size(event)
        
        @test final_count < initial_count
    end
end