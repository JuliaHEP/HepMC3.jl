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


    mod.method("get_particles_in", &get_particles_in);
    mod.method("get_particles_out", &get_particles_out);
    
    // Raw pointer access functions for particles
    mod.method("get_particle_pdg_id", &get_particle_pdg_id);
    mod.method("get_particle_status", &get_particle_status);
    mod.method("get_particle_id", &get_particle_id);
    mod.method("get_particle_px", &get_particle_px);
    mod.method("get_particle_py", &get_particle_py);
    mod.method("get_particle_pz", &get_particle_pz);
    mod.method("get_particle_e", &get_particle_e);


    // Navigation functions
    mod.method("get_production_vertex", &get_production_vertex);
    mod.method("get_end_vertex", &get_end_vertex);
    
    // Vertex property access
    mod.method("get_vertex_id", &get_vertex_id);
    mod.method("get_vertex_status", &get_vertex_status);
    mod.method("get_vertex_x", &get_vertex_x);
    mod.method("get_vertex_y", &get_vertex_y);
    mod.method("get_vertex_z", &get_vertex_z);
    mod.method("get_vertex_t", &get_vertex_t);
    
    // Pointer equality
    mod.method("particles_equal", &particles_equal);
    
    // Generated mass functions
    mod.method("set_generated_mass", &set_generated_mass);
    mod.method("get_generated_mass", &get_generated_mass);
    mod.method("is_generated_mass_set", &is_generated_mass_set);
    mod.method("unset_generated_mass", &unset_generated_mass);
    
    // Vertex positioning
    mod.method("set_vertex_position", &set_vertex_position);
    mod.method("get_vertex_position", &get_vertex_position);
    
    // Event weights
    mod.method("set_event_weights", &set_event_weights);
    mod.method("get_event_weights", &get_event_weights);
    mod.method("free_weights", &free_weights);
    
    // Enhanced event access
    mod.method("particles_size", &particles_size);
    mod.method("vertices_size", &vertices_size);
    mod.method("get_particle_at", &get_particle_at);
    mod.method("get_vertex_at", &get_vertex_at);
    
    // Run info support
    mod.method("create_gen_run_info", &create_gen_run_info);
    mod.method("set_event_run_info", &set_event_run_info);
    mod.method("set_weight_names", &set_weight_names);


    // Add vertex equality
    mod.method("vertices_equal", &vertices_equal);
    mod.method("get_production_vertex_safe", &get_production_vertex_safe);
    mod.method("get_end_vertex_safe", &get_end_vertex_safe);

}
// No JLCXX_MODULE here - that's handled by the generated code