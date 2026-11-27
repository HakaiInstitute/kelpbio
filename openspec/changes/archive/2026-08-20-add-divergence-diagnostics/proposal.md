## Why

`converged()` and `glance()` assess convergence from Rhat and the bulk effective
sample rate only. Divergent transitions, treedepth saturation, and low E-BFMI are
not part of the verdict and appear in no output that a reader is directed to:

- `fit_stan()` muffles rstan's post-sampling warnings for `progress = "bar"` (the
  default) and `progress = "none"`, on the stated grounds that
  "converged()/glance()/summary() give the structured summary regardless".
- The structured summary does not. `converged()` uses Rhat and `esr`; `glance()`
  has no divergence column; the divergent-transition count reaches exactly one
  surface, the grey footer of `print(summary(fit))`. Treedepth saturation and
  E-BFMI are computed nowhere.

So a fit with clean Rhat and 800 divergent transitions reports
`converged = TRUE`, prints no warning, and shows nothing in `glance()`. A
divergence is a validity problem (the sampler failed to explore part of the
posterior, so the draws may be biased), which makes this the one muffled warning
that must reach the verdict.

The Rhat threshold is a second, smaller gap. `posterior::rhat()` computes the
rank-normalized split/folded Rhat of Vehtari et al. (2021), and the package then
compares it against 1.05. The paper that defines the statistic recommends 1.01.

## What Changes

- `fit_stan()` computes `perc_divergent`, `perc_max_treedepth`, and `ebfmi` from
  rstan's own accessors (`get_divergent_iterations()`,
  `get_max_treedepth_iterations()`, `get_bfmi()`) and stores them on the fit
  alongside the existing `ndivergent` count. The percentages use rstan's own
  denominator, so they reproduce the numbers in the warnings being muffled.
- `converged()` gains `max_perc_divergent = 0.2` and returns `FALSE` when the
  divergence rate exceeds it. The Rhat default tightens from 1.05 to 1.01.
- `glance()` gains one column, `perc_divergent`, placed between `rhat` and
  `converged`.
- `print(summary(fit))` replaces its divergent-transition count line with a
  three-diagnostic footer: divergence rate, treedepth-saturation rate, and
  minimum E-BFMI.
- The pre-fit demo objects and both test fixtures are refit so they converge under
  the tightened Rhat threshold. Doing that robustly needs full-length fits, which
  are only affordable once the generated quantities come off the stored object, so
  this change stacks on the `gq` removal and refits at the package defaults. See
  the design for the measurements behind that.

## Capabilities

### Modified Capabilities

- `summaries`: the glance column set, the `converged()` thresholds and their
  defaults, and the `summary_kb_fit` diagnostics footer.
- `fitting`: the sampler diagnostics stored on the returned fit.

## Decisions

**Report a rate, not a count.** `perc_divergent`, with the count kept on
`fit$diagnostics` for programmatic access but out of `glance()`. A one-row
`glance()` goes into an appendix table, so column width is a real constraint, and
a rate is what the threshold is expressed against. This follows
`poissonconsulting/smbr2#21`, where the same question was settled for the
cmdstanr backend.

**0.2% for the verdict.** From the same discussion: 0.1% is roughly 1.5
divergences at a normal fit size, which is effectively zero tolerance, while 1% is
too lenient given that the funnel example in Stan's own case study biases at
2-3%. 0.2% allows 3-4 divergences at the package defaults. Exposed as an argument
rather than hardcoded, matching `rhat`/`esr`, so zero tolerance is available for
publication work.

**Three columns in `glance()`, five diagnostics on the object.** Vehtari et al.
(2021) and Stan's warnings guidance agree on the reportable core: Rhat, ESS, and
divergences. Stan's documentation states that treedepth saturation is an
efficiency concern rather than a validity one, and E-BFMI, while a validity
signal, is per-chain and second-order. Both are therefore recorded and rendered
in the `summary()` footer, which is the interactive drill-down, rather than in the
`glance()` row that reaches a report.

**Only divergences gate the verdict.** Treedepth saturation does not affect
validity, and E-BFMI below 0.2 is a reparameterization signal that in practice
co-occurs with divergences. Both are reported, neither is gated.

**The muffling stays.** Suppressing rstan's raw warnings on the default path was
never the defect; not routing the signal into the structured summary was.

## Non-goals

- The `esr` verdict stays on bulk ESS alone and stays a rate, not the absolute
  400-draw floor of Vehtari et al. Changing it would flip fits the team currently
  accepts, and warrants its own discussion.
- Divergences occurring on iterations discarded by thinning are invisible to
  rstan, so with `nthin > 1` the reported rate is over retained draws. Documented,
  not worked around.
- No new `diagnose()`-style verb. The three surfaces (`converged()`, `glance()`,
  `print(summary(fit))`) are enough.

## Impact

- Code: `R/fit_stan.R`, `R/converged.R`, `R/glance.R`, `R/summary.R`,
  `R/print.R`, `R/params.R`.
- Data: `data/fit_weight_sim_nereo.rda`, `data/fit_weight_sim_macro.rda`,
  `tests/testthat/fixtures/*.rds`, and the scripts that build them. All four are
  refit (Stan MCMC), since the stored diagnostics gain fields and the draw count
  changes.
- Depends on the `gq` removal landing first, for the reason in the design.
- Reader docs: `README.Rmd` (re-knit; the `glance()` output gains a column and
  every number changes with the refit) and `vignettes/kelpbio.Rmd`.
- Breaking, pre-release: `summary_kb_fit` drops its `ndivergent` field for the
  three rate/E-BFMI fields, and `converged()` is stricter, so a fit that reported
  `TRUE` at Rhat 1.02 now reports `FALSE`.
- Dependencies: none. All four rstan accessors are exported.
