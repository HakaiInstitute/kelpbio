# Decision: prediction / derived-quantity engine is posterior `rvar`

Status: accepted (2026-06)

## Context

kelpbio must (1) predict from a fitted model with `by` (grouping) and
`new_levels` (new group sampled or averaged) axes, and (2) compose independently-fit
sub-models into a derived biomass-per-group estimate by Monte-Carlo integrating
the weight allometry over the size distribution. The package fits via rstan and
stores extracted draws (not the live `stanfit`); the companion Shiny app makes
prediction latency matter; the code is reviewed by a statistician familiar with
the Poisson Consulting `mcmcr`/`mcmcderive` idiom.

Candidate engines, all consuming the same stored draws: (A) hand-written
vectorised R over `posterior` draws matrices; (B) Stan `generated quantities` via
`rstan::gqs`; (C) `mcmcderive::mcmc_derive` with a `new_expr`; (A-rvar)
`posterior::rvar` arithmetic; (bbou) the bboutools-style `mcmcr` stack.

## Decision

Build the engine on the **`posterior` `rvar` datatype**:

- Per-model prediction is `rvar` arithmetic in one internal generic, `.linpred()`
  (the single R source of truth for the mean; the Stan `model` block is the only
  other place the mean is defined), with one method per fit
  subclass in `R/linpred.R`.
- The `rstantools` generics (`posterior_linpred`/`posterior_epred`/
  `posterior_predict`/`log_lik`) are thin faces over that helper, returning
  `D x N` matrices for ecosystem interop (`bayesplot`, `loo`).
- Grids of rows to predict at are built by `kb_new_data()` (`tibble::tibble()`
  plus `dplyr::cross_join()`), which crosses the grouping levels named in `by`
  with the fit's predictor sequence. Either side may be absent, so one builder
  covers a curve model and a grouped-points model with no continuous predictor.
  An earlier draft of this record specified `newdata::xnew_data`; the dependency
  was never taken, because the grids kelpbio needs are a cross join over the
  fit's own stored levels and `xnew_data` is built for deriving a grid from a data
  frame of covariates.
- The predictor enters relative to a reference stored at fit time (the geometric
  mean of the observed predictor, `meta$predictor_ref`), with no per-new_data
  rescaling step: *Nereocystis* uses `diameter / d0`, *Macrocystis*
  `log(fronds) - log(f0)`. Expressing the predictor relative to its reference makes
  its unit immaterial.
- A rate model carries a log-scale offset (density is counts over a surveyed
  area). The offset column is named by `meta$offset`, set at fit time, and the
  offset is `log()` of that column read from the grid. It is added while the
  linear predictor is still an `rvar` over grid rows, so it broadcasts
  elementwise; adding it to a `D x N` draws matrix would recycle down columns.
  `.linpred()` itself stays offset-free, so the mean still has one definition.
- The offset comes from the grid: rows carrying the offset column (the observed
  transects, or user rows with `area_m2`) use it, and rows without it take one
  unit, whose log is zero. The draw generics (`posterior_*()`) therefore return
  counts on the supplied transects, or per m² when no area is given. The density
  verb drops the offset at any rows, so it always reports density per m²: a
  verb's unit never depends on its input, and the expected count on a transect is
  the per-m² estimate and limits times its area, since the expected count is
  linear in area. The neutral value is always `1` because the offset always
  enters as `log()`.
- Summaries, `augment()`, and the biomass composition all reuse the same engine;
  there is no bespoke `_samples()` function.

(The observable behaviour of these functions lives in the `predictions`,
`summaries`, and `fitting` specs; this record is the rationale only.)

## Rationale

A benchmark (`scripts/benchmark-prediction-methods.R`) compared the engines on
the same fits for speed and validity (recovery of a closed-form truth, two-model
biomass composition). All engines recovered truth and agreed; the differences
were speed, dependencies, and code clarity:

- **mcmcderive (C)** evaluates the expression per draw (split-apply-combine), so
  cost scales linearly with draws: ~130x slower than vectorised on prediction at
  realistic grid sizes. Ruled out for a latency-sensitive app, despite being the
  familiar house idiom.
- **Stan GQ (B)** is fastest on the heavy biomass integral (compiled), but
  composing independently-fit models forces bespoke `gqs` plumbing, and the
  `by`/`new_levels`/arbitrary-`new_data` combinatorics are rigid and require
  recompilation. Held in reserve only for the biomass composition if it ever becomes a
  measured bottleneck.
