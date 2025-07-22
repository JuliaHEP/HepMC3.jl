# Save as: test_manual_io_methods.jl
println("=== Testing Manual I/O Function Signatures ===")

using HepMC3

# Check what I/O methods are available
println("Available I/O methods:")
try
    println("create_writer_ascii: ", methods(HepMC3.create_writer_ascii))
    println("writer_write_event: ", methods(HepMC3.writer_write_event))
    println("create_reader_ascii: ", methods(HepMC3.create_reader_ascii))
    println("reader_read_event: ", methods(HepMC3.reader_read_event))
catch e
    println("Error checking methods: ", e)
end

# Test if we can use regular HepMC3 I/O instead
println("\nChecking if regular HepMC3 I/O is available...")
try
    # Look for regular I/O classes that might have been wrapped
    symbols = names(HepMC3)
    io_symbols = filter(s -> occursin("Writer", string(s)) || occursin("Reader", string(s)), symbols)
    println("Available I/O symbols: ", io_symbols)
catch e
    println("Error: ", e)
end