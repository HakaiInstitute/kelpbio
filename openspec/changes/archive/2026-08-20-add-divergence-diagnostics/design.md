# Design

## Where the numbers come from

rstan exports the accessors that back its own warning messages:

| Accessor | Returns |
|----------|---------|
| `get_divergent_iterations(fit)` | logical, one element per saved post-warmup draw across all chains |
| `get_max_treedepth_iterations(fit)` | same shape, treedepth saturation |
| `get_bfmi(fit)` | one E-BFMI per chain |

`rstan:::check_divergences()` reports `sum(x) / length(x)`, so taking both the
numerator and the denominator from the same logical vector reproduces rstan's
percentage exactly. This matters: it removes any chance of the denominator
drifting from the numerator, which is a live hazard on the cmdstanr side, where
`diagnostic_summary()$num_divergent` counts every post-warmup transition while a
percentage computed against `niters * nchains` counts only the retained ones. With
`nthin = 10` that formula inflates the rate by an order of magnitude and can
exceed 100%.

rstan records sampler parameters per *saved* iteration, so thinning drops the
divergence flags along with the draws. The reported rate is therefore over
retained draws, and divergences on thinned-away iterations are not observable
through rstan at all. Noted in the roxygen; the default `nthin = 1` makes it moot
in normal use.

`E-BFMI` is per chain, so a single stored number has to be a reduction. The
minimum is the right one: the diagnostic fires on the worst chain (rstan's
`get_low_bfmi_chains()` reports every chain below 0.2), and a mean would let one
pathological chain hide behind three healthy ones.

## Storage

`fit_stan()` already returns a `diagnostics` list holding the per-parameter
`summary` and `ndivergent`. It gains three fields:

```r
diagnostics = list(
  summary            = <tibble>,   # per-parameter rhat / ess_bulk / ess_tail
  ndivergent         = <integer>,  # count, kept for programmatic access
  perc_divergent     = <double>,
  perc_max_treedepth = <double>,
  ebfmi              = <double>    # minimum across chains
)
```

The live `stanfit` is discarded, so every one of these has to be computed inside
`fit_stan()` while it is still in scope. That is what forces the refit of the
shipped objects: there is no way to derive them later from stored draws.

The percentage helper is separated from the stanfit accessors so the arithmetic is
testable without sampling:

```r
perc_of <- function(n, total) {
  if (total <= 0L) return(NA_real_)
  100 * n / total
}
```

`NA` rather than 0 for an empty denominator: no draws means the rate is unknown,
not zero, and `NA < 0.2` is `NA`, which surfaces rather than silently passing the
verdict.

## The verdict

```r
converged(x, ..., rhat = 1.01, esr = 0.1, max_perc_divergent = 0.2)
```

Three conditions, all of which must hold.

The divergence comparison is inclusive (`<=`), which differs from smbr2's strict
`<`. With `<`, `max_perc_divergent = 0` is unsatisfiable: `0 < 0` is `FALSE`, so a
fit with no divergent transitions at all would fail the verdict, while the
argument's whole purpose at that setting is to admit exactly that fit. The
argument is named for the *maximum acceptable* rate, so inclusive is also what the
name says. At the 0.2 default this means 4 divergences in 2000 draws pass and 5
fail.

A guard is added for a case the current code passes silently:
`all(s$rhat < rhat, na.rm = TRUE)` is `TRUE` when every Rhat is `NA`, which
declares convergence on no evidence. `posterior::rhat()` returns `NA` for a
constant parameter, so an all-constant draws object reaches this. The verdict now
requires at least one finite Rhat. Individual `NA` entries are still skipped, as
before, since a legitimately constant parameter should not fail a fit.

`glance()` grows the same guard, because `max(s$rhat, na.rm = TRUE)` on an all-`NA`
vector returns `-Inf` with a base warning.

## Rendering

`glance()`, the report row, gets one new column between `rhat` and `converged`:

```
      n     K nchains niters nthin   ess  rhat perc_divergent converged
```

`print(summary(fit))`, the interactive drill-down, replaces

```
0 divergent transitions.
```

with

```
0% divergent transitions; 0% max-treedepth; min E-BFMI 1.04.
```

Three signals on one line, at the display boundary where rounding belongs
(`signif(3)`). The stored values stay unrounded, matching how the package handles
`sig_fig` elsewhere.

`summary_kb_fit` therefore carries `perc_divergent`, `perc_max_treedepth`, and
`ebfmi` in place of `ndivergent`. The count is not duplicated into the summary
object; `fit$diagnostics$ndivergent` is its one home.

