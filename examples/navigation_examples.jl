# Create: examples/navigation_examples.jl

"""
=== HepMC3.jl Event Navigation Examples ===

This script demonstrates comprehensive event navigation capabilities.
"""

using HepMC3

function navigation_demo()
    println("🔍 Event Navigation Demonstration")
    
    # Create the basic tree event
    event = create_event(1)
    
    # Build event structure: p1 -> v1 -> p2 -> v2 -> (p3, p4)
    p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # proton
    v1 = make_shared_vertex()
    connect_particle_in(v1, p1)
    
    p2 = make_shared_particle(10.0, 20.0, 100.0, 200.0, 23, 2)    # Z boson
    connect_particle_out(v1, p2)
    attach_vertex_to_event(event, v1)
    
    v2 = make_shared_vertex()
    connect_particle_in(v2, p2)
    
    p3 = make_shared_particle(5.0, 10.0, 50.0, 60.0, 11, 1)       # electron
    p4 = make_shared_particle(5.0, 10.0, 50.0, 60.0, -11, 1)      # positron
    connect_particle_out(v2, p3)
    connect_particle_out(v2, p4)
    attach_vertex_to_event(event, v2)
    
    println("\n📊 Event Structure Built:")
    println("  p1 (proton) -> v1 -> p2 (Z) -> v2 -> (p3(e-), p4(e+))")
    
    # Demonstrate navigation
    println("\n🔍 Navigation Examples:")
    
    # 1. Particle properties
    println("\n1. Particle Properties:")
    p2_props = get_particle_properties(p2)
    println("  Z boson properties: PDG=$(p2_props.pdg_id), mass=$(round(p2_props.mass, digits=2)) GeV")
    println("  Z boson pT: $(round(p2_props.pt, digits=2)) GeV")
    println("  Z boson charge: $(particle_charge(p2_props.pdg_id))")
    
    # 2. Vertex navigation
    println("\n2. Vertex Navigation:")
    prod_vertex = get_production_vertex(p2)
    decay_vertex = get_decay_vertex(p2)
    println("  p2 production vertex: $(prod_vertex != C_NULL ? "Found" : "None")")
    println("  p2 decay vertex: $(decay_vertex != C_NULL ? "Found" : "None")")
    
    # 3. Parent/child relationships
    println("\n3. Parent-Child Relationships:")
    parents = get_parent_particles(p2)
    children = get_decay_products(p2)
    println("  p2 parents: $(length(parents)) particles")
    println("  p2 children: $(length(children)) particles")
    
    for (i, child) in enumerate(children)
        child_props = get_particle_properties(child)
        println("    Child $i: PDG=$(child_props.pdg_id), pT=$(round(child_props.pt, digits=2)) GeV")
    end
    
    # 4. Sibling particles
    println("\n4. Sibling Particles:")
    siblings = get_sibling_particles(p3)
    println("  p3 siblings: $(length(siblings)) particles")
    
    # 5. Decay chain traversal
    println("\n5. Complete Decay Chain:")
    decay_tree = traverse_decay_chain(p1)
    print_decay_tree(decay_tree, 0)
    
    return event
end

function print_decay_tree(tree, indent_level)
    for node in tree
        indent = "  " ^ indent_level
        props = node.properties
        println("$(indent)├─ PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV, mass=$(round(props.mass, digits=2)) GeV")
        
        if !isempty(node.children)
            print_decay_tree(node.children, indent_level + 1)
        end
    end
end

# Run the demo
navigation_demo()