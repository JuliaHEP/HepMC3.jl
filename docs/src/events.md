# Events

The `GenEvent` type represents a complete Monte Carlo event, containing particles, vertices, and event-level metadata.

## Creating Events

### Basic Creation

```julia
# Create an event with default event number (1)
event = create_event()

# Create with specific event number
event = create_event(42)

# Or create directly
event = GenEvent()
set_event_number(event, 1)
```

### Setting Units

Events require explicit units for momentum and position:

```julia
# Using symbols (recommended)
set_units!(event, :GeV, :mm)

# Using constants
set_units!(event, GeV, mm)
```

## Event Properties

### Event Number

```julia
# Set event number
set_event_number(event, 42)

# Get event number
num = event_number(event)
```

### Event Weights

Events can have multiple weights (for reweighting, systematic variations, etc.):

```julia
# Set weights
set_event_weights!(event, [1.0, 0.95, 1.05])

# Get weights
weights = get_event_weights(event)
```

## Event Structure

### Accessing Particles and Vertices

```julia
# Get number of particles/vertices
n_particles = particles_size(event)
n_vertices = vertices_size(event)

# Access by index (1-based)
particle = get_particle_at(event, 1)
vertex = get_vertex_at(event, 1)
```

### Iterating Over Particles

```julia
for i in 1:particles_size(event)
    particle = get_particle_at(event, i)
    props = get_particle_properties(particle)
    println("Particle $i: PDG=$(props.pdg_id), pT=$(props.pt)")
end
```

## Event Metadata

### PDF Information

Add parton distribution function information:

```julia
pdf_info = add_pdf_info!(event,
    id1, id2,        # Parton IDs
    x1, x2,          # Bjorken x values
    q,               # Scale Q
    pdf1, pdf2,      # PDF values
    pdf_set_id1, pdf_set_id2  # PDF set IDs
)
```

### Cross Section

Add cross section information:

```julia
cross_section = add_cross_section!(event, xs, xs_err)
```

### Heavy Ion Information

Add heavy ion collision parameters:

```julia
heavy_ion = add_heavy_ion!(event,
    nh, np, nt, nc, ns, nsp, nn, nw, nwn,  # Nucleus parameters
    impact_b,      # Impact parameter
    plane_angle,   # Reaction plane angle
    eccentricity,  # Eccentricity
    sigma_nn       # Nucleon-nucleon cross section
)
```

## Event Manipulation

### Shifting Event Position

Shift all vertex positions in an event:

```julia
shift_position!(event, dx, dy, dz, dt)
```

### Removing Particles

Remove a particle from an event:

```julia
remove_particle!(event, particle_ptr)
```

## Event Attributes

Events can have attributes attached (see [Attributes](@ref) for details):

```julia
# Add string attribute
attr = create_string_attribute("some value")
add_event_attribute(event.cpp_object, "attribute_name", attr)
```

## Example: Building a Complete Event

```julia
using HepMC3

# Create event
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
p2 = make_shared_particle(0.750, -1.569, 32.191, 32.238, 1, 3)

# Create vertex
v1 = make_shared_vertex()
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Add metadata
add_cross_section!(event, 1.2, 0.1)
set_event_weights!(event, [1.0])

# Check event
println("Event $(event_number(event)): $(particles_size(event)) particles, $(vertices_size(event)) vertices")
```

## API Reference

```@docs
GenEvent
create_event
set_event_number
event_number
set_units!
set_event_weights!
get_event_weights
particles_size
vertices_size
get_particle_at
get_vertex_at
add_pdf_info!
add_cross_section!
add_heavy_ion!
shift_position!
remove_particle!
```