`print.kb_fit`'s slim header is untouched. It shows `Converged:` and points at
`kb_model_describe()`; the diagnostic detail belongs one level down, in
`summary()`.

## Refit: what it measured

Tightening Rhat to 1.01 fails the demo fits as they were built (2 x 500 draws,
max Rhat 1.0147, min bulk-ESS 153). Refitting at 4 chains x 500 did not settle it.
Measured across the four shipped objects at `adapt_delta = 0.95`:

| object | max Rhat | worst parameter | min bulk-ESS | divergences |
|---|---|---|---|---|
| demo nereo | 1.0208 | `sSiteYear` | 336 | 0% |
| demo macro | 1.0087 | `bWeight` | 516 | 0.05% |
| fixture nereo | 1.0077 | `bWeight` | 434 | 0% |
| fixture macro | 1.0120 | `bSite[3]` | 431 | 0.8% |

The demo nereo Rhat got *worse* with twice the draws (1.0147 to 1.0208), isolated
to `sSiteYear`, the term with the least data behind it. Raising `adapt_delta`
fixes it, so the cause is step size in a mild funnel rather than weak
identification:

| slim nereo, 2000 draws | seed 42 | seed 7 | seed 99 |
|---|---|---|---|
| `adapt_delta = 0.99` | 1.0099 pass | 1.0107 fail | 1.0111 fail |
| `adapt_delta = 0.999` | 1.0082 pass | 1.0090 pass | 1.0098 pass |

So 0.99 passes on one seed by luck (a 0.0001 margin) and 0.999 passes all three,
but never by more than 0.002. At 2000 draws this fit is marginal against 1.01
whatever the step size.

**The package default `adapt_delta = 0.95` is not implicated.** At the package's
own defaults (4 chains x 1000 draws) the full demo data gives max Rhat 1.0042, min
bulk-ESS 1171, no divergences. The difficulty belongs entirely to the *slim* demo
configuration, so the sampler default stays at 0.95.

That leaves draw count as the only robust lever, and draw count is what `gq` makes
expensive:

| demo config | max Rhat | robust | `data/` |
|---|---|---|---|
| 2000 draws, `adapt_delta = 0.999` | 1.0082 | 3/3 seeds, margins under 0.002 | 16 MB |
| 4000 draws, defaults | 1.0042 | comfortable | ~40 MB |
| 4000 draws, defaults, no `gq` | 1.0042 | comfortable | ~9 MB |

`log_lik` and `yrep` are 77% of a demo object and 88% of a fixture, scaling as
`2 x nObs x ndraws`. Both are recomputable in R: `extras::log_lik_student()` and
`extras::log_lik_gamma()` for the pointwise log-likelihood, and the existing
`.weight_add_noise()` path for the replicates. Dropping them makes a 4000-draw
demo smaller than today's 2000-draw one, and makes the shipped object identical to
what a user gets from `kb_fit_weight_nereo(data_weight_sim_nereo)` at defaults.

**Sequencing decision.** The `gq` removal therefore lands first, as its own change,
and this change rebases on top of it and refits the demos at package defaults. The
alternative was shipping the marginal 0.999 fit as an interim, which works because
the stored objects are deterministic, but it would bake in a caveat that the `gq`
change removes days later.

## Alternatives considered

**Count instead of rate.** Rejected: the threshold is naturally a rate, and a
count is not comparable across fits of different length. The count is still on the
object.

**Zero tolerance.** Defensible, and argued for in the smbr2 thread on the grounds
that divergences are usually fixable by raising `adapt_delta`. Rejected as a
*default* because false-positive divergence warnings exist and one divergence in
4000 draws should not fail a fit; available via `max_perc_divergent = 0`.

**All five diagnostics in `glance()`.** This is what smbr2 does, at 11 columns.
Rejected because kelpbio's `glance()` row goes into a report table, and treedepth
saturation is not a validity concern.

**Gate on E-BFMI too.** Rejected: it is per-chain, second-order, and in practice
co-occurs with divergences, so gating on it mostly duplicates the divergence gate
while adding a second threshold to explain.

**Stop muffling rstan's warnings.** Rejected: the progress-bar contract in the
`fitting` spec depends on the muffling, and a raw rstan warning is exactly the
unstructured output the spec set out to replace. Routing the signal into the
structured summary addresses the defect without reversing that decision.
