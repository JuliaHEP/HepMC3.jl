using CodecZstd

# Exports for C++ functions 
export get_generated_mass, is_generated_mass_set, set_generated_mass, unset_generated_mass
export set_vertex_position, get_vertex_position
export get_vertex_id, get_vertex_x, get_vertex_y, get_vertex_z, get_vertex_t
export vertices_equal

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
    return create_shared_particle(momentum_ptr, pdg_id, status)
end

"""
    make_shared_vertex()
Create a new shared_ptr GenVertex.
Uses different name to avoid conflict with C++ function.
"""
function make_shared_vertex()
    return create_shared_vertex()
end

"""
    connect_particle_in(vertex_ptr, particle_ptr)
Add a particle as incoming to a vertex (using shared_ptr).
"""
function connect_particle_in(vertex_ptr, particle_ptr)
    return add_shared_particle_in(vertex_ptr, particle_ptr)
end

"""
    connect_particle_out(vertex_ptr, particle_ptr) 
Add a particle as outgoing from a vertex (using shared_ptr).
"""
function connect_particle_out(vertex_ptr, particle_ptr)
    return add_shared_particle_out(vertex_ptr, particle_ptr)
end

"""
    attach_vertex_to_event(event, vertex_ptr)
Add a vertex to an event (using shared_ptr).
"""
function attach_vertex_to_event(event, vertex_ptr)
    event_ptr = event.cpp_object
    return add_shared_vertex_to_event(event_ptr, vertex_ptr)
end

# ============================================================================

export set_vertex_status!, shift_position!, add_pdf_info!, add_cross_section!, add_heavy_ion!
export create_particle_attribute, add_particle_attribute!, remove_particle!

"""
    set_vertex_status!(vertex_ptr, status)
Set the status of a vertex.
"""
function set_vertex_status!(vertex_ptr, status::Int)
    set_vertex_status(vertex_ptr, status)
end

"""
    shift_position!(event, dx, dy, dz, dt)
Shift the position of all vertices in the event.
"""
function shift_position!(event, dx::Float64, dy::Float64, dz::Float64, dt::Float64)
    shift_vector = FourVector(dx, dy, dz, dt)
    shift_event_position(event.cpp_object, shift_vector.cpp_object)
end

"""
    add_pdf_info!(event, id1, id2, x1, x2, q, pdf1, pdf2, pdf_set_id1, pdf_set_id2)
Add PDF information to the event.
"""
function add_pdf_info!(event, id1::Int, id2::Int, x1::Float64, x2::Float64, q::Float64, 
                      pdf1::Float64, pdf2::Float64, pdf_set_id1::Int, pdf_set_id2::Int)
    pdf_info = create_gen_pdf_info()
    set_pdf_info(pdf_info, id1, id2, x1, x2, q, pdf1, pdf2, pdf_set_id1, pdf_set_id2)
    add_pdf_info_attribute(event.cpp_object, pdf_info)
    return pdf_info
end

"""
    add_cross_section!(event, xs, xs_err)
Add cross section information to the event.
"""
function add_cross_section!(event, xs::Float64, xs_err::Float64)
    cross_section = create_gen_cross_section()
    set_cross_section(cross_section, xs, xs_err)
    add_cross_section_attribute(event.cpp_object, cross_section)
    return cross_section
end

"""
    add_heavy_ion!(event, nh, np, nt, nc, ns, nsp, nn, nw, nwn, impact_b, plane_angle, eccentricity, sigma_nn)
Add heavy ion collision information to the event.
"""
function add_heavy_ion!(event, nh::Int, np::Int, nt::Int, nc::Int, ns::Int, nsp::Int, nn::Int, 
                       nw::Int, nwn::Int, impact_b::Float64, plane_angle::Float64, 
                       eccentricity::Float64, sigma_nn::Float64)
    heavy_ion = create_gen_heavy_ion()
    set_heavy_ion_info(heavy_ion, nh, np, nt, nc, ns, nsp, nn, nw, nwn, 
                              impact_b, plane_angle, eccentricity, sigma_nn)
    add_heavy_ion_attribute(event.cpp_object, heavy_ion)
    return heavy_ion
end

"""
    create_particle_attribute(value)
Create an attribute for a particle or vertex.
"""
function create_particle_attribute(value::Int)
    return create_int_attribute(value)
