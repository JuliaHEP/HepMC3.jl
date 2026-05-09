# Building from Source

This page describes the source build used by contributors and current
development checkouts.

## Requirements

- Julia 1.10 or newer
- CMake 3.21 or newer
- A C++17 compiler
- zlib development headers

On macOS, install Xcode Command Line Tools and CMake:

```bash
xcode-select --install
brew install cmake
```

On Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake zlib1g-dev
```

## Standard Build

Clone the repository and build the wrapper:

```bash
git clone https://github.com/JuliaHEP/HepMC3.jl.git
cd HepMC3.jl
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.build()'
```

`Pkg.build()` runs `deps/build.jl`, which invokes `gen/build.jl` and creates the
shared library in `gen/build/lib/`.

## Development Build Script

For wrapper development, run the lower-level script directly:

```bash
julia --project=. gen/build.jl
```

By default this script uses the checked-in WrapIt-generated C++ sources. This
keeps normal builds reproducible and avoids requiring wrapper regeneration on
every platform.

## Regenerating Wrappers

Regenerate wrappers only when intentionally changing the wrapped C++ API:

```bash
julia --project=. gen/build.jl --generate
```

or, to preserve unchanged generated files where possible:

```bash
julia --project=. gen/build.jl --update
```

After regeneration, inspect all generated changes carefully. The generated
entrypoint must still include the manual wrapper registration, and
`gen/cpp/jlHepMC3.h` must include the HepMC3 headers required by the generated
translation units.

## Testing

Run the full test suite:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

Run the main example:

```bash
julia --project=. examples/basic_tree_julia.jl
```

## Common Issues

### Wrapper library not found

If `using HepMC3` reports that `libHepMC3Wrap` is missing, run:

```bash
julia --project=. -e 'using Pkg; Pkg.build()'
```

### CMake cannot find dependencies

The build uses `CxxWrap.prefix_path()` and `HepMC3_jll.artifact_dir` to locate
CxxWrap and HepMC3. If configuration fails, verify that the Julia environment is
instantiated:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### WrapIt crashes or produces invalid output

Normal builds do not need WrapIt regeneration. If regeneration fails, keep the
checked-in generated sources and investigate the `.wit` configuration and
platform-specific libclang behavior separately.
