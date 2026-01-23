# Building from Source

This guide covers building HepMC3.jl from source, which is necessary for development or when using the latest features not yet available in the package registry.

## Prerequisites

Before building HepMC3.jl, ensure you have the following installed:

### Required Software

- **Julia**: Version 1.10 or later
- **CMake**: Version 3.21 or later
- **C++ Compiler**: C++17 compatible (GCC 9+, Clang 10+, MSVC 2019+)
- **zlib**: Development headers

### Platform-Specific Installation

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install cmake build-essential zlib1g-dev
```

#### Arch Linux

```bash
sudo pacman -S cmake base-devel zlib
```

#### Fedora/RHEL

```bash
sudo dnf install cmake gcc-c++ zlib-devel
```

#### macOS

```bash
brew install cmake
```

Xcode Command Line Tools provides the C++ compiler:

```bash
xcode-select --install
```

#### Windows

Install Visual Studio 2019 or later with C++ support, and CMake from https://cmake.org/download/.

## Build Process

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/HepMC3.jl.git
cd HepMC3.jl
```

### Step 2: Install Julia Dependencies

Start Julia with the project environment:

```bash
julia --project=.
```

Then install dependencies:

```julia
using Pkg
Pkg.instantiate()
Pkg.add("WrapIt")  # Required for generating bindings
```

### Step 3: Generate Wrapper Code

The wrapper code is generated using WrapIt, which analyzes HepMC3 headers and produces CxxWrap bindings.

```julia
cd("gen")

using WrapIt, CxxWrap, HepMC3_jll

# Create the .wit configuration file from template
cxxwrap_prefix = CxxWrap.prefix_path()
hepmc3_prefix = HepMC3_jll.artifact_dir
julia_prefix = dirname(Sys.BINDIR)

wit = joinpath(@__DIR__, "HepMC3.wit")
witin = joinpath(@__DIR__, "HepMC3.wit.in")
open(wit, "w") do f
    for l in eachline(witin)
        println(f, replace(l,
            "@HepMC3_INCLUDE_DIR@" => "$hepmc3_prefix/include",
            "@Julia_INCLUDE_DIR@" => "$julia_prefix/include/julia",
            "@JlCxx_INCLUDE_DIR@" => "$cxxwrap_prefix/include",
            "@CxxWrap_VERSION@" => "$(pkgversion(CxxWrap))"))
    end
end

# Run wrapit to generate wrapper code
run(`$(WrapIt.wrapit_path) $wit --force -v 1`)
```

This generates the following files in `gen/cpp/`:
- `jlHepMC3.cxx` - Main wrapper implementation
- `jlHepMC3.h` - Header file
- Various `Jl*.cxx` files for individual types

### Step 4: Apply Patches

After generating the wrapper code, apply patches to include the manual wrapper implementations:

```bash
# Navigate to project root
cd /path/to/HepMC3.jl

# Add include for manual wrappers
sed -i '/#include "Wrapper.h"/a #include "HepMC3Wrap.h"' gen/cpp/jlHepMC3.cxx

# Add call to manual wrapper registration
sed -i '/for(const auto& w: wrappers) w->add_methods();/a \  add_manual_hepmc3_methods(jlModule);' gen/cpp/jlHepMC3.cxx
```

On macOS, use `sed -i ''` instead of `sed -i`:

```bash
sed -i '' '/#include "Wrapper.h"/a\
#include "HepMC3Wrap.h"' gen/cpp/jlHepMC3.cxx

sed -i '' '/for(const auto& w: wrappers) w->add_methods();/a\
  add_manual_hepmc3_methods(jlModule);' gen/cpp/jlHepMC3.cxx
```

### Step 5: Build the Binary Library

Configure and build using CMake:

```julia
using CxxWrap, HepMC3_jll

builddir = joinpath(@__DIR__, "gen/build")
sourcedir = joinpath(@__DIR__, "gen")
mkpath(builddir)

cxxwrap_prefix = CxxWrap.prefix_path()
hepmc3_prefix = HepMC3_jll.artifact_dir

cd(builddir)

# Configure
run(`cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -DCMAKE_PREFIX_PATH=$cxxwrap_prefix\;$hepmc3_prefix $sourcedir`)

# Build (use number of CPU cores)
run(`cmake --build . --config Release --parallel 8`)
```

