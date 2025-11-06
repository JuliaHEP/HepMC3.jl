# Attributes

Attributes allow you to attach metadata to events, particles, and vertices. HepMC3.jl supports integer, double (floating-point), and string attributes.

## Creating Attributes

### Integer Attributes

```julia
attr = create_int_attribute(42)
```

### Double Attributes

```julia
attr = create_double_attribute(3.14159)
```

### String Attributes

```julia
attr = create_string_attribute("some metadata")
```

### Convenience Function

A convenience function automatically creates the right type:

```julia
attr_int = create_particle_attribute(42)        # IntAttribute
attr_double = create_particle_attribute(3.14)   # DoubleAttribute
attr_string = create_particle_attribute("text")  # StringAttribute
```

## Particle Attributes

### Adding Attributes

```julia
# Add integer attribute
add_particle_attribute!(particle, "tool", 1)

# Add double attribute
add_particle_attribute!(particle, "weight", 0.95)

# Add string attribute
add_particle_attribute!(particle, "comment", "interesting particle")
```

### Accessing Attributes

Attributes can be accessed through the HepMC3 C++ interface. See the HepMC3 C++ documentation for details on attribute retrieval.

## Vertex Attributes

```julia
# Create attribute
attr = create_string_attribute("primary")

# Add to vertex
add_vertex_attribute(vertex, "type", attr)
```

## Event Attributes

```julia
# Create attribute
attr = create_string_attribute("generator_info")

# Add to event
add_event_attribute(event.cpp_object, "generator", attr)
```

## Example: Using Attributes

```julia
using HepMC3

# Create event and particles
event = create_event(1)
set_units!(event, :GeV, :mm)

p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)

# Add particle attributes
add_particle_attribute!(p1, "is_beam", 1)
add_particle_attribute!(p1, "beam_weight", 1.0)
add_particle_attribute!(p2, "is_final", 1)
add_particle_attribute!(p2, "reconstruction_status", "reconstructed")

# Create vertex and add attribute
v1 = make_shared_vertex()
attr = create_string_attribute("primary_vertex")
add_vertex_attribute(v1, "vertex_type", attr)

connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Add event attribute
event_attr = create_string_attribute("test_event")
add_event_attribute(event.cpp_object, "event_type", event_attr)
```

## Attribute Types

HepMC3.jl provides the following attribute types:

- `IntAttribute`: Integer values
- `DoubleAttribute`: Floating-point values
- `StringAttribute`: String values
- `Attribute`: Base type for all attributes

Vector attributes are also available:
- `VectorIntAttribute`
- `VectorDoubleAttribute`
- `VectorStringAttribute`

## API Reference

```@docs
Attribute
IntAttribute
DoubleAttribute
StringAttribute
create_int_attribute
create_double_attribute
create_string_attribute
create_particle_attribute
add_particle_attribute!
add_vertex_attribute
add_event_attribute
```