end

function create_particle_attribute(value::Float64)
    return create_double_attribute(value)
end

function create_particle_attribute(value::String)
    return create_string_attribute(value)
end

"""
    add_particle_attribute!(particle_ptr, name, value)
Add an attribute to a particle.
"""
function add_particle_attribute!(particle_ptr, name::String, value)
    attr = create_particle_attribute(value)
    add_particle_attribute(particle_ptr, name, attr)
    return attr
end

"""
    remove_particle!(event, particle_ptr)
Remove a particle from the event.
"""
function remove_particle!(event, particle_ptr)
    remove_particle_from_event(event.cpp_object, particle_ptr)
end

# ============================================================================
# Add to HepMC3Interface.jl

export get_particle_properties, get_vertex_properties, particle_mass, particle_charge


"""
    get_particle_properties(particle_ptr)
Get comprehensive properties of a particle in a type-safe manner.
Returns a NamedTuple with all particle properties.
"""
function get_particle_properties(particle_ptr)
    if particle_ptr == C_NULL
        @warn "Particle pointer is NULL"
        return nothing
    end
    
    try
        # Handle different types of particle representations
        if isa(particle_ptr, Ptr{Nothing})
            # Raw pointer - use our new manual wrapper functions
            pdg = get_particle_pdg_id(particle_ptr)
            stat = get_particle_status(particle_ptr)
            id_val = get_particle_id(particle_ptr)
            
            # Get momentum components directly
            px_val = get_particle_px(particle_ptr)
            py_val = get_particle_py(particle_ptr)
            pz_val = get_particle_pz(particle_ptr)
            e_val = get_particle_e(particle_ptr)
            
            mom = (px = px_val, py = py_val, pz = pz_val, e = e_val)
        else
            # Wrapped object - use normal methods
            pdg = pdg_id(particle_ptr)
            stat = status(particle_ptr)
            id_val = id(particle_ptr)
            
            mom_ptr = momentum(particle_ptr)
            mom = (
                px = px(mom_ptr), 
                py = py(mom_ptr), 
                pz = pz(mom_ptr), 
                e = e(mom_ptr)
            )
        end
        
        # Validate momentum components
        if !isfinite(mom.px) || !isfinite(mom.py) || !isfinite(mom.pz) || !isfinite(mom.e)
            @warn "Invalid momentum components: px=$(mom.px), py=$(mom.py), pz=$(mom.pz), E=$(mom.e)"
            return nothing
        end
        
        # Check for valid energy (must be positive)
        if mom.e <= 0
            @warn "Invalid energy: E=$(mom.e) <= 0"
            return nothing
        end
        
        # Calculate derived quantities safely
        pt_val = sqrt(mom.px^2 + mom.py^2)
        p_total = sqrt(mom.px^2 + mom.py^2 + mom.pz^2)
        
        # Safe mass calculation
        mass_squared = mom.e^2 - p_total^2
        mass_val = mass_squared >= 0 ? sqrt(mass_squared) : 0.0
        
        # Safe eta/rapidity calculation (avoid log of negative/zero)
        if pt_val > 0 && mom.e + mom.pz > 0 && mom.e - mom.pz > 0
            eta_val = 0.5 * log((mom.e + mom.pz) / (mom.e - mom.pz))
        else
            eta_val = 0.0
        end
        
        # Safe phi calculation
        phi_val = pt_val > 0 ? atan(mom.py, mom.px) : 0.0
        
        return (
            pdg_id = pdg,
            status = stat,
            momentum = mom,
            pt = pt_val,
            eta = eta_val,
            phi = phi_val,
            mass = mass_val,
            id = id_val
        )
        
    catch e
        @error "Error getting particle properties: $e"
        @error "Particle pointer: $particle_ptr"
        @error "Particle type: $(typeof(particle_ptr))"
        
        # Return nothing instead of invalid defaults
        return nothing
    end
end



"""
    get_vertex_properties(vertex_ptr)
Get comprehensive properties of a vertex.
"""
# Replace get_vertex_properties function:

