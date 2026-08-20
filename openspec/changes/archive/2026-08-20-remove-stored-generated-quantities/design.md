# Design

## Equivalence evidence

The R implementation reads only `draws`, `data` and `meta`, so it runs unchanged
on a pre-change fit that still carries `gq`. That makes the comparison
**same-draws**, and therefore exact for `log_lik` — unlike comparing a new fit to
an old one, which is worthless because a refit changes the draws.

Measured against all four pre-change objects (the shipped demos and both
fixtures), each carrying Stan's own `log_lik` and `yrep`:

| object | `log_lik` dim | max abs diff | `loo` elpd diff | deterministic |
|---|---|---|---|---|
| demo nereo | 1500 x 234, matches | 2.465e-14 | -1.56e-13 | yes |
| demo macro | 1500 x 234, matches | 3.908e-14 | 4.26e-13 | yes |
| fixture nereo | 600 x 72, matches | 2.487e-14 | -2.13e-14 | yes |
| fixture macro | 600 x 72, matches | 7.372e-14 | -4.26e-14 | yes |

`yrep` cannot match by value, since the RNG differs. It matches distributionally:

| object | KS p | per-obs median (Stan vs R) | per-obs IQR |
|---|---|---|---|
| demo nereo | 0.897 | 0.2277 / 0.2252 | 0.0610 / 0.0608 |
| demo macro | 0.925 | 0.4659 / 0.4660 | 0.1412 / 0.1413 |
| fixture nereo | 0.852 | 0.2042 / 0.2057 | 0.0519 / 0.0526 |
| fixture macro | 0.551 | 0.4620 / 0.4560 | 0.1245 / 0.1210 |

**Robust statistics only, deliberately.** Nereo `yrep` is
`exp(Student-t(4, mu, sWeight))`, and `E[exp(X)]` diverges for polynomial-tailed
`X`, so that quantity has infinite mean and variance. Its sample SD is determined
by the single largest draw and differs by ~43% between two *correct*
implementations: at one seed the pooled maximum was 59.7 for Stan against 231.9
for R, with the top five draws accounting for 7.7% versus 55.4% of the total sum
of squares — while the quantiles agreed out to the 99.99th percentile. Macro
(Gamma) has finite moments and agrees on SD too.

Consequence worth carrying forward independently of this change: **moment-based
posterior predictive checks on the *Nereocystis* model are unstable by
construction**. Comparing observed and replicated means or SDs there gives noisy,
non-reproducible answers whoever generates the replicates. Quantile or
density-overlay checks are the defensible form.

The validation objects were kept outside the repository and discarded; a fixture
carrying `gq` would defeat the change. These numbers are the record.

## Orientation: the highest-risk defect

`log_lik()` must return `D x N`. The pattern it mirrors, `.weight_deviance()`,
uses `vapply` — which fills columns and yields `N x D` — and that is fine there
because the next line reduces over rows. A transposed `log_lik` is accepted by
`loo::loo()` without complaint and silently reports elpd over draws instead of
observations.

So `.weight_log_lik()` preallocates at the contract orientation rather than
transposing a `vapply` result:

```r
out <- matrix(NA_real_, nrow = nrow(mu), ncol = length(y))
for (d in seq_len(nrow(mu))) out[d, ] <- extras::log_lik_student(...)
```

The orientation is declared at the `matrix()` call and cannot be lost, and there
is no `D x N` transpose copy. The existing `ncol == nrow(data)` and
`nrow == ndraws` assertions in `test-log_lik.R` are retained as the guard.

`test-log_lik.R` also checks both species against `stats::dt` / `stats::dgamma`
computed directly rather than through `extras`, which pins the parameterisation
(`theta = 1/nu`; `rate = shape/exp(mu)`; the nereo density is of `log(weight)`,
with no Jacobian adjustment) independently of the library the implementation uses.

## Stan: the mean as a guarded local

`log_eWeight` moves into `if (prior_only == 0)` rather than to the top of
`model{}`. Under `prior_only = 1` the likelihood is skipped, so a local at the top
would be computed on every leapfrog step and discarded; inside the guard, a
prior-only fit gets a *smaller* autodiff graph than it had when the mean was a
transformed parameter computed unconditionally.

Nothing else in either file existed only to serve the generated quantities:
`log_weight`, `nu`, `weight` and the transformed data are all shared with the
likelihood. Under `prior_only = 1` the transformed data is now written once and
never read, which is not an error and draws no stanc3 diagnostic.

