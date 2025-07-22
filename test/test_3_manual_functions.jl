# Save as: test_3_manual_functions.jl
println("=== HepMC3 Manual Wrapper Functions Test ===")

using HepMC3

println("Testing manual wrapper functions...")

# Test if manual functions are available
manual_functions = [
    "create_shared_particle",
    "create_shared_vertex", 
    "add_shared_particle_in",
    "add_shared_particle_out",
    "add_shared_vertex_to_event",
    "create_particle_vector",
    "delete_particle_vector",
    "particle_vector_size",
    "particle_vector_at",
    "create_reader_ascii",
    "reader_read_event",
    "create_writer_ascii",
    "writer_write_event"
]

available_manual = []
for func_name in manual_functions
    if hasfield(HepMC3, Symbol(func_name)) || hasmethod(getfield(HepMC3, Symbol(func_name)), Tuple{})
        push!(available_manual, func_name)
        println("✅ Found: ", func_name)
    else
        println("❌ Missing: ", func_name)
    end
end

println("\nManual functions available: ", length(available_manual), "/", length(manual_functions))

if length(available_manual) > 0
    println("✅ Manual wrapper integration successful!")
else
    println("❌ Manual wrapper integration failed - functions not found")
end