# Save as: test_2_basic_objects.jl
println("=== HepMC3 Basic Object Creation Test ===")

using HepMC3

println("Testing FourVector creation...")
try
    fv = HepMC3.FourVector(1.0, 2.0, 3.0, 4.0)
    println("✅ FourVector created successfully")
    
    # Test accessing components
    try
        println("  px = ", HepMC3.px(fv))
        println("  py = ", HepMC3.py(fv))
        println("  pz = ", HepMC3.pz(fv))
        println("  e  = ", HepMC3.e(fv))
        println("✅ FourVector methods work")
    catch e
        println("⚠️  FourVector methods error: ", e)
    end
catch e
    println("❌ FourVector creation error: ", e)
end

println("\nTesting GenEvent creation...")
try
    event = HepMC3.GenEvent()
    println("✅ GenEvent created successfully")
    
    # Test setting event number
    try
        HepMC3.set_event_number(event, 42)
        num = HepMC3.event_number(event)
        println("✅ Event number set to: ", num)
    catch e
        println("⚠️  Event number methods error: ", e)
    end
catch e
    println("❌ GenEvent creation error: ", e)
end

println("\nTesting GenParticle creation...")
try
    momentum = HepMC3.FourVector(10.0, 20.0, 30.0, 40.0)
    particle = HepMC3.GenParticle(momentum, 11, 1)  # electron, status 1
    println("✅ GenParticle created successfully")
    
    try
        println("  PDG ID = ", HepMC3.pdg_id(particle))
        println("  Status = ", HepMC3.status(particle))
        println("✅ GenParticle methods work")
    catch e
        println("⚠️  GenParticle methods error: ", e)
    end
catch e
    println("❌ GenParticle creation error: ", e)
end

println("\nTesting GenVertex creation...")
try
    vertex = HepMC3.GenVertex()
    println("✅ GenVertex created successfully")
catch e
    println("❌ GenVertex creation error: ", e)
end