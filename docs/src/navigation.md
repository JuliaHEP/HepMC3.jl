# Navigation

HepMC3.jl provides functions to navigate the event structure, traverse decay chains, and find particle relationships.

## Basic Navigation

### Production and Decay Vertices

Get the vertex where a particle was produced or decays:

```julia
# Production vertex (where particle was created)
prod_vertex = get_production_vertex(particle)

# Decay vertex (where particle decays, if any)
decay_vertex = get_decay_vertex(particle)
```

### Parent Particles

Get all parent particles (particles that decayed into this particle):

```julia
parents = get_parent_particles(particle)
```

### Decay Products

Get all immediate decay products (particles this particle decays into):

```julia
children = get_decay_products(particle)
```

### Sibling Particles

Get sibling particles (particles produced at the same vertex):

```julia
siblings = get_sibling_particles(particle)
```

## Traversing Decay Chains

### Forward Traversal

Traverse the complete decay chain forward (from a particle to all its descendants):

```julia
decay_tree = traverse_decay_chain(particle, max_depth=10)
```

Returns a tree structure with particle information and children.

### Backward Traversal

Find all ancestors of a particle:

```julia
ancestry = find_particle_ancestry(particle, max_depth=10)
```

Returns a tree structure with particle information and ancestors.

## Example: Basic Navigation

```julia
using HepMC3

# Create event with decay chain: p1 -> p2 -> (p3, p4)
event = create_event(1)
set_units!(event, :GeV, :mm)

p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # Proton
p2 = make_shared_particle(10.0, 20.0, 100.0, 200.0, 23, 2)     # Z boson
p3 = make_shared_particle(5.0, 10.0, 50.0, 60.0, 11, 1)        # Electron
p4 = make_shared_particle(5.0, 10.0, 50.0, 60.0, -11, 1)       # Positron

# Production vertex: p1 -> p2
v1 = make_shared_vertex()
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Decay vertex: p2 -> p3 + p4
v2 = make_shared_vertex()
connect_particle_in(v2, p2)
connect_particle_out(v2, p3)
connect_particle_out(v2, p4)
attach_vertex_to_event(event, v2)

# Navigate from p2
prod_vtx = get_production_vertex(p2)
decay_vtx = get_decay_vertex(p2)

parents = get_parent_particles(p2)      # [p1]
children = get_decay_products(p2)       # [p3, p4]
siblings = get_sibling_particles(p3)     # [p4]
```

## Example: Complete Decay Chain Traversal

```julia
using HepMC3

function print_decay_tree(tree, indent=0)
    for node in tree
        indent_str = "  " ^ indent
        props = node.properties
        println("$(indent_str)├─ PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV")

        if !isempty(node.children)
            print_decay_tree(node.children, indent + 1)
        end
    end
end

# Create complex decay chain
event = create_event(1)
set_units!(event, :GeV, :mm)

# Build: W -> e + nu_e
w = make_shared_particle(10.0, 20.0, 100.0, 200.0, -24, 2)
e = make_shared_particle(5.0, 10.0, 50.0, 60.0, 11, 1)
nu = make_shared_particle(5.0, 10.0, 50.0, 60.0, 12, 1)

v = make_shared_vertex()
connect_particle_in(v, w)
connect_particle_out(v, e)
connect_particle_out(v, nu)
attach_vertex_to_event(event, v)

# Traverse decay chain
decay_tree = traverse_decay_chain(w)
println("Decay chain of W boson:")
print_decay_tree(decay_tree)
```

## Example: Finding Ancestry

```julia
using HepMC3

# Build event: p1 -> p2 -> p3
event = create_event(1)
set_units!(event, :GeV, :mm)

p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
p2 = make_shared_particle(10.0, 20.0, 100.0, 200.0, 23, 2)
p3 = make_shared_particle(5.0, 10.0, 50.0, 60.0, 11, 1)

v1 = make_shared_vertex()
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

v2 = make_shared_vertex()
connect_particle_in(v2, p2)
connect_particle_out(v2, p3)
attach_vertex_to_event(event, v2)

# Find ancestry of p3
ancestry = find_particle_ancestry(p3)
println("Ancestry of p3:")
# Process ancestry tree...
```

## Accessing Vertex Particles

### Incoming Particles

Get all particles entering a vertex:

```julia
incoming = get_incoming_particles(vertex)
```

### Outgoing Particles

Get all particles leaving a vertex:

```julia
outgoing = get_outgoing_particles(vertex)
```

## Example: Event Analysis

```julia
using HepMC3

function analyze_event(event_ptr)
    println("Event Analysis:")
    println("  Particles: $(particles_size(event_ptr))")
    println("  Vertices: $(vertices_size(event_ptr))")

    # Find all final state particles
    final_state = get_final_state_particles(event_ptr)
    println("  Final state particles: $(length(final_state))")

    # Analyze each final state particle
    for particle in final_state
        props = get_particle_properties(particle)

        # Find parents
        parents = get_parent_particles(particle)
        parent_info = isempty(parents) ? "none" :
                      "PDG=$(get_particle_properties(parents[1]).pdg_id)"

        println("    PDG=$(props.pdg_id), pT=$(props.pt) GeV, parent=$parent_info")
    end
end

# Use with events
events = read_hepmc_file("events.hepmc3")
for event in events
    analyze_event(event)
end
```

## API Reference

```@docs
get_production_vertex
get_decay_vertex
get_parent_particles
get_decay_products
get_sibling_particles
traverse_decay_chain
find_particle_ancestry
get_incoming_particles
get_outgoing_particles
```

