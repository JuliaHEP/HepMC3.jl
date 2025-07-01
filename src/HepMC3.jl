module HepMC3
using CxxWrap
using HepMC3_jll
using Libdl
import Base: length, getindex, iterate, close

# First load the wrapper module
const gendir = normpath(joinpath(@__DIR__, "../gen"))
const libpath = joinpath(gendir, "build/lib", "libHepMC3Wrap.$(Libdl.dlext)")

if !isfile(libpath)
    error("Wrapper library not found. Please build the package first.")
end

# Load the wrapper module first
@wrapmodule(()->libpath)

# Initialize CxxWrap
function __init__()
    @initcxx
end

# Include the generated exports if they exist
if isfile(joinpath(gendir, "jl/src/HepMC3-export.jl"))
    include(joinpath(gendir, "jl/src/HepMC3-export.jl"))
end

include("HepMC3Utils.jl")
# Define the abstract type for our wrapper
abstract type AbstractHepMC3Type end
# Replace all type definitions with these versions:

mutable struct FourVector <: AbstractHepMC3Type
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function FourVector(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

mutable struct GenEvent <: AbstractHepMC3Type
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function GenEvent(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

mutable struct GenParticle <: AbstractHepMC3Type
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function GenParticle(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

mutable struct GenVertex <: AbstractHepMC3Type
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function GenVertex(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

mutable struct GenCrossSection <: AbstractHepMC3Type
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function GenCrossSection(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

mutable struct GenPdfInfo <: AbstractHepMC3Type
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function GenPdfInfo(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

mutable struct GenHeavyIon <: AbstractHepMC3Type
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function GenHeavyIon(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

mutable struct ParticleVector
    ptr::Ptr{Cvoid}
    
    # Inner constructor
    function ParticleVector(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        new(ptr)
    end
end

# Unit enums
@enum MomentumUnit begin
    MEV = 0
    GEV = 1
end

@enum LengthUnit begin
    MM = 0
    CM = 1
end


abstract type AbstractAttribute end

mutable struct IntAttribute <: AbstractAttribute
    ptr::Ptr{Cvoid}
    
    function IntAttribute(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                x.ptr = C_NULL
            end
        end
        obj
    end
end

mutable struct DoubleAttribute <: AbstractAttribute
    ptr::Ptr{Cvoid}
    
    function DoubleAttribute(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                x.ptr = C_NULL
            end
        end
        obj
    end
end

mutable struct StringAttribute <: AbstractAttribute
    ptr::Ptr{Cvoid}
    
    function StringAttribute(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                x.ptr = C_NULL
            end
        end
        obj
    end
end

mutable struct BoolAttribute <: AbstractAttribute
    ptr::Ptr{Cvoid}
    
    function BoolAttribute(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                x.ptr = C_NULL
            end
        end
        obj
    end
end

# Integer attribute
function IntAttribute(value::Integer)
    ptr = ccall((:create_int_attribute, libpath), Ptr{Cvoid}, 
                (Int32,), Int32(value))
    IntAttribute(ptr)
end

# Double attribute
function DoubleAttribute(value::Real)  # Accept any Real number
    ptr = ccall((:create_double_attribute, libpath), Ptr{Cvoid}, 
                (Float64,), Float64(value))
    DoubleAttribute(ptr)
end

# Boolean attribute
function BoolAttribute(value::Bool)  # Keep this strict as Bool
    ptr = ccall((:create_bool_attribute, libpath), Ptr{Cvoid}, 
                (Bool,), value)
    BoolAttribute(ptr)
end

# String attribute
function StringAttribute(value::AbstractString)  # Accept any string type
    ptr = ccall((:create_string_attribute, libpath), Ptr{Cvoid}, 
                (Cstring,), Base.cconvert(Cstring, String(value)))
    StringAttribute(ptr)
end

# Constructor functions
"""
    FourVector(x::Float64, y::Float64, z::Float64, t::Float64)
Create a new four-vector with components (x,y,z,t).
"""
function FourVector(x::Float64, y::Float64, z::Float64, t::Float64)
    ptr = ccall((:create_fourvector, libpath), Ptr{Cvoid}, 
                (Float64, Float64, Float64, Float64), x, y, z, t)
    FourVector(ptr)
end

"""
    GenEvent(momentum_unit::MomentumUnit = GEV, length_unit::LengthUnit = MM)

Create a new event with specified momentum and length units.
"""
function GenEvent(momentum_unit::MomentumUnit = GEV, length_unit::LengthUnit = MM)
    ptr = ccall((:create_genevent_with_units, libpath), Ptr{Cvoid}, 
                (Int32, Int32), Int32(momentum_unit), Int32(length_unit))
    GenEvent(ptr)
end

# Convenience constructor for backward compatibility
function GenEvent(units::Int)
    if units == -1
        return GenEvent(GEV, MM)
    else
        return GenEvent(MomentumUnit(units), MM)
    end
end

"""
    GenParticle(momentum::FourVector, pdg_id::Int, status::Int)
Create a new particle with given momentum, PDG ID, and status code.
"""
function GenParticle(momentum::FourVector, pdg_id::Int, status::Int)
    ptr = ccall((:create_particle, libpath), Ptr{Cvoid},
                (Ptr{Cvoid}, Int32, Int32), momentum.ptr, pdg_id, status)
    GenParticle(ptr)
end

# Add accessor functions for FourVector
function px(v::FourVector)
    ccall((:fourvector_px, libpath), Float64, (Ptr{Cvoid},), v.ptr)
end

function py(v::FourVector)
    ccall((:fourvector_py, libpath), Float64, (Ptr{Cvoid},), v.ptr)
end

function pz(v::FourVector)
    ccall((:fourvector_pz, libpath), Float64, (Ptr{Cvoid},), v.ptr)
end

function e(v::FourVector)
    ccall((:fourvector_e, libpath), Float64, (Ptr{Cvoid},), v.ptr)
end

# Add accessor functions for GenParticle
"""
    pid(particle::GenParticle)
Get the PDG ID of a particle.
"""
function pid(particle::GenParticle)
    ccall((:particle_pid, libpath), Int32, (Ptr{Cvoid},), particle.ptr)
end

"""
    status(particle::GenParticle)
Get the status code of a particle.
"""
function status(particle::GenParticle)
    ccall((:particle_status, libpath), Int32, (Ptr{Cvoid},), particle.ptr)
end

"""
    momentum(particle::GenParticle)
Get the four-momentum of a particle.
"""
function momentum(particle::GenParticle)
    ptr = ccall((:particle_momentum, libpath), Ptr{Cvoid}, (Ptr{Cvoid},), particle.ptr)
    FourVector(ptr)
end

"""
    set_status!(particle::GenParticle, status::Int)
Set the status code of a particle.
"""
function set_status!(particle::GenParticle, status::Int)
    ccall((:set_particle_status, libpath), Cvoid,
          (Ptr{Cvoid}, Int32), particle.ptr, status)
end

"""
    set_momentum!(particle::GenParticle, momentum::FourVector)
Set the four-momentum of a particle.
"""
function set_momentum!(particle::GenParticle, momentum::FourVector)
    ccall((:set_particle_momentum, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), particle.ptr, momentum.ptr)
end

# Add new functions
"""
    GenVertex()
Create a new vertex.
"""
function GenVertex()
    ptr = ccall((:create_vertex, libpath), Ptr{Cvoid}, ())
    GenVertex(ptr)
end

"""
    add_particle_in!(vertex::GenVertex, particle::GenParticle)
Add an incoming particle to the vertex.
"""
function add_particle_in!(vertex::GenVertex, particle::GenParticle)
    ccall((:add_particle_in, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), vertex.ptr, particle.ptr)
end

"""
    add_particle_out!(vertex::GenVertex, particle::GenParticle)
Add an outgoing particle to the vertex.
"""
function add_particle_out!(vertex::GenVertex, particle::GenParticle)
    ccall((:add_particle_out, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), vertex.ptr, particle.ptr)
end

"""
    vertex_status(vertex::GenVertex)
Get the status code of a vertex.
"""
function vertex_status(vertex::GenVertex)
    ccall((:vertex_status, libpath), Int32, (Ptr{Cvoid},), vertex.ptr)
end

"""
    set_vertex_status!(vertex::GenVertex, status::Int)
Set the status code of a vertex.
"""
function set_vertex_status!(vertex::GenVertex, status::Int)
    ccall((:set_vertex_status, libpath), Cvoid,
          (Ptr{Cvoid}, Int32), vertex.ptr, status)
end

"""
    add_vertex!(event::GenEvent, vertex::GenVertex)
Add a vertex to an event.
"""
function add_vertex!(event::GenEvent, vertex::GenVertex)
    ccall((:add_vertex_to_event, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), event.ptr, vertex.ptr)
end

"""
    GenCrossSection()

Create a new cross-section object.
"""
function GenCrossSection()
    ptr = ccall((:create_cross_section, libpath), Ptr{Cvoid}, ())
    GenCrossSection(ptr)
end

"""
    set_cross_section!(xs::GenCrossSection, value::Float64, error::Float64)

Set the cross-section value and its error.
"""
function set_cross_section!(xs::GenCrossSection, value::Float64, error::Float64)
    ccall((:set_cross_section, libpath), Cvoid,
          (Ptr{Cvoid}, Float64, Float64), xs.ptr, value, error)
end

"""
    cross_section(xs::GenCrossSection)

Get the cross-section value.
"""
function cross_section(xs::GenCrossSection)
    ccall((:get_cross_section, libpath), Float64, (Ptr{Cvoid},), xs.ptr)
end

"""
    cross_section_error(xs::GenCrossSection)

Get the cross-section error.
"""
function cross_section_error(xs::GenCrossSection)
    ccall((:get_cross_section_error, libpath), Float64, (Ptr{Cvoid},), xs.ptr)
end

"""
    add_cross_section!(event::GenEvent, xs::GenCrossSection)

Add a cross-section to an event.
"""
function add_cross_section!(event::GenEvent, xs::GenCrossSection)
    ccall((:add_cross_section_to_event, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), event.ptr, xs.ptr)
end

"""
    set_alternative_cross_section!(xs::GenCrossSection, value::Float64, error::Float64, id::Int)

Set an alternative cross-section value with a specific ID.
Note: The error parameter is currently not used as HepMC3 doesn't support separate errors for alternative cross-sections.
"""
function set_alternative_cross_section!(xs::GenCrossSection, value::Float64, error::Float64, id::Int)
    ccall((:set_cross_section_alternative, libpath), Cvoid,
          (Ptr{Cvoid}, Float64, Float64, Int32), xs.ptr, value, error, id)
end

"""
    alternative_cross_section(xs::GenCrossSection, id::Int)

Get an alternative cross-section value by ID.
"""
function alternative_cross_section(xs::GenCrossSection, id::Int)
    ccall((:get_cross_section_alternative, libpath), Float64,
          (Ptr{Cvoid}, Int32), xs.ptr, id)
end

"""
    alternative_cross_section_error(xs::GenCrossSection, id::Int)
Get an alternative cross-section error by ID.
Note: This always returns 0.0 as HepMC3 doesn't support separate errors for alternative cross-sections.
"""
function alternative_cross_section_error(xs::GenCrossSection, id::Int)
    # ccall((:get_cross_section_error_alternative, libpath), Float64,
    #       (Ptr{Cvoid}, Int32), xs.ptr, id)
    @info "HepMC3 doesn't support separate errors for alternative cross-sections."
    return 0.0
end

"""
    GenPdfInfo()

Create a new PDF information object.
"""
function GenPdfInfo()
    ptr = ccall((:create_pdf_info, libpath), Ptr{Cvoid}, ())
    GenPdfInfo(ptr)
end

"""
    set_pdf_info!(pdf::GenPdfInfo, parton_id1::Int, parton_id2::Int, x1::Float64, x2::Float64,
                 scale::Float64, xf1::Float64, xf2::Float64, pdf_id1::Int, pdf_id2::Int)

Set all PDF information at once.
"""
function set_pdf_info!(pdf::GenPdfInfo, parton_id1::Int, parton_id2::Int, x1::Float64, x2::Float64,
                      scale::Float64, xf1::Float64, xf2::Float64, pdf_id1::Int, pdf_id2::Int)
    ccall((:set_pdf_info, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Int32, Float64, Float64, Float64, Float64, Float64, Int32, Int32),
          pdf.ptr, parton_id1, parton_id2, x1, x2, scale, xf1, xf2, pdf_id1, pdf_id2)
end

"""
    parton_id1(pdf::GenPdfInfo)

Get the PDG ID of the first parton.
"""
function parton_id1(pdf::GenPdfInfo)
    ccall((:get_parton_id1, libpath), Int32, (Ptr{Cvoid},), pdf.ptr)
end

"""
    parton_id2(pdf::GenPdfInfo)

Get the PDG ID of the second parton.
"""
function parton_id2(pdf::GenPdfInfo)
    ccall((:get_parton_id2, libpath), Int32, (Ptr{Cvoid},), pdf.ptr)
end

"""
    x1(pdf::GenPdfInfo)

Get the momentum fraction of the first parton.
"""
function x1(pdf::GenPdfInfo)
    ccall((:get_x1, libpath), Float64, (Ptr{Cvoid},), pdf.ptr)
end

"""
    x2(pdf::GenPdfInfo)

Get the momentum fraction of the second parton.
"""
function x2(pdf::GenPdfInfo)
    ccall((:get_x2, libpath), Float64, (Ptr{Cvoid},), pdf.ptr)
end

"""
    scale(pdf::GenPdfInfo)

Get the scale at which PDFs are evaluated.
"""
function scale(pdf::GenPdfInfo)
    ccall((:get_scale, libpath), Float64, (Ptr{Cvoid},), pdf.ptr)
end

"""
    xf1(pdf::GenPdfInfo)

Get the PDF value for the first parton.
"""
function xf1(pdf::GenPdfInfo)
    ccall((:get_xf1, libpath), Float64, (Ptr{Cvoid},), pdf.ptr)
end

"""
    xf2(pdf::GenPdfInfo)

Get the PDF value for the second parton.
"""
function xf2(pdf::GenPdfInfo)
    ccall((:get_xf2, libpath), Float64, (Ptr{Cvoid},), pdf.ptr)
end

"""
    pdf_id1(pdf::GenPdfInfo)

Get the PDF set ID for the first parton.
"""
function pdf_id1(pdf::GenPdfInfo)
    ccall((:get_pdf_id1, libpath), Int32, (Ptr{Cvoid},), pdf.ptr)
end

"""
    pdf_id2(pdf::GenPdfInfo)

Get the PDF set ID for the second parton.
"""
function pdf_id2(pdf::GenPdfInfo)
    ccall((:get_pdf_id2, libpath), Int32, (Ptr{Cvoid},), pdf.ptr)
end

"""
    add_pdf_info!(event::GenEvent, pdf::GenPdfInfo)

Add PDF information to an event.
"""
function add_pdf_info!(event::GenEvent, pdf::GenPdfInfo)
    ccall((:add_pdf_info_to_event, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), event.ptr, pdf.ptr)
end

"""
    GenHeavyIon()

Create a new Heavy Ion information object.
"""
function GenHeavyIon()
    ptr = ccall((:create_heavy_ion, libpath), Ptr{Cvoid}, ())
    GenHeavyIon(ptr)
end

"""
    set_heavy_ion_basic!(hi::GenHeavyIon, ncoll_hard::Int, npart_proj::Int, npart_targ::Int, 
                        ncoll::Int, n_n_wounded::Int, nwounded_n::Int, nwounded_nwounded::Int,
                        impact_param::Float64, event_plane_angle::Float64)

Set basic heavy ion collision properties.
"""
function set_heavy_ion_basic!(hi::GenHeavyIon, ncoll_hard::Int, npart_proj::Int, npart_targ::Int, 
                            ncoll::Int, n_n_wounded::Int, nwounded_n::Int, nwounded_nwounded::Int,
                            impact_param::Float64, event_plane_angle::Float64)
    ccall((:set_heavy_ion_basic, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Int32, Int32, Int32, Int32, Int32, Int32, Float64, Float64),
          hi.ptr, ncoll_hard, npart_proj, npart_targ, ncoll, n_n_wounded, nwounded_n, 
          nwounded_nwounded, impact_param, event_plane_angle)
end

"""
    set_heavy_ion_nuclear!(hi::GenHeavyIon, nspec_proj_n::Int, nspec_targ_n::Int, 
                          nspec_proj_p::Int, nspec_targ_p::Int)

Set nuclear properties for heavy ion collision.
"""
function set_heavy_ion_nuclear!(hi::GenHeavyIon, nspec_proj_n::Int, nspec_targ_n::Int, 
                              nspec_proj_p::Int, nspec_targ_p::Int)
    ccall((:set_heavy_ion_nuclear, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Int32, Int32, Int32),
          hi.ptr, nspec_proj_n, nspec_targ_n, nspec_proj_p, nspec_targ_p)
end

"""
    set_heavy_ion_centrality!(hi::GenHeavyIon, sigma_inel_nn::Float64, centrality::Float64, 
                            user_cent_estimate::Float64)

Set centrality-related properties for heavy ion collision.
"""
function set_heavy_ion_centrality!(hi::GenHeavyIon, sigma_inel_nn::Float64, centrality::Float64, 
                                 user_cent_estimate::Float64)
    ccall((:set_heavy_ion_centrality, libpath), Cvoid,
          (Ptr{Cvoid}, Float64, Float64, Float64),
          hi.ptr, sigma_inel_nn, centrality, user_cent_estimate)
end

"""
    set_participant_plane_angle!(hi::GenHeavyIon, order::Int, angle::Float64)

Set participant plane angle for a specific order.
"""
function set_participant_plane_angle!(hi::GenHeavyIon, order::Int, angle::Float64)
    ccall((:set_heavy_ion_participant_plane_angle, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Float64),
          hi.ptr, order, angle)
end

"""
    set_eccentricity!(hi::GenHeavyIon, order::Int, ecc::Float64)

Set eccentricity for a specific order.
"""
function set_eccentricity!(hi::GenHeavyIon, order::Int, ecc::Float64)
    ccall((:set_heavy_ion_eccentricity, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Float64),
          hi.ptr, order, ecc)
end

# Getter functions
ncoll_hard(hi::GenHeavyIon) = ccall((:get_ncoll_hard, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
npart_proj(hi::GenHeavyIon) = ccall((:get_npart_proj, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
npart_targ(hi::GenHeavyIon) = ccall((:get_npart_targ, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
ncoll(hi::GenHeavyIon) = ccall((:get_ncoll, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
n_n_wounded(hi::GenHeavyIon) = ccall((:get_n_n_wounded, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
nwounded_n(hi::GenHeavyIon) = ccall((:get_nwounded_n, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
nwounded_nwounded(hi::GenHeavyIon) = ccall((:get_nwounded_nwounded, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
impact_parameter(hi::GenHeavyIon) = ccall((:get_impact_parameter, libpath), Float64, (Ptr{Cvoid},), hi.ptr)
event_plane_angle(hi::GenHeavyIon) = ccall((:get_event_plane_angle, libpath), Float64, (Ptr{Cvoid},), hi.ptr)
nspec_proj_n(hi::GenHeavyIon) = ccall((:get_nspec_proj_n, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
nspec_targ_n(hi::GenHeavyIon) = ccall((:get_nspec_targ_n, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
nspec_proj_p(hi::GenHeavyIon) = ccall((:get_nspec_proj_p, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
nspec_targ_p(hi::GenHeavyIon) = ccall((:get_nspec_targ_p, libpath), Int32, (Ptr{Cvoid},), hi.ptr)
sigma_inel_nn(hi::GenHeavyIon) = ccall((:get_sigma_inel_nn, libpath), Float64, (Ptr{Cvoid},), hi.ptr)
centrality(hi::GenHeavyIon) = ccall((:get_centrality, libpath), Float64, (Ptr{Cvoid},), hi.ptr)
user_cent_estimate(hi::GenHeavyIon) = ccall((:get_user_cent_estimate, libpath), Float64, (Ptr{Cvoid},), hi.ptr)

function participant_plane_angle(hi::GenHeavyIon, order::Int)
    ccall((:get_participant_plane_angle, libpath), Float64, (Ptr{Cvoid}, Int32), hi.ptr, order)
end

function eccentricity(hi::GenHeavyIon, order::Int)
    ccall((:get_eccentricity, libpath), Float64, (Ptr{Cvoid}, Int32), hi.ptr, order)
end

"""
    add_heavy_ion!(event::GenEvent, hi::GenHeavyIon)

Add heavy ion information to an event.
"""
function add_heavy_ion!(event::GenEvent, hi::GenHeavyIon)
    ccall((:add_heavy_ion_to_event, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), event.ptr, hi.ptr)
end

"""
    ParticleVector()

Create a new empty vector of particles.
"""
function ParticleVector()
    ptr = ccall((:create_particle_vector, libpath), Ptr{Cvoid}, ())
    finalizer(delete_particle_vector, ParticleVector(ptr))
end

function delete_particle_vector(pv::ParticleVector)
    if pv.ptr != C_NULL
        ccall((:delete_particle_vector, libpath), Cvoid, (Ptr{Cvoid},), pv.ptr)
        pv.ptr = C_NULL
    end
end

# Event traversal methods
particles_size(evt::GenEvent) = ccall((:event_particles_size, libpath), Int32, (Ptr{Cvoid},), evt.ptr)
vertices_size(evt::GenEvent) = ccall((:event_vertices_size, libpath), Int32, (Ptr{Cvoid},), evt.ptr)

function particle_at(evt::GenEvent, index::Int)
    ptr = ccall((:event_particle_at, libpath), Ptr{Cvoid}, (Ptr{Cvoid}, Int32), evt.ptr, index-1)
    ptr == C_NULL ? nothing : GenParticle(ptr)
end

function vertex_at(evt::GenEvent, index::Int)
    ptr = ccall((:event_vertex_at, libpath), Ptr{Cvoid}, (Ptr{Cvoid}, Int32), evt.ptr, index-1)
    ptr == C_NULL ? nothing : GenVertex(ptr)
end

# Particle search and filtering
function find_particles_by_pid(evt::GenEvent, pid::Int)
    result = ParticleVector()
    ccall((:find_particles_by_pid, libpath), Cvoid, 
          (Ptr{Cvoid}, Ptr{Cvoid}, Int32), evt.ptr, result.ptr, pid)
    result
end

# Vertex traversal
function particles_in(vertex::GenVertex)
    result = ParticleVector()
    ccall((:vertex_particles_in, libpath), Ptr{Cvoid}, 
          (Ptr{Cvoid}, Ptr{Cvoid}), vertex.ptr, result.ptr)
    result
end

function particles_out(vertex::GenVertex)
    result = ParticleVector()
    ccall((:vertex_particles_out, libpath), Ptr{Cvoid}, 
          (Ptr{Cvoid}, Ptr{Cvoid}), vertex.ptr, result.ptr)
    result
end

function production_vertex(particle::GenParticle)
    ptr = ccall((:particle_production_vertex, libpath), Ptr{Cvoid}, (Ptr{Cvoid},), particle.ptr)
    ptr == C_NULL ? nothing : GenVertex(ptr)
end

function end_vertex(particle::GenParticle)
    ptr = ccall((:particle_end_vertex, libpath), Ptr{Cvoid}, (Ptr{Cvoid},), particle.ptr)
    ptr == C_NULL ? nothing : GenVertex(ptr)
end

function parents(particle::GenParticle)
    result = ParticleVector()
    ccall((:particle_parents, libpath), Ptr{Cvoid}, 
          (Ptr{Cvoid}, Ptr{Cvoid}), particle.ptr, result.ptr)
    result
end

function children(particle::GenParticle)
    result = ParticleVector()
    ccall((:particle_children, libpath), Ptr{Cvoid}, 
          (Ptr{Cvoid}, Ptr{Cvoid}), particle.ptr, result.ptr)
    result
end

# Event statistics
particles_with_status(evt::GenEvent, status::Int) = 
    ccall((:event_particles_with_status, libpath), Int32, (Ptr{Cvoid}, Int32), evt.ptr, status)

function total_momentum(evt::GenEvent)
    e = ccall((:event_total_momentum, libpath), Float64, (Ptr{Cvoid}, Int32), evt.ptr, 0)
    px = ccall((:event_total_momentum, libpath), Float64, (Ptr{Cvoid}, Int32), evt.ptr, 1)
    py = ccall((:event_total_momentum, libpath), Float64, (Ptr{Cvoid}, Int32), evt.ptr, 2)
    pz = ccall((:event_total_momentum, libpath), Float64, (Ptr{Cvoid}, Int32), evt.ptr, 3)
    FourVector(px, py, pz, e)
end

is_valid(evt::GenEvent) = ccall((:event_is_valid, libpath), Bool, (Ptr{Cvoid},), evt.ptr)


# Add length method for ParticleVector
Base.length(pv::ParticleVector) = ccall((:particle_vector_size, libpath), Int32, (Ptr{Cvoid},), pv.ptr)

# Add indexing for ParticleVector
function Base.getindex(pv::ParticleVector, i::Int)
    ptr = ccall((:particle_vector_at, libpath), Ptr{Cvoid}, 
                (Ptr{Cvoid}, Int32), pv.ptr, i-1)
    ptr == C_NULL ? nothing : GenParticle(ptr)
end

# Add iteration interface for ParticleVector
Base.iterate(pv::ParticleVector, state=1) = state > length(pv) ? nothing : (pv[state], state + 1)


"""
    convert_momentum!(v::FourVector, from_unit::MomentumUnit, to_unit::MomentumUnit)

Convert a FourVector from one momentum unit to another.
"""
function convert_momentum!(v::FourVector, from_unit::MomentumUnit, to_unit::MomentumUnit)
    ccall((:convert_momentum, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Int32), v.ptr, Int32(from_unit), Int32(to_unit))
end

"""
    convert_length!(v::FourVector, from_unit::LengthUnit, to_unit::LengthUnit)

Convert a FourVector from one length unit to another.
"""
function convert_length!(v::FourVector, from_unit::LengthUnit, to_unit::LengthUnit)
    ccall((:convert_length, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Int32), v.ptr, Int32(from_unit), Int32(to_unit))
end

"""
    set_units!(evt::GenEvent, momentum_unit::MomentumUnit, length_unit::LengthUnit)

Convert all event quantities to new units.
"""
function set_units!(evt::GenEvent, momentum_unit::MomentumUnit, length_unit::LengthUnit)
    ccall((:convert_event_units, libpath), Cvoid,
          (Ptr{Cvoid}, Int32, Int32), evt.ptr, Int32(momentum_unit), Int32(length_unit))
end

"""
    momentum_unit(evt::GenEvent)
Get the momentum unit used in the event.
"""
function momentum_unit(evt::GenEvent)
    unit = ccall((:get_momentum_unit, libpath), Int32, (Ptr{Cvoid},), evt.ptr)
    # Add validation for the returned value
    if unit == 0
        return MEV
    elseif unit == 1
        return GEV
    else
        error("Unknown momentum unit value: $unit")
    end
end

"""
    length_unit(evt::GenEvent)

Get the length unit used in the event.
"""
function length_unit(evt::GenEvent)
    unit = ccall((:get_length_unit, libpath), Int32, (Ptr{Cvoid},), evt.ptr)
    # Add validation for the returned value
    if unit == 0
        return MM
    elseif unit == 1
        return CM
    else
        error("Unknown length unit value: $unit")
    end
end

"""
    unit_name(unit::Union{MomentumUnit,LengthUnit})

Get the string representation of a unit.
"""
function unit_name(unit::MomentumUnit)
    if unit == MEV
        return "MEV"
    else
        return "GEV"
    end
end

function unit_name(unit::LengthUnit)
    if unit == MM
        return "MM"
    else
        return "CM"
    end
end


# Add value accessor methods
function value(attr::IntAttribute)
    ccall((:get_int_attribute_value, libpath), Int32, (Ptr{Cvoid},), attr.ptr)
end

function value(attr::DoubleAttribute)
    ccall((:get_double_attribute_value, libpath), Float64, (Ptr{Cvoid},), attr.ptr)
end

function value(attr::StringAttribute)
    ptr = ccall((:get_string_attribute_value, libpath), Cstring, (Ptr{Cvoid},), attr.ptr)
    unsafe_string(ptr)
end

function value(attr::BoolAttribute)
    ccall((:get_bool_attribute_value, libpath), Bool, (Ptr{Cvoid},), attr.ptr)
end

# Attribute handling for events
function add_attribute!(event::GenEvent, name::String, attr::AbstractAttribute)
    ccall((:add_attribute_to_event, libpath), Cvoid,
          (Ptr{Cvoid}, Cstring, Ptr{Cvoid}), 
          event.ptr, name, attr.ptr)
end

function get_attribute(event::GenEvent, name::String)
    ptr = ccall((:get_attribute_from_event, libpath), Ptr{Cvoid},
                (Ptr{Cvoid}, Cstring), event.ptr, name)
    # Need to determine type and wrap appropriately
    # This might need additional C++ support to get the attribute type
end

function has_attribute(event::GenEvent, name::String)
    ccall((:has_attribute, libpath), Bool,
          (Ptr{Cvoid}, Cstring), event.ptr, name)
end

function remove_attribute!(event::GenEvent, name::String)
    ccall((:remove_attribute, libpath), Cvoid,
          (Ptr{Cvoid}, Cstring), event.ptr, name)
end







# Abstract types for I/O
abstract type AbstractReader end
abstract type AbstractWriter end

# Concrete types
mutable struct Reader <: AbstractReader
    ptr::Ptr{Cvoid}
    
    function Reader(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                # Add cleanup
                x.ptr = C_NULL
            end
        end
        obj
    end
end

mutable struct Writer <: AbstractWriter
    ptr::Ptr{Cvoid}
    
    function Writer(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                # Add cleanup
                x.ptr = C_NULL
            end
        end
        obj
    end
end

# ASCII specific types
mutable struct ReaderAscii <: AbstractReader
    ptr::Ptr{Cvoid}
    
    function ReaderAscii(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                close(x)
                x.ptr = C_NULL
            end
        end
        obj
    end
end

mutable struct WriterAscii <: AbstractWriter
    ptr::Ptr{Cvoid}
    
    function WriterAscii(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                close(x)
                x.ptr = C_NULL
            end
        end
        obj
    end
end

# Constructor functions
function ReaderAscii(filename::AbstractString)
    ptr = ccall((:create_reader_ascii, libpath), Ptr{Cvoid}, 
                (Cstring,), filename)
    ReaderAscii(ptr)
end

function WriterAscii(filename::AbstractString)
    ptr = ccall((:create_writer_ascii, libpath), Ptr{Cvoid}, 
                (Cstring,), filename)
    if ptr == C_NULL
        error("Failed to create WriterAscii for file: $filename")
    end
    WriterAscii(ptr)
end


# Common interface functions
function read_event!(reader::AbstractReader, event::GenEvent)
    ccall((:reader_read_event, libpath), Bool,
          (Ptr{Cvoid}, Ptr{Cvoid}), reader.ptr, event.ptr)
end

function write_event(writer::AbstractWriter, event::GenEvent)
    @debug "Writing event" writer_ptr=writer.ptr event_ptr=event.ptr
    ccall((:writer_write_event, libpath), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), writer.ptr, event.ptr)
end

function failed(io::Union{AbstractReader, AbstractWriter})
    @debug "Checking failed status" ptr=io.ptr
    ccall((:writer_failed, libpath), Bool, (Ptr{Cvoid},), io.ptr)
end

"""
    close(io::Union{AbstractReader, AbstractWriter})
Close the I/O stream and clean up resources.
"""
function Base.close(io::Union{AbstractReader, AbstractWriter})
    if io.ptr != C_NULL
        if io isa AbstractReader
            ccall((:reader_close, libpath), Cvoid, (Ptr{Cvoid},), io.ptr)
        else
            ccall((:writer_close, libpath), Cvoid, (Ptr{Cvoid},), io.ptr)
        end
        io.ptr = C_NULL
    end
end

@enum Compression begin
    PLAINTEXT = -1  # This matches bxz::Compression::plaintext
    Z = 0          # This matches bxz::Compression::z
    LZMA = 1       # This matches bxz::Compression::lzma
    BZ2 = 2        # This matches bxz::Compression::bz2
    ZSTD = 3       # This matches bxz::Compression::zstd
end

# Concrete types for compressed I/O
mutable struct ReaderGZ <: AbstractReader
    ptr::Ptr{Cvoid}
    
    function ReaderGZ(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                close(x)
                x.ptr = C_NULL
            end
        end
        obj
    end
end

mutable struct WriterGZ <: AbstractWriter
    ptr::Ptr{Cvoid}
    
    function WriterGZ(ptr::Ptr{Cvoid})
        ptr == C_NULL && return nothing
        obj = new(ptr)
        finalizer(obj) do x
            if x.ptr != C_NULL
                close(x)
                x.ptr = C_NULL
            end
        end
        obj
    end
end

"""
    ReaderGZ(filename::AbstractString, compression::Compression = Z)

Create a compressed reader for the given file with specified compression type.
"""
function ReaderGZ(filename::AbstractString, compression::Compression = Z)
    ptr = ccall((:create_reader_gz, libpath), Ptr{Cvoid}, 
                (Cstring, Int32), filename, Int32(compression))
    if ptr == C_NULL
        error("Failed to create compressed reader for file: $filename")
    end
    ReaderGZ(ptr)
end

"""
    WriterGZ(filename::AbstractString, compression::Compression = Z)

Create a compressed writer for the given file with specified compression type.
"""
function WriterGZ(filename::AbstractString, compression::Compression = Z)
    ptr = ccall((:create_writer_gz, libpath), Ptr{Cvoid}, 
                (Cstring, Int32), filename, Int32(compression))
    if ptr == C_NULL
        error("Failed to create compressed writer for file: $filename")
    end
    WriterGZ(ptr)
end

"""
    detect_compression(filename::AbstractString)

Detect the compression type of a file.
"""
function detect_compression(filename::AbstractString)
    compression = ccall((:detect_compression, libpath), Int32, 
                       (Cstring,), filename)
    return Compression(compression)
end

"""
    auto_reader(filename::AbstractString)

Create an appropriate reader based on the file's compression type.
"""
function auto_reader(filename::AbstractString)
    compression = detect_compression(filename)
    if compression == PLAINTEXT
        return ReaderAscii(filename)
    else
        return ReaderGZ(filename, compression)
    end
end
export Compression, PLAINTEXT, Z, LZMA, BZ2, ZSTD
export ReaderGZ, WriterGZ
export detect_compression, auto_reader











# Add to your exports section
export AbstractReader, AbstractWriter
export Reader, Writer
export ReaderAscii, WriterAscii
export read_event!, write_event
export failed, close


# Add to exports
export MomentumUnit, LengthUnit, MEV, GEV, MM, CM
export convert_momentum!, convert_length!, set_units!
export momentum_unit, length_unit, unit_name


# Add to exports
export particles_size, vertices_size, particle_at, vertex_at
export find_particles_by_pid
export particles_in, particles_out
export production_vertex, end_vertex
export parents, children
export particles_with_status, total_momentum, is_valid

# Add to your exports
export GenHeavyIon
export set_heavy_ion_basic!, set_heavy_ion_nuclear!, set_heavy_ion_centrality!
export set_participant_plane_angle!, set_eccentricity!
export ncoll_hard, npart_proj, npart_targ, ncoll
export n_n_wounded, nwounded_n, nwounded_nwounded
export impact_parameter, event_plane_angle
export nspec_proj_n, nspec_targ_n, nspec_proj_p, nspec_targ_p
export sigma_inel_nn, centrality, user_cent_estimate
export participant_plane_angle, eccentricity
export add_heavy_ion!
# Add exports
export GenPdfInfo
export set_pdf_info!
export parton_id1, parton_id2
export x1, x2, scale
export xf1, xf2
export pdf_id1, pdf_id2
export add_pdf_info!


# Add exports
export GenCrossSection
export set_cross_section!, cross_section, cross_section_error
export add_cross_section!
export set_alternative_cross_section!, alternative_cross_section, alternative_cross_section_error


# Add exports
export GenVertex
export add_particle_in!, add_particle_out!
export vertex_status, set_vertex_status!
export add_vertex!


# Export the interface
export FourVector, GenEvent, GenVertex, GenParticle
export px, py, pz, e
export pid, status, momentum, set_status!, set_momentum!
export length, getindex, iterate

# Add to exports
export AbstractAttribute
export IntAttribute, DoubleAttribute, StringAttribute, BoolAttribute
export add_attribute!, get_attribute, has_attribute, remove_attribute!
export value
end # module