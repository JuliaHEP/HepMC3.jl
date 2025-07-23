## Steps: to reproduce:

### For bindings from scratch

```julia
cd gen
rm -rf build/ cpp/jlHepMC3.* jl/
julia build.jl
```
## Apply patch to include manual wrappers, since we only define on Jlcxx module
```bash
sed -i '/#include "HepMC3\/Units.h"/a #include "HepMC3Wrap.h"' gen/cpp/jlHepMC3.cxx

sed -i '/for(const auto& w: wrappers) w->add_methods();/a \  add_manual_hepmc3_methods(jlModule);' gen/cpp/jlHepMC3.cxx 
```

## After applying patch rebuild the binary

```julia
cd gen/build

cmake --build . --config Release --parallel 8
```

# Executing a basic example

```julia
cd ../..
julia --project=. examples/basic_tree_julia.jl
```


