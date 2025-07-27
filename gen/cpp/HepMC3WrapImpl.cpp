#include "HepMC3Wrap.h"
#include "HepMC3/GenEvent.h"
#include "HepMC3/GenParticle.h"
#include "HepMC3/GenVertex.h"
#include "HepMC3/ReaderAscii.h"
#include "HepMC3/WriterAscii.h"
#include "HepMC3/GenCrossSection.h"
#include "HepMC3/GenPdfInfo.h" 
#include "HepMC3/GenHeavyIon.h"
#include "HepMC3/Attribute.h"
#include <vector>
#include <memory>

using namespace HepMC3;

// Particle management with shared_ptr
void* create_shared_particle(void* momentum, int pdg_id, int status) {
    FourVector* fv = static_cast<FourVector*>(momentum);
    auto particle = std::make_shared<GenParticle>(*fv, pdg_id, status);
    return new std::shared_ptr<GenParticle>(particle);
}

void* create_shared_vertex() {
    auto vertex = std::make_shared<GenVertex>();
    return new std::shared_ptr<GenVertex>(vertex);
}

void add_shared_particle_in(void* vertex, void* particle) {
    auto v = static_cast<std::shared_ptr<GenVertex>*>(vertex);
    auto p = static_cast<std::shared_ptr<GenParticle>*>(particle);
    (*v)->add_particle_in(*p);
}

void add_shared_particle_out(void* vertex, void* particle) {
    auto v = static_cast<std::shared_ptr<GenVertex>*>(vertex);
    auto p = static_cast<std::shared_ptr<GenParticle>*>(particle);
    (*v)->add_particle_out(*p);
}

void add_shared_vertex_to_event(void* event, void* vertex) {
    auto e = static_cast<GenEvent*>(event);
    auto v = static_cast<std::shared_ptr<GenVertex>*>(vertex);
    e->add_vertex(*v);
}

// Vector operations
void* create_particle_vector() {
    return new std::vector<std::shared_ptr<GenParticle>>();
}

void delete_particle_vector(void* vec) {
    delete static_cast<std::vector<std::shared_ptr<GenParticle>>*>(vec);
}

int particle_vector_size(void* vec) {
    auto v = static_cast<std::vector<std::shared_ptr<GenParticle>>*>(vec);
    return v->size();
}

void* particle_vector_at(void* vec, int index) {
    auto v = static_cast<std::vector<std::shared_ptr<GenParticle>>*>(vec);
    return new std::shared_ptr<GenParticle>((*v)[index]);
}

// I/O operations
void* create_reader_ascii(const char* filename) {
    return new ReaderAscii(std::string(filename));
}

bool reader_read_event(void* reader, void* event) {
    auto r = static_cast<ReaderAscii*>(reader);
    auto e = static_cast<GenEvent*>(event);
    return r->read_event(*e);
}

void* create_writer_ascii(const char* filename) {
    return new WriterAscii(std::string(filename));
}

// Replace the writer_write_event function:
bool writer_write_event(void* writer, void* event) {
    auto w = static_cast<WriterAscii*>(writer);
    auto e = static_cast<GenEvent*>(event);
    w->write_event(*e);
    return true;  // Return success indicator
}

// Also add explicit close/flush functions:
void writer_close(void* writer) {
    auto w = static_cast<WriterAscii*>(writer);
    w->close();
}

void reader_close(void* reader) {
    auto r = static_cast<ReaderAscii*>(reader);
    r->close();
}




// Vertex operations
void set_vertex_status(void* vertex, int status) {
    auto v = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex);
    (*v)->set_status(status);
}

// Event operations
void shift_event_position(void* event, void* four_vector) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    auto fv = static_cast<HepMC3::FourVector*>(four_vector);
    e->shift_position_by(*fv);
}

// PDF Info
void* create_gen_pdf_info() {
    return new std::shared_ptr<HepMC3::GenPdfInfo>(std::make_shared<HepMC3::GenPdfInfo>());
}

void delete_gen_pdf_info(void* pdf_info) {
    delete static_cast<std::shared_ptr<HepMC3::GenPdfInfo>*>(pdf_info);
}