- **raw matrices (A)** are fastest and lightest but require manual draw-vs-data
  broadcasting (`outer`/`sweep`), whose row/column asymmetry is a silent-wrong-
  answer footgun in reviewed code.
- **`rvar` (A-rvar)** keeps near-matrix speed (the draw dimension is array-backed,
  no per-draw loop; ~3 ms vs 1 ms on prediction, ~1.3x on the biomass integral)
  while the per-model math reads as the model equation with the draw dimension
  hidden, so it is the most reviewable and least bug-prone. It is a standard
  `posterior` datatype, so no extra house dependency.

Only the production `rvar` paths are used (native operators, `rvar_rng`, the
`rvar_*` reducers, over-draws summaries); the prototyping helpers `rfun`/`rdo`/
`for_each_draw` are avoided.

## Consequences

- Dependencies: `posterior` (rvar + draws + diagnostics), `dplyr`/`tibble`
  (grids), `rstantools` (the prediction generics). No `mcmcr`/`mcmcderive`
  engine, and no `newdata`.
- The mean is defined once per model in its `.linpred()` method; every consumer
  (generics, `augment`, `kb_predict_*`, biomass) calls it, so it is never
  re-implemented.
- The biomass composition may drop to `posterior::draws_of()` matrices for speed where
  needed; the result is identical and re-wrapped as an `rvar`.
## Cross-model prediction contract

Every model has one prediction verb, `kb_predict_<model>(fit, new_data)`, meaning
"the expected response at these rows" (the observed data when `new_data = NULL`,
matching base R `predict()`), in the model's natural quantity. Rows by group, or
over a predictor sequence, come from `kb_new_data(fit, by, ...)`, passed as
`new_data`:

```r
kb_predict_weight(fit)                                     # observed plants
kb_predict_weight(fit, kb_new_data(fit, by = "site"))      # curves by site
kb_predict_weight(fit, plants)                             # your own rows
```

- This follows modelr (`data_grid()` then `add_predictions()`) and tidymodels
  (`predict(fit, new_data)`, one row per input row), and keeps `new_data` and
  `by` off the same function (tidyverse design guide: no mutually exclusive
  arguments). It replaced a row-wise verb plus a `_by` verb per model, whose
  split meant something different for each model (predictor values for weight,
  site/year rows for size, a transect count versus a density for density) and
  whose `new_levels` defaults differed. `_by` wrappers can be added later without
  breaking code, as exact one-line wrappers over `kb_new_data()`.
- The verbs stay model-named rather than one generic `kb_predict()`: when a
  pre-fit model is loaded in a reviewed script, the call names the model in play.
  They are plain functions that check the fit class, not S3 generics.
- `kb_new_data()` takes the species predictor by its column name through `...`
  (`diameter_mm` or `fronds`) and checks it against the fit, so no species
  dispatch is needed. It marks its grid as a curve, and the mark travels into the
  `kb_predictions` object so `kb_plot_predictions()` draws a ribbon only for
  curves: observed plants also vary in diameter, so the data alone cannot say.
- Density reports per m² everywhere it is summarised (see the offset above);
  transect counts come from the draw generics.
- Scalar, intercept-only models (wet/dry, carbon) take no `new_data` and return
  the population estimate.
- The size models have no predictor, so the verb reports the expected size (the
  mean of the size distribution). The distribution itself is reached through
  `posterior_predict()`; the biomass composition draws from it per draw rather
  than through a prediction verb.

`augment()` stays a diagnostics verb (fitted/residuals on the training data, on
the observation scale), not a prediction entry point.

Conditioning is resolved **per row, per factor** by level membership, in the
shared `.linpred()` engine: a row whose grouping level is known is
conditioned on its estimated random effect; a new level, or an absent grouping
column, is handled by `new_levels` (`"average"` zeroes it, `"sample"` draws
`Normal(0, sd)`). Known levels condition regardless of `new_levels`. This makes a
mix of observed and new groups resolve in a single call (no bind), and lets the
`rstantools` generics infer conditioning from the `new_data` columns with no `by`
argument. `"average"` is the default for every verb and the draw generics: with
a grid that has no `site` column the typical site is what users usually mean,
and the result needs no seed. `"sample"` gives a calibrated interval for a
specific new group and is documented for that case. The biomass composition
defaults to `"sample"`, since its rows are always specific surveyed site-years,
and its limits become the measurement error of a cover biomass fit. Later sub-models follow this same contract.
