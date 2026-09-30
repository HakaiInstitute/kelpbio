## Why

The simulated *Nereocystis* weight data leave density unrecorded for three
site-years. In practice a survey programme either pairs every harvest with a
density survey or records none, so partial density is an unusual case. Leading
with it makes the bundled data, the default fit's messages, and the examples
less representative of what users will see.

## What Changes

- `data_weight_sim_nereo` records density for every site-year.
- `fit_weight_sim_nereo` and the *Nereocystis* test fixture are refitted to it.
- Partial density remains supported and tested on constructed data.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the bundled *Nereocystis* weight data have complete density.

## Non-goals

- Any change to how missing density is handled in fitting or prediction.