void set_pdf_info(void* pdf_info, int id1, int id2, double x1, double x2, double q, double pdf1, double pdf2, int pdf_set_id1, int pdf_set_id2) {
    auto pi = static_cast<std::shared_ptr<HepMC3::GenPdfInfo>*>(pdf_info);
    (*pi)->set(id1, id2, x1, x2, q, pdf1, pdf2, pdf_set_id1, pdf_set_id2);
}

void add_pdf_info_attribute(void* event, void* pdf_info) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    auto pi = static_cast<std::shared_ptr<HepMC3::GenPdfInfo>*>(pdf_info);
    e->add_attribute("GenPdfInfo", *pi);
}

// Cross Section
void* create_gen_cross_section() {
    return new std::shared_ptr<HepMC3::GenCrossSection>(std::make_shared<HepMC3::GenCrossSection>());
}

void delete_gen_cross_section(void* cross_section) {
    delete static_cast<std::shared_ptr<HepMC3::GenCrossSection>*>(cross_section);
}

void set_cross_section(void* cross_section, double xs, double xs_err) {
    auto cs = static_cast<std::shared_ptr<HepMC3::GenCrossSection>*>(cross_section);
    (*cs)->set_cross_section(xs, xs_err);
}

void add_cross_section_attribute(void* event, void* cross_section) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    auto cs = static_cast<std::shared_ptr<HepMC3::GenCrossSection>*>(cross_section);
    e->add_attribute("GenCrossSection", *cs);
}

// Heavy Ion
void* create_gen_heavy_ion() {
    return new std::shared_ptr<HepMC3::GenHeavyIon>(std::make_shared<HepMC3::GenHeavyIon>());
}

void delete_gen_heavy_ion(void* heavy_ion) {
    delete static_cast<std::shared_ptr<HepMC3::GenHeavyIon>*>(heavy_ion);
}

void set_heavy_ion_info(void* heavy_ion, int nh, int np, int nt, int nc, int ns, int nsp, int nn, int nw, int nwn, double impact_parameter, double event_plane_angle, double eccentricity, double sigma_inel_nn) {
    auto hi = static_cast<std::shared_ptr<HepMC3::GenHeavyIon>*>(heavy_ion);
    (*hi)->set(nh, np, nt, nc, ns, nsp, nn, nw, nwn, impact_parameter, event_plane_angle, eccentricity, sigma_inel_nn);
}

void add_heavy_ion_attribute(void* event, void* heavy_ion) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    auto hi = static_cast<std::shared_ptr<HepMC3::GenHeavyIon>*>(heavy_ion);
    e->add_attribute("GenHeavyIon", *hi);
}

// Attribute management
void remove_event_attribute(void* event, const char* name) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    e->remove_attribute(std::string(name));
}

// Particle/Vertex attributes
void* create_int_attribute(int value) {
    return new std::shared_ptr<HepMC3::Attribute>(std::make_shared<HepMC3::IntAttribute>(value));
}

void* create_double_attribute(double value) {
    return new std::shared_ptr<HepMC3::Attribute>(std::make_shared<HepMC3::DoubleAttribute>(value));
}

void* create_string_attribute(const char* value) {
    return new std::shared_ptr<HepMC3::Attribute>(std::make_shared<HepMC3::StringAttribute>(std::string(value)));
}

void delete_attribute(void* attribute) {
    delete static_cast<std::shared_ptr<HepMC3::Attribute>*>(attribute);
}

void add_particle_attribute(void* particle, const char* name, void* attribute) {
    auto p = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle);
    auto attr = static_cast<std::shared_ptr<HepMC3::Attribute>*>(attribute);
    (*p)->add_attribute(std::string(name), *attr);
}

void add_vertex_attribute(void* vertex, const char* name, void* attribute) {
    auto v = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex);
    auto attr = static_cast<std::shared_ptr<HepMC3::Attribute>*>(attribute);
    (*v)->add_attribute(std::string(name), *attr);
}

// Event manipulation
void remove_particle_from_event(void* event, void* particle) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    auto p = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle);
    e->remove_particle(*p);
}


void* get_particles_in(void* vertex) {
    auto v = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex);
    auto particles = (*v)->particles_in();
    
    // Create and return a vector of particle pointers
    auto* particle_vec = new std::vector<std::shared_ptr<HepMC3::GenParticle>>();
    for (auto& p : particles) {
        particle_vec->push_back(p);
    }
    return particle_vec;
}

