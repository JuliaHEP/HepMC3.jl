using Documenter
using HepMC3

makedocs(sitename = "HepMC3.jl",
         clean = false,
         warnonly = true,
         pages = [
             "Home" => "index.md",
             "Getting Started" => "getting_started.md",
             "Building from Source" => "building.md",
             "Events" => "events.md",
             "Particles" => "particles.md",
             "Vertices" => "vertices.md",
             "Four-Vectors" => "fourvector.md",
             "File I/O" => "file_io.md",
             "Attributes" => "attributes.md",
             "Units" => "units.md",
             "Navigation" => "navigation.md",
             "Examples" => "examples.md",
             "Contributing" => "contributing.md",
             "Reference Docs" => Any["Public API" => "lib/public.md",
                                     "Internal API" => "lib/internal.md"]
         ])

deploydocs(repo = "github.com/JuliaHEP/HepMC3.jl.git",
           devbranch = "main",
           devurl = "dev",
           versions = ["stable" => "v^", "v#.#", "dev" => "dev"],
           push_preview = true)
