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