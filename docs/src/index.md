# HepMC3.jl

Julia bindings for the [HepMC3](https://gitlab.cern.ch/hepmc/HepMC3) library for representing High Energy Physics (HEP) Monte Carlo events. The bindings use the [CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl) package to wrap C++ types and functions to Julia.

## Overview

HepMC3.jl provides a complete Julia interface to the HepMC3 C++ library, enabling you to:

- **Create and manipulate** Monte Carlo event structures
- **Read and write** HepMC3 event files
- **Navigate** particle decay chains and event topologies
- **Access** particle properties, vertices, and event metadata
- **Work with** four-vectors, attributes, and units

## Quick Start

```julia
using HepMC3

# Create an event
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # proton
p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)    # electron

# Create a vertex
vertex = make_shared_vertex()
connect_particle_in(vertex, p1)
connect_particle_out(vertex, p2)
attach_vertex_to_event(event, vertex)

# Access particle properties
props = get_particle_properties(p2)
println("Electron pT: $(props.pt) GeV")
```

## Installation

```julia
using Pkg
Pkg.add("HepMC3")
```

## Features

### Event Management
- Create and manipulate `GenEvent` objects
- Set event numbers, weights, and metadata
- Add PDF information, cross sections, and heavy ion data

### Particle Handling
- Create particles with four-momentum and PDG IDs
- Access particle properties (momentum, mass, charge, etc.)
- Navigate particle relationships (parents, children, siblings)

### Vertex Operations
- Create vertices and connect particles
- Set vertex positions and status codes
- Navigate event topology

### File I/O
- Read and write HepMC3 ASCII files
- Support for compressed files (zstd)
- Batch event reading

### Navigation
- Traverse decay chains forward and backward
- Find particle ancestry
- Get production and decay vertices

## Documentation Structure

- **[Getting Started](@ref)** - Installation and basic usage
- **[Events](@ref)** - Working with GenEvent objects
- **[Particles](@ref)** - Creating and accessing particles
- **[Vertices](@ref)** - Building event topologies
- **[Four-Vectors](@ref)** - Momentum and position vectors
- **[File I/O](@ref)** - Reading and writing event files
- **[Attributes](@ref)** - Adding metadata to events and particles
- **[Units](@ref)** - Setting and working with units
- **[Navigation](@ref)** - Traversing event structures
- **[Examples](@ref)** - Complete working examples

## Package Information

This package wraps the HepMC3 C++ library version 3.x using CxxWrap.jl. The wrapper code is generated using [WrapIt](https://github.com/grasph/wrapit), which automates the generation of wrapper code by analyzing the HepMC3 header files.

## Compatibility

- **Julia**: 1.6+
- **HepMC3_jll**: 3.3.0
- **CxxWrap**: 0.16.0

## References

If you use HepMC3.jl in your research, please cite the HepMC3 library:

```bibtex
@article{hepmc3,
    title = {HepMC3 Event Record Library},
    author = {The HepMC3 Collaboration},
    journal = {https://gitlab.cern.ch/hepmc/HepMC3}
}
```

## License

This package is licensed under the same license as the HepMC3 library. See the [LICENSE](../LICENSE) file for details.
