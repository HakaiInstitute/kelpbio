## Why

The *Nereocystis* weight and size models fit any plant diameter that relates to weight as a power law, but the docs named the maximum sub-bulb diameter in some places and plain "sub-bulb diameter" in others, which reads as two different measurements and as a requirement to use one of them.

## What Changes

- `diameter_mm` is described as a plant diameter that relates to weight as a power law, such as the maximum sub-bulb diameter, the diameter 15 cm below the sub-bulb, or the bulb diameter, with the weight and size data using the same diameter.
- The prediction plot labels the axis "Diameter (mm)", and `kb_model_describe()` says "plant diameter".

## Non-goals

- No change to the models, the column name, or any check.
- The README and vignettes follow in their pending pass.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the input data describe `diameter_mm` as a plant diameter.
- `predictions`: the plot axis label and the size prediction wording.

## Impact

- Roxygen of the *Nereocystis* data checks, fits, `kb_predict_size()`, `fitted()`, and the simulated datasets; `kb_model_describe()`; the `kb_plot_predictions()` axis label (one plot snapshot and the `kb_model_describe()` snapshot).
