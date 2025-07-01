#include "HepMC3Wrap.h"
#include <memory>
#include <unordered_map>
#include <string>
#include <vector>
#include <algorithm>




// Global storage for shared pointers to maintain ownership
static std::unordered_map<void*, std::shared_ptr<HepMC3::GenParticle>> particle_store;
static std::unordered_map<void*, std::shared_ptr<HepMC3::GenVertex>> vertex_store;
static std::unordered_map<void*, std::shared_ptr<HepMC3::GenCrossSection>> xs_store;
static std::unordered_map<void*, std::shared_ptr<HepMC3::GenPdfInfo>> pdf_store;
static std::unordered_map<void*, std::shared_ptr<HepMC3::GenHeavyIon>> hi_store;
static std::unordered_map<void*, std::shared_ptr<HepMC3::Attribute>> attribute_store;
// Implementation of the C-style interface
extern "C" {
    void* create_fourvector(double x, double y, double z, double t) {
        return new HepMC3::FourVector(x, y, z, t);
    }

    void* create_genevent(int units) {
        return new HepMC3::GenEvent(static_cast<HepMC3::Units::MomentumUnit>(units));
    }

    void* create_particle(void* momentum, int pdg_id, int status) {
        auto* mom = static_cast<HepMC3::FourVector*>(momentum);
        // Create particle with shared ownership
        auto particle = std::make_shared<HepMC3::GenParticle>(*mom, pdg_id, status);
        void* ptr = particle.get();
        // Store the shared_ptr
        particle_store[ptr] = particle;
        return ptr;
    }

    void* create_vertex() {
        auto vertex = std::make_shared<HepMC3::GenVertex>();
        void* ptr = vertex.get();
        // Store the shared_ptr
        vertex_store[ptr] = vertex;
        return ptr;
    }

    void add_particle_in(void* vertex, void* particle) {
        auto v_it = vertex_store.find(vertex);
        auto p_it = particle_store.find(particle);
        if (v_it != vertex_store.end() && p_it != particle_store.end()) {
            v_it->second->add_particle_in(p_it->second);
        }
    }

    void add_particle_out(void* vertex, void* particle) {
        auto v_it = vertex_store.find(vertex);
        auto p_it = particle_store.find(particle);
        if (v_it != vertex_store.end() && p_it != particle_store.end()) {
            v_it->second->add_particle_out(p_it->second);
        }
    }

    void set_vertex_status(void* vertex, int status) {
        auto v_it = vertex_store.find(vertex);
        if (v_it != vertex_store.end()) {
            v_it->second->set_status(status);
        }
    }

    int vertex_status(void* vertex) {
        auto v_it = vertex_store.find(vertex);
        if (v_it != vertex_store.end()) {
            return v_it->second->status();
        }
        return 0;
    }

    void add_vertex_to_event(void* event, void* vertex) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        auto v_it = vertex_store.find(vertex);
        if (v_it != vertex_store.end()) {
            evt->add_vertex(v_it->second);
        }
    }

    int particle_pid(void* particle) {
        auto p_it = particle_store.find(particle);
        if (p_it != particle_store.end()) {
            return p_it->second->pid();
        }
        return 0;
    }

    int particle_status(void* particle) {
        auto p_it = particle_store.find(particle);
        if (p_it != particle_store.end()) {
            return p_it->second->status();
        }
        return 0;
    }

    void* particle_momentum(void* particle) {
        auto p_it = particle_store.find(particle);
        if (p_it != particle_store.end()) {
            return new HepMC3::FourVector(p_it->second->momentum());
        }
        return nullptr;
    }

    void set_particle_status(void* particle, int status) {
        auto p_it = particle_store.find(particle);
        if (p_it != particle_store.end()) {
            p_it->second->set_status(status);
        }
    }

    void set_particle_momentum(void* particle, void* momentum) {
        auto p_it = particle_store.find(particle);
        if (p_it != particle_store.end()) {
            auto* mom = static_cast<HepMC3::FourVector*>(momentum);
            p_it->second->set_momentum(*mom);
        }
    }

    double fourvector_px(void* v) {
        return static_cast<HepMC3::FourVector*>(v)->px();
    }

    double fourvector_py(void* v) {
        return static_cast<HepMC3::FourVector*>(v)->py();
    }

    double fourvector_pz(void* v) {
        return static_cast<HepMC3::FourVector*>(v)->pz();
    }

    double fourvector_e(void* v) {
        return static_cast<HepMC3::FourVector*>(v)->e();
    }




    void* create_cross_section() {
        auto xs = std::make_shared<HepMC3::GenCrossSection>();
        void* ptr = xs.get();
        xs_store[ptr] = xs;
        return ptr;
    }

    void set_cross_section(void* xs, double value, double error) {
        auto xs_it = xs_store.find(xs);
        if (xs_it != xs_store.end()) {
            xs_it->second->set_cross_section(value, error);
        }
    }

    double get_cross_section(void* xs) {
        auto xs_it = xs_store.find(xs);
        if (xs_it != xs_store.end()) {
            return xs_it->second->xsec();
        }
        return 0.0;
    }

    double get_cross_section_error(void* xs) {
        auto xs_it = xs_store.find(xs);
        if (xs_it != xs_store.end()) {
            return xs_it->second->xsec_err();
        }
        return 0.0;
    }

    void add_cross_section_to_event(void* event, void* xs) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        auto xs_it = xs_store.find(xs);
        if (xs_it != xs_store.end()) {
            evt->set_cross_section(xs_it->second);
        }
    }

    void set_cross_section_alternative(void* xs, double value, double error, int id) {
        auto xs_it = xs_store.find(xs);
        if (xs_it != xs_store.end()) {
            // Convert id to string for named cross section
            std::string name = "alternative_" + std::to_string(id);
            xs_it->second->set_xsec(name, value);
            // Set the error separately if needed
            // Note: HepMC3 doesn't directly support setting errors for alternative cross sections
        }
    }

    double get_cross_section_alternative(void* xs, int id) {
        auto xs_it = xs_store.find(xs);
        if (xs_it != xs_store.end()) {
            std::string name = "alternative_" + std::to_string(id);
            return xs_it->second->xsec(name);
        }
        return 0.0;
    }

    double get_cross_section_error_alternative(void* xs, int id) {
        // Note: HepMC3 doesn't directly support getting errors for alternative cross sections
        // We'll return 0.0 as a default
        return 0.0;
    }

    void* create_pdf_info() {
        auto pdf = std::make_shared<HepMC3::GenPdfInfo>();
        void* ptr = pdf.get();
        pdf_store[ptr] = pdf;
        return ptr;
    }

    void set_pdf_info(void* pdf, int parton_id1, int parton_id2, double x1, double x2,
                     double scale, double xf1, double xf2, int pdf_id1, int pdf_id2) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            pdf_it->second->set(parton_id1, parton_id2, x1, x2, scale, xf1, xf2, pdf_id1, pdf_id2);
        }
    }

    int get_parton_id1(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->parton_id[0];  // Access first element of array
        }
        return 0;
    }

    int get_parton_id2(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->parton_id[1];  // Access second element of array
        }
        return 0;
    }

    double get_x1(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->x[0];  // Access first element of array
        }
        return 0.0;
    }

    double get_x2(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->x[1];  // Access second element of array
        }
        return 0.0;
    }

    double get_scale(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->scale;  // Direct member access
        }
        return 0.0;
    }

    double get_xf1(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->xf[0];  // Access first element of array
        }
        return 0.0;
    }

    double get_xf2(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->xf[1];  // Access second element of array
        }
        return 0.0;
    }

    int get_pdf_id1(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->pdf_id[0];  // Access first element of array
        }
        return 0;
    }

    int get_pdf_id2(void* pdf) {
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            return pdf_it->second->pdf_id[1];  // Access second element of array
        }
        return 0;
    }

    void add_pdf_info_to_event(void* event, void* pdf) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        auto pdf_it = pdf_store.find(pdf);
        if (pdf_it != pdf_store.end()) {
            evt->set_pdf_info(pdf_it->second);
        }
    }



    void* create_heavy_ion() {
        auto hi = std::make_shared<HepMC3::GenHeavyIon>();
        void* ptr = hi.get();
        hi_store[ptr] = hi;
        return ptr;
    }

    void set_heavy_ion_basic(void* hi, int ncoll_hard, int npart_proj, int npart_targ, int ncoll,
                            int n_n_wounded, int nwounded_n, int nwounded_nwounded,
                            double impact_param, double event_plane_angle) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            hi_it->second->Ncoll_hard = ncoll_hard;
            hi_it->second->Npart_proj = npart_proj;
            hi_it->second->Npart_targ = npart_targ;
            hi_it->second->Ncoll = ncoll;
            hi_it->second->N_Nwounded_collisions = n_n_wounded;
            hi_it->second->Nwounded_N_collisions = nwounded_n;
            hi_it->second->Nwounded_Nwounded_collisions = nwounded_nwounded;
            hi_it->second->impact_parameter = impact_param;
            hi_it->second->event_plane_angle = event_plane_angle;
        }
    }

    void set_heavy_ion_nuclear(void* hi, int nspec_proj_n, int nspec_targ_n, 
                             int nspec_proj_p, int nspec_targ_p) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            hi_it->second->Nspec_proj_n = nspec_proj_n;
            hi_it->second->Nspec_targ_n = nspec_targ_n;
            hi_it->second->Nspec_proj_p = nspec_proj_p;
            hi_it->second->Nspec_targ_p = nspec_targ_p;
        }
    }

    void set_heavy_ion_centrality(void* hi, double sigma_inel_nn, double centrality, 
                                double user_cent_estimate) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            hi_it->second->sigma_inel_NN = sigma_inel_nn;
            hi_it->second->centrality = centrality;
            hi_it->second->user_cent_estimate = user_cent_estimate;
        }
    }

    void set_heavy_ion_participant_plane_angle(void* hi, int order, double angle) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            hi_it->second->participant_plane_angles[order] = angle;
        }
    }

    void set_heavy_ion_eccentricity(void* hi, int order, double ecc) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            hi_it->second->eccentricities[order] = ecc;
        }
    }

        // ... (previous implementations) ...

    int get_ncoll_hard(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Ncoll_hard;
        }
        return -1;
    }

    int get_npart_proj(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Npart_proj;
        }
        return -1;
    }

    int get_npart_targ(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Npart_targ;
        }
        return -1;
    }

    int get_ncoll(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Ncoll;
        }
        return -1;
    }

    int get_n_n_wounded(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->N_Nwounded_collisions;
        }
        return -1;
    }

    int get_nwounded_n(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Nwounded_N_collisions;
        }
        return -1;
    }

    int get_nwounded_nwounded(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Nwounded_Nwounded_collisions;
        }
        return -1;
    }

    double get_impact_parameter(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->impact_parameter;
        }
        return -1.0;
    }

    double get_event_plane_angle(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->event_plane_angle;
        }
        return -1.0;
    }

    int get_nspec_proj_n(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Nspec_proj_n;
        }
        return -1;
    }

    int get_nspec_targ_n(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Nspec_targ_n;
        }
        return -1;
    }

    int get_nspec_proj_p(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Nspec_proj_p;
        }
        return -1;
    }

    int get_nspec_targ_p(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->Nspec_targ_p;
        }
        return -1;
    }

    double get_sigma_inel_nn(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->sigma_inel_NN;
        }
        return -1.0;
    }

    double get_centrality(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->centrality;
        }
        return -1.0;
    }

    double get_user_cent_estimate(void* hi) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            return hi_it->second->user_cent_estimate;
        }
        return -1.0;
    }

    double get_participant_plane_angle(void* hi, int order) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            auto& angles = hi_it->second->participant_plane_angles;
            auto angle_it = angles.find(order);
            if (angle_it != angles.end()) {
                return angle_it->second;
            }
        }
        return -1.0;
    }

    double get_eccentricity(void* hi, int order) {
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            auto& eccs = hi_it->second->eccentricities;
            auto ecc_it = eccs.find(order);
            if (ecc_it != eccs.end()) {
                return ecc_it->second;
            }
        }
        return -1.0;
    }

    void add_heavy_ion_to_event(void* event, void* hi) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        auto hi_it = hi_store.find(hi);
        if (hi_it != hi_store.end()) {
            evt->set_heavy_ion(hi_it->second);
        }
    }

    int event_particles_size(void* event) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        return evt->particles().size();
    }

    int event_vertices_size(void* event) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        return evt->vertices().size();
    }

    void* event_particle_at(void* event, int index) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        if (index >= 0 && index < evt->particles().size()) {
            return evt->particles()[index].get();
        }
        return nullptr;
    }

    void* event_vertex_at(void* event, int index) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        if (index >= 0 && index < evt->vertices().size()) {
            return evt->vertices()[index].get();
        }
        return nullptr;
    }

    void* create_particle_vector() {
        return new std::vector<HepMC3::GenParticlePtr>();
    }

    void delete_particle_vector(void* vec) {
        auto* v = static_cast<std::vector<HepMC3::GenParticlePtr>*>(vec);
        delete v;
    }

    int particle_vector_size(void* vec) {
        auto* v = static_cast<std::vector<HepMC3::GenParticlePtr>*>(vec);
        return v->size();
    }

    void* particle_vector_at(void* vec, int index) {
        auto* v = static_cast<std::vector<HepMC3::GenParticlePtr>*>(vec);
        if (index >= 0 && index < v->size()) {
            return (*v)[index].get();
        }
        return nullptr;
    }

    void find_particles_by_pid(void* event, void* result_vec, int pid) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        auto* results = static_cast<std::vector<HepMC3::GenParticlePtr>*>(result_vec);
        results->clear();
        for (const auto& particle : evt->particles()) {
            if (particle->pid() == pid) {
                results->push_back(particle);
            }
        }
    }

    void* vertex_particles_in(void* vertex, void* result_vec) {
        auto* v = static_cast<HepMC3::GenVertex*>(vertex);
        auto* results = static_cast<std::vector<HepMC3::GenParticlePtr>*>(result_vec);
        results->clear();
        for (const auto& p : v->particles_in()) {
            results->push_back(p);
        }
        return result_vec;
    }

    void* vertex_particles_out(void* vertex, void* result_vec) {
        auto* v = static_cast<HepMC3::GenVertex*>(vertex);
        auto* results = static_cast<std::vector<HepMC3::GenParticlePtr>*>(result_vec);
        results->clear();
        for (const auto& p : v->particles_out()) {
            results->push_back(p);
        }
        return result_vec;
    }

    void* particle_production_vertex(void* particle) {
        auto* p = static_cast<HepMC3::GenParticle*>(particle);
        return p->production_vertex().get();
    }

    void* particle_end_vertex(void* particle) {
        auto* p = static_cast<HepMC3::GenParticle*>(particle);
        return p->end_vertex().get();
    }

    void* particle_parents(void* particle, void* result_vec) {
        auto* p = static_cast<HepMC3::GenParticle*>(particle);
        auto* results = static_cast<std::vector<HepMC3::GenParticlePtr>*>(result_vec);
        results->clear();
        auto parents = p->parents();
        for (const auto& parent : parents) {
            results->push_back(parent);
        }
        return result_vec;
    }

    void* particle_children(void* particle, void* result_vec) {
        auto* p = static_cast<HepMC3::GenParticle*>(particle);
        auto* results = static_cast<std::vector<HepMC3::GenParticlePtr>*>(result_vec);
        results->clear();
        auto children = p->children();
        for (const auto& child : children) {
            results->push_back(child);
        }
        return result_vec;
    }

    int event_particles_with_status(void* event, int status) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        int count = 0;
        for (const auto& p : evt->particles()) {
            if (p->status() == status) count++;
        }
        return count;
    }

    double event_total_momentum(void* event, int component) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        double total = 0.0;
        for (const auto& p : evt->particles()) {
            switch(component) {
                case 0: total += p->momentum().e(); break;
                case 1: total += p->momentum().px(); break;
                case 2: total += p->momentum().py(); break;
                case 3: total += p->momentum().pz(); break;
            }
        }
        return total;
    }

    bool event_is_valid(void* event) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        return !evt->particles().empty() && !evt->vertices().empty();
    }


    void convert_momentum(void* four_vector, int from_unit, int to_unit) {
        auto* v = static_cast<HepMC3::FourVector*>(four_vector);
        HepMC3::Units::convert(*v, 
                              static_cast<HepMC3::Units::MomentumUnit>(from_unit),
                              static_cast<HepMC3::Units::MomentumUnit>(to_unit));
    }

    void convert_length(void* four_vector, int from_unit, int to_unit) {
        auto* v = static_cast<HepMC3::FourVector*>(four_vector);
        HepMC3::Units::convert(*v,
                              static_cast<HepMC3::Units::LengthUnit>(from_unit),
                              static_cast<HepMC3::Units::LengthUnit>(to_unit));
    }


