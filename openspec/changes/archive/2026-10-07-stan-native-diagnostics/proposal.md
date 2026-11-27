## Why

kelpbio's convergence and draw accessors come from `universals`, a set of
generics internal to Poisson Consulting. The package is for the general public,
whose users know the Stan ecosystem's vocabulary instead, and `universals`'
`rhat()` is masked by posterior's and bayesplot's whenever either is attached.

## What Changes

- **BREAKING** `rhat()`, `esr()`, `estimates()`, `npars()`, `nterms()`,
  `pars()`, `nchains()`, and `niters()` are removed, with `universals` as a
  dependency. Per-parameter Rhat and effective sample sizes come from
  `summarise_draws(fit)`; estimates from `tidy()` and `coef()`.
- `posterior`'s `nchains()`, `niterations()`, `ndraws()`, `nvariables()`, and
  `variables()` accept a fit and are re-exported, as `as_draws()` is.
- **BREAKING** `converged()` becomes `kb_converged()`, and its effective
  sample size check follows Vehtari et al. (2021) and the Stan diagnostics
  guide: bulk and tail effective sample size at least 100 per chain (`ess`),
  replacing the effective sample rate (`esr`, ESS divided by draws), which
  measures efficiency rather than whether the estimates are reliable. Rhat and
  divergence thresholds are unchanged, and the documentation cites each.
- **BREAKING** `glance()` reports `ess_bulk` and `ess_tail` in place of `ess`.

## Non-goals

- No change to the Rhat or divergence thresholds or to the diagnostics stored on
  a fit.
- No `rhat()` or `ess_bulk()` method for a fit: posterior defines those per
  variable, and `summarise_draws(fit)` reports them for every parameter.
