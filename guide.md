# HepMC3.jl User Guide

This guide covers building HepMC3.jl from source and using its API for reading, writing, and manipulating HepMC3 event records.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Building from Source](#building-from-source)
3. [Basic Usage](#basic-usage)
4. [Reading HepMC3 Files](#reading-hepmc3-files)
5. [Working with Events](#working-with-events)
6. [Working with Particles](#working-with-particles)
7. [Working with Vertices](#working-with-vertices)
8. [Four-Vectors](#four-vectors)
9. [Units](#units)
10. [Integration with JetReconstruction.jl](#integration-with-jetreconstructionjl)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before building HepMC3.jl, ensure you have the following installed:

- Julia 1.10 or later
- CMake 3.21 or later
- A C++17 compatible compiler (GCC 9+, Clang 10+)
- zlib development headers

On Ubuntu/Debian:
```bash
sudo apt install cmake build-essential zlib1g-dev
```

On Arch Linux:
```bash
sudo pacman -S cmake base-devel zlib
```

On macOS:
```bash
brew install cmake
```

---

## Building from Source

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/HepMC3.jl.git
cd HepMC3.jl
```

### Step 2: Install Julia Dependencies

Start Julia with the project environment and install dependencies:

```julia
julia --project=.
```

Then in the Julia REPL:

```julia
using Pkg
Pkg.instantiate()
Pkg.add("WrapIt")  # Required for generating bindings
```

### Step 3: Generate Wrapper Code

Navigate to the `gen` directory and run the build script:

```julia
cd("gen")
include("build.jl")
```

If the `wrapit` executable is not in your PATH, you can run it manually:

```julia
using WrapIt, CxxWrap, HepMC3_jll

# Create the .wit configuration file
cxxwrap_prefix = CxxWrap.prefix_path()
hepmc3_prefix = HepMC3_jll.artifact_dir
julia_prefix = dirname(Sys.BINDIR)

wit = joinpath(@__DIR__, "HepMC3.wit")
witin = joinpath(@__DIR__, "HepMC3.wit.in")
open(wit, "w") do f
    for l in eachline(witin)
        println(f, replace(l, "@HepMC3_INCLUDE_DIR@" => "$hepmc3_prefix/include",
                             "@Julia_INCLUDE_DIR@" => "$julia_prefix/include/julia",
                             "@JlCxx_INCLUDE_DIR@" => "$cxxwrap_prefix/include",
                             "@CxxWrap_VERSION@" => "$(pkgversion(CxxWrap))"))
    end
end

# Run wrapit
run(`$(WrapIt.wrapit_path) $wit --force -v 1`)
```

### Step 4: Apply Patches

After generating the wrapper code, apply the required patches to include manual wrappers:

```bash
cd /path/to/HepMC3.jl

# Add include for manual wrappers
sed -i '/#include "Wrapper.h"/a #include "HepMC3Wrap.h"' gen/cpp/jlHepMC3.cxx

# Add call to manual wrapper registration
sed -i '/for(const auto& w: wrappers) w->add_methods();/a \  add_manual_hepmc3_methods(jlModule);' gen/cpp/jlHepMC3.cxx
```

### Step 5: Build the Binary

```julia
using CxxWrap, HepMC3_jll

builddir = joinpath(@__DIR__, "gen/build")
sourcedir = joinpath(@__DIR__, "gen")
mkpath(builddir)

cxxwrap_prefix = CxxWrap.prefix_path()
hepmc3_prefix = HepMC3_jll.artifact_dir

cd(builddir)
run(`cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -DCMAKE_PREFIX_PATH=$cxxwrap_prefix\;$hepmc3_prefix $sourcedir`)
run(`cmake --build . --config Release --parallel 8`)
```

### Step 6: Verify Installation

```julia
cd("/path/to/HepMC3.jl")
using HepMC3

# Run tests
using Pkg
Pkg.test()
```

---

## Basic Usage

```julia
using HepMC3

# Read events from a file
events = read_hepmc_file("events.hepmc3")

# Process each event
for event in events
    println("Event number: ", event_number(event))

    # Get final state particles
    final_state = get_final_state_particles(event)
    println("Number of final state particles: ", length(final_state))
end
```

---

## Reading HepMC3 Files

HepMC3.jl supports reading plain HepMC3 files as well as compressed files (gzip and zstd).

### Reading Plain Files

```julia
events = read_hepmc_file("events.hepmc3")
```

### Reading Compressed Files

The `read_hepmc_file_with_compression` function automatically detects compression based on file extension:

```julia
# Reads .zst (zstd) compressed files
events = read_hepmc_file_with_compression("events.hepmc3.zst")

# Reads .gz (gzip) compressed files
events = read_hepmc_file_with_compression("events.hepmc3.gz")

# Also works with uncompressed files
events = read_hepmc_file_with_compression("events.hepmc3")
```

### Limiting Number of Events

```julia
# Read only the first 100 events
events = read_hepmc_file_with_compression("events.hepmc3.zst"; max_events=100)
```

### Reading All Events at Once

```julia
events = read_all_events_from_file("events.hepmc3")
```

---

## Working with Events

### Creating Events

```julia
# Create a new event
event = create_event()

# Set event number
set_event_number(event, 1)

# Set units (optional, defaults to GeV and mm)
set_units!(event, HepMC3.GEV, HepMC3.MM)
```

### Event Properties

```julia
# Get event number
num = event_number(event)

# Get all particles in the event
all_particles = particles(event)

# Get all vertices in the event
all_vertices = vertices(event)

# Get number of particles and vertices
n_particles = particles_size(event)
n_vertices = vertices_size(event)

# Get beam particles
beam_particles = beams(event)
```

### Event Weights

```julia
# Get event weights
w = weights(event)

# Set weight names
set_weight_names!(event, ["weight1", "weight2"])

# Set event weights
set_event_weights!(event, [1.0, 0.5])
```

---

## Working with Particles

### Getting Particle Information

```julia
# Get final state particles (status == 1)
final_state = get_final_state_particles(event)

# Get all particle properties at once
for particle in final_state
    props = get_particle_properties(particle)

    println("PDG ID: ", props.pdg_id)
    println("Status: ", props.status)
    println("px: ", props.momentum.px)
    println("py: ", props.momentum.py)
    println("pz: ", props.momentum.pz)
    println("E: ", props.momentum.e)
    println("Mass: ", props.momentum.mass)
end
```

### Individual Particle Accessors

```julia
# PDG particle ID
pdg = pdg_id(particle)
# or
pdg = pid(particle)

# Status code
stat = status(particle)

# Four-momentum
mom = momentum(particle)
px_val = px(mom)
py_val = py(mom)
pz_val = pz(mom)
e_val = e(mom)

# Derived quantities
pt_val = pt(mom)      # Transverse momentum
eta_val = eta(mom)    # Pseudorapidity
phi_val = phi(mom)    # Azimuthal angle
rap_val = rap(mom)    # Rapidity
m_val = m(mom)        # Invariant mass
```

### Creating Particles

```julia
# Create a particle with PDG ID and status
particle = create_particle(pdg_id=11, status=1)  # electron, final state

# Set momentum
set_momentum(particle, FourVector(px, py, pz, E))

# Or set components individually
set_px(particle, 10.0)
set_py(particle, 5.0)
set_pz(particle, 100.0)
set_e(particle, 101.0)
```

### Particle Relationships

```julia
# Get parent particles
parent_list = parents(particle)

# Get child particles
child_list = children(particle)

# Get production vertex
prod_vertex = production_vertex(particle)

# Get end/decay vertex
end_vtx = end_vertex(particle)
```

---

## Working with Vertices

### Getting Vertex Information

```julia
# Get vertex properties
props = get_vertex_properties(vertex)

println("Vertex ID: ", props.id)
println("Status: ", props.status)
println("Position x: ", props.position.x)
println("Position y: ", props.position.y)
println("Position z: ", props.position.z)
println("Position t: ", props.position.t)
```

### Vertex Particles

```julia
# Get incoming particles
incoming = particles_in(vertex)
# or
incoming = get_incoming_particles(vertex)

# Get outgoing particles
outgoing = particles_out(vertex)
# or
outgoing = get_outgoing_particles(vertex)
```

### Creating Vertices

```julia
# Create a vertex
vertex = create_vertex()

# Set position
set_position(vertex, FourVector(x, y, z, t))

# Add particles
add_particle_in(vertex, incoming_particle)
add_particle_out(vertex, outgoing_particle)

# Add vertex to event
add_vertex(event, vertex)
```

---

## Four-Vectors

HepMC3.jl provides a `FourVector` type for representing four-momenta and spacetime positions.

### Creating Four-Vectors

```julia
# Create from components
fv = FourVector(px, py, pz, E)

# Zero vector
zero_fv = FourVector(0.0, 0.0, 0.0, 0.0)
```

### Four-Vector Components

```julia
# Momentum components
px_val = px(fv)
py_val = py(fv)
pz_val = pz(fv)
e_val = e(fv)

# Position/time components (aliases)
x_val = x(fv)
y_val = y(fv)
z_val = z(fv)
t_val = t(fv)
```

### Derived Quantities

```julia
# Transverse momentum
pt_val = pt(fv)
pt2_val = pt2(fv)  # pt squared

# Pseudorapidity
eta_val = eta(fv)
abs_eta_val = abs_eta(fv)

# Rapidity
rap_val = rap(fv)
abs_rap_val = abs_rap(fv)

# Azimuthal angle
phi_val = phi(fv)

# Polar angle
theta_val = theta(fv)

# Invariant mass
mass_val = m(fv)
mass2_val = m2(fv)  # mass squared

# 3-momentum magnitude
p3_val = p3mod(fv)
p3_2_val = p3mod2(fv)  # squared

# Length (for position vectors)
len = length(fv)
len2 = length2(fv)
```

### Four-Vector Operations

```julia
# Delta quantities between two four-vectors
delta_eta_val = delta_eta(fv1, fv2)
delta_phi_val = delta_phi(fv1, fv2)
delta_rap_val = delta_rap(fv1, fv2)
delta_r_eta_val = delta_r_eta(fv1, fv2)  # Delta R using eta
delta_r_rap_val = delta_r_rap(fv1, fv2)  # Delta R using rapidity
```

---

## Units

HepMC3 supports different unit systems for momentum and length.

### Available Units

Momentum units:
- `HepMC3.GEV` or `HepMC3.GeV` - GeV (default)
- `HepMC3.MEV` or `HepMC3.MeV` - MeV

Length units:
- `HepMC3.MM` or `HepMC3.mm` - millimeters (default)
- `HepMC3.CM` or `HepMC3.cm` - centimeters

### Setting Units

```julia
# Set units for an event
set_units!(event, HepMC3.GEV, HepMC3.MM)

# Query current units
mom_unit = momentum_unit(event)
len_unit = length_unit(event)
```

---

## Integration with JetReconstruction.jl

HepMC3.jl can be used alongside JetReconstruction.jl for jet physics analyses.

### Reading Events for Jet Reconstruction

```julia
using HepMC3
using JetReconstruction

function read_events_for_jets(filename::String; max_events::Int=-1)
    events = read_hepmc_file_with_compression(filename; max_events=max_events)

    pseudojet_events = Vector{PseudoJet}[]

    for event in events
        final_state = get_final_state_particles(event)

        if isempty(final_state)
            continue
        end

        input_particles = PseudoJet[]

        for particle in final_state
            props = get_particle_properties(particle)

            pseudojet = PseudoJet(
                props.momentum.px,
                props.momentum.py,
                props.momentum.pz,
                props.momentum.e
            )
            push!(input_particles, pseudojet)
        end

        push!(pseudojet_events, input_particles)
    end

    return pseudojet_events
end

# Usage
events = read_events_for_jets("events.hepmc3.zst"; max_events=100)

# Run jet reconstruction
for event_particles in events
    jets = jet_reconstruct(event_particles; R=0.4, algorithm=JetAlgorithm.AntiKt)
    final_jets = inclusive_jets(jets; ptmin=20.0)

    for jet in final_jets
        println("Jet: pt=$(jet.pt), eta=$(jet.eta), phi=$(jet.phi)")
    end
end
```

---

## Troubleshooting

### CxxWrap Version Mismatch

If you encounter errors like "invalid subtyping in definition of StdString", you may need to update CxxWrap:

```julia
using Pkg
Pkg.rm("CxxWrap")
# Update Project.toml to allow CxxWrap 0.17
Pkg.add("CxxWrap")
```

Edit `Project.toml` to set:
```toml
[compat]
CxxWrap = "0.17"
```

### Library Not Found

If you see "Wrapper library not found", ensure you have built the library:

```julia
cd("gen/build")
run(`cmake --build . --config Release --parallel 8`)
```

The library should be at `gen/build/lib/libHepMC3Wrap.so` (Linux) or `libHepMC3Wrap.dylib` (macOS).

### Missing wrapit Executable

If `wrapit` is not found, use the path from WrapIt.jl:

```julia
using WrapIt
println(WrapIt.wrapit_path)  # Use this path directly
```

### Precompilation Disabled

HepMC3.jl has `__precompile__(false)` set because it loads a dynamically generated library. This means it will be compiled on first use in each session. This is expected behavior.

---

## API Reference

For a complete API reference, see the documentation at the project repository or run:

```julia
using HepMC3
?HepMC3.function_name  # Get help for specific functions
names(HepMC3)          # List all exported symbols
```

---

## License

HepMC3.jl is released under the same license as the upstream HepMC3 library. See the LICENSE file for details.