void convert_event_units(void* event, int new_momentum_unit, int new_length_unit) {
    auto* evt = static_cast<HepMC3::GenEvent*>(event);
    evt->set_units(
        static_cast<HepMC3::Units::MomentumUnit>(new_momentum_unit),
        static_cast<HepMC3::Units::LengthUnit>(new_length_unit)
    );
}


    int get_momentum_unit(void* event) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        return static_cast<int>(evt->momentum_unit());
    }

    int get_length_unit(void* event) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        return static_cast<int>(evt->length_unit());
    }
    

    const char* momentum_unit_name(int unit) {
        static std::string name = HepMC3::Units::name(static_cast<HepMC3::Units::MomentumUnit>(unit));
        return name.c_str();
    }

    const char* length_unit_name(int unit) {
        static std::string name = HepMC3::Units::name(static_cast<HepMC3::Units::LengthUnit>(unit));
        return name.c_str();
    }

    void* create_genevent_with_units(int momentum_unit, int length_unit) {
        return new HepMC3::GenEvent(
            static_cast<HepMC3::Units::MomentumUnit>(momentum_unit),
            static_cast<HepMC3::Units::LengthUnit>(length_unit)
        );
    }
    void* create_int_attribute(int value) {
        auto attr = std::make_shared<HepMC3::IntAttribute>(value);
        void* ptr = attr.get();
        attribute_store[ptr] = attr;
        return ptr;
    }

    void* create_double_attribute(double value) {
        auto attr = std::make_shared<HepMC3::DoubleAttribute>(value);
        void* ptr = attr.get();
        attribute_store[ptr] = attr;
        return ptr;
    }

 



