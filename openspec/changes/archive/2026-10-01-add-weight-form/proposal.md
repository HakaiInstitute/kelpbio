## Why

The *Nereocystis* weight model fits a three-parameter power function of
diameter (Packard 2008): a power law plus a size-independent weight floor. A
user may want the simpler two-parameter power law, the conventional allometry,
for comparison with published allometries or for data without the small plants
that identify the floor. The analysis project compared both forms
(`models-weight-nereo-form.R`). The choice should be an argument that can take
further forms later, not a flag.

## What Changes

- `kb_fit_weight_nereo()` gains `form`, a string: `"packard_floor"` (the default, the
  current model) or `"power"` (a power law in diameter, with no floor). An
  invalid value errors listing the available forms.
- Under `"power"`, expected weight is `alpha * (diameter / d0)^bPower`, with the
  same Normal likelihood on log weight, the same random effects and optional
  density effect on `log(alpha)`, and the same priors. `bFloor` is not fitted, so
  it is absent from the draws, summaries, convergence, and model description,
  and the `floor` prior is unused.
- Predictions, `log_lik()`, `residuals()`, and `posterior_predict()` follow the
  fitted form.
- `kb_model_describe()` shows the fitted form in notation and prose.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: a requirement for the weight functional form.
- `summaries`: an effect omitted because of the form is not reported, like one
  omitted because of the data.

## Non-goals

- A `form` argument for *Macrocystis* weight, which is already a power law in
  frond count.
- Forms other than these two (quadratic, cubic, spline, exponential).
- Model comparison helpers; `log_lik()` already supports `loo::loo()` on two
  fits.
- A pre-fit example of the power law.
