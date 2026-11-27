## Why

`loo(fit)` gives each observation's Pareto k and leave-one-out predictive
density, but reading them needs the loo package's objects and knowledge of the
Pareto k threshold. Most kelpbio users are not statisticians, and the kelpbioshiny
app needs a table it can show beside convergence and prior sensitivity, so a user
can see which observations strongly influence the fit and check them for
recording errors.

## What Changes

- `kb_influence(fit, ..., threshold = 0.7)` returns the fitted data with each
  observation's `elpd_loo` (log predictive density with the observation left
  out), `pareto_k` (its influence on the fit), and an `influential` flag
  (`pareto_k` above `threshold`), following `kb_sensitivity()`.

Addresses poissonconsulting/kelpbio#12.

## Non-goals

- `pareto_k` and `elpd_loo` columns in `augment()`, which would make every
  `augment()` call run PSIS.
- A flag for poorly predicted observations: `elpd_loo` is on the scale of the
  response's units, so no single threshold applies.
- Refitting without an observation (reloo) or moment matching.