void* create_string_attribute(const char* value) {
    // Create a std::string from the C string to ensure proper handling
    std::string str_value(value);
    auto attr = std::make_shared<HepMC3::StringAttribute>(str_value);
    void* ptr = attr.get();
    attribute_store[ptr] = attr;
    return ptr;
}

// Add a static string storage to prevent the string from being deallocated
static std::string last_string_value;

const char* get_string_attribute_value(void* attr) {
    if (auto* string_attr = dynamic_cast<HepMC3::StringAttribute*>(static_cast<HepMC3::Attribute*>(attr))) {
        // Store the string in our static storage
        last_string_value = string_attr->value();
        return last_string_value.c_str();
    }
    return "";
}


    void* create_bool_attribute(bool value) {
        auto attr = std::make_shared<HepMC3::BoolAttribute>(value);
        void* ptr = attr.get();
        attribute_store[ptr] = attr;
        return ptr;
    }

    void add_attribute_to_event(void* event, const char* name, void* attr) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        auto attr_it = attribute_store.find(attr);
        if (attr_it != attribute_store.end()) {
            evt->add_attribute(name, attr_it->second);
        }
    }

 void* get_attribute_from_event(void* event, const char* name) {
    auto* evt = static_cast<HepMC3::GenEvent*>(event);
    auto names = evt->attribute_names();
    if (std::find(names.begin(), names.end(), name) != names.end()) {
        // Try each type until we find the right one
        if (auto attr = evt->attribute<HepMC3::IntAttribute>(name)) {
            void* ptr = attr.get();
            attribute_store[ptr] = attr;
            return ptr;
        }
        if (auto attr = evt->attribute<HepMC3::DoubleAttribute>(name)) {
            void* ptr = attr.get();
            attribute_store[ptr] = attr;
            return ptr;
        }
        if (auto attr = evt->attribute<HepMC3::StringAttribute>(name)) {
            void* ptr = attr.get();
            attribute_store[ptr] = attr;
            return ptr;
        }
        if (auto attr = evt->attribute<HepMC3::BoolAttribute>(name)) {
            void* ptr = attr.get();
            attribute_store[ptr] = attr;
            return ptr;
        }
    }
    return nullptr;
}

   bool has_attribute(void* event, const char* name) {
    auto* evt = static_cast<HepMC3::GenEvent*>(event);
    auto names = evt->attribute_names();
    return std::find(names.begin(), names.end(), name) != names.end();
}

    void remove_attribute(void* event, const char* name) {
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        evt->remove_attribute(name);
    }

   int get_int_attribute_value(void* attr) {
    if (auto* int_attr = dynamic_cast<HepMC3::IntAttribute*>(static_cast<HepMC3::Attribute*>(attr))) {
        return int_attr->value();
    }
    return 0;
}

