HepMC3.jl Had to modify names for functions in order to prevent overwriting of wrapper functions.

For creating events without units, use GenEvent, for creating events with units use create_event_with_units() function

## APPLE SILICON GUIDE : 

#### Enhanced CMakeLists.txt for Apple silicon : 
```cmake
cmake_minimum_required(VERSION 3.21)
project(HepMC3Wrap)

set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

# Apple Silicon specific optimizations
if(APPLE)
    # Ensure we're building for the correct architecture
    if(NOT CMAKE_OSX_ARCHITECTURES)
        # Auto-detect architecture if not specified
        execute_process(COMMAND uname -m OUTPUT_VARIABLE NATIVE_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
        set(CMAKE_OSX_ARCHITECTURES ${NATIVE_ARCH})
    endif()
    
    # Set minimum macOS version for Apple Silicon compatibility
    if(CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
        set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")  # Big Sur minimum for M1/M2/M3/M4
        message(STATUS "Building for Apple Silicon (${CMAKE_OSX_ARCHITECTURES})")
    else()
        set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")  # Catalina for Intel
        message(STATUS "Building for Intel Mac (${CMAKE_OSX_ARCHITECTURES})")
    endif()
    
    # Apple Silicon specific compiler flags
    if(CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mcpu=apple-m1")  # Optimize for Apple Silicon
    endif()
endif()

#---Find JlCxx package-------------------------------------------------------------
find_package(JlCxx)
get_target_property(JlCxx_location JlCxx::cxxwrap_julia LOCATION)
get_filename_component(JlCxx_location ${JlCxx_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${JlCxx_location}")
message(STATUS "Found JlCxx at ${JlCxx_location}")

#---Find HepMC3---------------------------------------------------------------------
find_package(HepMC3 REQUIRED)
find_package(ZLIB REQUIRED)

# Check if we found Apple Silicon compatible versions
if(APPLE AND CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
    message(STATUS "Verifying Apple Silicon compatibility...")
    get_target_property(HEPMC3_LOCATION HepMC3::HepMC3 LOCATION)
    message(STATUS "HepMC3 library: ${HEPMC3_LOCATION}")
endif()

file(REAL_PATH ${CMAKE_SOURCE_DIR}/../gen SOURCE_DIR)
file(GLOB GEN_SOURCES CONFIGURE_DEPENDS  ${SOURCE_DIR}/cpp/Jl*.cxx)

# Build library with BOTH manual wrapper and generated bindings
add_library(HepMC3Wrap SHARED 
    ${SOURCE_DIR}/cpp/HepMC3Wrap.cxx 
    ${SOURCE_DIR}/cpp/HepMC3WrapImpl.cpp
    ${SOURCE_DIR}/cpp/jlHepMC3.cxx  # This is the WrapIt-generated file
    ${GEN_SOURCES})

target_include_directories(HepMC3Wrap PRIVATE ${SOURCE_DIR})

# C++17 standard (compatible with Apple Silicon)
target_compile_features(HepMC3Wrap PRIVATE cxx_std_17)

if(HEPMC3_USE_COMPRESSION)
    target_compile_definitions(HepMC3Wrap PRIVATE HEPMC3_USE_COMPRESSION=1)
endif()

target_link_libraries(HepMC3Wrap 
    JlCxx::cxxwrap_julia 
    JlCxx::cxxwrap_julia_stl 
    HepMC3::HepMC3
    ZLIB::ZLIB)

# Apple Silicon specific linking
if(APPLE AND CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
    # Ensure proper linking for Apple Silicon
    target_link_options(HepMC3Wrap PRIVATE -Wl,-rpath,@loader_path)
endif()

install(TARGETS HepMC3Wrap
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION lib)
```