function get_vertex_properties(vertex_ptr)
    if vertex_ptr == C_NULL
        return (
            id = 0,
            status = -1,
            position = (x = 0.0, y = 0.0, z = 0.0, t = 0.0)
        )
    end
    
    try
        if isa(vertex_ptr, Ptr{Nothing})
            # Raw pointer - use manual wrapper functions
            vertex_id = get_vertex_id(vertex_ptr)
            vertex_status = get_vertex_status(vertex_ptr)
            
            vertex_position = (
                x = get_vertex_x(vertex_ptr),
                y = get_vertex_y(vertex_ptr),
                z = get_vertex_z(vertex_ptr),
                t = get_vertex_t(vertex_ptr)
            )
        else
            # Wrapped object - use normal methods
            vertex_id = id(vertex_ptr)
            vertex_status = try 
                status(vertex_ptr)
            catch 
                -1 
            end
            
            vertex_position = try
                pos = position(vertex_ptr)
                (x = x(pos), y = y(pos), z = z(pos), t = t(pos))
            catch
                (x = 0.0, y = 0.0, z = 0.0, t = 0.0)
            end
        end
        
        return (
            id = vertex_id,
            status = vertex_status,
            position = vertex_position
        )
    catch e
        @error "Error getting vertex properties: $e"
        return (
            id = 0,
            status = -1,
            position = (x = 0.0, y = 0.0, z = 0.0, t = 0.0)
        )
    end
end


"""
    particle_mass(particle_ptr)
Calculate the invariant mass of a particle from its four-momentum.
"""
function particle_mass(particle_ptr)
    props = get_particle_properties(particle_ptr)
    return props.mass
end

"""
    particle_charge(pdg_id::Int)
Get the electric charge of a particle from its PDG ID.
"""

function particle_charge(pdg_id::Integer)
    # Basic charge lookup for common particles
    charge_map = Dict(
        11 => -1,    # electron
        -11 => 1,    # positron
        13 => -1,    # muon
        -13 => 1,    # anti-muon
        22 => 0,     # photon
        23 => 0,     # Z boson
        24 => 1,     # W+
        -24 => -1,   # W-
        2212 => 1,   # proton
        -2212 => -1, # anti-proton
        2112 => 0,   # neutron
        211 => 1,    # pi+
        -211 => -1,  # pi-
        111 => 0,    # pi0
        1 => 1/3,    # d quark
        -1 => -1/3,  # d anti-quark
        2 => 2/3,    # u quark
        -2 => -2/3   # u anti-quark
    )
    
    return get(charge_map, pdg_id, 0)
end



export get_production_vertex, get_decay_vertex, get_incoming_particles, get_outgoing_particles
export get_parent_particles, get_decay_products, get_sibling_particles, traverse_decay_chain
export find_particle_ancestry



function get_production_vertex(particle_ptr)
    try
        return get_production_vertex(particle_ptr)
    catch e
        @warn "Could not get production vertex: $e"
        return C_NULL
    end
end

function get_decay_vertex(particle_ptr)
    try
        return get_end_vertex(particle_ptr)
    catch e
        @warn "Could not get decay vertex: $e"
        return C_NULL
    end
end



"""
    get_incoming_particles(vertex_ptr)
Get all incoming particles for a vertex.
"""
function get_incoming_particles(vertex_ptr)
    particles = []
    try
        # Use our new manual wrapper
        particle_vec = get_particles_in(vertex_ptr)
        if particle_vec != C_NULL
            n_particles = particle_vector_size(particle_vec)
            
            for i in 0:(n_particles-1)
                particle = particle_vector_at(particle_vec, i)
                push!(particles, particle)
            end
            
            delete_particle_vector(particle_vec)
        end
    catch e
        @warn "Could not get incoming particles: $e"
    end
    return particles
end

"""
    get_outgoing_particles(vertex_ptr)
Get all outgoing particles for a vertex.
"""
function get_outgoing_particles(vertex_ptr)
    particles = []
    try
        # Use our new manual wrapper
        particle_vec = get_particles_out(vertex_ptr)
        if particle_vec != C_NULL
            n_particles = particle_vector_size(particle_vec)
            
            for i in 0:(n_particles-1)
                particle = particle_vector_at(particle_vec, i)
                push!(particles, particle)
            end
            
            delete_particle_vector(particle_vec)
        end
    catch e
        @warn "Could not get outgoing particles: $e"
    end
    return particles