The built library will be located at:
- Linux: `gen/build/lib/libHepMC3Wrap.so`
- macOS: `gen/build/lib/libHepMC3Wrap.dylib`
- Windows: `gen/build/lib/HepMC3Wrap.dll`

### Step 6: Verify the Build

```julia
cd("/path/to/HepMC3.jl")
using HepMC3

# Check that the module loads
println("HepMC3 loaded successfully!")
println("Exported symbols: ", length(names(HepMC3)))

# Run tests
using Pkg
Pkg.test()
```

## Build Configuration Options

### CMake Options

| Option | Default | Description |
|--------|---------|-------------|
| `CMAKE_BUILD_TYPE` | Release | Build type (Debug, Release, RelWithDebInfo) |
| `CMAKE_CXX_STANDARD` | 17 | C++ standard version |
| `CMAKE_PREFIX_PATH` | - | Paths to CxxWrap and HepMC3 |

### Debug Build

For debugging, use:

```bash
cmake -DCMAKE_BUILD_TYPE=Debug ...
```

## Troubleshooting

### CxxWrap Version Mismatch

If you encounter errors like "invalid subtyping in definition of StdString", update CxxWrap:

```julia
using Pkg
Pkg.rm("CxxWrap")
```

Edit `Project.toml` to allow CxxWrap 0.17:

```toml
[compat]
CxxWrap = "0.17"
```

Then reinstall:

```julia
Pkg.add("CxxWrap")
```

### Missing wrapit Executable

If `wrapit` is not in your PATH, use the full path from WrapIt.jl:

```julia
using WrapIt
println(WrapIt.wrapit_path)
# Use this path directly in the run command
```

### Library Not Found

If you see "Wrapper library not found" errors:

1. Verify the library was built:
   ```bash
   ls -la gen/build/lib/
   ```

2. Check the library path in `src/HepMC3.jl` matches the actual location.

3. Rebuild if necessary:
   ```bash
   cd gen/build
   cmake --build . --config Release
   ```

### CMake Cannot Find Dependencies

Ensure the `CMAKE_PREFIX_PATH` includes both CxxWrap and HepMC3 directories:

```julia
println("CxxWrap prefix: ", CxxWrap.prefix_path())
println("HepMC3 prefix: ", HepMC3_jll.artifact_dir)
```

### Precompilation Disabled Warning

HepMC3.jl uses `__precompile__(false)` because it loads a dynamically generated library at runtime. This warning is expected and does not indicate a problem.

## Updating Bindings

When the HepMC3 version changes or you need to regenerate bindings:

1. Delete the generated files:
   ```bash
   rm -rf gen/build gen/cpp/jl*.cxx gen/cpp/jl*.h gen/jl/
   ```

2. Regenerate by following Steps 3-5 above.

## Contributing

When contributing changes to the wrapper:

1. Modify files in `gen/cpp/` for manual wrapper implementations
2. Update `HepMC3Wrap.cxx` and `HepMC3WrapImpl.cpp` for custom bindings
3. Regenerate and rebuild as described above
4. Run tests to verify changes:
   ```julia
   using Pkg
   Pkg.test()
   ```

## Directory Structure

```
HepMC3.jl/
├── gen/
│   ├── build/          # CMake build directory
│   │   └── lib/        # Built library
│   ├── cpp/            # C++ wrapper source files
│   │   ├── HepMC3Wrap.cxx      # Manual wrapper definitions
│   │   ├── HepMC3WrapImpl.cpp  # Implementation
│   │   └── jlHepMC3.cxx        # Generated wrapper (after wrapit)
│   ├── build.jl        # Build script
│   ├── CMakeLists.txt  # CMake configuration
│   └── HepMC3.wit.in   # WrapIt configuration template
├── src/
│   ├── HepMC3.jl       # Main module
│   └── HepMC3Interface.jl  # Julia interface functions
└── test/
    └── runtests.jl     # Test suite
```