double get_double_attribute_value(void* attr) {
    if (auto* double_attr = dynamic_cast<HepMC3::DoubleAttribute*>(static_cast<HepMC3::Attribute*>(attr))) {
        return double_attr->value();
    }
    return 0.0;
}



bool get_bool_attribute_value(void* attr) {
    if (auto* bool_attr = dynamic_cast<HepMC3::BoolAttribute*>(static_cast<HepMC3::Attribute*>(attr))) {
        return bool_attr->value();
    }
    return false;
}

 

    void* create_reader_ascii(const char* filename) {
        try {
            return new HepMC3::ReaderAscii(filename);
        } catch (...) {
            return nullptr;
        }
    }

    bool reader_read_event(void* reader, void* event) {
        if (!reader || !event) return false;
        auto* r = static_cast<HepMC3::ReaderAscii*>(reader);
        auto* evt = static_cast<HepMC3::GenEvent*>(event);
        return r->read_event(*evt);
    }

    bool reader_failed(void* reader) {
        if (!reader) return true;
        return static_cast<HepMC3::ReaderAscii*>(reader)->failed();
    }

    void reader_close(void* reader) {
        if (!reader) return;
        static_cast<HepMC3::ReaderAscii*>(reader)->close();
    }



    bool writer_failed(void* writer) {
        if (!writer) return true;
        return static_cast<HepMC3::WriterAscii*>(writer)->failed();
    }

    void writer_close(void* writer) {
        if (!writer) return;
        static_cast<HepMC3::WriterAscii*>(writer)->close();
    }














