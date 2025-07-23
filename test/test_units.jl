@testset "Units and Clean Interface" begin
    @testset "Unit Constants" begin
        # Test that our clean constants work
        @test GeV != C_NULL
        @test MeV != C_NULL  
        @test mm != C_NULL
        @test cm != C_NULL
    end
    
    @testset "Clean Units Interface" begin
        event = GenEvent()
        
        # Test symbol-based interface
        set_units!(event, :GeV, :mm)
        # Note: Getting units back might need manual wrapper
        
        # Test constant-based interface  
        set_units!(event, GeV, mm)
        set_units!(event, MeV, cm)
    end
    
    @testset "Event Creation with Units" begin
        # Test various unit combinations using clean interface
        event_gev_mm = GenEvent()
        set_units!(event_gev_mm, :GeV, :mm)
        @test event_gev_mm isa GenEvent
        
        event_mev_cm = GenEvent()
        set_units!(event_mev_cm, :MeV, :cm)
        @test event_mev_cm isa GenEvent
        
        event_const = GenEvent()
        set_units!(event_const, GeV, mm)
        @test event_const isa GenEvent
    end
end