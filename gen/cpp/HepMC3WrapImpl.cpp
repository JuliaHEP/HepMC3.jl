#include "HepMC3Wrap.h"
#include "HepMC3/GenEvent.h"
#include "HepMC3/GenParticle.h"
#include "HepMC3/GenVertex.h"
#include "HepMC3/ReaderAscii.h"
#include "HepMC3/WriterAscii.h"

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