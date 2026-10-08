## Why

A user has no built-in way to see whether a fitted model reproduces its data.
`posterior_predict()` returns the replicates, but turning them into a check
needs bayesplot and knowledge of its functions. Most kelpbio users are not
statisticians, so the check should be one call that flags gross misfit: the
wrong shape, the wrong units, excess zeros, or data errors.

## What Changes

- `pp_check()` on any fit returns a plot overlaying the density of the observed
  data on the densities of replicate datasets from the posterior predictive
  distribution, following the bayesplot convention used by brms and rstanarm.
- `type = "response"` (the default) compares the recorded response;
  `type = "residual"` compares deviance residuals, observed against those of the
  replicates.
- `ndraws` sets the number of replicates drawn (default 50).
- `pp_check()` is re-exported, so it works after `library(kelpbio)`; bayesplot
  moves from Suggests to Imports.

## Non-goals

- Statistical summaries of the check (a table of moments or s-values).
- Other bayesplot check types (grouped, ECDF, rootogram, LOO-PIT); users can call
  bayesplot directly with `posterior_predict()`.
- Checks at new data.
