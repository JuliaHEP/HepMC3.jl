# Save as: test_fixed.jl
println("=== HepMC3 Fixed Test ===")

using HepMC3

println("✅ HepMC3 module loaded successfully!")

println("\nTesting type aliases...")
try
    # Test FourVector
    fv = HepMC3.FourVector(1.0, 2.0, 3.0, 4.0)
    println("✅ FourVector created: px=", px(fv), " py=", py(fv), " pz=", pz(fv), " e=", e(fv))
    
    # Test GenEvent
    event = HepMC3.GenEvent()
    set_event_number(event, 42)
    println("✅ GenEvent created with number: ", event_number(event))
    
    # Test GenParticle
    particle = HepMC3.GenParticle(fv, 11, 1)  # electron
    println("✅ GenParticle created: PDG=", pdg_id(particle), " Status=", status(particle))
    
    # Test GenVertex
    vertex = HepMC3.GenVertex()
    println("✅ GenVertex created")
    
    # Test Units
    println("✅ Units: MEV=", HepMC3.var"HepMC3!Units!MEV", " GEV=", HepMC3.var"HepMC3!Units!GEV")
    
    # Test manual function
    println("✅ Manual function available: ", typeof(HepMC3.add_manual_hepmc3_methods))
    
catch e
    println("❌ Error: ", e)
    println("Stacktrace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end

println("\n=== Testing convenience functions ===")
try
    # Test create_event
    event = create_event(123)
    println("✅ create_event: ", event)
    
    # Test create_particle  
    p = create_particle(10.0, 20.0, 30.0, 40.0, 11, 1)
    println("✅ create_particle: ", p)
    
    # Test create_vertex
    v = create_vertex()
    println("✅ create_vertex created")
    
catch e
    println("❌ Convenience function error: ", e)
end