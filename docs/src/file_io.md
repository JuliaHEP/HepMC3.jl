# File I/O

HepMC3.jl supports reading and writing HepMC3 event files in ASCII format, with full support for compressed files using zstd and gzip compression.

## Reading Events

### Basic Reading

Read all events from a plain HepMC3 file:

```julia
events = read_hepmc_file("events.hepmc3")
```

Each element in `events` is a pointer to a `GenEvent` object that can be used with all HepMC3.jl functions.

### Reading with Event Limit

Limit the number of events read to reduce memory usage:

```julia
# Read only the first 100 events
events = read_hepmc_file("events.hepmc3"; max_events=100)
```

### Reading Compressed Files

HepMC3.jl automatically detects and handles compressed files based on file extension:

```julia
# Read zstd compressed file (.zst)
events = read_hepmc_file_with_compression("events.hepmc3.zst")

# Read gzip compressed file (.gz)
events = read_hepmc_file_with_compression("events.hepmc3.gz")

# Also works with uncompressed files
events = read_hepmc_file_with_compression("events.hepmc3")
```

Supported compression formats:
- `.zst` - Zstandard compression (recommended for large files)
- `.gz` - Gzip compression (widely compatible)
- No extension or other extensions - treated as uncompressed

### Combining Options

```julia
# Read first 50 events from a compressed file
events = read_hepmc_file_with_compression("events.hepmc3.zst"; max_events=50)
```

### Using Native Readers

For more control over the reading process, use the native HepMC3 readers directly:

```julia
# Create reader
reader = create_reader_ascii("events.hepmc3")

# Read events one by one
event = GenEvent()
event_count = 0
while reader_read_event(reader, event.cpp_object)
    event_count += 1
    println("Event $(event_number(event)): $(particles_size(event)) particles")

    # Process event...
end

# Close reader
reader_close(reader)
println("Processed $event_count events")
```

### Reading All Events at Once

For convenience, read all events into a vector:

```julia
events = read_all_events_from_file("events.hepmc3")
```

## Writing Events

### Basic Writing

Write events to a file:

```julia
# Create writer
writer = create_writer_ascii("output.hepmc3")

# Write an event
writer_write_event(writer, event.cpp_object)

# Close writer (important to flush buffers)
writer_close(writer)
```

### Writing Multiple Events

```julia
writer = create_writer_ascii("output.hepmc3")

for event in events
    writer_write_event(writer, event.cpp_object)
end

writer_close(writer)
```

### Writing with Run Information

Include run-level information in the output:

```julia
# Create run info
run_info = create_run_info()
add_tool_info!(run_info, "generator", "Pythia8", "8.306")

# Create event with run info
event = create_event(1)
set_run_info(event, run_info)

# Write
writer = create_writer_ascii("output.hepmc3")
writer_write_event(writer, event.cpp_object)
writer_close(writer)
```

## Working with Event Pointers

When reading files, you receive pointers to events. These work seamlessly with all HepMC3.jl functions:

```julia
events = read_hepmc_file("events.hepmc3")

for (i, event_ptr) in enumerate(events)
    # Access event properties directly
    n_particles = particles_size(event_ptr)
    n_vertices = vertices_size(event_ptr)
    evt_num = event_number(event_ptr)

    println("Event $i: number=$evt_num, particles=$n_particles, vertices=$n_vertices")

    # Access particles by index (1-based)
    for j in 1:n_particles
        particle = get_particle_at(event_ptr, j)
        props = get_particle_properties(particle)
        println("  Particle $j: PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV")
    end
end
```

## Extracting Final State Particles

Get all final state particles (status == 1) from an event:

```julia
final_state = get_final_state_particles(event_ptr)

println("Found $(length(final_state)) final state particles:")
for particle in final_state
    props = get_particle_properties(particle)
    println("  PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV, eta=$(round(props.eta, digits=2))")
end
```

## Complete Examples

