# HepMC3.jl

Julia bindings for the [HepMC3](https://gitlab.cern.ch/hepmc/HepMC3) event
record library used in high-energy physics Monte Carlo workflows.

The package wraps HepMC3 C++ types with
[CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl). Most wrapper sources
are generated with [WrapIt](https://github.com/grasph/wrapit), with a small
manual C++ layer for pointer ownership, graph navigation, attributes, ASCII I/O,
and other convenience operations.

## Current Status

Implemented and tested:

- Create and update `GenEvent`, `GenParticle`, `GenVertex`, and `FourVector`
  objects.
- Build event graphs by connecting parent and child particles through vertices.
- Read and write HepMC3 ASCII event files.
- Access particle properties, vertex properties, event weights, units, and
  common attributes.
- Attach and query run information, including weight names and generator tool
  metadata.
- Navigate event graphs through parents, children, siblings, and decay chains.
- Run the core test suite on macOS Apple Silicon locally.

Still planned:

- Binary artifact distribution for `libHepMC3Wrap` so users do not need local
  C++ build tools.
- General registry registration.
- Broader CI coverage and documentation polish.
- ROOT serialization support.

## Building from Source

Clone the repository, instantiate dependencies, and build the C++ wrapper:

```bash
git clone https://github.com/JuliaHEP/HepMC3.jl.git
cd HepMC3.jl
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.build()'
```

The build creates the wrapper library under `gen/build/lib/`.

For wrapper development, call the lower-level build script directly:

```bash
julia --project=. gen/build.jl
```

By default, `gen/build.jl` uses the checked-in WrapIt-generated C++ sources.
Pass `--generate` or `--update` only when intentionally regenerating wrappers:

```bash
julia --project=. gen/build.jl --generate
```

## Testing

Run the package tests:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

Run the main example:

```bash
julia --project=. examples/basic_tree_julia.jl
```

## Minimal Example

```julia
using HepMC3

event = create_event(1)
set_units!(event, :GeV, :mm)

run_info = create_run_info()
set_weight_names!(run_info, ["nominal"])
add_tool_info!(run_info, "Pythia8", "8.306", "hard process generator")
set_run_info!(event, run_info)

particle = make_shared_particle(10.0, 0.0, 20.0, 25.0, 11, 1)
vertex = make_shared_vertex()
connect_particle_out(vertex, particle)
attach_vertex_to_event(event, vertex)

filename = "event.hepmc3"
writer = HepMC3.create_writer_ascii(filename)
HepMC3.writer_write_event(writer, event.cpp_object)
HepMC3.writer_close(writer)

reader = HepMC3.create_reader_ascii(filename)
read_event = GenEvent()
HepMC3.reader_read_event(reader, read_event.cpp_object)
HepMC3.reader_close(reader)
```

## Developer Notes

- `deps/build.jl` is the package build entrypoint used by `Pkg.build()`.
- `gen/build.jl` configures and builds `libHepMC3Wrap`.
- `gen/cpp/jlHepMC3.cxx`, `gen/cpp/jlHepMC3.h`, and `gen/cpp/Jl*.cxx` are
  generated wrapper sources that are intentionally checked in.
- `src/HepMC3Interface.jl` provides the higher-level Julia convenience API on
  top of generated and manual CxxWrap bindings.
