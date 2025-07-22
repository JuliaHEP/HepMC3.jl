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
    
    // I/O operations
    mod.method("create_reader_ascii", &create_reader_ascii);
    mod.method("reader_read_event", &reader_read_event);
    mod.method("create_writer_ascii", &create_writer_ascii);
    mod.method("writer_write_event", &writer_write_event);
    mod.method("writer_close", &writer_close);
    mod.method("reader_close", &reader_close);
    
    // NEW: Vertex operations
    mod.method("set_vertex_status", &set_vertex_status);
    
    // NEW: Event operations
    mod.method("shift_event_position", &shift_event_position);
    
    // NEW: PDF Info
    mod.method("create_gen_pdf_info", &create_gen_pdf_info);
    mod.method("delete_gen_pdf_info", &delete_gen_pdf_info);
    mod.method("set_pdf_info", &set_pdf_info);
    mod.method("add_pdf_info_attribute", &add_pdf_info_attribute);
    
    // NEW: Cross Section
    mod.method("create_gen_cross_section", &create_gen_cross_section);
    mod.method("delete_gen_cross_section", &delete_gen_cross_section);
    mod.method("set_cross_section", &set_cross_section);
    mod.method("add_cross_section_attribute", &add_cross_section_attribute);
    
    // NEW: Heavy Ion
    mod.method("create_gen_heavy_ion", &create_gen_heavy_ion);
    mod.method("delete_gen_heavy_ion", &delete_gen_heavy_ion);
    mod.method("set_heavy_ion_info", &set_heavy_ion_info);
    mod.method("add_heavy_ion_attribute", &add_heavy_ion_attribute);
    
    // NEW: Attribute management
    mod.method("remove_event_attribute", &remove_event_attribute);
    mod.method("create_int_attribute", &create_int_attribute);
    mod.method("create_double_attribute", &create_double_attribute);
    mod.method("create_string_attribute", &create_string_attribute);
    mod.method("delete_attribute", &delete_attribute);
    mod.method("add_particle_attribute", &add_particle_attribute);
    mod.method("add_vertex_attribute", &add_vertex_attribute);
    
    // NEW: Event manipulation
    mod.method("remove_particle_from_event", &remove_particle_from_event);
}
// No JLCXX_MODULE here - that's handled by the generated code