void* get_particles_out(void* vertex) {
    auto v = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex);
    auto particles = (*v)->particles_out();
    
    // Create and return a vector of particle pointers
    auto* particle_vec = new std::vector<std::shared_ptr<HepMC3::GenParticle>>();
    for (auto& p : particles) {
        particle_vec->push_back(p);
    }
    return particle_vec;
}

// Raw pointer access functions for particles
int get_particle_pdg_id(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    return (*particle)->pdg_id();
}

int get_particle_status(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    return (*particle)->status();
}

int get_particle_id(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    return (*particle)->id();
}

double get_particle_px(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    return (*particle)->momentum().px();
}

double get_particle_py(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    return (*particle)->momentum().py();
}

double get_particle_pz(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    return (*particle)->momentum().pz();
}

double get_particle_e(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    return (*particle)->momentum().e();
}


// Add these functions after your existing ones:

// Navigation functions
void* get_production_vertex(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    auto vertex = (*particle)->production_vertex();
    if (vertex) {
        return new std::shared_ptr<HepMC3::GenVertex>(vertex);
    }
    return nullptr;
}

void* get_end_vertex(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    auto vertex = (*particle)->end_vertex();
    if (vertex) {
        return new std::shared_ptr<HepMC3::GenVertex>(vertex);
    }
    return nullptr;
}

// Vertex property access for raw pointers
int get_vertex_id(void* vertex_ptr) {
    auto* vertex = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex_ptr);
    return (*vertex)->id();
}

int get_vertex_status(void* vertex_ptr) {
    auto* vertex = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex_ptr);
    return (*vertex)->status();
}

double get_vertex_x(void* vertex_ptr) {
    auto* vertex = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex_ptr);
    return (*vertex)->position().x();
}

double get_vertex_y(void* vertex_ptr) {
    auto* vertex = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex_ptr);
    return (*vertex)->position().y();
}

double get_vertex_z(void* vertex_ptr) {
    auto* vertex = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex_ptr);
    return (*vertex)->position().z();
}

double get_vertex_t(void* vertex_ptr) {
    auto* vertex = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex_ptr);
    return (*vertex)->position().t();
}

// Pointer equality check
bool particles_equal(void* p1, void* p2) {
    auto* particle1 = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(p1);
    auto* particle2 = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(p2);
    return (*particle1).get() == (*particle2).get();
}

// Generated mass functions (for Python compatibility)
void set_generated_mass(void* particle, double mass) {
    auto p = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle);
    (*p)->set_generated_mass(mass);
}

double get_generated_mass(void* particle) {
    auto p = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle);
    return (*p)->generated_mass();
}

bool is_generated_mass_set(void* particle) {
    auto p = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle);
    return (*p)->is_generated_mass_set();
}

void unset_generated_mass(void* particle) {
    auto p = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle);
    (*p)->unset_generated_mass();
}

// Vertex position functions
void set_vertex_position(void* vertex, double x, double y, double z, double t) {
    auto v = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex);
    (*v)->set_position(HepMC3::FourVector(x, y, z, t));
}

void* get_vertex_position(void* vertex) {
    auto v = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(vertex);
    return new HepMC3::FourVector((*v)->position());
}

// Event weights
void set_event_weights(void* event, double* weights, int n_weights) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    std::vector<double> weight_vec(weights, weights + n_weights);
    e->weights() = weight_vec;
}

double* get_event_weights(void* event, int* n_weights) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    auto& weights = e->weights();
    *n_weights = weights.size();
    
    // Allocate and copy weights (caller must free)
    double* result = new double[weights.size()];
    for (size_t i = 0; i < weights.size(); ++i) {
        result[i] = weights[i];
    }
    return result;
}

void free_weights(double* weights) {
    delete[] weights;
}

int particles_size(void* event) {
    auto e = static_cast<std::shared_ptr<HepMC3::GenEvent>*>(event);  // ← Use shared_ptr
    return (*e)->particles().size();
}

int vertices_size(void* event) {
    auto e = static_cast<std::shared_ptr<HepMC3::GenEvent>*>(event);  // ← Use shared_ptr
    return (*e)->vertices().size();
}

// void* get_particle_at(void* event, int index) {
//     auto e = static_cast<std::shared_ptr<HepMC3::GenEvent>*>(event);  // ← Use shared_ptr
//     if (index >= 0 && index < (int)(*e)->particles().size()) {
//         return new std::shared_ptr<HepMC3::GenParticle>((*e)->particles()[index]);
//     }
//     return nullptr;
// }

