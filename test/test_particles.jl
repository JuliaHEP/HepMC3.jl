@testset "Particle Creation and Management" begin
    @testset "Manual Wrapper Particle Creation" begin
        # Test our clean interface
        p1 = make_shared_particle(25.0, 15.0, 50.0, 60.0, 11, 1)  # electron
        @test p1 != C_NULL
        
        # Test particle properties through clean interface
        props = get_particle_properties(p1)
        @test props.pdg_id == 11
        @test props.status == 1
        @test props.momentum.px ≈ 25.0
        @test props.momentum.py ≈ 15.0
        @test props.momentum.pz ≈ 50.0
        @test props.momentum.e ≈ 60.0
        @test props.pt ≈ sqrt(25.0^2 + 15.0^2)
        @test props.mass ≈ sqrt(60.0^2 - 25.0^2 - 15.0^2 - 50.0^2)
    end
    
    @testset "Standard Particle Types" begin
        # Electron
        electron = make_shared_particle(10.0, 0.0, 0.0, 10.0, 11, 1)
        props = get_particle_properties(electron)
        @test props.pdg_id == 11
        @test particle_charge(props.pdg_id) == -1
        
        # Positron
        positron = make_shared_particle(-10.0, 0.0, 0.0, 10.0, -11, 1)
        props = get_particle_properties(positron)
        @test props.pdg_id == -11
        @test particle_charge(props.pdg_id) == 1
        
        # Photon
        photon = make_shared_particle(5.0, 5.0, 0.0, sqrt(50), 22, 1)
        props = get_particle_properties(photon)
        @test props.pdg_id == 22
        @test particle_charge(props.pdg_id) == 0
        
        # Proton
        proton = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
        props = get_particle_properties(proton)
        @test props.pdg_id == 2212
        @test particle_charge(props.pdg_id) == 1
    end
    
    @testset "Particle Status Codes" begin
        # Beam particles (status 4)
        beam = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 4)
        props = get_particle_properties(beam)
        @test props.status == 4
        
        # Final state particles (status 1)
        final = make_shared_particle(10.0, 20.0, 30.0, 40.0, 11, 1)
        props = get_particle_properties(final)
        @test props.status == 1
        
        # Intermediate particles (status 2)
        intermediate = make_shared_particle(50.0, 0.0, 100.0, 120.0, 23, 2)
        props = get_particle_properties(intermediate)
        @test props.status == 2
    end
    
    @testset "Physics Validation" begin
        # Test momentum conservation principles
        p1 = make_shared_particle(10.0, 0.0, 0.0, 10.0, 11, 1)   # electron
        p2 = make_shared_particle(-10.0, 0.0, 0.0, 10.0, -11, 1) # positron
        
        props1 = get_particle_properties(p1)
        props2 = get_particle_properties(p2)
        
        # Conservation check
        total_px = props1.momentum.px + props2.momentum.px
        total_py = props1.momentum.py + props2.momentum.py
        @test abs(total_px) < 1e-10  # Should be conserved
        @test abs(total_py) < 1e-10  # Should be conserved
    end
end