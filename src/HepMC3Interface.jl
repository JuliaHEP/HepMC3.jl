# Create convenient aliases for the CxxWrap-generated types
const FourVector = var"HepMC3!FourVector"
const GenEvent = var"HepMC3!GenEvent"  
const GenParticle = var"HepMC3!GenParticle"
const GenVertex = var"HepMC3!GenVertex"
const GenEventData = var"HepMC3!GenEventData"
const GenParticleData = var"HepMC3!GenParticleData"
const GenVertexData = var"HepMC3!GenVertexData"
const Attribute = var"HepMC3!Attribute"
const IntAttribute = var"HepMC3!IntAttribute"
const DoubleAttribute = var"HepMC3!DoubleAttribute"
const StringAttribute = var"HepMC3!StringAttribute"
const GenCrossSection = var"HepMC3!GenCrossSection"
const GenPdfInfo = var"HepMC3!GenPdfInfo"
const GenHeavyIon = var"HepMC3!GenHeavyIon"

# Units constants
const MEV = var"HepMC3!Units!MEV"
const GEV = var"HepMC3!Units!GEV"
const MM = var"HepMC3!Units!MM"
const CM = var"HepMC3!Units!CM"

# Export the convenient names
export FourVector, GenEvent, GenParticle, GenVertex
export GenEventData, GenParticleData, GenVertexData
export Attribute, IntAttribute, DoubleAttribute, StringAttribute
export GenCrossSection, GenPdfInfo, GenHeavyIon
export MEV, GEV, MM, CM

# High-level interface functions for easier use
export create_event, create_particle, create_vertex

"""
    create_event(event_number=1)
Create a new HepMC3 GenEvent with the specified event number.
"""
function create_event(event_number::Int = 1)
    event = GenEvent()
    set_event_number(event, event_number)
    return event
end

"""
    create_particle(px, py, pz, e, pdg_id, status)
Create a new GenParticle with the given momentum and properties.
"""
function create_particle(px::Float64, py::Float64, pz::Float64, e::Float64, 
                        pdg_id::Int, status::Int)
    momentum = FourVector(px, py, pz, e)
    return GenParticle(momentum, pdg_id, status)
end

"""
    create_vertex()
Create a new GenVertex.
"""
function create_vertex()
    return GenVertex()
end

# Pretty printing for HepMC3 objects
function Base.show(io::IO, p::GenParticle)
    mom = momentum(p)
    print(io, "GenParticle(PDG=$(pdg_id(p)), status=$(status(p)), p=($(px(mom)), $(py(mom)), $(pz(mom)), $(e(mom))))")
end

function Base.show(io::IO, event::GenEvent)
    print(io, "GenEvent(number=$(event_number(event)))")
end

# ============================================================================
# COMMENTED OUT: These functions conflict with C++ function names
# ============================================================================

# REMOVE from exports - these conflict with C++ functions:
# export create_shared_particle, create_shared_vertex, add_particle_to_vertex_in, add_particle_to_vertex_out, add_vertex_to_event

# CONFLICT: This shadows HepMC3.create_shared_particle (C++ function)
# """
#     create_shared_particle(px, py, pz, e, pdg_id, status)
# Create a new shared_ptr GenParticle (for use with vertices).
# """
# function create_shared_particle(px::Float64, py::Float64, pz::Float64, e::Float64, 
#                                pdg_id::Int, status::Int)
#     momentum = FourVector(px, py, pz, e)
#     momentum_ptr = momentum.cpp_object
#     return HepMC3.create_shared_particle(momentum_ptr, pdg_id, status)
# end

# CONFLICT: This shadows HepMC3.create_shared_vertex (C++ function) - ALREADY COMMENTED ✅
# """
#     create_shared_vertex()
# Create a new shared_ptr GenVertex.
# """
# function create_shared_vertex()
#     return HepMC3.create_shared_vertex()
# end

# CONFLICT: This shadows HepMC3.add_shared_particle_in (C++ function)
# """
#     add_particle_to_vertex_in(vertex_ptr, particle_ptr)
# Add a particle as incoming to a vertex (using shared_ptr).
# """
# function add_particle_to_vertex_in(vertex_ptr, particle_ptr)
#     return HepMC3.add_shared_particle_in(vertex_ptr, particle_ptr)
# end

# CONFLICT: This shadows HepMC3.add_shared_particle_out (C++ function)
# """
#     add_particle_to_vertex_out(vertex_ptr, particle_ptr) 
# Add a particle as outgoing from a vertex (using shared_ptr).
# """
# function add_particle_to_vertex_out(vertex_ptr, particle_ptr)
#     return HepMC3.add_shared_particle_out(vertex_ptr, particle_ptr)
# end

# CONFLICT: This shadows HepMC3.add_shared_vertex_to_event (C++ function)
# """
#     add_vertex_to_event(event, vertex_ptr)
# Add a vertex to an event (using shared_ptr).
# """
# function add_vertex_to_event(event, vertex_ptr)
#     event_ptr = event.cpp_object
#     return HepMC3.add_shared_vertex_to_event(event_ptr, vertex_ptr)
# end

# ============================================================================
# ALTERNATIVE: Use different names if you want convenience functions
# ============================================================================

export make_shared_particle, make_shared_vertex, connect_particle_in, connect_particle_out, attach_vertex_to_event

