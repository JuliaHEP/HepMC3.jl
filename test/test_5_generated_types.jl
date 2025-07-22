# Save as: test_5_generated_types.jl
println("=== HepMC3 Generated Types Check ===")

using HepMC3

println("Checking for key HepMC3 types...")

key_types = [
    "FourVector",
    "GenEvent", 
    "GenParticle",
    "GenVertex",
    "GenEventData",
    "GenParticleData", 
    "GenVertexData",
    "Attribute",
    "IntAttribute",
    "DoubleAttribute",
    "StringAttribute",
    "GenCrossSection",
    "GenPdfInfo",
    "GenHeavyIon"
]

available_types = []
for type_name in key_types
    try
        if hasfield(HepMC3, Symbol(type_name))
            push!(available_types, type_name)
            println("✅ ", type_name)
        else
            println("❌ ", type_name, " - not found")
        end
    catch e
        println("⚠️  ", type_name, " - error checking: ", e)
    end
end

println("\nTypes available: ", length(available_types), "/", length(key_types))

# Check Units enum
println("\nChecking Units enum...")
try
    println("✅ MomentumUnit MEV: ", HepMC3.MEV)
    println("✅ MomentumUnit GEV: ", HepMC3.GEV)
    println("✅ LengthUnit MM: ", HepMC3.MM) 
    println("✅ LengthUnit CM: ", HepMC3.CM)
    println("✅ Units enum working")
catch e
    println("❌ Units enum error: ", e)
end