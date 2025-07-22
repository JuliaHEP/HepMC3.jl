# Save as: test_4_simple_event.jl
println("=== HepMC3 Simple Event Creation Test ===")

using HepMC3

try
    println("Creating a simple particle physics event...")
    
    # Create event
    event = HepMC3.GenEvent()
    HepMC3.set_event_number(event, 1)
    println("✅ Event created with number: ", HepMC3.event_number(event))
    
    # Create particles
    println("\nCreating particles...")
    
    # Incoming proton 1 (beam)
    p1_momentum = HepMC3.FourVector(0.0, 0.0, 7000.0, 7000.0)  # High energy proton
    p1 = HepMC3.GenParticle(p1_momentum, 2212, -1)  # proton, incoming
    println("✅ Proton 1 created: PDG=", HepMC3.pdg_id(p1), " Status=", HepMC3.status(p1))
    
    # Incoming proton 2 (beam)
    p2_momentum = HepMC3.FourVector(0.0, 0.0, -7000.0, 7000.0)  # High energy proton (opposite direction)
    p2 = HepMC3.GenParticle(p2_momentum, 2212, -1)  # proton, incoming
    println("✅ Proton 2 created: PDG=", HepMC3.pdg_id(p2), " Status=", HepMC3.status(p2))
    
    # Outgoing particles (e.g., from collision)
    e_momentum = HepMC3.FourVector(10.0, 20.0, 30.0, 50.0)
    electron = HepMC3.GenParticle(e_momentum, 11, 1)  # electron, final state
    println("✅ Electron created: PDG=", HepMC3.pdg_id(electron), " Status=", HepMC3.status(electron))
    
    positron_momentum = HepMC3.FourVector(-10.0, -20.0, -30.0, 50.0)
    positron = HepMC3.GenParticle(positron_momentum, -11, 1)  # positron, final state
    println("✅ Positron created: PDG=", HepMC3.pdg_id(positron), " Status=", HepMC3.status(positron))
    
    # Create vertices
    println("\nCreating vertices...")
    
    # Initial vertex (beam collision)
    initial_vertex = HepMC3.GenVertex()
    println("✅ Initial vertex created")
    
    # Final vertex (particle production)  
    final_vertex = HepMC3.GenVertex()
    println("✅ Final vertex created")
    
    println("\n✅ Basic event structure created successfully!")
    println("   - Event number: ", HepMC3.event_number(event))
    println("   - Created 4 particles and 2 vertices")
    
catch e
    println("❌ Error creating simple event: ", e)
    println("Stacktrace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end