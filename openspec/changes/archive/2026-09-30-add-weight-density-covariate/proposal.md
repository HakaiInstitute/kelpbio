## Why

The analysis project's production *Nereocystis* weight model carries a site-year
stipe density covariate on `log(alpha)`: at a given diameter, plants in denser
stands weigh less (`bDensity` -0.159, -0.243 to -0.073, per SD of density). kelpbio
matches that model in every other term. Density surveys are not available for
every harvested site-year, so the covariate must be optional: a user without
density data fits the model without the term, and a user with density for some
site-years uses what they have.

## What Changes

- `data` for `kb_fit_weight_nereo()` gains an optional `density` column (stipes per
  m²), a site-year value. A missing column or an all-`NA` column omits the density
  term.
- When density is present, `log(alpha)` gains `bDensity * density_std`, where
  `density_std` is density standardised by its mean and SD over the fitted plants.
  Site-years with no recorded density take the mean (`density_std = 0`), with an
  informational message.
- The term is gated by a data-determined `density_on` flag in the Stan data block,
  following the `site_year_on` pattern; it is recorded in `meta$density_on`. It is
  also off when every recorded site-year has the same density.
- `meta` stores the standardisation (`density_mean`, `density_sd`) and the recorded
  density of each fitted site-year.
- Predictions resolve density per row: a supplied `density` value, else the stored
  value for a fitted site-year, else the fitted mean. `new_data` may carry
  `density`; it is ignored for a fit without the term.
- `kb_priors_weight_nereo()` gains `density = kb_prior_normal(0, 0.5)`.
- `tidy()`, `summary()`, and `kb_model_describe()` include `bDensity` only when the
  term is on.
- `kb_check_data_weight_nereo()` validates `density` when present: numeric,
  non-negative, and at most one distinct value per site-year.
- `data_weight_sim_nereo` gains a `density` column with a few unrecorded
  site-years; `fit_weight_sim_nereo` and the test fixture are refitted.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the *Nereocystis* fit accepts optional density and records
  `density_on` and the standardisation in `meta`.
- `data`: `kb_check_data_weight_nereo()` validates the optional `density` column;
  the bundled dataset gains it. Also states the mm/kg units, which the current
  requirement still describes as the user's choice.
- `priors`: the default *Nereocystis* prior list gains `density`. The current
  requirement still lists the pre-Packard entries and is rewritten.
- `stan-engine`: the weight model's mean gains the gated density term.
- `predictions`: density is resolved per prediction row.
- `summaries`: `bDensity` appears only when the term is on.
- `model-description`: the notation and prose show the density term when on.

## Non-goals

- A density covariate for *Macrocystis* (the analysis model has none).
- Latent (Bayesian) imputation of missing density, or drawing density for
  unrecorded site-years under `new_levels = "sample"`.
- Linking to a kelpbio density sub-model; density is a user-supplied covariate.
- The density covariate on blade fraction, which is not yet a kelpbio sub-model.
- Unit plausibility checks on `diameter` / `weight` (a separate change).

## Impact

- `inst/stan/weight_nereo.stan` (recompile), `R/kb_fit_weight_nereo.R`,
  `R/assemble_weight_nereo_data.R`, `R/kb_priors_weight_nereo.R`, `R/linpred.R`,
  `R/kb_check_data_weight_nereo.R`, `R/chk.R`/`R/vld.R` (new-data check),
  `R/kb_model_describe.R`, a new density helper file.
- `data/data_weight_sim_nereo.rda`, `data/fit_weight_sim_nereo.rda`,
  `tests/testthat/fixtures/weight_fit.rds` (MCMC rebuild).
- Fits made before this change have no `meta$density_on` and are treated as
  density-off.
- See `decisions/architecture.md` ("Meta Versus Dispatch") for why the density
  standardisation is stored in `meta`.
