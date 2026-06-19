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

- Per-model prediction is `rvar` arithmetic in one helper, `.weight_linpred()`
  (the single R source of truth for the mean; the Stan `transformed parameters`
  block is the only other place the mean is defined).
- The `rstantools` generics (`posterior_linpred`/`posterior_epred`/
  `posterior_predict`/`log_lik`) are thin faces over that helper, returning
  `D x N` matrices for ecosystem interop (`bayesplot`, `loo`).
- Prediction grids are built with `newdata::xnew_data`; predictors enter on a
  fixed-reference transform (`log(diameter) - log(30)`) with no rescaling step.
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
- The mean is defined once per model in `.weight_linpred()`; every consumer
  (generics, `augment`, `kb_predict_*`, biomass) calls it, so it is never
  re-implemented.
- The biomass kernel may drop to `posterior::draws_of()` matrices for speed where
  needed; the result is identical and re-wrapped as an `rvar`.
- Conditioning is a property of the prediction grid's columns, not a separate
  argument: `.weight_linpred()` conditions on a random-effect factor when its
  grouping column is present in the grid and applies `new_levels`
  (`"sample"`/`"average"`) to factors with no column. The `rstantools` generics
  therefore take no `by` argument (conditioning is inferred from `newdata`,
  matching the ecosystem; `newdata = NULL` conditions on the observed groups);
  `by` survives only on `kb_predict_weight()` as the grid-construction control.
  Later sub-models follow the same "condition on the columns present" rule.
