#include "HepMC3Wrap.h"
#include "jlcxx/jlcxx.hpp"
#include "jlcxx/functions.hpp"



void add_manual_hepmc3_methods(jlcxx::Module& mod) {
    // Existing functions...
    mod.method("create_shared_particle", &create_shared_particle);
    mod.method("create_shared_vertex", &create_shared_vertex);
    mod.method("add_shared_particle_in", &add_shared_particle_in);
    mod.method("add_shared_particle_out", &add_shared_particle_out);
    mod.method("add_shared_vertex_to_event", &add_shared_vertex_to_event);
    
    // Vector operations
    mod.method("create_particle_vector", &create_particle_vector);
    mod.method("delete_particle_vector", &delete_particle_vector);
    mod.method("particle_vector_size", &particle_vector_size);
    mod.method("particle_vector_at", &particle_vector_at);
    
    // I/O operations - note the corrected return type
    mod.method("create_reader_ascii", &create_reader_ascii);
    mod.method("reader_read_event", &reader_read_event);
    mod.method("create_writer_ascii", &create_writer_ascii);
    mod.method("writer_write_event", &writer_write_event);  // Now returns bool
    
    // Add close functions
    mod.method("writer_close", &writer_close);
    mod.method("reader_close", &reader_close);
}

// No JLCXX_MODULE here - that's handled by the generated code