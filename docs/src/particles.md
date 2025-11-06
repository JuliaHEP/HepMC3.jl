# Particles

Particles in HepMC3 are represented by the `GenParticle` type, which contains four-momentum, PDG ID, status code, and optional attributes.

## Creating Particles

### Using make_shared_particle

The recommended way to create particles for use in events:

```julia
particle = make_shared_particle(px, py, pz, e, pdg_id, status)
```

Parameters:
- `px, py, pz, e`: Four-momentum components
- `pdg_id`: Particle Data Group ID
- `status`: Particle status code

Example:

```julia
# Create a proton
proton = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)

# Create an electron
electron = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)
```

### Using create_particle

For standalone particles (not connected to vertices):

```julia
particle = create_particle(px, py, pz, e, pdg_id, status)
```

## Particle Properties

### Getting All Properties

Get comprehensive particle information:

```julia
props = get_particle_properties(particle)

# Access individual properties
props.pdg_id      # PDG ID
props.status      # Status code
props.momentum    # NamedTuple with px, py, pz, e
props.pt          # Transverse momentum
props.eta         # Pseudorapidity
props.phi         # Azimuthal angle
props.mass        # Invariant mass
props.id          # Internal particle ID
```

### Individual Property Access

```julia
# PDG ID and status
pdg = pdg_id(particle)
stat = status(particle)

# Momentum components
mom = momentum(particle)
px_val = px(mom)
py_val = py(mom)
pz_val = pz(mom)
e_val = e(mom)
```

### Derived Quantities

The `get_particle_properties` function automatically calculates:

- **pT**: Transverse momentum `√(px² + py²)`
- **Mass**: Invariant mass `√(E² - p²)`
- **Eta**: Pseudorapidity
- **Phi**: Azimuthal angle

## Particle Status Codes

Common status codes:
- `1`: Final state particle (stable, observable)
- `2`: Intermediate particle (decays)
- `3`: Initial state particle
- `4`: Beam particle

## Generated Mass

Particles can have a "generated mass" that differs from the calculated invariant mass:

```julia
# Check if generated mass is set
is_set = is_generated_mass_set(particle)

# Get generated mass
mass = get_generated_mass(particle)

# Set generated mass
set_generated_mass(particle, 0.938)  # Proton mass

# Unset generated mass
unset_generated_mass(particle)
```

## Particle Charge

Get electric charge from PDG ID:

```julia
charge = particle_charge(pdg_id)
```

Examples:
- `particle_charge(11)` → `-1` (electron)
- `particle_charge(2212)` → `1` (proton)
- `particle_charge(22)` → `0` (photon)

## Particle Attributes

Add metadata to particles (see [Attributes](@ref) for details):

```julia
# Add integer attribute
add_particle_attribute!(particle, "tool", 1)

# Add double attribute
add_particle_attribute!(particle, "weight", 0.95)

# Add string attribute
add_particle_attribute!(particle, "comment", "interesting")
```

## Common PDG IDs

| PDG ID | Particle | Charge |
|--------|----------|--------|
| 11 | e⁻ | -1 |
| -11 | e⁺ | +1 |
| 13 | μ⁻ | -1 |
| 22 | γ | 0 |
| 23 | Z⁰ | 0 |
| 24 | W⁺ | +1 |
| -24 | W⁻ | -1 |
| 211 | π⁺ | +1 |
| -211 | π⁻ | -1 |
| 2212 | p | +1 |
| -2212 | p̄ | -1 |

## Example: Working with Particles

```julia
using HepMC3

# Create particles
proton = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)
electron = make_shared_particle(10.0, 20.0, 100.0, 150.0, 11, 1)

# Get properties
p_props = get_particle_properties(proton)
e_props = get_particle_properties(electron)

println("Proton:")
println("  PDG: $(p_props.pdg_id)")
println("  pT: $(p_props.pt) GeV")
println("  Mass: $(p_props.mass) GeV")
println("  Charge: $(particle_charge(p_props.pdg_id))")

println("Electron:")
println("  PDG: $(e_props.pdg_id)")
println("  pT: $(e_props.pt) GeV")
println("  Eta: $(e_props.eta)")
println("  Phi: $(e_props.phi)")

# Set generated mass
set_generated_mass(proton, 0.938)
println("Generated mass: $(get_generated_mass(proton)) GeV")
```

## API Reference

```@docs
GenParticle
make_shared_particle
create_particle
get_particle_properties
pdg_id
status
momentum
particle_mass
particle_charge
get_generated_mass
set_generated_mass
is_generated_mass_set
unset_generated_mass
add_particle_attribute!
```