// In HepMC3WrapImpl.cpp
void* create_writer_ascii(const char* filename) {
    try {
        // Create writer with shared_ptr to manage lifetime
        auto* writer = new HepMC3::WriterAscii(std::string(filename));
        return writer;
    } catch (const std::exception& e) {
        std::cerr << "Error creating writer: " << e.what() << std::endl;
        return nullptr;
    } catch (...) {
        std::cerr << "Unknown error creating writer" << std::endl;
        return nullptr;
    }
}

void writer_write_event(void* writer, void* event) {
    if (!writer || !event) {
        std::cerr << "Null pointer in writer_write_event" << std::endl;
        return;
    }
    try {
        auto* w = static_cast<HepMC3::WriterAscii*>(writer);
        auto* evt = static_cast<const HepMC3::GenEvent*>(event);
        w->write_event(*evt);
    } catch (const std::exception& e) {
        std::cerr << "Error writing event: " << e.what() << std::endl;
    } catch (...) {
        std::cerr << "Unknown error writing event" << std::endl;
    }
}

    void* create_writer_gz(const char* filename, int compression_type) {
    try {
        std::cerr << "Creating compressed writer with type: " << compression_type << std::endl;
        
        // For gzip compression
        if (compression_type == 0) {  // Z
            using WriterType = HepMC3::WriterGZ<HepMC3::WriterAscii>;
            return new WriterType(std::string(filename));
        }
        
        std::cerr << "Unsupported compression type: " << compression_type << std::endl;
        return nullptr;
    } catch (const std::exception& e) {
        std::cerr << "Exception creating writer: " << e.what() << std::endl;
        return nullptr;
    } catch (...) {
        std::cerr << "Unknown exception creating writer" << std::endl;
        return nullptr;
    }
}

