# Units

HepMC3 uses explicit units for momentum and position. All events must have units set to ensure consistent interpretation of numerical values.

## Overview

HepMC3 supports two momentum units and two length units:

| Momentum Units | Length Units |
|---------------|--------------|
| GeV (gigaelectronvolts) | mm (millimeters) |
| MeV (megaelectronvolts) | cm (centimeters) |

The default and most common convention in LHC experiments is GeV for momentum and mm for length.

## Setting Units

### Using Symbols (Recommended)

```julia
event = create_event(1)
set_units!(event, :GeV, :mm)
```

Available symbols:
- Momentum: `:GeV`, `:MeV`
- Length: `:mm`, `:cm`

### Using Constants

```julia
event = create_event(1)
set_units!(event, GEV, MM)
```

Available constants:
- Momentum: `GEV`, `MEV`, `GeV`, `MeV`
- Length: `MM`, `CM`, `mm`, `cm`

## Querying Units

Get the current units of an event:

```julia
event = create_event(1)
set_units!(event, :GeV, :mm)

# Query momentum unit
mom_unit = momentum_unit(event)
println("Momentum unit: $mom_unit")  # GEV

# Query length unit
len_unit = length_unit(event)
println("Length unit: $len_unit")    # MM
```

## Unit Constants

The following constants are exported for use:

### Momentum Units

```julia
using HepMC3

GEV   # Gigaelectronvolts (enum value)
GeV   # Alias for GEV
MEV   # Megaelectronvolts (enum value)
MeV   # Alias for MEV
```

### Length Units

```julia
MM    # Millimeters (enum value)
mm    # Alias for MM
CM    # Centimeters (enum value)
cm    # Alias for CM
```

## Unit Consistency

All momentum and position values in an event must use the same units as specified when setting units.

### Example: GeV and mm (LHC Convention)

```julia
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create a 7 TeV proton (momentum in GeV)
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)

# Create a vertex at the origin (position in mm)
v1 = make_shared_vertex()
set_vertex_position(v1, 0.0, 0.0, 0.0, 0.0)

connect_particle_in(v1, p1)
attach_vertex_to_event(event, v1)
```

### Example: MeV and cm

```julia
event = create_event(1)
set_units!(event, :MeV, :cm)

# Create a 7 TeV proton (momentum in MeV = 7,000,000 MeV)
p1 = make_shared_particle(0.0, 0.0, 7e6, 7e6, 2212, 3)

# Create a vertex (position in cm)
v1 = make_shared_vertex()
set_vertex_position(v1, 0.0, 0.0, 0.0, 0.0)

connect_particle_in(v1, p1)
attach_vertex_to_event(event, v1)
```

## Unit Conversion

When you need to convert between units, perform the conversion before creating particles or setting positions:

### Momentum Conversion

```julia
# MeV to GeV
momentum_gev = momentum_mev / 1000.0

# GeV to MeV
momentum_mev = momentum_gev * 1000.0
```

### Length Conversion

```julia
# cm to mm
position_mm = position_cm * 10.0

# mm to cm
position_cm = position_mm / 10.0
```

### Conversion Example

```julia
# Data is in MeV, but we want to use GeV
px_mev, py_mev, pz_mev, e_mev = 1000.0, 2000.0, 50000.0, 50100.0

# Convert to GeV
px_gev = px_mev / 1000.0
py_gev = py_mev / 1000.0
pz_gev = pz_mev / 1000.0
e_gev = e_mev / 1000.0

# Create event with GeV units
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particle with converted values
p1 = make_shared_particle(px_gev, py_gev, pz_gev, e_gev, 11, 1)
```

## Reading Files with Different Units

When reading HepMC3 files, the units are embedded in the file header. You can query the units after reading:

```julia
events = read_hepmc_file("events.hepmc3")
event = events[1]

mom_unit = momentum_unit(event)
len_unit = length_unit(event)

println("File uses $mom_unit for momentum and $len_unit for length")
```

## Best Practices

1. **Set units immediately after creating an event**:
   ```julia
   event = create_event(1)
   set_units!(event, :GeV, :mm)  # Do this first
   # ... then add particles and vertices
   ```

2. **Use consistent units throughout your analysis**:
   - Pick one unit system and stick with it
   - Convert external data to your chosen system before processing

3. **Document your unit conventions**:
   - Especially important when sharing code or data

4. **Use GeV/mm for LHC analyses**:
   - This is the standard convention for most LHC experiments
   - Makes it easier to compare with published results

## Common Unit Values

| Quantity | GeV Value | MeV Value |
|----------|-----------|-----------|
| Electron mass | 0.000511 | 0.511 |
| Proton mass | 0.938 | 938 |
| W boson mass | 80.4 | 80400 |
| Z boson mass | 91.2 | 91200 |
| Higgs mass | 125 | 125000 |
| LHC beam energy | 6500-7000 | 6.5e6-7e6 |

| Quantity | mm Value | cm Value |
|----------|----------|----------|
| B meson flight distance | ~1 | ~0.1 |
| Tau lepton flight distance | ~0.1 | ~0.01 |
| Typical vertex resolution | ~0.01-0.1 | ~0.001-0.01 |

## Complete Example

```julia
using HepMC3

# Create event with standard LHC units
event = create_event(1)
set_units!(event, :GeV, :mm)

# Verify units
println("Momentum unit: $(momentum_unit(event))")
println("Length unit: $(length_unit(event))")

# Create beam protons (7 TeV each)
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 4)   # Forward proton
p2 = make_shared_particle(0.0, 0.0, -7000.0, 7000.0, 2212, 4)  # Backward proton

# Create hard scatter products
z_boson = make_shared_particle(50.0, 30.0, 200.0, 220.0, 23, 2)

# Create primary vertex at origin
v1 = make_shared_vertex()
set_vertex_position(v1, 0.0, 0.0, 0.0, 0.0)
set_vertex_status!(v1, 4)  # Beam vertex

connect_particle_in(v1, p1)
connect_particle_in(v1, p2)
connect_particle_out(v1, z_boson)
attach_vertex_to_event(event, v1)

# Create Z decay products
electron = make_shared_particle(25.0, 15.0, 100.0, 102.0, 11, 1)
positron = make_shared_particle(25.0, 15.0, 100.0, 102.0, -11, 1)

# Create decay vertex (slightly displaced)
v2 = make_shared_vertex()
set_vertex_position(v2, 0.001, 0.001, 0.01, 0.0001)  # Position in mm
set_vertex_status!(v2, 2)  # Decay vertex

connect_particle_in(v2, z_boson)
connect_particle_out(v2, electron)
connect_particle_out(v2, positron)
attach_vertex_to_event(event, v2)

# Print summary
println("\nEvent summary:")
println("  Particles: $(particles_size(event))")
println("  Vertices: $(vertices_size(event))")

for i in 1:particles_size(event)
    p = get_particle_at(event, i)
    props = get_particle_properties(p)
    println("  Particle $i: PDG=$(props.pdg_id), pT=$(round(props.pt, digits=2)) GeV")
end
```

## API Reference

### Setting Units

```@docs
set_units!
```

### Querying Units

```@docs
momentum_unit
length_unit
```

### Unit Constants

```@docs
GEV
MEV
MM
CM
GeV
MeV
mm
cm
```
