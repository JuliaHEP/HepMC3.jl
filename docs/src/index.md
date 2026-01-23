# HepMC3.jl

Julia bindings for the [HepMC3](https://gitlab.cern.ch/hepmc/HepMC3) library for representing High Energy Physics (HEP) Monte Carlo events. The bindings use the [CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl) package to wrap C++ types and functions to Julia.

## Overview

HepMC3.jl provides a complete Julia interface to the HepMC3 C++ library, enabling you to:

- **Create and manipulate** Monte Carlo event structures
- **Read and write** HepMC3 event files (including compressed formats)
- **Navigate** particle decay chains and event topologies
- **Access** particle properties, vertices, and event metadata
- **Work with** four-vectors, attributes, and units
- **Integrate** with other Julia HEP packages like JetReconstruction.jl

## Quick Start

```julia
using HepMC3

# Read events from a compressed file
events = read_hepmc_file_with_compression("events.hepmc3.zst")

# Process each event
for event in events
    # Get final state particles
    final_state = get_final_state_particles(event)

    for particle in final_state
        props = get_particle_properties(particle)
        println("PDG: $(props.pdg_id), pT: $(props.pt) GeV")
    end
end
```

## Installation

### From Julia Package Registry

```julia
using Pkg
Pkg.add("HepMC3")
```

### From Source (Development)

For development or to use the latest features, you can build from source. See the [Building from Source](@ref) section for detailed instructions.

## Features

### Event Management
- Create and manipulate `GenEvent` objects
- Set event numbers, weights, and metadata
- Add PDF information, cross sections, and heavy ion data
- Shift event positions

### Particle Handling
- Create particles with four-momentum and PDG IDs
- Access particle properties (momentum, mass, charge, etc.)
- Navigate particle relationships (parents, children, siblings)
- Get and set generated masses

### Vertex Operations
- Create vertices and connect particles
- Set vertex positions and status codes
- Navigate event topology
- Access incoming and outgoing particles

### File I/O
- Read and write HepMC3 ASCII files
- Support for compressed files (zstd and gzip)
- Batch event reading with configurable limits
- Automatic compression detection

### Navigation
- Traverse decay chains forward and backward
- Find particle ancestry
- Get production and decay vertices
- Find sibling particles

### Four-Vector Operations
- Full four-vector algebra
- Derived quantities: pt, eta, phi, rapidity, mass
- Delta calculations between vectors (deltaR, deltaPhi, etc.)
- Component accessors for momentum and position

## Documentation Structure

- **[Getting Started](@ref)** - Installation and basic usage
- **[Building from Source](@ref)** - Compiling the wrapper library
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

- **Julia**: 1.10 or later
- **HepMC3_jll**: 3.3.0
- **CxxWrap**: 0.17.x

### System Requirements for Building from Source

- CMake 3.21 or later
- C++17 compatible compiler (GCC 9+, Clang 10+)
- zlib development headers

## Integration with Other Packages

HepMC3.jl is designed to work seamlessly with other Julia HEP packages:

### JetReconstruction.jl

```julia
using HepMC3
using JetReconstruction

# Read events and convert to PseudoJets
events = read_hepmc_file_with_compression("events.hepmc3.zst")

for event in events
    final_state = get_final_state_particles(event)

    # Convert to PseudoJets
    pseudojets = [
        PseudoJet(p.momentum.px, p.momentum.py, p.momentum.pz, p.momentum.e)
        for p in (get_particle_properties(particle) for particle in final_state)
    ]

    # Run jet reconstruction
    jets = jet_reconstruct(pseudojets; R=0.4, algorithm=JetAlgorithm.AntiKt)
    final_jets = inclusive_jets(jets; ptmin=20.0)
end
```

## References

If you use HepMC3.jl in your research, please cite the HepMC3 library:

```bibtex
@article{Buckley:2019xhk,
    author = "Buckley, Andy and others",
    title = "{The HepMC3 event record library for Monte Carlo event generators}",
    journal = "Comput. Phys. Commun.",
    volume = "260",
    pages = "107310",
    year = "2021",
    doi = "10.1016/j.cpc.2020.107310"
}
```

## License

This package is licensed under the same license as the HepMC3 library. See the LICENSE file for details.
