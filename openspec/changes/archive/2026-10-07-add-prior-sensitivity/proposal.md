## Why

Users need to know whether a fitted model's estimates come from their data or from
the default priors, especially with the small datasets kelpbio is fitted to (a few
sites and years). The analysis project reports power-scaling prior sensitivity
(priorsense, through `embr::sensitivity()`) for every sub-model, and kelpbio fits
currently offer no equivalent. A fit already stores what power-scaling needs: the
posterior draws with their chains, the priors, and the pointwise log-likelihood
from `log_lik()`. Since every prior entry is named after the parameter it sets
(`decisions/parameter-naming.md`), a sensitivity row's `term` also names the prior
to change.

## What Changes

- New `kb_sensitivity(fit, ..., prior_threshold = 0.1, likelihood_threshold = 0.05)`
  returning one row per estimated parameter that has a prior: `term`, `prior_cjs`
  and `likelihood_cjs` (the power-scaling sensitivity to the prior and to the
  likelihood), and the flags `weak_prior` (`prior_cjs` below `prior_threshold`) and
  `strong_data` (`likelihood_cjs` at or above `likelihood_threshold`). The default
  thresholds are the ones the analysis project reports with, so kelpbio and report
  numbers agree.
- priorsense's own functions (`powerscale_sensitivity()`, `powerscale_plot_dens()`,
  `powerscale_plot_quantities()`, and the rest) accept a `kb_fit` directly.
- priorsense joins Suggests; `kb_sensitivity()` errors with an install hint when it
  is missing.
- `kb_sensitivity()` errors on a prior-only fit (there is no likelihood to scale)
  and on a fit with no observations.
- Works for every sub-model: weight, size, density, wet/dry, carbon, and cover
  biomass, for both species.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `summaries`: a new prior-sensitivity requirement; the unsupported-object errors
  and the estimated-effects-only requirement gain `kb_sensitivity()`.

## Non-goals

- Changing any default prior. This change reports sensitivity; prior revisions,
  if any are needed, are separate model changes.
- Sensitivity of individual random-effect levels or of derived quantities
  (predictions, biomass). Only the parameters a user can set a prior on are
  reported, as in the analysis project.
- Suggesting replacement priors; choosing new values stays with the user.
- A `kb_` plotting function for sensitivity: priorsense's plots work on a fit.

## Impact

- New exported `kb_sensitivity()` and an S3 method on priorsense's
  `create_priorsense_data()` generic (registered only when priorsense is
  installed).
- DESCRIPTION (priorsense in Suggests), `_pkgdown.yml`, NAMESPACE, the demo
  script.
- No Stan, data, fit-object, pre-fit, or fixture changes.
- kelpbioshiny can show the table and highlight flagged parameters next to the
  prior inputs of the same name.