end

"""
    get_parent_particles(particle_ptr)
Get all parent particles (backward traversal).
"""
function get_parent_particles(particle_ptr)
    parents = []
    prod_vertex = get_production_vertex(particle_ptr)
    
    if prod_vertex != C_NULL
        parents = get_incoming_particles(prod_vertex)
    end
    
    return parents
end

"""
    get_decay_products(particle_ptr)
Get all immediate decay products (forward traversal).
"""
function get_decay_products(particle_ptr)
    products = []
    decay_vertex = get_decay_vertex(particle_ptr)
    
    if decay_vertex != C_NULL
        products = get_outgoing_particles(decay_vertex)
    end
    
    return products
end


function Base.:(==)(v1::Ptr{Nothing}, v2::Ptr{Nothing})
    # Handle NULL pointers with identity comparison (no recursion)
    if v1 === C_NULL && v2 === C_NULL
        return true
    elseif v1 === C_NULL || v2 === C_NULL
        return false
    end
    
    # Both pointers are non-NULL, try semantic equality
    try
        # First try vertices_equal (for vertex pointers)
        return vertices_equal(v1, v2)
    catch e1
        try
            # Then try particles_equal (for particle pointers)  
            return particles_equal(v1, v2)
        catch e2
            # Fall back to address comparison as last resort
            return v1 === v2
        end
    end
end


# Fix the get_sibling_particles function:
function get_sibling_particles(particle_ptr)
    siblings = []
    prod_vertex = get_production_vertex(particle_ptr)
    
    if prod_vertex != C_NULL
        all_products = get_outgoing_particles(prod_vertex)
        # Use proper equality check for filtering
        for p in all_products
            if !particles_equal(particle_ptr, p)
                push!(siblings, p)
            end
        end
    end
    
    return siblings
end


"""
    traverse_decay_chain(particle_ptr, max_depth=10)
Recursively traverse the complete decay chain forward.
Returns a tree structure of all decay products.
"""
function traverse_decay_chain(particle_ptr, max_depth=10)
    if max_depth <= 0
        return []
    end
    
    decay_tree = []
    products = get_decay_products(particle_ptr)
    
    for product in products
        product_info = get_particle_properties(product)
        children = traverse_decay_chain(product, max_depth - 1)
        
        push!(decay_tree, (
            particle = product,
            properties = product_info,
            children = children
        ))
    end
    
    return decay_tree
end

"""
    find_particle_ancestry(particle_ptr, max_depth=10)
Recursively traverse backward to find all ancestors.
"""
function find_particle_ancestry(particle_ptr, max_depth=10)
    if max_depth <= 0
        return []
    end
    
    ancestry = []
    parents = get_parent_particles(particle_ptr)
    
    for parent in parents
        parent_info = get_particle_properties(parent)
        grandparents = find_particle_ancestry(parent, max_depth - 1)
        
        push!(ancestry, (
            particle = parent,
            properties = parent_info,
            ancestors = grandparents
        ))
    end
    
    return ancestry
end

# Export clean unit constants and set_units!
export GeV, MeV, mm, cm, set_units!

# Define clean unit constants
const GeV = var"HepMC3!Units!GEV"
const MeV = var"HepMC3!Units!MEV"  
const mm = var"HepMC3!Units!MM"
const cm = var"HepMC3!Units!CM"

# Symbol-based interface
const UNIT_MAP = Dict(
    :GeV => var"HepMC3!Units!GEV",
    :MeV => var"HepMC3!Units!MEV",
    :mm => var"HepMC3!Units!MM", 
    :cm => var"HepMC3!Units!CM"
)

"""
    set_units!(event, momentum_unit, length_unit)
Set the units for an event using clean syntax.

# Examples
```julia
event = GenEvent()
set_units!(event, :GeV, :mm)    # Using symbols
set_units!(event, GeV, mm)      # Using constants
```
"""

function set_units!(event, momentum_unit, length_unit)
    # Convert symbols to internal constants if needed
    mom_unit = momentum_unit isa Symbol ? UNIT_MAP[momentum_unit] : momentum_unit
    len_unit = length_unit isa Symbol ? UNIT_MAP[length_unit] : length_unit
    
    set_units(event, mom_unit, len_unit)
