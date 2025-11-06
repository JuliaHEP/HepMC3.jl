# Units

HepMC3 uses explicit units for momentum and position. All events must have units set before use.

## Setting Units

### Using Symbols (Recommended)

```julia
set_units!(event, :GeV, :mm)
```

### Using Constants

```julia
set_units!(event, GeV, mm)
```

## Available Units

### Momentum Units

- `:GeV` or `GEV`: Gigaelectronvolts
- `:MeV` or `MEV`: Megaelectronvolts

### Length Units

- `:mm` or `MM`: Millimeters
- `:cm` or `CM`: Centimeters

## Unit Constants

You can also use the exported constants directly:

```julia
using HepMC3

# Momentum units
GEV  # Gigaelectronvolts
MEV  # Megaelectronvolts

# Length units
MM   # Millimeters
CM   # Centimeters
```

## Examples

### Setting Units on Event Creation

```julia
# Create event and set units immediately
event = create_event(1)
set_units!(event, :GeV, :mm)
```

### Using Different Unit Combinations

```julia
# GeV and mm (common for LHC)
event1 = create_event(1)
set_units!(event1, :GeV, :mm)

# MeV and cm (alternative)
event2 = create_event(2)
set_units!(event2, :MeV, :cm)
```

### Using Constants

```julia
event = create_event(1)
set_units!(event, GEV, MM)
```

## Unit Consistency

**Important**: All momentum and position values in an event must use the same units as specified when setting units. For example, if you set units to `:GeV` and `:mm`:

- Momentum components (px, py, pz, E) should be in GeV
- Position components (x, y, z, t) should be in mm

## Example: Working with Units

```julia
using HepMC3

# Create event with GeV and mm
event = create_event(1)
set_units!(event, :GeV, :mm)

# Create particles (momentum in GeV)
p1 = make_shared_particle(0.0, 0.0, 7000.0, 7000.0, 2212, 3)  # 7 TeV proton

# Create vertex (position in mm)
v1 = make_shared_vertex()
set_vertex_position(v1, 0.0, 0.0, 0.0, 0.0)  # Position in mm

connect_particle_in(v1, p1)
attach_vertex_to_event(event, v1)

# All values are consistent with :GeV and :mm units
```

## Unit Conversion

If you need to convert between units, do so before creating particles or setting positions:

```julia
# Convert MeV to GeV
momentum_gev = momentum_mev / 1000.0

# Convert cm to mm
position_mm = position_cm * 10.0
```

## API Reference

```@docs
set_units!
GEV
MEV
MM
CM
GeV
MeV
mm
cm
```

