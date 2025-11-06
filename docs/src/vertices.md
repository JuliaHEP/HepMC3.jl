# Vertices

Vertices (`GenVertex`) represent interaction points in the event, connecting incoming and outgoing particles.

## Creating Vertices

```julia
# Create a vertex
vertex = make_shared_vertex()

# Or using the convenience function
vertex = create_vertex()
```

## Connecting Particles

### Incoming Particles

Add particles entering the vertex:

```julia
connect_particle_in(vertex, particle)
```

### Outgoing Particles

Add particles leaving the vertex:

```julia
connect_particle_out(vertex, particle)
```

### Complete Example

```julia
# Create particles
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)

# Create vertex
v1 = make_shared_vertex()

# Connect particles
connect_particle_in(v1, p1)   # Proton enters
connect_particle_out(v1, p2)  # Electron leaves

# Add to event
attach_vertex_to_event(event, v1)
```

## Vertex Position

Set and get the spatial position of a vertex:

```julia
# Set position (x, y, z, t)
set_vertex_position(vertex, 1.0, 2.0, 3.0, 4.0)

# Get position
pos = get_vertex_position(vertex)
x_val = get_vertex_x(vertex)
y_val = get_vertex_y(vertex)
z_val = get_vertex_z(vertex)
t_val = get_vertex_t(vertex)
```

Or get all properties at once:

```julia
props = get_vertex_properties(vertex)
props.position.x
props.position.y
props.position.z
props.position.t
props.id
props.status
```

## Vertex Status

Set the status code of a vertex:

```julia
set_vertex_status!(vertex, 4)
```

Common status codes:
- `0`: Null vertex
- `1`: Primary vertex
- `2`: Decay vertex
- `3`: End vertex
- `4`: Beam vertex

## Accessing Connected Particles

### Get Incoming Particles

```julia
incoming = get_incoming_particles(vertex)
```

### Get Outgoing Particles

```julia
outgoing = get_outgoing_particles(vertex)
```

Example:

```julia
vertex = make_shared_vertex()
connect_particle_in(vertex, p1)
connect_particle_out(vertex, p2)
connect_particle_out(vertex, p3)

incoming = get_incoming_particles(vertex)  # [p1]
outgoing = get_outgoing_particles(vertex)  # [p2, p3]
```

## Vertex Attributes

Add metadata to vertices:

```julia
# Create and add attribute
attr = create_string_attribute("primary")
add_vertex_attribute(vertex, "type", attr)
```

## Example: Building a Decay Chain

```julia
using HepMC3

event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # Proton
p2 = make_shared_particle(10.0, 20.0, 100.0, 200.0, 23, 2)    # Z boson
p3 = make_shared_particle(5.0, 10.0, 50.0, 60.0, 11, 1)       # Electron
p4 = make_shared_particle(5.0, 10.0, 50.0, 60.0, -11, 1)     # Positron

# Production vertex: p1 -> p2
v1 = make_shared_vertex()
set_vertex_position(v1, 0.0, 0.0, 0.0, 0.0)
set_vertex_status!(v1, 4)  # Beam vertex
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Decay vertex: p2 -> p3 + p4
v2 = make_shared_vertex()
set_vertex_position(v2, 0.1, 0.1, 0.1, 0.1)
set_vertex_status!(v2, 2)  # Decay vertex
connect_particle_in(v2, p2)
connect_particle_out(v2, p3)
connect_particle_out(v2, p4)
attach_vertex_to_event(event, v2)

# Check structure
println("Event has $(vertices_size(event)) vertices")
for i in 1:vertices_size(event)
    v = get_vertex_at(event, i)
    props = get_vertex_properties(v)
    println("Vertex $i: status=$(props.status), position=($(props.position.x), $(props.position.y), $(props.position.z), $(props.position.t))")
end
```

## API Reference

```@docs
GenVertex
make_shared_vertex
create_vertex
connect_particle_in
connect_particle_out
attach_vertex_to_event
set_vertex_position
get_vertex_position
get_vertex_x
get_vertex_y
get_vertex_z
get_vertex_t
get_vertex_properties
set_vertex_status!
get_incoming_particles
get_outgoing_particles
```

