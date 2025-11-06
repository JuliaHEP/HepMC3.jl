# Examples

This page contains complete, working examples demonstrating various features of HepMC3.jl.

## Basic Event Creation

Create a simple event with one particle:

```julia
using HepMC3

# Create event
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create a proton
proton = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)

# Create vertex
vertex = make_shared_vertex()
connect_particle_out(vertex, proton)
attach_vertex_to_event(event, vertex)

# Check event
println("Event $(event_number(event)): $(particles_size(event)) particles")
```

## Decay Chain

Create a particle decay chain:

```julia
using HepMC3

event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles: Z boson decaying to electron-positron pair
z_boson = make_shared_particle(10.0, 20.0, 100.0, 200.0, 23, 2)
electron = make_shared_particle(5.0, 10.0, 50.0, 60.0, 11, 1)
positron = make_shared_particle(5.0, 10.0, 50.0, 60.0, -11, 1)

# Create decay vertex
decay_vertex = make_shared_vertex()
connect_particle_in(decay_vertex, z_boson)
connect_particle_out(decay_vertex, electron)
connect_particle_out(decay_vertex, positron)
attach_vertex_to_event(event, decay_vertex)

# Navigate decay chain
children = get_decay_products(z_boson)
println("Z boson decays to $(length(children)) particles")
```

## Complete Event with Metadata

Create an event with PDF info, cross section, and attributes:

```julia
using HepMC3

event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
p2 = make_shared_particle(0.750, -1.569, 32.191, 32.238, 1, 3)

# Create vertex
v1 = make_shared_vertex()
set_vertex_position(v1, 0.0, 0.0, 0.0, 0.0)
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Add PDF information
add_pdf_info!(event, 1, 2, 0.1, 0.2, 100.0, 0.5, 0.6, 1, 2)

# Add cross section
add_cross_section!(event, 1.2, 0.1)

# Add event weights
set_event_weights!(event, [1.0, 0.95, 1.05])

# Add particle attributes
add_particle_attribute!(p1, "is_beam", 1)
add_particle_attribute!(p2, "flavor", 1)

println("Event created with metadata")
```

## File I/O Round Trip

Write an event to file and read it back:

```julia
using HepMC3

# Create event
event = create_event(42)
set_units!(event, :GeV, :mm)

p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)

v1 = make_shared_vertex()
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Write to file
filename = "test_event.hepmc3"
writer = create_writer_ascii(filename)
writer_write_event(writer, event.cpp_object)
writer_close(writer)

# Read back
events = read_hepmc_file(filename)
read_event = events[1]

# Verify
@assert particles_size(read_event) == particles_size(event)
@assert vertices_size(read_event) == vertices_size(event)
@assert event_number(read_event) == event_number(event)

println("Round trip successful!")
rm(filename)
```

## Processing Event Files

Read and analyze multiple events from a file:

```julia
using HepMC3

# Read events
events = read_hepmc_file("events.hepmc3"; max_events=100)

println("Processing $(length(events)) events")

for (i, event_ptr) in enumerate(events)
    # Get final state particles
    final_state = get_final_state_particles(event_ptr)

    # Calculate statistics
    total_pt = sum(p -> get_particle_properties(p).pt, final_state)
    n_charged = count(p -> particle_charge(get_particle_properties(p).pdg_id) != 0,
                      final_state)

    println("Event $i: $(length(final_state)) final state, " *
            "total pT = $(round(total_pt, digits=2)) GeV, " *
            "$n_charged charged particles")
end
```

## Complex Decay Chain

Build and traverse a complex decay chain:

```julia
using HepMC3

function build_complex_event()
    event = create_event(1)
    set_units!(event, :GeV, :mm)

    # W boson production and decay
    # p1 + p2 -> W -> e + nu_e

    p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # Proton
    p2 = make_shared_particle(0.0, 0.0, -7000.0, 7000.0, 2212, 3) # Anti-proton

    # Production vertex
    v1 = make_shared_vertex()
    connect_particle_in(v1, p1)
    connect_particle_in(v1, p2)

    w = make_shared_particle(0.0, 0.0, 0.0, 80.4, -24, 2)  # W- boson
    connect_particle_out(v1, w)
    attach_vertex_to_event(event, v1)

    # Decay vertex
    v2 = make_shared_vertex()
    connect_particle_in(v2, w)

    e = make_shared_particle(0.0, 0.0, 40.0, 40.0, 11, 1)      # Electron
    nu = make_shared_particle(0.0, 0.0, -40.0, 40.0, 12, 1)    # Electron neutrino

    connect_particle_out(v2, e)
    connect_particle_out(v2, nu)
    attach_vertex_to_event(event, v2)

    return event
end

event = build_complex_event()

# Traverse decay chain
w_particle = get_particle_at(event, 3)  # Assuming W is 3rd particle
decay_tree = traverse_decay_chain(w_particle)

println("W boson decay chain:")
for node in decay_tree
    props = node.properties
    println("  -> PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV")
end
```

