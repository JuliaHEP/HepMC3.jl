# Four-Vectors

Four-vectors (`FourVector`) represent four-momentum (px, py, pz, E) or four-position (x, y, z, t) in HepMC3.

## Creating Four-Vectors

### Momentum Four-Vector

```julia
# Create four-momentum (px, py, pz, E)
momentum = FourVector(px, py, pz, e)
```

Example:

```julia
# Proton with pz = 7000 GeV, E = 7000 GeV
proton_momentum = FourVector(0.0, 0.0, 7000.0, 7000.0)
```

### Position Four-Vector

Position four-vectors use the same type but represent (x, y, z, t):

```julia
position = FourVector(x, y, z, t)
```

## Accessing Components

```julia
vec = FourVector(10.0, 20.0, 30.0, 40.0)

# Access components
px_val = px(vec)
py_val = py(vec)
pz_val = pz(vec)
e_val = e(vec)
```

## Using with Particles

Four-vectors are automatically created when creating particles:

```julia
# This creates a FourVector internally
particle = make_shared_particle(px, py, pz, e, pdg_id, status)

# Access the momentum four-vector
mom = momentum(particle)
px_val = px(mom)
```

## Using with Vertices

Set vertex position using a four-vector:

```julia
position = FourVector(1.0, 2.0, 3.0, 4.0)
set_vertex_position(vertex, x(position), y(position), z(position), t(position))
```

## Physics Calculations

### Invariant Mass

Calculate invariant mass from four-momentum:

```julia
vec = FourVector(px, py, pz, e)
mass = sqrt(e(vec)^2 - px(vec)^2 - py(vec)^2 - pz(vec)^2)
```

Or use the convenience function:

```julia
props = get_particle_properties(particle)
mass = props.mass  # Automatically calculated
```

### Transverse Momentum

```julia
vec = FourVector(px, py, pz, e)
pt = sqrt(px(vec)^2 + py(vec)^2)
```

Or from particle properties:

```julia
props = get_particle_properties(particle)
pt = props.pt
```

### Pseudorapidity

```julia
vec = FourVector(px, py, pz, e)
pt = sqrt(px(vec)^2 + py(vec)^2)
if pt > 0 && e(vec) + pz(vec) > 0 && e(vec) - pz(vec) > 0
    eta = 0.5 * log((e(vec) + pz(vec)) / (e(vec) - pz(vec)))
end
```

Or from particle properties:

```julia
props = get_particle_properties(particle)
eta = props.eta
```

## Example: Working with Four-Vectors

```julia
using HepMC3

# Create momentum four-vector
mom = FourVector(10.0, 20.0, 100.0, 150.0)

# Access components
println("px = $(px(mom))")
println("py = $(py(mom))")
println("pz = $(pz(mom))")
println("E = $(e(mom))")

# Calculate derived quantities
pt = sqrt(px(mom)^2 + py(mom)^2)
mass_sq = e(mom)^2 - px(mom)^2 - py(mom)^2 - pz(mom)^2
mass = mass_sq >= 0 ? sqrt(mass_sq) : 0.0

println("pT = $pt GeV")
println("Mass = $mass GeV")

# Use in particle creation
particle = make_shared_particle(px(mom), py(mom), pz(mom), e(mom), 11, 1)

# Retrieve momentum
retrieved_mom = momentum(particle)
println("Retrieved px = $(px(retrieved_mom))")
```

## API Reference

```@docs
FourVector
px
py
pz
e
x
y
z
t
```

