@testset "Physics Validation Tests" begin
    @testset "Momentum Conservation" begin
        # Create e+ e- -> gamma gamma
        event = GenEvent()
        set_units!(event, :GeV, :mm)
        
        # Initial particles
        electron = make_shared_particle(10.0, 0.0, 0.0, 10.0, 11, 1)
        positron = make_shared_particle(-10.0, 0.0, 0.0, 10.0, -11, 1)
        
        # Final particles  
        photon1 = make_shared_particle(5.0, 5.0, 0.0, sqrt(50), 22, 1)
        photon2 = make_shared_particle(-5.0, -5.0, 0.0, sqrt(50), 22, 1)
        
        # Build event
        vertex = make_shared_vertex()
        connect_particle_in(vertex, electron)
        connect_particle_in(vertex, positron)
        connect_particle_out(vertex, photon1)
        connect_particle_out(vertex, photon2)
        attach_vertex_to_event(event, vertex)
        
        # Check conservation
        e_props = get_particle_properties(electron)
        p_props = get_particle_properties(positron)
        g1_props = get_particle_properties(photon1)
        g2_props = get_particle_properties(photon2)
        
        initial_px = e_props.momentum.px + p_props.momentum.px
        final_px = g1_props.momentum.px + g2_props.momentum.px
        @test abs(initial_px - final_px) < 1e-10
        
        initial_py = e_props.momentum.py + p_props.momentum.py
        final_py = g1_props.momentum.py + g2_props.momentum.py
        @test abs(initial_py - final_py) < 1e-10
    end
    
    @testset "Realistic LHC Event" begin
        # Test building a realistic LHC-like event
        event = create_event(1)
        set_units!(event, :GeV, :mm)
        
        # LHC beam energies
        proton1 = make_shared_particle(0.0, 0.0, 6500.0, 6500.0, 2212, 4)
        proton2 = make_shared_particle(0.0, 0.0, -6500.0, 6500.0, 2212, 4)
        
        # Build collision
        collision_vertex = make_shared_vertex()
        connect_particle_in(collision_vertex, proton1)
        connect_particle_in(collision_vertex, proton2)
        
        # Add some final state particles
        muon = make_shared_particle(45.0, 30.0, 20.0, 60.0, 13, 1)
        antimuon = make_shared_particle(-45.0, -30.0, -20.0, 60.0, -13, 1)
        
        connect_particle_out(collision_vertex, muon)
        connect_particle_out(collision_vertex, antimuon)
        attach_vertex_to_event(event, collision_vertex)
        
        # Physics checks
        @test particles_size(event) == 4
        @test vertices_size(event) == 1
        
        # Check center-of-mass energy  
        sqrt_s = 2 * 6500.0  # LHC energy
        @test sqrt_s ≈ 13000.0
    end
end