// void* get_vertex_at(void* event, int index) {
//     auto e = static_cast<std::shared_ptr<HepMC3::GenEvent>*>(event);  // ← Use shared_ptr
//     if (index >= 0 && index < (int)(*e)->vertices().size()) {
//         return new std::shared_ptr<HepMC3::GenVertex>((*e)->vertices()[index]);
//     }
//     return nullptr;
// }

void* get_particle_at(void* event, int index) {
    auto e = static_cast<std::shared_ptr<HepMC3::GenEvent>*>(event);
    auto particles = (*e)->particles();
    if (index >= 0 && index < (int)particles.size()) {
        // Return shared_ptr for compatibility
        return new std::shared_ptr<HepMC3::GenParticle>(particles[index]);
    }
    return nullptr;
}

void* get_vertex_at(void* event, int index) {
    auto e = static_cast<std::shared_ptr<HepMC3::GenEvent>*>(event);
    auto vertices = (*e)->vertices();
    if (index >= 0 && index < (int)vertices.size()) {
        // Return shared_ptr for compatibility
        return new std::shared_ptr<HepMC3::GenVertex>(vertices[index]);
    }
    return nullptr;
}
// Run info support
void* create_gen_run_info() {
    return new std::shared_ptr<HepMC3::GenRunInfo>(std::make_shared<HepMC3::GenRunInfo>());
}

void set_event_run_info(void* event, void* run_info) {
    auto e = static_cast<HepMC3::GenEvent*>(event);
    auto ri = static_cast<std::shared_ptr<HepMC3::GenRunInfo>*>(run_info);
    e->set_run_info(*ri);
}

void set_weight_names(void* run_info, const char** names, int n_names) {
    auto ri = static_cast<std::shared_ptr<HepMC3::GenRunInfo>*>(run_info);
    std::vector<std::string> weight_names;
    for (int i = 0; i < n_names; ++i) {
        weight_names.push_back(std::string(names[i]));
    }
    (*ri)->set_weight_names(weight_names);
}




// Vertex equality check
bool vertices_equal(void* v1, void* v2) {
    auto* vertex1 = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(v1);
    auto* vertex2 = static_cast<std::shared_ptr<HepMC3::GenVertex>*>(v2);
    return (*vertex1).get() == (*vertex2).get();
}

// Safer navigation functions that return consistent pointers
void* get_production_vertex_safe(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    auto vertex = (*particle)->production_vertex();
    if (vertex) {
        return new std::shared_ptr<HepMC3::GenVertex>(vertex);
    }
    return nullptr;
}

void* get_end_vertex_safe(void* particle_ptr) {
    auto* particle = static_cast<std::shared_ptr<HepMC3::GenParticle>*>(particle_ptr);
    auto vertex = (*particle)->end_vertex();
    if (vertex) {
        return new std::shared_ptr<HepMC3::GenVertex>(vertex);
    }
    return nullptr;
}



void* read_all_events_from_file(const char* filename, int max_events) {
    auto* events = new std::vector<std::shared_ptr<HepMC3::GenEvent>>();
    
    HepMC3::ReaderAscii reader(filename);
    if (reader.failed()) {
        delete events;
        return nullptr;
    }
    
    int event_count = 0;
    while (!reader.failed() && (max_events < 0 || event_count < max_events)) {
        auto event = std::make_shared<HepMC3::GenEvent>();
        if (reader.read_event(*event)) {
            events->push_back(event);
            event_count++;
        } else {
            break;
        }
    }
    
    return events;
}

// Get event from vector
void* get_event_from_vector(void* events_vector, int index) {
    auto* events = static_cast<std::vector<std::shared_ptr<HepMC3::GenEvent>>*>(events_vector);
    if (index >= 0 && index < events->size()) {
        return new std::shared_ptr<HepMC3::GenEvent>((*events)[index]);
    }
    return nullptr;
}

int get_events_vector_size(void* events_vector) {
    auto* events = static_cast<std::vector<std::shared_ptr<HepMC3::GenEvent>>*>(events_vector);
    return events->size();
}

void delete_events_vector(void* events_vector) {
    auto* events = static_cast<std::vector<std::shared_ptr<HepMC3::GenEvent>>*>(events_vector);
    delete events;
}