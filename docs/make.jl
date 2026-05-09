using Documenter
using HepMC3

makedocs(sitename = "HepMC3.jl",
         clean = true,
         format = Documenter.HTML(edit_link = "main"),
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
         ])

if get(ENV, "GITHUB_ACTIONS", "false") == "true"
    deploydocs(repo = "github.com/JuliaHEP/HepMC3.jl.git",
               devbranch = "main",
               devurl = "dev",
               versions = ["stable" => "v^", "v#.#", "dev" => "dev"],
               push_preview = true)
end
