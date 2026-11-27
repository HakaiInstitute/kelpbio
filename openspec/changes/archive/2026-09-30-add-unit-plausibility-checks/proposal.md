## Why

The models assume fixed units: sub-bulb diameter in millimetres, wet weight in
kilograms, and stipe density in stipes per m². Data in another unit (centimetres,
grams, stipes per hectare) still fit and predict without error, but give wrong
results. These mistakes are off by a factor of 10 to 10,000, so a range check
catches them.

## What Changes

- The data checks (`kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`),
  and so the fit functions, warn when the median of `diameter`, `weight`, or
  `density` falls outside the range plausible in its expected unit, naming the
  column, its median, and the expected unit.
- Prediction warns when supplied predictor values lie below half the fitted
  minimum or above twice the fitted maximum, or density values above twice the
  fitted maximum.
- Warnings only: a valid but unusual dataset is never blocked.

## Capabilities

### Modified Capabilities

- `fitting`: data checks warn on implausible units.
- `predictions`: prediction warns on values far outside the fitted range.

## Non-goals

- Converting units, or a `units` argument.
- Detecting small-factor mistakes (inches, pounds), which a range check cannot
  separate from real variation.
- A check on `fronds`, a count with no unit.

## Impact

- `R/kb_check_data_weight_nereo.R`, `R/kb_check_data_weight_macro.R`, the
  prediction grid paths, and new helper files. No model or Stan change.
