## Why

Biomass integrates the weight allometry over the size distribution of the plants
at a site-year (`decisions/prediction-engine.md`), so kelpbio needs a size model
for each species before it can estimate biomass. The analysis project's production
size models are a Weibull on maximum sub-bulb diameter for *Nereocystis* and a
zero-truncated negative binomial on the number of fronds at 1 m for *Macrocystis*.
Both have site, year, site:year, and month random effects on the log mean.

## What Changes

- New fit functions `kb_fit_size_nereo()` and `kb_fit_size_macro()`, with
  `kb_check_data_size_nereo()`, `kb_check_data_size_macro()`,
  `kb_priors_size_nereo()`, and `kb_priors_size_macro()`. These follow the weight
  models' data-check, prior, sampler, progress, and fit-object behaviour
  unchanged.
- *Nereocystis*: `diameter` (mm, > 0) follows a Weibull distribution with a
  constant shape, parameterised by its mean. *Macrocystis*: `fronds` (a positive
  whole number) follows a zero-truncated negative binomial distribution. For both,
  the log mean varies by site, year, and site:year (included or omitted from the
  data as for weight). The analysis month effect is dropped (site-year
  resolution, as for weight).
- New prediction verbs `kb_predict_size(fit, new_data)` and
  `kb_predict_size_by(fit, by)`, plus `predict()`. They return the expected size
  (the distribution mean) at supplied rows or per group, with the same group
  resolution (`new_levels`, `representative_site`) and summary arguments as the
  weight verbs. There is no continuous predictor, so `_by` predictions are grouped
  points.
- Every existing `kb_fit` method (`tidy`, `coef`, `glance`, `summary`, `print`,
  `augment`, `fitted`, `residuals`, `log_lik`, `posterior_*`, `samples`,
  `kb_model_describe`, `kb_stancode`) works on size fits.
- `kb_plot_predictions()` draws size predictions as point ranges by group.
- Bundled `data_size_sim_nereo`, `data_size_sim_macro`, `fit_size_sim_nereo`, and
  `fit_size_sim_macro`, with test fixtures.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the fit requirement covers the size models, and the input data,
  priors, and bundled objects requirements gain the size entries.
- `predictions`: the prediction verbs, group-resolution defaults, expected-value
  generics, plotting, and new-data validation cover size.
- `summaries`: fitted values, print, and the unsupported-object errors are stated
  for any response, not only weight.

## Non-goals

- The biomass composition (size integration of weight), and any verb returning
  the size distribution itself (density over a size grid, stratified draws). Draws
  of plant size are available from `posterior_predict()`.
- The month effect, and nearest-month substitution.
- The *Nereocystis* cumulative blade length size model.
- A shape that varies by group, or any covariate on size.
- Truncating drawn sizes at a physiological ceiling or floor. The analysis
  applies this in the biomass step, not in the size model.

## Impact

- New: `inst/stan/size_nereo.stan`, `inst/stan/size_macro.stan` (recompiled at
  install), one file per new exported function, simulated data and fits under
  `data/` and `data-raw/`, and test fixtures.
- Methods added to the existing internal generics for the new classes; no change
  to the weight models' numbers or outputs.
- `print.md`, `summary.md`, and `kb_model_describe.md` snapshots gain size cases.
- New internal Weibull and zero-truncated negative binomial helpers, to move to
  `extras` later (see design.md).
- `_pkgdown.yml` gains the size functions. README and vignette updates are deferred until all sub-models are in place.