### Example: Reading and Analyzing Events

```julia
using HepMC3

# Read events from compressed file
filename = "events.hepmc3.zst"
events = read_hepmc_file_with_compression(filename; max_events=100)

println("Read $(length(events)) events from $filename")

# Analyze events
total_particles = 0
total_final_state = 0

for event in events
    total_particles += particles_size(event)

    final_state = get_final_state_particles(event)
    total_final_state += length(final_state)
end

println("Total particles: $total_particles")
println("Total final state particles: $total_final_state")
println("Average particles per event: $(total_particles / length(events))")
println("Average final state per event: $(total_final_state / length(events))")
```

### Example: Creating and Writing Events

```julia
using HepMC3

# Create an event
event = create_event(1)
set_units!(event, :GeV, :mm)

# Build event structure
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # proton
p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)    # electron

v1 = make_shared_vertex()
connect_particle_in(v1, p1)
connect_particle_out(v1, p2)
attach_vertex_to_event(event, v1)

# Write to file
filename = "test_event.hepmc3"
writer = create_writer_ascii(filename)
writer_write_event(writer, event.cpp_object)
writer_close(writer)

println("Wrote event to $filename")

# Verify by reading back
events = read_hepmc_file(filename)
read_event = events[1]

println("Read back: $(particles_size(read_event)) particles, $(vertices_size(read_event)) vertices")

# Clean up
rm(filename)
```

### Example: Processing Large Files

For large files, process events one at a time to minimize memory usage:

```julia
using HepMC3

function process_large_file(filename::String)
    reader = create_reader_ascii(filename)
    event = GenEvent()

    event_count = 0
    total_pt = 0.0

    while reader_read_event(reader, event.cpp_object)
        event_count += 1

        # Process final state particles
        final_state = get_final_state_particles(event)
        for particle in final_state
            props = get_particle_properties(particle)
            total_pt += props.pt
        end

        # Progress indicator
        if event_count % 1000 == 0
            println("Processed $event_count events...")
        end
    end

    reader_close(reader)

    println("Finished processing $event_count events")
    println("Total pT sum: $total_pt GeV")
    return event_count, total_pt
end

# Usage
process_large_file("large_dataset.hepmc3")
```

### Example: Converting Between Formats

```julia
using HepMC3

function convert_file(input_file::String, output_file::String; max_events::Int=-1)
    events = read_hepmc_file_with_compression(input_file; max_events=max_events)

    writer = create_writer_ascii(output_file)
    for event in events
        writer_write_event(writer, event)
    end
    writer_close(writer)

    println("Converted $(length(events)) events from $input_file to $output_file")
end

# Convert compressed to uncompressed
convert_file("input.hepmc3.zst", "output.hepmc3")
```

## Error Handling

```julia
# Check if file exists before reading
filename = "events.hepmc3"
if !isfile(filename)
    error("File not found: $filename")
end

events = read_hepmc_file(filename)

# Handle empty files
if isempty(events)
    println("Warning: No events found in file")
end
```

## Performance Considerations

### Memory Usage

- `read_hepmc_file` loads all events into memory
- Use `max_events` parameter to limit memory usage
- For very large files, use the native reader interface to process events one at a time

### Compression

- Zstd (`.zst`) provides the best compression ratio and speed
- Gzip (`.gz`) is more widely compatible but slower
- Reading compressed files requires decompression, which uses additional memory

### File Format

HepMC3 ASCII format is human-readable but larger than binary formats. For production use with very large datasets, consider using compressed files.

## API Reference

### Reading Functions

```@docs
read_hepmc_file
read_hepmc_file_with_compression
read_all_events_from_file
create_reader_ascii
reader_read_event
reader_close
```

### Writing Functions

```@docs
create_writer_ascii
writer_write_event
writer_close
```

### Utility Functions

```@docs
get_final_state_particles
get_particle_at
get_vertex_at
```
