#ifndef HEPMC3_WRAP_H
#define HEPMC3_WRAP_H

#include "HepMC3/FourVector.h"
#include "HepMC3/GenEvent.h"
#include "HepMC3/GenParticle.h"
#include "HepMC3/GenVertex.h"
#include "HepMC3/ReaderAscii.h"
#include "HepMC3/WriterAscii.h"

#include "jlcxx/jlcxx.hpp"
#include "jlcxx/functions.hpp"
#include <memory>
#include <vector>
#include <string>

// Function to add manual methods to the generated module
void add_manual_hepmc3_methods(jlcxx::Module& mod);

// Forward declarations for manual wrapper functions
extern "C" {
    void* create_shared_particle(void* momentum, int pdg_id, int status);
    void* create_shared_vertex();
    void add_shared_particle_in(void* vertex, void* particle);
    void add_shared_particle_out(void* vertex, void* particle);
    void add_shared_vertex_to_event(void* event, void* vertex);
    
    void* create_particle_vector();
    void delete_particle_vector(void* vec);
    int particle_vector_size(void* vec);
    void* particle_vector_at(void* vec, int index);
    
    void* create_reader_ascii(const char* filename);
    bool reader_read_event(void* reader, void* event);
    void* create_writer_ascii(const char* filename);
    
    bool writer_write_event(void* writer, void* event);  
    void writer_close(void* writer);
    void reader_close(void* reader);



    // Vertex operations
    void set_vertex_status(void* vertex, int status);
    
    // Event operations  
    void shift_event_position(void* event, void* four_vector);
    
    // Event attributes
    void* create_gen_pdf_info();
    void delete_gen_pdf_info(void* pdf_info);
    void set_pdf_info(void* pdf_info, int id1, int id2, double x1, double x2, double q, double pdf1, double pdf2, int pdf_set_id1, int pdf_set_id2);
    void add_pdf_info_attribute(void* event, void* pdf_info);
    
    void* create_gen_cross_section();
    void delete_gen_cross_section(void* cross_section);
    void set_cross_section(void* cross_section, double xs, double xs_err);
    void add_cross_section_attribute(void* event, void* cross_section);
    
    void* create_gen_heavy_ion();
    void delete_gen_heavy_ion(void* heavy_ion);
    void set_heavy_ion_info(void* heavy_ion, int nh, int np, int nt, int nc, int ns, int nsp, int nn, int nw, int nwn, double impact_parameter, double event_plane_angle, double eccentricity, double sigma_inel_nn);
    void add_heavy_ion_attribute(void* event, void* heavy_ion);
    
    // Attribute management
    void remove_event_attribute(void* event, const char* name);
    
    // Particle attributes
    void* create_int_attribute(int value);
    void* create_double_attribute(double value);
    void* create_string_attribute(const char* value);
    void delete_attribute(void* attribute);
    void add_particle_attribute(void* particle, const char* name, void* attribute);
    void add_vertex_attribute(void* vertex, const char* name, void* attribute);
    
    // Event manipulation
    void remove_particle_from_event(void* event, void* particle);

    
    void* get_particles_in(void* vertex);
    void* get_particles_out(void* vertex);
    
    // Raw pointer access functions for particles
    int get_particle_pdg_id(void* particle_ptr);
    int get_particle_status(void* particle_ptr);
    int get_particle_id(void* particle_ptr);
    double get_particle_px(void* particle_ptr);
    double get_particle_py(void* particle_ptr);
    double get_particle_pz(void* particle_ptr);
    double get_particle_e(void* particle_ptr);

    // Navigation functions
    void* get_production_vertex(void* particle_ptr);
    void* get_end_vertex(void* particle_ptr);
    
    // Vertex property access
    int get_vertex_id(void* vertex_ptr);
    int get_vertex_status(void* vertex_ptr);
    double get_vertex_x(void* vertex_ptr);
    double get_vertex_y(void* vertex_ptr);
    double get_vertex_z(void* vertex_ptr);
    double get_vertex_t(void* vertex_ptr);
    
    // Pointer equality
    bool particles_equal(void* p1, void* p2);
    
    // Generated mass functions
    void set_generated_mass(void* particle, double mass);
    double get_generated_mass(void* particle);
    bool is_generated_mass_set(void* particle);
    void unset_generated_mass(void* particle);
    
    // Vertex positioning
    void set_vertex_position(void* vertex, double x, double y, double z, double t);
    void* get_vertex_position(void* vertex);
    
    // Event weights
    void set_event_weights(void* event, double* weights, int n_weights);
    double* get_event_weights(void* event, int* n_weights);
    void free_weights(double* weights);
    
    // Enhanced event access
    int particles_size(void* event);
    int vertices_size(void* event);
    void* get_particle_at(void* event, int index);
    void* get_vertex_at(void* event, int index);
    
    // Run info support
    void* create_gen_run_info();
    void set_event_run_info(void* event, void* run_info);
    void set_weight_names(void* run_info, const char** names, int n_names);

    // Vertex equality and safe navigation functions
    bool vertices_equal(void* v1, void* v2);
    void* get_production_vertex_safe(void* particle_ptr);
    void* get_end_vertex_safe(void* particle_ptr);

}

#endif