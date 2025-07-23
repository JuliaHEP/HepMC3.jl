# Create a debug test file: test/debug_particles.jl

using Test
using HepMC3

println("🔍 Debugging particle creation...")

# Test 1: Check if particle creation works
p1 = make_shared_particle(25.0, 15.0, 50.0, 60.0, 11, 1)
println("Particle pointer: $p1")
println("Is NULL? $(p1 == C_NULL)")

if p1 != C_NULL
    # Test 2: Try direct function calls
    try
        pdg = HepMC3.pdg_id(p1)
        println("Direct PDG call: $pdg")
    catch e
        println("❌ Direct PDG call failed: $e")
    end
    
    try
        stat = HepMC3.status(p1)
        println("Direct status call: $stat")
    catch e
        println("❌ Direct status call failed: $e")
    end
    
    try
        mom_ptr = HepMC3.momentum(p1)
        println("Momentum pointer: $mom_ptr")
        if mom_ptr != C_NULL
            px_val = HepMC3.px(mom_ptr)
            py_val = HepMC3.py(mom_ptr)
            pz_val = HepMC3.pz(mom_ptr)
            e_val = HepMC3.e(mom_ptr)
            println("Momentum: px=$px_val, py=$py_val, pz=$pz_val, e=$e_val")
        end
    catch e
        println("❌ Momentum call failed: $e")
    end
    
    # Test 3: Try our function
    try
        props = get_particle_properties(p1)
        println("Properties: $props")
    catch e
        println("❌ get_particle_properties failed: $e")
    end
end