end


# function get_particle_at(event::GenEvent, index::Int)
#     return get_particle_at(event.cpp_object, index - 1)
# end

# function get_vertex_at(event::GenEvent, index::Int)
#     return get_vertex_at(event.cpp_object, index - 1)
# end

# function particles_size(event::GenEvent)
#     return particles_size(event.cpp_object)
# end

# function vertices_size(event::GenEvent)
#     return vertices_size(event.cpp_object)
# end


export set_event_weights!, get_event_weights
export particles_size, vertices_size, get_particle_at, get_vertex_at
export particles_equal

function set_event_weights!(event::GenEvent, weights::Vector{Float64})
    set_event_weights(event.cpp_object, weights, length(weights))
end


# Replace the get_event_weights function:

function get_event_weights(event::GenEvent)
    n_weights = Ref{Int32}(0)
    weights_ptr = get_event_weights(event.cpp_object, n_weights)
    
    if weights_ptr == C_NULL || n_weights[] == 0
        return Float64[]
    end
    
    # Convert CxxPtr to regular Ptr for unsafe_wrap
    raw_ptr = Ptr{Float64}(weights_ptr.cpp_object)
    
    # Copy weights to Julia array
    weights = unsafe_wrap(Array, raw_ptr, n_weights[])
    result = copy(weights)
    
    # Free C++ allocated memory
    free_weights(weights_ptr)
    
    return result
end


# Override Base.in for particle pointer arrays
function Base.in(particle::Ptr{Nothing}, particles::Vector)
    for p in particles
        if isa(p, Ptr{Nothing}) && particles_equal(particle, p)
            return true
        end
    end
    return false
end



export create_run_info, add_tool_info!, set_weight_names!

"""
    create_run_info()
Create a new GenRunInfo object (alias for existing function).
"""
function create_run_info()
    return create_gen_run_info()
end

"""
    set_weight_names!(run_info, names)
Set the weight names for a RunInfo object.
"""
function set_weight_names!(run_info, names::Vector{String})
    c_names = [pointer(name) for name in names]
    set_weight_names(run_info, c_names, length(names))
end

"""
    add_tool_info!(run_info, name, version, description)
Add tool information to RunInfo (if you want full pyhepmc compatibility).
For now, this is a placeholder since ToolInfo might need C++ implementation.
"""
function add_tool_info!(run_info, name::String, version::String, description::String)
    # For now, just log that tool info was requested
    println("ToolInfo requested: $name $version - $description")
    # This could be implemented in C++ later if needed
    return nothing
end


















# Add to HepMC3Interface.jl:

using CodecZlib, CodecZstd  # You'll need to add these dependencies

export read_hepmc_file, get_final_state_particles 

# C++ exports
export read_all_events_from_file, get_events_vector_size, get_event_from_vector, delete_events_vector


"""
    read_hepmc_file(filename; max_events=-1)
Read an uncompressed HepMC3 ASCII file using native HepMC3 reader.
"""
function read_hepmc_file(filename::String; max_events::Int=-1)
    if !isfile(filename)
        error("File not found: $filename")
    end
    
    # println("Reading HepMC3 file: $filename")
    
    # Use your existing C++ function
    events_vector = read_all_events_from_file(filename, max_events)
    
    if events_vector == C_NULL
        error("HepMC3 reader failed to read file: $filename")
    end
    
    n_events = get_events_vector_size(events_vector)
    events = []
    
    # println("Read $n_events events using HepMC3 native reader")
    
    for i in 0:(n_events-1)
        event_ptr = get_event_from_vector(events_vector, i)
        if event_ptr != C_NULL
            push!(events, event_ptr)
        end
    end
    
    # Clean up C++ vector
    delete_events_vector(events_vector)
    
    return events
end

"""
    get_final_state_particles(event_ptr)
Extract all final state particles (status == 1) from an event.
Returns a vector of particle pointers.
"""
function get_final_state_particles(event_ptr)
    final_state_particles = []
    n_particles = particles_size(event_ptr)

    if n_particles <= 0
        return final_state_particles 
    end
    
    for i in 1:n_particles
        particle_ptr = get_particle_at(event_ptr, i)
        if particle_ptr != C_NULL
            props = get_particle_properties(particle_ptr)
            
            # Final state particles have status == 1
            if props.status == 1
                push!(final_state_particles, particle_ptr)
            end
        end
    end
    
    return final_state_particles