void* create_reader_gz(const char* filename, int compression_type) {
    try {
        std::cerr << "Creating compressed reader with type: " << compression_type << std::endl;
        
        // For gzip compression
        if (compression_type == 0) {  // Z
            using ReaderType = HepMC3::ReaderGZ<HepMC3::ReaderAscii>;
            return new ReaderType(std::string(filename));
        }
        
        std::cerr << "Unsupported compression type: " << compression_type << std::endl;
        return nullptr;
    } catch (const std::exception& e) {
        std::cerr << "Exception creating reader: " << e.what() << std::endl;
        return nullptr;
    } catch (...) {
        std::cerr << "Unknown exception creating reader" << std::endl;
        return nullptr;
    }
}

    int detect_compression(const char* filename) {
        try {
            std::cerr << "Detecting compression for: " << filename << std::endl;
            std::ifstream file(filename, std::ios::binary);
            if (!file) {
                std::cerr << "Could not open file" << std::endl;
                return -1;  // PLAINTEXT
            }

            char buffer[4] = {0};
            file.read(buffer, 4);
            if (!file) {
                std::cerr << "Could not read file header" << std::endl;
                return -1;  // PLAINTEXT
            }

            auto compression = bxz::detect_type(buffer, buffer + 4);
            int result = static_cast<int>(compression);
            std::cerr << "Detected compression: " << result << std::endl;
            return result;
        } catch (const std::exception& e) {
            std::cerr << "Exception detecting compression: " << e.what() << std::endl;
            return -1;  // PLAINTEXT
        } catch (...) {
            std::cerr << "Unknown exception detecting compression" << std::endl;
            return -1;  // PLAINTEXT
        }
    }
}










