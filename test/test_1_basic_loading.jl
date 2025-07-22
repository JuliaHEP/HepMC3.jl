# Save as: test_1_basic_loading.jl
println("=== HepMC3 Basic Loading Test ===")

using HepMC3

println("✅ HepMC3 module loaded successfully!")

println("\nAvailable symbols:")
symbols = filter(x -> !startswith(string(x), "_"), names(HepMC3))
for (i, name) in enumerate(symbols)
    print(rpad(string(name), 25))
    if i % 3 == 0
        println()
    end
end
println("\n\nTotal symbols: ", length(symbols))