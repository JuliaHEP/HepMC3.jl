// Standard C++ constructs that cause wrapping issues
std::char_traits
std::allocator
std::basic_istream
std::basic_ostream
std::basic_istringstream
std::basic_ostringstream
std::__wrap_iter
std::map
std::unordered_map
std::shared_ptr
std::weak_ptr
std::enable_shared_from_this
std::unique_ptr
std::pair
std::vector<std::pair
/.*operator delete.*/
/.*operator new.*/

// Specific HepMC3 shared_ptr issues
HepMC3::GenParticlePtr
HepMC3::GenVertexPtr
HepMC3::ConstGenParticlePtr
HepMC3::ConstGenVertexPtr
HepMC3::AttributePtr

// Complex container types with shared_ptr
std::vector<HepMC3::GenParticlePtr>
std::vector<HepMC3::ConstGenParticlePtr>
std::vector<HepMC3::GenVertexPtr>
std::vector<HepMC3::ConstGenVertexPtr>
std::vector<std::shared_ptr<HepMC3::GenParticle>>
std::vector<std::shared_ptr<HepMC3::GenVertex>>
std::vector<std::shared_ptr<HepMC3::Attribute>>

// The problematic pair types
std::pair<int,std::shared_ptr<HepMC3::Attribute>>
std::pair<std::string,std::shared_ptr<HepMC3::Attribute>>
std::vector<std::pair<int,std::shared_ptr<HepMC3::Attribute>>>
std::vector<std::pair<std::string,std::shared_ptr<HepMC3::Attribute>>>

// Map-based attributes and complex data structures
std::map<std::string,std::map<int,std::shared_ptr<HepMC3::Attribute>>>
std::map<int,std::shared_ptr<HepMC3::Attribute>>
std::map<std::string,std::shared_ptr<HepMC3::Attribute>>

// Problematic methods that use shared_ptr containers
std::vector<HepMC3::ConstGenParticlePtr> HepMC3::GenParticle::parents()
std::vector<HepMC3::ConstGenParticlePtr> HepMC3::GenParticle::children()
const std::vector<HepMC3::ConstGenParticlePtr> & HepMC3::GenVertex::particles_in()
const std::vector<HepMC3::ConstGenParticlePtr> & HepMC3::GenVertex::particles_out()
const std::vector<HepMC3::ConstGenParticlePtr> & HepMC3::GenEvent::particles()
const std::vector<HepMC3::ConstGenVertexPtr> & HepMC3::GenEvent::vertices()

// Attribute-related methods with shared_ptr
void HepMC3::GenEvent::add_attribute(std::string const&, std::shared_ptr<HepMC3::Attribute>, int)
void HepMC3::GenEvent::add_attributes(std::string const&, std::vector<std::pair<int,std::shared_ptr<HepMC3::Attribute>>> const&)
std::map<std::string,std::map<int,std::shared_ptr<HepMC3::Attribute>>> HepMC3::GenEvent::attributes() const

// Heavy Ion map issues
HepMC3::GenHeavyIon::participant_plane_angles
HepMC3::GenHeavyIon::eccentricities

// Long double issues
HepMC3::LongDoubleAttribute
HepMC3::VectorLongDoubleAttribute

// Specific methods causing double registration
std::vector<HepMC3::ConstGenParticlePtr> HepMC3::GenEvent::beams()
std::vector<HepMC3::ConstGenParticlePtr> HepMC3::GenEvent::beams(const int)
HepMC3::ConstGenParticlePtr HepMC3::Attribute::particle()

// I/O classes with template complexity
HepMC3::ReaderGZ
HepMC3::WriterGZ
HepMC3::Reader
HepMC3::Writer

// Additional pair-related patterns
/.*std::pair.*std::shared_ptr.*/
/.*std::vector.*std::pair.*std::shared_ptr.*/
/.*std::map.*std::shared_ptr.*/

// Manual wrapper functions - don't let WrapIt wrap these
void add_manual_hepmc3_methods(jlcxx::Module&)
void* create_shared_particle(void*, int, int)
void* create_shared_vertex()
void add_shared_particle_in(void*, void*)
void add_shared_particle_out(void*, void*)
void add_shared_vertex_to_event(void*, void*)
void* create_particle_vector()
void delete_particle_vector(void*)
int particle_vector_size(void*)
void* particle_vector_at(void*, int)
void* create_reader_ascii(const char*)
bool reader_read_event(void*, void*)
void* create_writer_ascii(const char*)
void writer_write_event(void*, void*)