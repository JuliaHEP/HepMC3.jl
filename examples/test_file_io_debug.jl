# Save as: test_io_with_cleanup.jl
println("=== I/O Test with Proper Cleanup ===")

using HepMC3

try
    # Create simple event
    event = HepMC3.GenEvent()
    HepMC3.set_event_number(event, 42)
    
    # Set units (important for valid file)
    HepMC3.set_units(event, HepMC3.var"HepMC3!Units!GEV", HepMC3.var"HepMC3!Units!MM")
    
    println("✅ Event created: number ", HepMC3.event_number(event))
    
    filename = "cleanup_test.hepmc3"
    
    # Write with proper cleanup
    println("\n=== WRITING ===")
    writer_ptr = HepMC3.create_writer_ascii(filename)
    event_ptr = event.cpp_object
    
    write_result = HepMC3.writer_write_event(writer_ptr, event_ptr)
    println("Write result: ", write_result, " (type: ", typeof(write_result), ")")
    
    # Close writer if available
    try
        HepMC3.writer_close(writer_ptr)
        println("✅ Writer closed")
    catch e
        println("⚠️  Writer close not available: ", e)
    end
    
    # Check file
    if isfile(filename)
        size = filesize(filename)
        println("✅ File created: ", size, " bytes")
        
        if size > 0
            println("File content:")
            content = read(filename, String)
            println(content)
        else
            println("❌ File is still empty after close")
        end
    end
    
catch e
    println("❌ Error: ", e)
end