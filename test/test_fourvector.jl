@testset "FourVector Operations" begin
    @testset "Construction and Basic Access" begin
        # Default constructor
        v1 = FourVector()
        @test px(v1) == 0.0
        @test py(v1) == 0.0
        @test pz(v1) == 0.0
        @test e(v1) == 0.0
        
        # Parameterized constructor
        v2 = FourVector(1.0, 2.0, 3.0, 4.0)
        @test px(v2) ≈ 1.0
        @test py(v2) ≈ 2.0
        @test pz(v2) ≈ 3.0
        @test e(v2) ≈ 4.0
    end
    
    @testset "Physics Calculations" begin
        # Test realistic physics values
        electron_p = FourVector(25.0, 15.0, 50.0, 60.0)  # GeV
        
        # Transverse momentum
        expected_pt = sqrt(25.0^2 + 15.0^2)
        @test sqrt(px(electron_p)^2 + py(electron_p)^2) ≈ expected_pt
        
        # Invariant mass
        expected_mass = sqrt(60.0^2 - 25.0^2 - 15.0^2 - 50.0^2)
        calculated_mass = sqrt(e(electron_p)^2 - px(electron_p)^2 - py(electron_p)^2 - pz(electron_p)^2)
        @test calculated_mass ≈ expected_mass
        
        # Rapidity (when pz != 0)
        if pz(electron_p) != 0
            eta = 0.5 * log((e(electron_p) + pz(electron_p))/(e(electron_p) - pz(electron_p)))
            @test !isnan(eta)
            @test !isinf(eta)
        end
    end
    
    @testset "Edge Cases" begin
        # Zero vector
        zero_v = FourVector(0.0, 0.0, 0.0, 0.0)
        @test px(zero_v) == 0.0
        @test py(zero_v) == 0.0
        @test pz(zero_v) == 0.0
        @test e(zero_v) == 0.0
        
        # Large values
        large_v = FourVector(1e6, 2e6, 3e6, 4e6)
        @test px(large_v) ≈ 1e6
        @test py(large_v) ≈ 2e6
        @test pz(large_v) ≈ 3e6
        @test e(large_v) ≈ 4e6
        
        # Negative values
        neg_v = FourVector(-10.0, -20.0, -30.0, 40.0)
        @test px(neg_v) ≈ -10.0
        @test py(neg_v) ≈ -20.0
        @test pz(neg_v) ≈ -30.0
        @test e(neg_v) ≈ 40.0
    end
end