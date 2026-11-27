## Why

The *Nereocystis* weight model carries an optional site-year stipe density
covariate on the allometric intercept. It does not improve prediction at
harvested site-years, where the site:year effect already absorbs it. It helps at
unharvested site-years only modestly: in leave-site-out cross-validation on the
Hakai Institute harvests (28 sites, 46 site-years; analysis project
`compare-weight-nereo-density-cv.R`), the mean log-weight error of a held-out
site-year fell from 0.29 to 0.24 RMSE, with the gain concentrated at a few
high-density site-years.

Against that, the covariate ties a fit to one density survey protocol: a
pre-fit model applied to another programme's data is only valid when that
programme measures stipe density the same way. A site-year without density takes
the fitted mean while the site:year variance excludes what density explained, so
its interval is too narrow. The term is also the only covariate shared between
sub-models (plot biomass passes the density fit's observed density into the
weight fit) and the only *Nereocystis*/*Macrocystis* asymmetry in the weight
models. Without it, the weight model depends only on diameter, site, and year,
and a pre-fit applies to any programme that measures diameter the same way.

## What Changes

- **BREAKING** The *Nereocystis* weight model has no density effect. A
  `stipes_m2` column in weight data or `new_data` is ignored like any other extra
  column, and is no longer validated.
- `kb_priors_weight_nereo()` drops `density_slope`.
- `kb_predict_plot_biomass()` no longer passes the density fit's observed density
  to the weight fit, and no longer warns about it.
- `data_weight_sim_nereo` drops `stipes_m2`; `fit_weight_sim_nereo` and the test
  fixture are refitted.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: input data, fitted effects, priors, bundled objects, unit checks,
  and the weight form no longer mention density.
- `predictions`: the per-row density requirement is removed; group resolution,
  draws, the out-of-range warning, and plot biomass no longer mention it.
- `summaries`: omitted effects, model description, and draws no longer mention
  density.

## Non-goals

- No change to the density sub-models (`kb_fit_density_*()`).
- No change to the analysis project's production weight model.
- No replacement covariate.

## Impact

- `inst/stan/weight_nereo.stan` (recompile) and the weight pre-fit and fixture
  (MCMC rebuild with `--fits=weight`).
- Removes `R/density_structure.R` and `R/standardised_density.R` and the
  density paths through fitting, prediction, plot biomass, validation, and
  model description.