"""
    make_shared_particle(px, py, pz, e, pdg_id, status)
Create a new shared_ptr GenParticle (for use with vertices).
Uses different name to avoid conflict with C++ function.
"""
function make_shared_particle(px::Float64, py::Float64, pz::Float64, e::Float64, 
                             pdg_id::Int, status::Int)
    momentum = FourVector(px, py, pz, e)
    momentum_ptr = momentum.cpp_object
    return HepMC3.create_shared_particle(momentum_ptr, pdg_id, status)
end

"""
    make_shared_vertex()
Create a new shared_ptr GenVertex.
Uses different name to avoid conflict with C++ function.
"""
function make_shared_vertex()
    return HepMC3.create_shared_vertex()
end

"""
    connect_particle_in(vertex_ptr, particle_ptr)
Add a particle as incoming to a vertex (using shared_ptr).
"""
function connect_particle_in(vertex_ptr, particle_ptr)
    return HepMC3.add_shared_particle_in(vertex_ptr, particle_ptr)
end

"""
    connect_particle_out(vertex_ptr, particle_ptr) 
Add a particle as outgoing from a vertex (using shared_ptr).
"""
function connect_particle_out(vertex_ptr, particle_ptr)
    return HepMC3.add_shared_particle_out(vertex_ptr, particle_ptr)
end

"""
    attach_vertex_to_event(event, vertex_ptr)
Add a vertex to an event (using shared_ptr).
"""
function attach_vertex_to_event(event, vertex_ptr)
    event_ptr = event.cpp_object
    return HepMC3.add_shared_vertex_to_event(event_ptr, vertex_ptr)
end





# Add to HepMC3Interface.jl

export set_vertex_status!, shift_position!, add_pdf_info!, add_cross_section!, add_heavy_ion!
export create_particle_attribute, add_particle_attribute!, remove_particle!

"""
    set_vertex_status!(vertex_ptr, status)
Set the status of a vertex.
"""
function set_vertex_status!(vertex_ptr, status::Int)
    HepMC3.set_vertex_status(vertex_ptr, status)
end

"""
    shift_position!(event, dx, dy, dz, dt)
Shift the position of all vertices in the event.
"""
function shift_position!(event, dx::Float64, dy::Float64, dz::Float64, dt::Float64)
    shift_vector = FourVector(dx, dy, dz, dt)
    HepMC3.shift_event_position(event.cpp_object, shift_vector.cpp_object)
end

"""
    add_pdf_info!(event, id1, id2, x1, x2, q, pdf1, pdf2, pdf_set_id1, pdf_set_id2)
Add PDF information to the event.
"""
function add_pdf_info!(event, id1::Int, id2::Int, x1::Float64, x2::Float64, q::Float64, 
                      pdf1::Float64, pdf2::Float64, pdf_set_id1::Int, pdf_set_id2::Int)
    pdf_info = HepMC3.create_gen_pdf_info()
    HepMC3.set_pdf_info(pdf_info, id1, id2, x1, x2, q, pdf1, pdf2, pdf_set_id1, pdf_set_id2)
    HepMC3.add_pdf_info_attribute(event.cpp_object, pdf_info)
    return pdf_info
end

"""
    add_cross_section!(event, xs, xs_err)
Add cross section information to the event.
"""
function add_cross_section!(event, xs::Float64, xs_err::Float64)
    cross_section = HepMC3.create_gen_cross_section()
    HepMC3.set_cross_section(cross_section, xs, xs_err)
    HepMC3.add_cross_section_attribute(event.cpp_object, cross_section)
    return cross_section
end

"""
    add_heavy_ion!(event, nh, np, nt, nc, ns, nsp, nn, nw, nwn, impact_b, plane_angle, eccentricity, sigma_nn)
Add heavy ion collision information to the event.
"""
function add_heavy_ion!(event, nh::Int, np::Int, nt::Int, nc::Int, ns::Int, nsp::Int, nn::Int, 
                       nw::Int, nwn::Int, impact_b::Float64, plane_angle::Float64, 
                       eccentricity::Float64, sigma_nn::Float64)
    heavy_ion = HepMC3.create_gen_heavy_ion()
    HepMC3.set_heavy_ion_info(heavy_ion, nh, np, nt, nc, ns, nsp, nn, nw, nwn, 
                              impact_b, plane_angle, eccentricity, sigma_nn)
    HepMC3.add_heavy_ion_attribute(event.cpp_object, heavy_ion)
    return heavy_ion
end

"""
    create_particle_attribute(value)
Create an attribute for a particle or vertex.
"""
function create_particle_attribute(value::Int)
    return HepMC3.create_int_attribute(value)
end

function create_particle_attribute(value::Float64)
    return HepMC3.create_double_attribute(value)
end

function create_particle_attribute(value::String)
    return HepMC3.create_string_attribute(value)
end

"""
    add_particle_attribute!(particle_ptr, name, value)
Add an attribute to a particle.
"""
function add_particle_attribute!(particle_ptr, name::String, value)
    attr = create_particle_attribute(value)
    HepMC3.add_particle_attribute(particle_ptr, name, attr)
    return attr
end

"""
    remove_particle!(event, particle_ptr)
Remove a particle from the event.
"""
function remove_particle!(event, particle_ptr)
    HepMC3.remove_particle_from_event(event.cpp_object, particle_ptr)
end