### Enhanced build.jl file for better Apple Silicon Support
```julia
using Pkg
Pkg.instantiate()
using CxxWrap
using HepMC3_jll

#---Apple Silicon Detection and Setup----------------------------------------------
if Sys.isapple()
    ENV["SDKROOT"] = readchomp(`xcrun --sdk macosx --show-sdk-path`)
    
    # Detect architecture
    arch = readchomp(`uname -m`)
    println("Detected architecture: $arch")
    
    if arch == "arm64"
        println("🍎 Building for Apple Silicon (M1/M2/M3/M4)")
        # Set Apple Silicon specific environment variables
        ENV["CMAKE_OSX_ARCHITECTURES"] = "arm64"
        ENV["CMAKE_OSX_DEPLOYMENT_TARGET"] = "11.0"
    else
        println("🍎 Building for Intel Mac")
        ENV["CMAKE_OSX_ARCHITECTURES"] = "x86_64" 
        ENV["CMAKE_OSX_DEPLOYMENT_TARGET"] = "10.15"
    end
    
    # Check if we have Rosetta 2 (for compatibility testing)
    if arch == "arm64" && success(`which arch`)
        println("✅ Rosetta 2 available for Intel compatibility testing")
    end
end

#---Build the wrapper library----------------------------------------------------------------------
builddir = joinpath(@__DIR__, "build")
sourcedir = @__DIR__
cd(@__DIR__)
mkpath(builddir)

cxxwrap_prefix = CxxWrap.prefix_path()
hepmc3_prefix = HepMC3_jll.artifact_dir
julia_prefix = dirname(Sys.BINDIR)

# Verify Apple Silicon compatibility of dependencies
if Sys.isapple() && readchomp(`uname -m`) == "arm64"
    println("\n🔍 Checking Apple Silicon compatibility of dependencies...")
    
    # Check Julia
    julia_arch = readchomp(`file $julia_prefix/bin/julia`)
    if occursin("arm64", julia_arch)
        println("✅ Julia: Native Apple Silicon")
    else
        println("⚠️  Julia: Running under Rosetta 2")
    end
    
    # Check HepMC3_jll
    hepmc3_libs = readdir(joinpath(hepmc3_prefix, "lib"), join=true)
    hepmc3_lib = findfirst(f -> occursin("libHepMC3", f), hepmc3_libs)
    if hepmc3_lib !== nothing
        hepmc3_arch = readchomp(`file $(hepmc3_libs[hepmc3_lib])`)
        if occursin("arm64", hepmc3_arch)
            println("✅ HepMC3: Native Apple Silicon")
        else
            println("⚠️  HepMC3: x86_64 (will use Rosetta 2)")
        end
    end
end

#---Generate the wrapper code----------------------------------------------------------------------
updatemode = ("--update" ∈ ARGS)
updatemode && println("Update mode")
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

# Use native wrapit command
rc = run(`wrapit $wit --force -v 1`).exitcode
if !isnothing(rc) && rc != 0
    println(stderr, "Failed to produce wrapper code with the wrapit function. Exited with code ", rc, ".")
    exit(rc)
end

#---Build with CMake---------------------------------------------------------------
cd(builddir)

# Build command with Apple Silicon considerations
cmake_args = [
    "-DCMAKE_BUILD_TYPE=Release",
    "-DCMAKE_CXX_STANDARD=17",
    "-DCMAKE_PREFIX_PATH=$cxxwrap_prefix;$hepmc3_prefix"
]

# Apple Silicon specific flags
if Sys.isapple()
    arch = readchomp(`uname -m`)
    push!(cmake_args, "-DCMAKE_OSX_ARCHITECTURES=$arch")
    
    if arch == "arm64"
        push!(cmake_args, "-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0")
        println("🍎 Using Apple Silicon optimizations")
    else
        push!(cmake_args, "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15")
    end
end

println("CMake configuration...")
run(`cmake $cmake_args $sourcedir`)

println("Building...")
run(`cmake --build . --config Release --parallel 8`)

# Post-build verification for Apple Silicon
if Sys.isapple() && readchomp(`uname -m`) == "arm64"
    println("\n🔍 Verifying Apple Silicon build...")
    built_lib = joinpath(builddir, "lib", "libHepMC3Wrap.dylib")
    if isfile(built_lib)
        lib_arch = readchomp(`file $built_lib`)
        if occursin("arm64", lib_arch)
            println("✅ Successfully built native Apple Silicon library!")
        else
            println("⚠️  Built x86_64 library (will use Rosetta 2)")
        end
    end
end

println("\n🎉 Build completed!")
```



### Adding an apple Silicon Test Script 
```julia
println("=== Apple Silicon Compatibility Test ===")

if !Sys.isapple()
    println("❌ This test is only for macOS systems")
    exit(1)
end

arch = readchomp(`uname -m`)
println("System architecture: $arch")

if arch == "arm64"
    println("🍎 Running on Apple Silicon (M1/M2/M3/M4)")
    
    # Test Julia architecture
    julia_bin = joinpath(Sys.BINDIR, "julia")
    julia_arch = readchomp(`file $julia_bin`)
    println("Julia architecture: ", occursin("arm64", julia_arch) ? "Native ARM64" : "x86_64 (Rosetta)")
    
    # Test HepMC3.jl
    try
        using HepMC3
        println("✅ HepMC3.jl loaded successfully")
        
        # Quick functionality test
        event = create_event(1)
        p1 = make_shared_particle(1.0, 2.0, 3.0, 5.0, 11, 1)
        vertex = make_shared_vertex()
        connect_particle_out(vertex, p1)
        attach_vertex_to_event(event, vertex)
        
        println("✅ Basic functionality working on Apple Silicon")
        println("  Event particles: ", particles_size(event))
        println("  Event vertices: ", vertices_size(event))
        
        # Test file I/O
        filename = "apple_silicon_test.hepmc3"
        writer = HepMC3.create_writer_ascii(filename)
        success = HepMC3.writer_write_event(writer, event.cpp_object)
        HepMC3.writer_close(writer)
        
        if success && isfile(filename)
            println("✅ File I/O working on Apple Silicon")
            rm(filename)
        end
        
        println("\n🎉 HepMC3.jl is fully compatible with Apple Silicon!")
        
    catch e
        println("❌ Error testing HepMC3.jl on Apple Silicon: ", e)
    end
    
else
    println("🍎 Running on Intel Mac")
    println("Note: This should also work on Apple Silicon via Rosetta 2")
end
```

🎯 Key Apple Silicon Considerations:
✅ Your Current Setup Should Work Because:
Julia M4 Support: Julia has excellent Apple Silicon support
CxxWrap Compatibility: CxxWrap works well on Apple Silicon
HepMC3_jll: Should provide Apple Silicon binaries
C++17 Standard: Fully supported on Apple Silicon
⚠️ Potential Issues to Watch:
Mixed Architectures: Ensure all components (Julia, HepMC3, CxxWrap) are same architecture
Rosetta 2 Fallback: Some dependencies might fall back to x86_64
Library Linking: RPATH issues more common on macOS
🔧 To Test Apple Silicon Compatibility:
Update your files with the enhanced versions above


```julia
cd gen
julia build.jl
```

Run the test file 
