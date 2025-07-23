@testset "Event Attributes (Manual Wrappers)" begin
    @testset "PDF Info Attributes" begin
        event = GenEvent()
        
        # Test PDF info creation and addition
        pdf_info = add_pdf_info!(event, 1, 2, 0.1, 0.2, 100.0, 0.5, 0.6, 1, 2)
        @test pdf_info != C_NULL
    end
    
    @testset "Cross Section Attributes" begin
        event = GenEvent()
        
        # Test cross section
        cross_section = add_cross_section!(event, 1.23, 0.45)
        @test cross_section != C_NULL
        
        # Test modification
        HepMC3.set_cross_section(cross_section, 2.0, 0.1)
        
        # Test removal
        HepMC3.remove_event_attribute(event.cpp_object, "GenCrossSection")
    end
    
    @testset "Heavy Ion Attributes" begin
        event = GenEvent()
        
        # Test heavy ion info
        heavy_ion = add_heavy_ion!(event, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0.1, 2.3, 4.5, 6.7)
        @test heavy_ion != C_NULL
    end
    
    @testset "Particle Attributes" begin
        # Test particle attributes
        p1 = make_shared_particle(10.0, 20.0, 30.0, 40.0, 11, 1)
        
        # Test different attribute types
        int_attr = add_particle_attribute!(p1, "tool", 42)
        @test int_attr != C_NULL
        
        float_attr = add_particle_attribute!(p1, "weight", 1.5)
        @test float_attr != C_NULL
        
        string_attr = add_particle_attribute!(p1, "label", "test_particle")
        @test string_attr != C_NULL
    end
end