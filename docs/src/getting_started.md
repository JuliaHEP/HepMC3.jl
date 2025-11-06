# Getting Started

This guide will help you get started with HepMC3.jl.

## Installation

Install HepMC3.jl using Julia's package manager:

```julia
using Pkg
Pkg.add("HepMC3")
```

The package includes the HepMC3 C++ library via `HepMC3_jll`, so no additional system dependencies are required.

## Basic Usage

### Creating an Event

Start by creating a new event:

```julia
using HepMC3

# Create an event with event number 1
event = create_event(1)

# Or create directly
event = GenEvent()
set_event_number(event, 1)
```

### Setting Units

HepMC3 uses explicit units for momentum and position. Set them when creating events:

```julia
# Using symbols (recommended)
set_units!(event, :GeV, :mm)

# Or using constants
set_units!(event, GeV, mm)
```

Available momentum units: `:GeV`, `:MeV` (or `GEV`, `MEV`)
Available length units: `:mm`, `:cm` (or `MM`, `CM`)

### Creating Particles

Create particles with four-momentum and PDG ID:

```julia
# Create a proton with momentum (px, py, pz, E)
proton = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)

# Create an electron
electron = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)
```

The function signature is:
```julia
make_shared_particle(px, py, pz, e, pdg_id, status)
```

- `px, py, pz, e`: Four-momentum components
- `pdg_id`: Particle Data Group ID (e.g., 11 = electron, 2212 = proton)
- `status`: Particle status code (1 = final state, 2 = intermediate, etc.)

### Creating Vertices

Vertices connect particles in the event:

```julia
# Create a vertex
vertex = make_shared_vertex()

# Connect particles
connect_particle_in(vertex, proton)   # Incoming particle
connect_particle_out(vertex, electron) # Outgoing particle

# Add vertex to event
attach_vertex_to_event(event, vertex)
```

### Accessing Particle Properties

Get comprehensive particle information:

```julia
props = get_particle_properties(proton)

# Access properties
println("PDG ID: $(props.pdg_id)")
println("Status: $(props.status)")
println("Momentum: $(props.momentum)")
println("pT: $(props.pt) GeV")
println("Mass: $(props.mass) GeV")
println("Eta: $(props.eta)")
println("Phi: $(props.phi)")
```

### Reading Event Files

Read events from HepMC3 files:

```julia
# Read all events
events = read_hepmc_file("events.hepmc3")

# Read limited number of events
events = read_hepmc_file("events.hepmc3"; max_events=10)

# Read compressed files (automatic detection)
events = read_hepmc_file_with_compression("events.hepmc3.zst")
```

### Writing Event Files

Write events to files:

```julia
# Create writer
writer = create_writer_ascii("output.hepmc3")

# Write event
writer_write_event(writer, event.cpp_object)

# Close writer
writer_close(writer)
```

### Complete Example

Here's a complete example creating a simple event:

```julia
using HepMC3

# Create event
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # proton
p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)    # electron

# Create vertex
v1 = make_shared_vertex()
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Check event
println("Particles: $(particles_size(event))")
println("Vertices: $(vertices_size(event))")

# Get particle properties
props = get_particle_properties(p2)
println("Electron pT: $(props.pt) GeV")
```

## Next Steps

- Learn about [Events](@ref) in detail
- Explore [Particles](@ref) and their properties
- Understand [Vertices](@ref) and event topology
- See [Examples](@ref) for more complex use cases

