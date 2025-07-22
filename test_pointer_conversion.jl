# Save as: test_pointer_extraction.jl
println("=== Testing Pointer Extraction Methods ===")

using HepMC3

try
    # Test FourVector pointer extraction
    fv = HepMC3.FourVector(1.0, 2.0, 3.0, 4.0)
    println("FourVector created: ", fv)
    println("FourVector type: ", typeof(fv))
    
    # Try different ways to extract the pointer
    println("\n--- Method 1: Direct field access ---")
    try
        # The FourVectorAllocated shows it has a Ptr{Nothing}, let's try to access it
        if hasfield(typeof(fv), :cpp_object)
            raw_ptr = fv.cpp_object
            println("✅ Raw pointer via cpp_object: ", raw_ptr, " (type: ", typeof(raw_ptr), ")")
            
            # Test if we can create a particle with this pointer
            particle_ptr = HepMC3.create_shared_particle(raw_ptr, 11, 1)
            println("✅ Particle created successfully!")
            
        else
            println("❌ No cpp_object field found")
        end
    catch e
        println("❌ Method 1 error: ", e)
    end
    
    println("\n--- Method 2: CxxPtr then unsafe_convert ---")
    try
        cxx_ptr = CxxPtr(fv)
        println("CxxPtr: ", cxx_ptr)
        
        # Try unsafe_convert
        raw_ptr = unsafe_convert(Ptr{Nothing}, cxx_ptr)
        println("✅ Raw pointer via unsafe_convert: ", raw_ptr)
        
        # Test particle creation
        particle_ptr = HepMC3.create_shared_particle(raw_ptr, 11, 1)
        println("✅ Particle created successfully!")
        
    catch e
        println("❌ Method 2 error: ", e)
    end
    
    println("\n--- Method 3: Try CxxWrap pointer functions ---")
    try
        # CxxWrap might have special functions
        cxx_ptr = CxxPtr(fv)
        
        # Try different CxxWrap approaches
        println("CxxPtr internals:")
        println("  Type: ", typeof(cxx_ptr))
        
        # Try getting the actual pointer value
        ptr_val = pointer_from_objref(cxx_ptr)
        println("  pointer_from_objref: ", ptr_val)
        
    catch e
        println("❌ Method 3 error: ", e)
    end
    
    println("\n--- Method 4: Check if CxxPtr can be used directly ---")
    try
        cxx_ptr = CxxPtr(fv)
        
        # Maybe the manual functions can accept CxxPtr directly?
        particle_ptr = HepMC3.create_shared_particle(cxx_ptr, 11, 1)
        println("✅ CxxPtr works directly!")
        
    catch e
        println("❌ Method 4 error: ", e)
    end
    
catch e
    println("❌ Overall error: ", e)
end