## Particle Analysis

Analyze particle properties in an event:

```julia
using HepMC3

function analyze_particles(event_ptr)
    n_particles = particles_size(event_ptr)

    println("Particle Analysis:")
    println("  Total particles: $n_particles")

    # Categorize by status
    final_state = []
    intermediate = []
    initial = []

    for i in 1:n_particles
        particle = get_particle_at(event_ptr, i)
        props = get_particle_properties(particle)

        if props.status == 1
            push!(final_state, particle)
        elseif props.status == 2
            push!(intermediate, particle)
        elseif props.status >= 3
            push!(initial, particle)
        end
    end

    println("  Final state: $(length(final_state))")
    println("  Intermediate: $(length(intermediate))")
    println("  Initial: $(length(initial))")

    # Analyze final state
    if !isempty(final_state)
        pts = [get_particle_properties(p).pt for p in final_state]
        println("  Final state pT range: $(minimum(pts)) - $(maximum(pts)) GeV")
    end
end

# Use with events
events = read_hepmc_file("events.hepmc3"; max_events=10)
for event in events
    analyze_particles(event)
end
```

## Event Building Pattern

A reusable pattern for building events:

```julia
using HepMC3

function build_event_template()
    event = create_event(1)
    set_units!(event, :GeV, :mm)

    # Helper function to add particle to vertex
    function add_particle_to_vertex(vertex, px, py, pz, e, pdg_id, status, is_incoming)
        particle = make_shared_particle(px, py, pz, e, pdg_id, status)
        if is_incoming
            connect_particle_in(vertex, particle)
        else
            connect_particle_out(vertex, particle)
        end
        return particle
    end

    # Build event structure
    v1 = make_shared_vertex()
    p1 = add_particle_to_vertex(v1, 0.0, 0.0, 7000.0, 7000.0, 2212, 3, true)
    p2 = add_particle_to_vertex(v1, 10.0, 20.0, 100.0, 150.0, 11, 1, false)
    attach_vertex_to_event(event, v1)

    return event
end

event = build_event_template()
println("Event built: $(particles_size(event)) particles")
```

## JetReconstruction Integration

