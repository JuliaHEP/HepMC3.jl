# Getting Started

This guide will help you get started with HepMC3.jl, covering installation, basic usage, and common workflows.

## Installation

### From Package Registry

Install HepMC3.jl using Julia's package manager:

```julia
using Pkg
Pkg.add("HepMC3")
```

The package includes the HepMC3 C++ library via `HepMC3_jll`, so no additional system dependencies are required for basic usage.

### From Source

For development or to use the latest features, see the [Building from Source](@ref) section.

## Basic Usage

### Loading the Package

```julia
using HepMC3
```

Note: On first load, you may see a message about skipping precompilation. This is expected behavior since HepMC3.jl loads a dynamically generated library.

### Creating an Event

Create a new Monte Carlo event:

```julia
# Create an event with event number 1
event = create_event(1)

# Set units (required before adding particles)
set_units!(event, :GeV, :mm)
```

### Creating Particles

Create particles with four-momentum (px, py, pz, E), PDG ID, and status code:

```julia
# Create a proton beam particle
# make_shared_particle(px, py, pz, E, pdg_id, status)
proton = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 4)

# Create an electron (final state)
electron = make_shared_particle(10.0, 20.0, 100.0, 102.5, 11, 1)
```

Parameters:
- `px, py, pz, E`: Four-momentum components (in units set for the event)
- `pdg_id`: Particle Data Group ID (e.g., 11 = electron, 2212 = proton)
- `status`: Particle status code:
  - `1` = final state (stable, observable)
  - `2` = intermediate (decays)
  - `3` = documentation particle
  - `4` = beam particle

### Creating Vertices

Vertices connect incoming and outgoing particles:

```julia
# Create a vertex
vertex = make_shared_vertex()

# Connect particles
connect_particle_in(vertex, proton)    # Incoming particle
connect_particle_out(vertex, electron) # Outgoing particle

# Add vertex to event
attach_vertex_to_event(event, vertex)
```

### Accessing Particle Properties

Get comprehensive information about a particle:

```julia
props = get_particle_properties(electron)

# Access properties
println("PDG ID: $(props.pdg_id)")
println("Status: $(props.status)")
println("pT: $(props.pt) GeV")
println("Mass: $(props.mass) GeV")
println("Eta: $(props.eta)")
println("Phi: $(props.phi)")

# Momentum components
println("px: $(props.momentum.px)")
println("py: $(props.momentum.py)")
println("pz: $(props.momentum.pz)")
println("E: $(props.momentum.e)")
```

## Reading Event Files

### Basic File Reading

Read all events from a HepMC3 file:

```julia
events = read_hepmc_file("events.hepmc3")
println("Read $(length(events)) events")
```

### Reading Compressed Files

HepMC3.jl automatically handles compressed files:

```julia
# Read zstd compressed file
events = read_hepmc_file_with_compression("events.hepmc3.zst")

# Read gzip compressed file
events = read_hepmc_file_with_compression("events.hepmc3.gz")
```

### Limiting Events

For large files, limit the number of events read:

```julia
events = read_hepmc_file_with_compression("large_file.hepmc3.zst"; max_events=100)
```

### Processing Events

Iterate over events and access their contents:

```julia
for (i, event) in enumerate(events)
    # Get final state particles
    final_state = get_final_state_particles(event)

    println("Event $i: $(length(final_state)) final state particles")

    for particle in final_state
        props = get_particle_properties(particle)
        println("  PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV")
    end
end
```

## Writing Event Files

Write events to a HepMC3 ASCII file:

```julia
# Create writer
writer = create_writer_ascii("output.hepmc3")

# Write event
writer_write_event(writer, event.cpp_object)

# Close writer (important!)
writer_close(writer)
```

## Complete Example

Here is a complete example creating and processing an event:

