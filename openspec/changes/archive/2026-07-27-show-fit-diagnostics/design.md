## Context

`with_quiet_sampler()` unconditionally muffles rstan's post-sampling HMC
diagnostic warnings (divergences, treedepth, BFMI, Rhat/ESS). Rhat/ESS are
re-derived and surfaced by `converged()`/`glance()`, and the divergence count by
`summary()`, but treedepth and BFMI are computed by rstan, muffled, and never
stored, so they are lost. Letting rstan's warnings through at `quiet = FALSE`
restores all of them with no new machinery.

## Goals / Non-Goals

**Goals:** at `quiet = FALSE`, surface rstan's full diagnostic warnings at fit
time; keep `quiet = TRUE` fully silent; keep the stored structured summary.

**Non-Goals:** no change to `converged()`'s verdict; no capture of treedepth/BFMI
into the discarded `stanfit`.

## Decisions

**Conditional muffle, leaning on rstan.** `with_quiet_sampler(expr, quiet)`
installs the warning-muffling handler only when `quiet = TRUE`; when
`quiet = FALSE` it evaluates the sampling call with no handler so rstan's own
warnings propagate. rstan's diagnostics are comprehensive and familiar
(brms/rstanarm behave the same), so we surface those rather than re-implement
treedepth/BFMI capture.

**Diagnostics at `quiet = FALSE` are fit-time only.** The `stanfit` is discarded,
so treedepth/BFMI are not retrievable from a stored or shipped fit; the persistent
record stays Rhat/ESS (`converged()`/`glance()`) and the divergence count
(`summary()`). Acceptable: whoever runs the fit sees the full diagnostics.

## Risks / Trade-offs

- Noisier `quiet = FALSE` output. Intended, and standard for an interactive fit;
  `quiet = TRUE` (used for fixtures and batch runs) stays silent.
- A test asserting a silent `quiet = FALSE` fit would break. Mitigation: fixtures
  and the slow end-to-end fits use `quiet = TRUE`; verify none assert silence at
  `quiet = FALSE`.