**What this costs.** The spec previously asserted that the mean is "defined once
in `transformed parameters` and reused by both the likelihood and the generated
quantities". After this change the mean genuinely lives in two places — Stan's
local and `.weight_linpred()` — and no Stan output remains to compare against.
That duplication already existed for the new-data prediction path; it now also
covers the observed-data path. The same-draws validation above is the only
end-to-end check that the two agree, which is why its numbers are recorded here
rather than left in a transcript.

## The recompile trap, hit in practice

`rstantools::rstan_config()` regenerates `src/stanExports_*.h`, but the makefile
dependency is on the `.cc`, which does not change. So `make` sees the `.cc` as
current, reuses the existing `.o`, and the install silently ships the **old**
model. The first install after the Stan edit did exactly this: `model_pars` still
contained `log_lik`, `yrep` and `log_eWeight`, while the regenerated header
contained none of them.

`pkgbuild::clean_dll()` before installing fixes it. `scripts/build.R` already
guards this case, but only by size (it drops any `src/*.o` over 15 MB, and the
stale object was 49.8 MB); calling `devtools::install()` directly bypasses the
guard entirely. A stale *optimised* object would slip through both.

This is why the gate — sample both models and assert `model_pars` contains none of
`log_lik`, `yrep`, `log_eWeight` — runs before anything downstream. Without it the
whole validation would have been performed against a package that still had the
generated quantities.

## Measured outcome

| object | before | after | reduction |
|---|---|---|---|
| demo nereo | 5.99 MB | 0.76 MB | 87% |
| demo macro | 5.76 MB | 0.68 MB | 88% |
| fixture nereo | 765 KB | 120 KB | 84% |
| fixture macro | 742 KB | 110 KB | 85% |
| `data/` | 11.5 MB | 1.5 MB | 87% |
| fixtures | 1.5 MB | 260 KB | 83% |

Better than the ~75% projected, because the objects now carry only `draws` plus a
few KB of metadata, and the simulated data tripled without affecting fit size —
which is the point: **size is now a function of the draw count alone**.

All four objects still converge after the refit (demo Rhat 1.0069 / 1.0078,
fixtures 1.0061 / 1.0099; no divergences beyond the macro fixture's 0.167% against
a 0.2% gate).

## Simulated data

`n_per` rises from 6 to 20 observations per site-year cell (39 cells, so 234 to
780 rows), which puts the demo data in the same order as the real coastwide nereo
dataset (1230 obs). The old cap existed solely because `gq` scaled with `nObs`;
the number now has a different justification — identifiability of the site-level
SDs and fast tests — and the comments say so.

Knock-on: the fixtures subset 4 sites x 3 years, so they go from 72 to 240
observations, and the geometric-mean references move (diameter 38.8 to 43.1,
fronds 5.36 to 4.95), re-recording the `print` and `kb_model_describe` snapshots
and the prediction ribbon.

## Deferred: the generics are placed for one sub-model, not six

`log_lik` moved from `kb_fit` to `kb_fit_weight` in this change, reasoned on the
species axis (identical signature, species-specific kernel) without checking the
*model* axis. That was a narrowing of something already at the right level, and it
is wrong for a package that will carry six sub-models: `kb_fit_size`,
`kb_fit_density` and the rest would each need a near-identical public method.

`posterior_predict`, `posterior_epred`, `posterior_linpred`, `fitted`,
`residuals` and `tidy` sit at `kb_fit_weight` with `.weight_*` internal generics
for the same reason, which predates this change.

The target, to be done as its own change before the size model lands: one public
method per generic at `kb_fit` with a model-agnostic body (guard, orientation
contract, observed-data mean), delegating to an internal generic named after the
public one, with methods registered at whichever level of
`c("kb_fit_<model>_<species>", "kb_fit_<model>", "kb_fit")` is actually right:

```
log_lik.kb_fit -> .log_lik(object, mu)
                    .log_lik.kb_fit_weight_nereo
                    .log_lik.kb_fit_size_nereo
                    .log_lik.kb_fit_carbon      # wetdry/carbon do not vary by species
```

`.fit_descriptor()` in `R/summary.R` is already a `kb_fit`-level generic with a
`.default`, and is the precedent. Until that change lands, the `predictions` spec
records `log_lik()` as taking a `kb_fit_weight`, which will need re-modifying.
