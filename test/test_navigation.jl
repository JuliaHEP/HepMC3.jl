# Create: test/test_navigation.jl

using Test
using HepMC3

@testset "Event Navigation Tests" begin
    
    @testset "Particle Property Access" begin
        # Create test particle
        p = make_shared_particle(10.0, 20.0, 30.0, 50.0, 11, 1)
        
        # Test property access
        props = get_particle_properties(p)
        @test props.pdg_id == 11
        @test props.status == 1
        @test props.momentum.px ≈ 10.0
        @test props.pt ≈ sqrt(10.0^2 + 20.0^2)
        @test props.mass > 0
        
        # Test charge lookup
        @test particle_charge(11) == -1    # electron
        @test particle_charge(-11) == 1    # positron
        @test particle_charge(22) == 0     # photon
    end
    
    @testset "Vertex Navigation" begin
        # Create test event structure
        event = create_event(1)
        
        p1 = make_shared_particle(0.0, 0.0, 100.0, 100.0, 22, 1)
        v1 = make_shared_vertex()
        connect_particle_out(v1, p1)
        attach_vertex_to_event(event, v1)
        
        # Test vertex properties
        v_props = get_vertex_properties(v1)
        @test haskey(v_props, :id)
        @test haskey(v_props, :position)
        
        # Test particle-vertex relationships
        prod_vertex = get_production_vertex(p1)
        @test prod_vertex == v1
    end
    
    @testset "Parent-Child Relationships" begin
        # Create decay chain: p1 -> v1 -> p2 -> v2 -> (p3, p4)
        event = create_event(1)
        
        p1 = make_shared_particle(0.0, 0.0, 100.0, 100.0, 23, 2)   # Z boson
        v1 = make_shared_vertex()
        connect_particle_in(v1, p1)
        
        p2 = make_shared_particle(5.0, 0.0, 50.0, 51.0, 11, 1)     # electron
        p3 = make_shared_particle(-5.0, 0.0, 50.0, 51.0, -11, 1)   # positron
        connect_particle_out(v1, p2)
        connect_particle_out(v1, p3)
        attach_vertex_to_event(event, v1)
        
        # Test parent relationships
        parents_p2 = get_parent_particles(p2)
        @test length(parents_p2) == 1
        @test parents_p2[1] == p1
        
        # Test child relationships  
        children_p1 = get_decay_products(p1)
        @test length(children_p1) == 2
        @test p2 in children_p1
        @test p3 in children_p1
        
        # Test sibling relationships
        siblings_p2 = get_sibling_particles(p2)
        @test length(siblings_p2) == 1
        @test siblings_p2[1] == p3
    end
    
    @testset "Decay Chain Traversal" begin
        # Test complete decay chain traversal
        event = create_event(1)
        
        # Create multi-level decay
        p1 = make_shared_particle(0.0, 0.0, 200.0, 200.0, 23, 2)
        v1 = make_shared_vertex()
        connect_particle_out(v1, p1)
        attach_vertex_to_event(event, v1)
        
        tree = traverse_decay_chain(p1)
        @test isa(tree, Vector)
        
        # Test ancestry traversal
        ancestry = find_particle_ancestry(p1)
        @test isa(ancestry, Vector)
    end
end