# Four-Vectors

Four-vectors (`FourVector`) represent four-momentum (px, py, pz, E) or four-position (x, y, z, t) in HepMC3. They are fundamental objects for particle physics calculations.

## Creating Four-Vectors

### From Components

```julia
# Create four-momentum (px, py, pz, E)
momentum = FourVector(px, py, pz, e)

# Create four-position (x, y, z, t)
position = FourVector(x, y, z, t)
```

### Examples

```julia
# Proton with pz = 7000 GeV, E = 7000 GeV (massless approximation)
proton_momentum = FourVector(0.0, 0.0, 7000.0, 7000.0)

# Electron with some transverse momentum
electron_momentum = FourVector(10.0, 20.0, 100.0, 102.5)

# Vertex at the origin
origin = FourVector(0.0, 0.0, 0.0, 0.0)

# Displaced vertex
displaced_vertex = FourVector(0.1, 0.2, 5.0, 0.01)
```

## Accessing Components

### Momentum Components

```julia
vec = FourVector(10.0, 20.0, 30.0, 40.0)

# Access momentum components
px_val = px(vec)  # x-component of momentum
py_val = py(vec)  # y-component of momentum
pz_val = pz(vec)  # z-component of momentum
e_val = e(vec)    # energy
```

### Position/Time Components

The same four-vector can represent position, using alternative accessors:

```julia
pos = FourVector(1.0, 2.0, 3.0, 4.0)

# Access position components
x_val = x(pos)  # x-position
y_val = y(pos)  # y-position
z_val = z(pos)  # z-position
t_val = t(pos)  # time
```

## Derived Quantities

HepMC3.jl provides functions to compute common kinematic quantities directly from four-vectors.

### Transverse Momentum

```julia
vec = FourVector(10.0, 20.0, 100.0, 150.0)

pt_val = pt(vec)    # Transverse momentum: sqrt(px^2 + py^2)
pt2_val = pt2(vec)  # Transverse momentum squared: px^2 + py^2
perp_val = perp(vec)   # Alias for pt
perp2_val = perp2(vec) # Alias for pt2
```

### Pseudorapidity

```julia
eta_val = eta(vec)          # Pseudorapidity: -ln(tan(theta/2))
abs_eta_val = abs_eta(vec)  # Absolute pseudorapidity
```

### Rapidity

```julia
rap_val = rap(vec)          # Rapidity: 0.5 * ln((E+pz)/(E-pz))
abs_rap_val = abs_rap(vec)  # Absolute rapidity
```

### Azimuthal Angle

```julia
phi_val = phi(vec)  # Azimuthal angle: atan2(py, px)
```

### Polar Angle

```julia
theta_val = theta(vec)  # Polar angle: acos(pz/|p|)
```

### Invariant Mass

```julia
mass_val = m(vec)   # Invariant mass: sqrt(E^2 - px^2 - py^2 - pz^2)
mass2_val = m2(vec) # Invariant mass squared: E^2 - px^2 - py^2 - pz^2
```

### Three-Momentum Magnitude

```julia
p3_val = p3mod(vec)   # |p| = sqrt(px^2 + py^2 + pz^2)
p3_2_val = p3mod2(vec) # |p|^2 = px^2 + py^2 + pz^2
rho_val = rho(vec)    # Alias for p3mod (cylindrical coordinates)
```

### Spatial Length

For position four-vectors:

```julia
len = length(vec)   # Spatial length: sqrt(x^2 + y^2 + z^2)
len2 = length2(vec) # Spatial length squared: x^2 + y^2 + z^2
```

## Delta Calculations

Calculate differences between two four-vectors:

### Delta Eta

```julia
d_eta = delta_eta(vec1, vec2)  # Difference in pseudorapidity
```

### Delta Phi

```julia
d_phi = delta_phi(vec1, vec2)  # Difference in azimuthal angle (normalized to [-pi, pi])
```

### Delta Rapidity

```julia
d_rap = delta_rap(vec1, vec2)  # Difference in rapidity
```

### Delta R (Angular Distance)

```julia
# Delta R using pseudorapidity
dr_eta = delta_r_eta(vec1, vec2)   # sqrt(delta_eta^2 + delta_phi^2)
dr2_eta = delta_r2_eta(vec1, vec2) # delta_eta^2 + delta_phi^2

# Delta R using rapidity
dr_rap = delta_r_rap(vec1, vec2)   # sqrt(delta_rap^2 + delta_phi^2)
dr2_rap = delta_r2_rap(vec1, vec2) # delta_rap^2 + delta_phi^2
```

## Using with Particles

Four-vectors are automatically created when creating particles:

```julia
# This creates a FourVector internally
particle = make_shared_particle(px, py, pz, e, pdg_id, status)

# Access the momentum four-vector
mom = momentum(particle)
px_val = px(mom)
pt_val = pt(mom)
eta_val = eta(mom)
```

## Using with Vertices

Set vertex position using four-vector components:

```julia
position = FourVector(1.0, 2.0, 3.0, 4.0)
set_vertex_position(vertex, x(position), y(position), z(position), t(position))

# Or get vertex position
pos = position(vertex)
```

## Complete Example

```julia
using HepMC3

# Create momentum four-vectors for two jets
jet1 = FourVector(50.0, 30.0, 200.0, 210.0)
jet2 = FourVector(-45.0, -35.0, 180.0, 190.0)

# Calculate kinematic properties
println("Jet 1:")
println("  px = $(px(jet1)) GeV")
println("  py = $(py(jet1)) GeV")
println("  pz = $(pz(jet1)) GeV")
println("  E  = $(e(jet1)) GeV")
println("  pT = $(pt(jet1)) GeV")
println("  eta = $(eta(jet1))")
println("  phi = $(phi(jet1))")
println("  mass = $(m(jet1)) GeV")

println("\nJet 2:")
println("  pT = $(pt(jet2)) GeV")
println("  eta = $(eta(jet2))")
println("  phi = $(phi(jet2))")
println("  mass = $(m(jet2)) GeV")

# Calculate angular separation
println("\nAngular separation:")
println("  delta_eta = $(delta_eta(jet1, jet2))")
println("  delta_phi = $(delta_phi(jet1, jet2))")
println("  delta_R (eta) = $(delta_r_eta(jet1, jet2))")
println("  delta_R (rap) = $(delta_r_rap(jet1, jet2))")

# Use in particle creation
particle = make_shared_particle(px(jet1), py(jet1), pz(jet1), e(jet1), 1, 1)  # down quark jet

# Retrieve momentum from particle
retrieved_mom = momentum(particle)
println("\nRetrieved from particle:")
println("  pT = $(pt(retrieved_mom)) GeV")
```

## Particle Properties Convenience

For particles, `get_particle_properties` provides pre-calculated kinematic quantities:

```julia
props = get_particle_properties(particle)

# These are pre-calculated:
props.momentum.px   # px
props.momentum.py   # py
props.momentum.pz   # pz
props.momentum.e    # E
props.pt            # Transverse momentum
props.eta           # Pseudorapidity
props.phi           # Azimuthal angle
props.mass          # Invariant mass
```

## API Reference

### Constructors

```@docs
FourVector
```

### Component Accessors

```@docs
px
py
pz
e
x
y
z
t
```

### Derived Quantities

```@docs
pt
pt2
perp
perp2
eta
abs_eta
rap
abs_rap
phi
theta
m
m2
p3mod
p3mod2
rho
length
length2
```

### Delta Calculations

```@docs
delta_eta
delta_phi
delta_rap
delta_r_eta
delta_r2_eta
delta_r_rap
delta_r2_rap
```