end


"""
    dump_final_state_particles(filename; max_events=3)
Simple function to dump final state particles from events.
"""
function dump_final_state_particles(filename::String; max_events::Int=3)
    events = read_hepmc_file(filename; max_events=max_events)
    
    # println("File: $filename")
    # println("Events: $(length(events))")
    # println()
    
    for (event_idx, event_ptr) in enumerate(events)
        n_particles = particles_size(event_ptr)
        
        # Skip empty events
        if n_particles <= 0
            println("Event $event_idx: EMPTY (skipping)")
            continue
        end
        
        final_state = get_final_state_particles(event_ptr)
        
        println("Event $event_idx: $(length(final_state)) final state particles")
        println("Final state particles:")
        
        for (i, particle) in enumerate(final_state)
            props = get_particle_properties(particle)
            println("  [$i] PDG=$(props.pdg_id), pt=$(round(props.pt, digits=2)), " *
                    "p=($(round(props.momentum.px, digits=2)), $(round(props.momentum.py, digits=2)), " *
                    "$(round(props.momentum.pz, digits=2)), $(round(props.momentum.e, digits=2)))")
        end
        println()
    end
end

export dump_final_state_particles


"""
    decompress_to_temp(compressed_file)
Decompress a .zst file to a temporary file for HepMC3 to read.
"""
function decompress_to_temp(compressed_file::String)
    temp_file = tempname() * ".hepmc3"
    
    # Decompress
    open(compressed_file, "r") do input
        zstd_stream = ZstdDecompressorStream(input)
        open(temp_file, "w") do output
            write(output, read(zstd_stream))
        end
    end
    
    return temp_file
end

"""
    read_hepmc_file_with_compression(filename; max_events=-1)
Read HepMC3 file with automatic compression detection.
"""
function read_hepmc_file_with_compression(filename::String; max_events::Int=-1)
    if endswith(filename, ".zst")
        # Decompress to temp file
        temp_file = decompress_to_temp(filename)
        try
            return read_hepmc_file(temp_file; max_events=max_events)
        finally
            # Clean up temp file
            rm(temp_file, force=true)
        end
    else
        # Read directly
        return read_hepmc_file(filename; max_events=max_events)
    end
end

export read_hepmc_file_with_compression




# ============================================================================
# WRAPPER METHODS FOR SHARED_PTR COMPATIBILITY
# ============================================================================

# Create alias for the generated type
const GenEventAllocated = var"HepMC3!GenEventAllocated"
export GenEventAllocated

# ============================================================================
# WRAPPER METHODS FOR TEST COMPATIBILITY (using _raw functions)
# ============================================================================

# Wrapper methods for GenEventAllocated (the type used in tests)
function particles_size(event::GenEventAllocated)
    event_raw_ptr = event.cpp_object  # This is GenEvent*
    return particles_size_raw(event_raw_ptr)
end

function vertices_size(event::GenEventAllocated)
    event_raw_ptr = event.cpp_object
    return vertices_size_raw(event_raw_ptr)
end

function get_particle_at(event::GenEventAllocated, index::Integer)
    event_raw_ptr = event.cpp_object
    return get_particle_at_raw(event_raw_ptr, index - 1)  # Convert to 0-based indexing
end

function get_vertex_at(event::GenEventAllocated, index::Integer)
    event_raw_ptr = event.cpp_object
    return get_vertex_at_raw(event_raw_ptr, index - 1)
end

# Same for GenEvent type
function particles_size(event::GenEvent)
    event_raw_ptr = event.cpp_object
    return particles_size_raw(event_raw_ptr)
end

function vertices_size(event::GenEvent)
    event_raw_ptr = event.cpp_object
    return vertices_size_raw(event_raw_ptr)
end

function get_particle_at(event::GenEvent, index::Integer)
    event_raw_ptr = event.cpp_object
    return get_particle_at_raw(event_raw_ptr, index - 1)
end

function get_vertex_at(event::GenEvent, index::Integer)
    event_raw_ptr = event.cpp_object
    return get_vertex_at_raw(event_raw_ptr, index - 1)
end

