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