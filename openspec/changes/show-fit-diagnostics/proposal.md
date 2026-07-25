## Why

`kb_fit_weight_nereo()` muffles rstan's post-sampling HMC diagnostic warnings
even at `quiet = FALSE`, and the documentation claims they can be inspected via
`converged()`/`glance()`. That is only partly true: Rhat/ESS are surfaced there
and the divergence count in `summary()`, but max-treedepth and BFMI warnings are
suppressed and never surfaced anywhere, so real sampler pathologies are silently
swallowed. The simplest, most standard fix is to let rstan's own diagnostics
through when the user has not asked for quiet.

## What Changes

- With `quiet = FALSE` (default), `kb_fit_weight_nereo()` SHALL let rstan's
  post-sampling HMC diagnostic warnings (divergent transitions, treedepth, BFMI,
  Rhat/ESS) reach the console alongside progress. `quiet = TRUE` continues to
  suppress both.
- `with_quiet_sampler()` muffles only when `quiet = TRUE`.
- The stored structured summary is unchanged: `converged()`/`glance()` (Rhat,
  effective sample rate) and `summary()` (per-term Rhat/ESS plus the divergence
  count) remain the persistent convergence record.
- Documentation corrected to match (no longer implies treedepth is inspectable
  post-hoc via `glance()`).

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `fitting`: the `quiet = FALSE` behaviour changes from suppressing the
  post-sampling HMC diagnostic warnings to showing them.

## Impact

- `R/fit_stan.R` (`with_quiet_sampler()` gains a `quiet` argument; the call site
  passes it). Doc edits in `R/kb_fit_weight_nereo.R` (`@details`) and `R/params.R`
  (`quiet`). `man/` regenerated. No change to the fit object, draws, or the
  prediction/summary surface.

## Non-goals

- `converged()` is not changed to fail on divergences (divergences are now
  visible at fit time; the verdict stays Rhat + effective-sample-rate).
- Treedepth/BFMI are not captured into the fit object (they remain fit-time
  console warnings; the `stanfit` is still discarded).
