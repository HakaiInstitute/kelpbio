## Why

The Stan ecosystem's standard check for observations that a model predicts
poorly or that strongly influence the fit is Pareto-smoothed importance-sampling
leave-one-out cross-validation (PSIS-LOO; Vehtari et al. 2017). `log_lik()`
already returns the pointwise log-likelihood, but a user must know to pass it to
the loo package with the right relative efficiencies, which needs the fit's
chain structure. brms and rstanarm make `loo()` work on a fit directly.

## What Changes

- `loo()` on any fit returns the loo package's `psis_loo` object, computed
  from the stored draws with relative efficiencies from the fit's chains. Its
  pointwise values give each observation's expected log predictive density and
  Pareto k diagnostic, and `loo_compare()` compares fits of the same
  response.
- `loo()` and `loo_compare()` are re-exported, so they work after
  `library(kelpbio)`, following brms and rstanarm; loo moves from Suggests to
  Imports.

## Non-goals

- A per-observation influence table or `augment()` columns for flagging
  influential rows; deferred to poissonconsulting/kelpbio#12.
- Moment matching, reloo, or K-fold cross-validation, which need the live model
  or refits.
