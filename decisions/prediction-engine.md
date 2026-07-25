# Decision: prediction / derived-quantity engine is posterior `rvar`

Status: accepted (2026-06)

## Context

kelpbio must (1) predict from a fitted model with `by` (grouping) and
`uncertainty` (marginal/typical) axes, and (2) compose independently-fit
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

- Per-model prediction is `rvar` arithmetic in one helper, `.weight_nereo_linpred()`
  (the single R source of truth for the mean; the Stan `transformed parameters`
  block is the only other place the mean is defined).
- The `rstantools` generics (`posterior_linpred`/`posterior_epred`/
  `posterior_predict`/`log_lik`) are thin faces over that helper, returning
  `D x N` matrices for ecosystem interop (`bayesplot`, `loo`).
- Prediction grids are built with `newdata::xnew_data`; the predictor enters on a
  stored-reference transform (`log(diameter) - log(diameter_ref)`, where
  `diameter_ref` is the geometric mean of the observed diameter, computed at fit
  time and stored in `meta$diameter_ref`) with no per-newdata rescaling step.
  Centering log-diameter at its mean makes the diameter unit immaterial.
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
  `by`/`uncertainty`/arbitrary-`new_data` combinatorics are rigid and require
  recompilation. Held in reserve only for the biomass kernel if it ever becomes a
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

- Dependencies: `posterior` (rvar + draws + diagnostics), `newdata` (grids),
  `rstantools` (the prediction generics). No `mcmcr`/`mcmcderive` engine.
- The mean is defined once per model in `.weight_nereo_linpred()`; every consumer
  (generics, `augment`, `kb_predict_*`, biomass) calls it, so it is never
  re-implemented.
- The biomass kernel may drop to `posterior::draws_of()` matrices for speed where
  needed; the result is identical and re-wrapped as an `rvar`.
## Cross-model prediction contract

Prediction is split into two verbs per model, with independent arguments so no
`by` + `new_data` combination is representable (tidyverse argument independence;
the `fct_lump_n`/`fct_lump_prop` precedent):

- **`kb_predict_<model>(fit, new_data, new_levels)` + `predict()`** - predict at
  the rows you supply (or the observed data when `new_data = NULL`, matching base
  R `predict()`). The genuinely-new capability: turn cheaply-measured predictors
  into the expensive response without re-fitting. Most useful for the
  continuous-predictor models (weight, blade fraction), where the predictor
  (diameter) is the cheap field measurement; the bare verb is valid but rarely
  needed where the response is measured directly (density, size).
- **`kb_predict_<model>_by(fit, by, new_levels)`** - the grid-free, `by`-driven
  summary; the function builds the design grid (no user grid construction). It
  renders as a curve over the continuous predictor (weight, blade) or grouped
  points (density, size). Exists wherever the model has grouping factors.
- Scalar, intercept-only models (wet/dry, carbon) have only the bare verb (the
  population estimate); no `_by`. The size model returns a distribution and needs
  its own pass.

`augment()` stays a diagnostics verb (fitted/residuals on the training data), not
a prediction entry point.

Conditioning is resolved **per row, per factor** by level membership, in the
shared `.weight_nereo_linpred()` engine: a row whose grouping level is known is
conditioned on its estimated random effect; a new level, or an absent grouping
column, is handled by `new_levels` (`"sample"` draws `Normal(0, sd)`, `"average"`
zeroes it). Known levels condition regardless of `new_levels`. This makes a mix
of observed and new groups resolve in a single call (no bind), and lets the
`rstantools` generics infer conditioning from `newdata` columns with no `by`
argument. `new_levels` defaults to `"sample"` so an unseen group carries honest
between-group uncertainty; `"average"` is opt-in and reports the typical group,
not a calibrated interval for the specific new group. Later sub-models follow
this same contract.
