# File I/O

HepMC3.jl supports reading and writing HepMC3 event files in ASCII format, with support for compressed files.

## Reading Events

### Basic Reading

Read all events from a file:

```julia
events = read_hepmc_file("events.hepmc3")
```

Each element in `events` is a pointer to a `GenEvent` object.

### Reading Limited Events

Limit the number of events read:

```julia
# Read first 10 events
events = read_hepmc_file("events.hepmc3"; max_events=10)
```

### Reading Compressed Files

Automatic detection and decompression of compressed files:

```julia
# Automatically handles .zst files
events = read_hepmc_file_with_compression("events.hepmc3.zst")
```

Supported compression formats:
- `.zst` (zstd compression)

### Using Native Readers

For more control, use the native HepMC3 readers directly:

```julia
# Create reader
reader = create_reader_ascii("events.hepmc3")

# Read events one by one
event = GenEvent()
while reader_read_event(reader, event.cpp_object)
    # Process event
    println("Event $(event_number(event)): $(particles_size(event)) particles")
end

# Close reader
reader_close(reader)
```

## Writing Events

### Basic Writing

Write events to a file:

```julia
# Create writer
writer = create_writer_ascii("output.hepmc3")

# Write event
writer_write_event(writer, event.cpp_object)

# Close writer
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

## Working with Event Pointers

When reading files, you get pointers to events. Access them like regular events:

```julia
events = read_hepmc_file("events.hepmc3")

for (i, event_ptr) in enumerate(events)
    # Access event properties
    n_particles = particles_size(event_ptr)
    n_vertices = vertices_size(event_ptr)
    evt_num = event_number(event_ptr)

    println("Event $i: number=$evt_num, particles=$n_particles, vertices=$n_vertices")

    # Access particles
    for j in 1:n_particles
        particle = get_particle_at(event_ptr, j)
        props = get_particle_properties(particle)
        println("  Particle $j: PDG=$(props.pdg_id), pT=$(props.pt)")
    end
end
```

## Extracting Final State Particles

Get all final state particles (status == 1) from an event:

```julia
final_state = get_final_state_particles(event_ptr)

for particle in final_state
    props = get_particle_properties(particle)
    println("PDG=$(props.pdg_id), pT=$(props.pt) GeV")
end
```

## Example: Complete File I/O Workflow

```julia
using HepMC3

# Create and write an event
event = create_event(1)
set_units!(event, :GeV, :mm)

# Build event structure
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
p2 = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)

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

# Read back
events = read_hepmc_file(filename)
read_event = events[1]

println("Read event: $(particles_size(read_event)) particles, $(vertices_size(read_event)) vertices")

# Clean up
rm(filename)
```

## Example: Processing Multiple Events

```julia
using HepMC3

# Read events
events = read_hepmc_file("large_file.hepmc3"; max_events=100)

println("Processing $(length(events)) events")

for (i, event_ptr) in enumerate(events)
    # Get final state particles
    final_state = get_final_state_particles(event_ptr)

    # Calculate some statistics
    total_pt = sum(p -> get_particle_properties(p).pt, final_state)
    n_charged = count(p -> particle_charge(get_particle_properties(p).pdg_id) != 0, final_state)

    println("Event $i: $(length(final_state)) final state particles, " *
            "total pT = $total_pt GeV, $n_charged charged")
end
```

## Error Handling

```julia
# Check if file exists before reading
if isfile("events.hepmc3")
    events = read_hepmc_file("events.hepmc3")
else
    error("File not found")
end

# Handle empty files
if isempty(events)
    println("No events found in file")
end
```

## API Reference

```@docs
read_hepmc_file
read_hepmc_file_with_compression
create_reader_ascii
reader_read_event
reader_close
create_writer_ascii
writer_write_event
writer_close
get_final_state_particles
```

