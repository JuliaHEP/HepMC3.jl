using HepMC3, JetReconstruction

"""
    read_final_state_particles(filename; max_events=-1)
Read HepMC3 file and return JetReconstruction-compatible PseudoJet events.
Mimics JetReconstruction.read_final_state_particles() exactly.
"""
function final_state_particles(filename::String; max_events::Int=-1)
    # Read events using HepMC3 interface
    events = read_hepmc_file_with_compression(filename; max_events=max_events)
    
    # Convert to PseudoJets exactly like JetReconstruction does
    pseudojet_events = Vector{PseudoJet}[]
    
    events_processed = 0
    for (event_idx, event_ptr) in enumerate(events)
        final_state = get_final_state_particles(event_ptr)
        
        # Skip empty events (like JetReconstruction might do)
        if isempty(final_state)
            continue
        end
        
        input_particles = PseudoJet[]
        particle_index = 1
        
        for particle in final_state
            props = get_particle_properties(particle)
            
            # Match JetReconstruction's PseudoJet constructor exactly
            pseudojet = PseudoJet(
                props.momentum.px,  # px
                props.momentum.py,  # py  
                props.momentum.pz,  # pz
                props.momentum.e;   # E
                cluster_hist_index = particle_index
            )
            push!(input_particles, pseudojet)
            particle_index += 1
        end
        
        push!(pseudojet_events, input_particles)
        events_processed += 1
        
        # Respect max_events limit like JetReconstruction
        if max_events > 0 && events_processed >= max_events
            break
        end
    end
    
    @info "Total Events: $(length(pseudojet_events))"
    return pseudojet_events
end

# Test and compare
println("🔍 COMPARING EVENT COUNTS")
println("=" ^ 50)

# Our implementation
println("Testing our implementation...")
data_two = final_state_particles("../JetReconstruction.jl/test/data/events.eeH.hepmc3.zst")
println("Our events: $(length(data_two))")

# JetReconstruction's implementation  
println("\nTesting JetReconstruction's implementation...")
data_one = JetReconstruction.read_final_state_particles("../JetReconstruction.jl/test/data/events.eeH.hepmc3.zst")
println("JetReconstruction events: $(length(data_one))")

println("\n📊 COMPARISON:")
println("JetReconstruction: $(length(data_one)) events")
println("Our implementation: $(length(data_two)) events")
println("Difference: $(length(data_two) - length(data_one))")

# Debug: Check if it's the max_events parameter
println("\n🔧 TESTING WITH EXPLICIT LIMITS:")
data_two_limited = final_state_particles("../JetReconstruction.jl/test/data/events.eeH.hepmc3.zst"; max_events=100)
println("Our implementation (max_events=100): $(length(data_two_limited))")

# Check first few and last few events for differences
if length(data_one) > 0 && length(data_two) > 0
    println("\n🔍 FIRST EVENT COMPARISON:")
    println("JetReconstruction event 1: $(length(data_one[1])) particles")
    println("Our implementation event 1: $(length(data_two[1])) particles")
    
    if length(data_one) >= 2 && length(data_two) >= 2
        println("\nSECOND EVENT COMPARISON:")
        println("JetReconstruction event 2: $(length(data_one[2])) particles") 
        println("Our implementation event 2: $(length(data_two[2])) particles")
    end
end

events = data_two