HepMC3.jl can be used with [JetReconstruction.jl](https://github.com/JuliaHEP/JetReconstruction.jl) by converting HepMC3 particles to `PseudoJet` objects. The `PseudoJet` struct is a generic data structure that can be used for both proton-proton (pp) and electron-positron (e⁺e⁻) events. The difference lies in the jet reconstruction algorithm used:

- **For pp events**: Use algorithms like `JetAlgorithm.AntiKt`, `JetAlgorithm.Kt`, or `JetAlgorithm.CA` (Cambridge/Aachen)
- **For e⁺e⁻ events**: Use algorithms like `JetAlgorithm.Durham` or `JetAlgorithm.EEKt` (generalized e⁺e⁻ kₜ)

This example demonstrates reading HepMC3 files and converting final state particles to the `PseudoJet` format:

```julia
using HepMC3, JetReconstruction

"""
    read_final_state_particles(filename; max_events=-1)
Read HepMC3 file and return JetReconstruction-compatible PseudoJet events.
This function extracts final state particles (status == 1) from HepMC3 events
and converts them to PseudoJet format for jet reconstruction.
"""
function read_final_state_particles(filename::String; max_events::Int=-1)
    # Read events using HepMC3 interface (handles compressed files automatically)
    events = read_hepmc_file_with_compression(filename; max_events=max_events)

    # Convert to PseudoJets for JetReconstruction
    pseudojet_events = Vector{PseudoJet}[]

    events_processed = 0
    for (event_idx, event_ptr) in enumerate(events)
        # Extract final state particles (status == 1)
        final_state = get_final_state_particles(event_ptr)

        # Skip empty events
        if isempty(final_state)
            continue
        end

        # Convert HepMC3 particles to PseudoJets
        input_particles = PseudoJet[]
        particle_index = 1

        for particle in final_state
            props = get_particle_properties(particle)

            # Create PseudoJet from four-momentum
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

        # Respect max_events limit
        if max_events > 0 && events_processed >= max_events
            break
        end
    end

    @info "Processed $(length(pseudojet_events)) events from $filename"
    return pseudojet_events
end

# Example: Read events and perform jet reconstruction
filename = "events.hepmc3.zst"  # Can be compressed or uncompressed

# Read final state particles
pseudojet_events = read_final_state_particles(filename; max_events=100)

# Perform jet reconstruction on first event
if !isempty(pseudojet_events)
    event_particles = pseudojet_events[1]

    # For pp events: use anti-kT algorithm
    clusterseq_pp = jet_reconstruct(event_particles;
                                     algorithm = JetAlgorithm.AntiKt,
                                     R = 0.4)
    jets_pp = inclusive_jets(clusterseq_pp, ptmin = 5.0)

    # For e⁺e⁻ events: use Durham algorithm (R parameter is ignored)
    clusterseq_ee = jet_reconstruct(event_particles;
                                     algorithm = JetAlgorithm.Durham)
    jets_ee = inclusive_jets(clusterseq_ee, ptmin = 5.0)

    println("Event 1: $(length(event_particles)) particles")
    println("PP jets (anti-kT, R=0.4): $(length(jets_pp)) jets with pT > 5 GeV")
    println("e⁺e⁻ jets (Durham): $(length(jets_ee)) jets with pT > 5 GeV")
end
```

### Complete Pipeline Example

A complete workflow from HepMC3 file to jet analysis. Note that the same `PseudoJet` conversion works for both pp and e⁺e⁻ events; only the algorithm differs:

```julia
using HepMC3, JetReconstruction

# For pp events
function analyze_pp_jets_from_hepmc(filename::String; max_events::Int=10, R::Float64=0.4, ptmin::Float64=5.0)
    pseudojet_events = read_final_state_particles(filename; max_events=max_events)

    println("Analyzing $(length(pseudojet_events)) pp events")
    println("=" ^ 60)

    for (event_idx, event_particles) in enumerate(pseudojet_events)
        # Use anti-kT for pp events
        clusterseq = jet_reconstruct(event_particles;
                                     algorithm = JetAlgorithm.AntiKt,
                                     R = R)
        jets = inclusive_jets(clusterseq, ptmin = ptmin)

        println("Event $event_idx: $(length(jets)) jets (anti-kT, R=$R)")
    end
end

# For e⁺e⁻ events
function analyze_ee_jets_from_hepmc(filename::String; max_events::Int=10, ptmin::Float64=5.0)
    pseudojet_events = read_final_state_particles(filename; max_events=max_events)

    println("Analyzing $(length(pseudojet_events)) e⁺e⁻ events")
    println("=" ^ 60)

    for (event_idx, event_particles) in enumerate(pseudojet_events)
        # Use Durham algorithm for e⁺e⁻ events (R parameter is ignored)
        clusterseq = jet_reconstruct(event_particles;
                                     algorithm = JetAlgorithm.Durham)
        jets = inclusive_jets(clusterseq, ptmin = ptmin)

        println("Event $event_idx: $(length(jets)) jets (Durham)")
    end
end

# Run analysis
analyze_pp_jets_from_hepmc("pp_events.hepmc3.zst"; max_events=10, R=0.4, ptmin=5.0)
analyze_ee_jets_from_hepmc("ee_events.hepmc3.zst"; max_events=10, ptmin=5.0)
```

### Key Points

1. **Final State Extraction**: Use `get_final_state_particles()` to extract only stable particles (status == 1) from HepMC3 events.

2. **PseudoJet Conversion**: The `PseudoJet` struct is a generic data structure that works for both pp and e⁺e⁻ events. Convert HepMC3 particle four-momenta to `PseudoJet` objects using the same conversion function regardless of event type.

3. **Algorithm Selection**: The choice of jet reconstruction algorithm depends on the event type:
   - **pp events**: Use `JetAlgorithm.AntiKt`, `JetAlgorithm.Kt`, or `JetAlgorithm.CA` with an `R` parameter
   - **e⁺e⁻ events**: Use `JetAlgorithm.Durham` or `JetAlgorithm.EEKt` (the `R` parameter is ignored for Durham)

4. **Compressed Files**: The `read_hepmc_file_with_compression()` function automatically handles both compressed (`.zst`) and uncompressed HepMC3 files.

5. **Event Processing**: The conversion function processes events one at a time, allowing for efficient memory usage with large files.

This example demonstrates how to convert HepMC3 event data to the `PseudoJet` format expected by JetReconstruction.jl. The same conversion works for both pp and e⁺e⁻ events; only the jet reconstruction algorithm differs.

## See Also

- [Getting Started](@ref) for installation and basics
- [Events](@ref) for event manipulation
- [Particles](@ref) for particle operations
- [File I/O](@ref) for reading and writing files
- [JetReconstruction.jl](https://github.com/JuliaHEP/JetReconstruction.jl) for jet finding algorithms