```julia
using HepMC3

# Create event
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles for a simple process: proton -> Z -> e+ e-
p_beam = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 4)  # proton beam
z_boson = make_shared_particle(50.0, 30.0, 200.0, 215.0, 23, 2)   # Z boson
electron = make_shared_particle(25.0, 15.0, 100.0, 102.5, 11, 1)  # electron
positron = make_shared_particle(25.0, 15.0, 100.0, 102.5, -11, 1) # positron

# Create production vertex
v1 = make_shared_vertex()
set_vertex_position(v1, 0.0, 0.0, 0.0, 0.0)
connect_particle_in(v1, p_beam)
connect_particle_out(v1, z_boson)
attach_vertex_to_event(event, v1)

# Create decay vertex
v2 = make_shared_vertex()
set_vertex_position(v2, 0.0, 0.0, 0.1, 0.0001)  # Slightly displaced
connect_particle_in(v2, z_boson)
connect_particle_out(v2, electron)
connect_particle_out(v2, positron)
attach_vertex_to_event(event, v2)

# Print event summary
println("Event $(event_number(event)):")
println("  Particles: $(particles_size(event))")
println("  Vertices: $(vertices_size(event))")

# Get final state particles
final_state = get_final_state_particles(event)
println("  Final state: $(length(final_state)) particles")

for particle in final_state
    props = get_particle_properties(particle)
    println("    PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV, eta=$(round(props.eta, digits=2))")
end

# Write to file
writer = create_writer_ascii("test_event.hepmc3")
writer_write_event(writer, event.cpp_object)
writer_close(writer)
println("Wrote event to test_event.hepmc3")

# Read back and verify
events_read = read_hepmc_file("test_event.hepmc3")
println("Read back: $(particles_size(events_read[1])) particles")

# Clean up
rm("test_event.hepmc3")
```

## Common Workflows

### Analyzing Final State Particles

```julia
events = read_hepmc_file_with_compression("events.hepmc3.zst")

for event in events
    final_state = get_final_state_particles(event)

    # Filter electrons and positrons
    leptons = filter(final_state) do p
        abs(get_particle_properties(p).pdg_id) == 11
    end

    if length(leptons) >= 2
        # Calculate invariant mass of lepton pair
        l1 = get_particle_properties(leptons[1])
        l2 = get_particle_properties(leptons[2])

        # ... physics analysis
    end
end
```

### Navigating Decay Chains

```julia
for event in events
    # Find all Z bosons
    for i in 1:particles_size(event)
        particle = get_particle_at(event, i)
        props = get_particle_properties(particle)

        if props.pdg_id == 23  # Z boson
            # Get decay products
            children = get_decay_products(particle)

            println("Z boson decays to $(length(children)) particles:")
            for child in children
                child_props = get_particle_properties(child)
                println("  PDG=$(child_props.pdg_id)")
            end
        end
    end
end
```

### Integration with JetReconstruction.jl

```julia
using HepMC3
using JetReconstruction

events = read_hepmc_file_with_compression("events.hepmc3.zst")

for event in events
    final_state = get_final_state_particles(event)

    # Convert to PseudoJets
    pseudojets = PseudoJet[]
    for particle in final_state
        props = get_particle_properties(particle)
        push!(pseudojets, PseudoJet(
            props.momentum.px,
            props.momentum.py,
            props.momentum.pz,
            props.momentum.e
        ))
    end

    # Run jet reconstruction
    jets = jet_reconstruct(pseudojets; R=0.4, algorithm=JetAlgorithm.AntiKt)
    final_jets = inclusive_jets(jets; ptmin=20.0)

    println("Found $(length(final_jets)) jets with pT > 20 GeV")
end
```

## Next Steps

- Learn about [Events](@ref) in detail
- Explore [Particles](@ref) and their properties
- Understand [Vertices](@ref) and event topology
- Work with [Four-Vectors](@ref) for kinematic calculations
- Read about [File I/O](@ref) for handling large datasets
- See [Examples](@ref) for more complex use cases
