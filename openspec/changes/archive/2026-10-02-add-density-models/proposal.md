## Why

Biomass per unit area is plant density times the expected weight of a plant at a
site-year, integrated over the size distribution (`decisions/prediction-engine.md`),
so kelpbio needs a density model for each species. The analysis project's
production density models are a zero-inflated negative binomial on *Nereocystis*
stipe counts and a negative binomial on *Macrocystis* plant counts, each counted on
diver transects of known area, with site, year, and site:year random effects on log
density.

## What Changes

- New fit functions `kb_fit_density_nereo()` and `kb_fit_density_macro()`, with
  `kb_check_data_density_nereo()`, `kb_check_data_density_macro()`,
  `kb_priors_density_nereo()`, and `kb_priors_density_macro()`. These follow the
  weight and size models' data-check, prior, sampler, progress, and fit-object
  behaviour unchanged.
- Input data are one row per transect: `stipes` (*Nereocystis*) or `plants`
  (*Macrocystis*), a whole-number count `>= 0`; `area_m2`, the area surveyed
  (m², > 0); `site`; and `year`. The expected count is density times area.
- *Nereocystis*: the count follows a zero-inflated negative binomial with one
  zero-inflation probability for all transects. *Macrocystis*: a negative binomial.
  For both, log density varies by site, year, and site:year (included or omitted
  from the data as for weight and size). The analysis month effect is dropped
  (site-year resolution).
- Default priors use round, weakly informative values for every species:
  `intercept` Normal(0, 2), `dispersion` Exponential(1), `sd_site`, `sd_year`, and
  `sd_site_year` Exponential(1), and for *Nereocystis* `zero_inflation`
  Normal(0, 2) on the logit scale.
- New prediction verbs `kb_predict_density(fit, new_data)` and
  `kb_predict_density_by(fit, by)`, plus `predict()`. `kb_predict_density()`
  returns the expected count at the supplied rows, so `new_data` must carry
  `area_m2`; `kb_predict_density_by()` returns density per m² by group. For
  *Nereocystis* the expected value includes the zero-inflation probability.
- Every existing `kb_fit` method works on density fits. `kb_plot_predictions()`
  draws density predictions as point ranges by group.
- `area_m2` joins the implausible-unit warning.
- Bundled `data_density_sim_nereo`, `data_density_sim_macro`,
  `fit_density_sim_nereo`, and `fit_density_sim_macro`, with test fixtures.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the fit, input data, priors, bundled objects, and implausible-unit
  requirements gain the density models.
- `predictions`: the prediction verbs, group-resolution defaults, expected-value
  generics, plotting, and new-data validation cover density.
- `summaries`: fitted values, the print header, and the unsupported-object errors
  cover density.

## Non-goals

- The month effect, transect or line effects, and any covariate on density.
- Zero inflation for *Macrocystis*, or a zero-inflation probability that varies by
  group.
- Aggregating bin-level counts to transects, or converting partial plants; the
  user supplies one count per transect.
- Feeding density predictions into the *Nereocystis* weight model's `stipes_m2`
  covariate, and the biomass composition.
- Reducing the bundled-object size budget (objects move to `kelpbiodata` later).

## Impact

- New: `inst/stan/density_nereo.stan`, `inst/stan/density_macro.stan` (recompiled
  at install), one file per new exported function, simulated data and fits under
  `data/` and `data-raw/`, and test fixtures.
- First use of the log-scale area offset (`decisions/prediction-engine.md`).
- Methods added to the existing internal generics for the new classes; no change to
  the weight or size models' numbers or outputs.
- `print.md`, `summary.md`, `kb_model_describe.md`, `chk.md`, and plot snapshots
  gain density cases.
- `_pkgdown.yml` gains the density functions. README and vignette updates are
  deferred until all sub-models are in place.
