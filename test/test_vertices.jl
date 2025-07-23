@testset "Vertex Creation and Connections" begin
    @testset "Basic Vertex Operations" begin
        # Create vertex
        vertex = make_shared_vertex()
        @test vertex != C_NULL
        
        # Test vertex status setting (manual wrapper)
        set_vertex_status!(vertex, 4)
        # Note: Getting vertex status might need manual wrapper
    end
    
    @testset "Particle-Vertex Connections" begin
        # Create particles
        p1 = make_shared_particle(10.0, 0.0, 0.0, 10.0, 11, 1)   # electron
        p2 = make_shared_particle(-10.0, 0.0, 0.0, 10.0, -11, 1) # positron
        p3 = make_shared_particle(0.0, 0.0, 20.0, 20.0, 22, 1)   # photon
        
        # Create vertex
        vertex = make_shared_vertex()
        
        # Connect particles
        connect_particle_in(vertex, p1)
        connect_particle_in(vertex, p2)
        connect_particle_out(vertex, p3)
        
        # Test connections (these functions need to be implemented)
        incoming = get_incoming_particles(vertex)
        outgoing = get_outgoing_particles(vertex)
        
        @test length(incoming) == 2
        @test length(outgoing) == 1
        @test p1 in incoming
        @test p2 in incoming
        @test p3 in outgoing
    end
    
    @testset "Complex Vertex Topologies" begin
        # Test multi-particle decay: 1 -> 3
        parent = make_shared_particle(100.0, 0.0, 0.0, 100.0, 23, 2)  # Z boson
        child1 = make_shared_particle(30.0, 10.0, 20.0, 40.0, 11, 1)  # electron
        child2 = make_shared_particle(-30.0, -10.0, -20.0, 40.0, -11, 1) # positron
        child3 = make_shared_particle(0.0, 0.0, 0.0, 20.0, 22, 1)     # photon
        
        decay_vertex = make_shared_vertex()
        connect_particle_in(decay_vertex, parent)
        connect_particle_out(decay_vertex, child1)
        connect_particle_out(decay_vertex, child2)
        connect_particle_out(decay_vertex, child3)
        
        # Verify topology
        incoming = get_incoming_particles(decay_vertex)
        outgoing = get_outgoing_particles(decay_vertex)
        
        @test length(incoming) == 1
        @test length(outgoing) == 3
        @test parent in incoming
    end
end