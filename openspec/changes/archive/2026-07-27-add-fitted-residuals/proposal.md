## Why

A fitted-vs-residual diagnostic on the weight model currently has to go through
`augment()`, whose `residual` column is a raw response residual (`weight -
fitted`, kg). Because the model is multiplicative (Student-t on `log(weight)`),
that residual fans out with the fitted value and is hard to read. The base
`stats::fitted()` and `stats::residuals()` generics, which users reach for first,
are not implemented.

## What Changes

- Add `fitted(object)`: posterior point estimates of expected weight at the
  observed rows, response scale (the posterior median of `posterior_epred()`),
  returned as a numeric vector.
- Add `residuals(object)`: deviance residuals from the Student-t log-weight
  likelihood, returned as a numeric vector. Computed with `extras::res_student()`
  so the definition matches the validated analysis project exactly.
- **BREAKING** `augment()`'s `residual` column becomes the deviance residual
  (was the raw response residual); `augment()` delegates to `fitted()` /
  `residuals()` so the values cannot drift, and no longer adds `lower`/`upper`
  (use `kb_predict_weight()` for intervals).
- Add `extras` to Imports.
- Store `nu` (the fixed Student-t degrees of freedom) in the fit `meta` so the
  residual uses `theta = 1 / nu` rather than a hard-coded constant; rebuild the
  shipped `fit_weight` and the test fixture.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `summaries`: add the `fitted()` and `residuals()` methods and redefine the
  `augment()` `residual` column as the deviance residual.

## Impact

- New `R/fitted.R`, `R/residuals.R`; `augment.kb_fit_weight()` refactored to
  delegate. New dependency `extras` (poissonconsulting R-universe; deps `chk`,
  `lifecycle`, `stats`). `new_kb_fit_weight()` gains `meta$nu`; `fit_weight.rda`
  and `tests/testthat/fixtures/weight_fit.rds` rebuilt (no Stan recompile).
- No change to the Stan model, sampling, priors, or the prediction engine.

## Non-goals

- No `type` argument on `residuals()` (deviance only, kept simple).
- No change to `fitted()`/`residuals()` for other (future) model subclasses.
- No randomized-quantile or Pearson residual variants.
