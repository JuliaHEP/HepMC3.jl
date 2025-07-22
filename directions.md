## Steps: to reproduce:

### For bindings from scratch

```julia
cd gen
rm -rf build/ cpp/jlHepMC3.* jl/
julia build.jl
```

```julia
cd ..
julia --project=. basic_tree_julia.jl
```


### For rebuilding the library

```julia
cd gen/build

cmake --build . --config Release --parallel 8
```
