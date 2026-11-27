## Why

`kb_fit` objects stored the Stan `log_lik` and `yrep` generated quantities in a
`gq` element. That scales as `2 * nObs * ndraws * 8` bytes and was **76-78% of
every shipped fit object**: 5.99 MB of the nereo demo fit, 5.76 MB of the macro
one, and about 60% of each test fixture.

The binding constraint is the planned `kelpbiodata` companion package, whose
repository exists but is still empty. Inference-grade fits make the cost
prohibitive:

| fit | observations | `gq` at 4000 draws |
|---|---|---|
| nereo weight | 1230 | 79 MB |
| macro frond-level | 2366 | 151 MB |

With six macro sub-models in the biomass composition, that package would carry
several hundred MB to over 1 GB of pure generated quantities against a few MB of
`draws` per fit. The archived `bundle-simulated-data-only` change already
identified this ("a large inference-grade fit (`log_lik`/`yrep` scale with n_obs)
do not belong in the public code package"), and both `data-raw/data_weight_sim_*.R`
scripts capped the simulated data at 6 observations per site-year cell purely to
hold fit size down.

Neither quantity needs to be stored. Both are recomputable in R from the draws,
and the machinery already existed for the `new_data` prediction path.

## What Changes

- Both Stan `generated quantities` blocks are deleted. `log_eWeight` moves from
  `transformed parameters` into a local inside the `prior_only == 0` guard in
  `model{}`, so rstan no longer saves `nObs` columns per draw into the stanfit and
  the progress `sample_file` CSV, and a prior-only fit does not compute it at all.
- `fit_stan()` loses `gq_vars`, and the fit object loses `gq`, leaving
  `draws / diagnostics / data / meta`. This aligns the object with what
  `CLAUDE.md` and `openspec/config.yaml` already documented.
- `log_lik()` recomputes the pointwise matrix from the stored draws and moves from
  `kb_fit` to `kb_fit_weight`, with an internal `.weight_log_lik()` generic for
  the species density kernel.
- `posterior_predict(new_data = NULL)` recomputes replicates in R through the
  existing `.weight_add_noise()` path, so it is RNG-dependent.
- Both verbs error for a zero-observation fit, triggered on
  `nrow(object$data) == 0L`.
- `n_per` in the simulated datasets rises from 6 to 20 per site-year cell, since
  the constraint that set it is gone.

## Capabilities

### Modified Capabilities

- `stan-engine`: no generated quantities; the mean is a model-block local rather
  than a saved transformed parameter.
- `fitting`: the fit stores no per-observation quantity, so its size is a function
  of the draw count alone.
- `predictions`: `log_lik()` is recomputed, deterministic, dispatches on
  `kb_fit_weight`, and errors for a zero-observation fit; `posterior_predict()`
  draws its noise in R for every `new_data`.

## Decisions

**Drop both, not just `log_lik`.** They are each exactly `D x N`, so keeping
`yrep` would recover only half the size. `log_lik` is free of behavioural
consequence; `yrep` costs RNG-dependence, which the package already has elsewhere.

**`posterior_predict()` becomes RNG-dependent, documented rather than worked
around.** `kb_predict_weight(new_levels = "sample")` already draws fresh
randomness per call and its docs already direct the reader to `set.seed()`.
Extending the same contract is consistent rather than novel, and a `seed` argument
would add surface area for one verb only.

**`log_lik` moves to `kb_fit_weight` with an internal species generic.** The
package uses species-level public methods where the *interface* differs
(`kb_predict_weight`'s `diameter` vs `fronds`, `kb_model_describe`'s notation) and
a `kb_fit_weight` method plus an internal generic where only a kernel differs
(`residuals` + `.weight_deviance`, `posterior_predict` + `.weight_add_noise`,
`tidy` + `.weight_terms`). `log_lik(object, ...)` is the second shape: identical
signature and documentation, species-specific density only.

**Zero-observation fits error rather than return a `D x 0` matrix.** That matrix
composes with nothing: `loo::loo()` has no pointwise terms to weight and
`bayesplot::ppc_dens_overlay()` has no observations to overlay. The guard is on
`nrow(data)`, never on `prior_only`, because a prior-only fit *with* data rows is
a valid prior-predictive check and must keep working.

## Non-goals

- Vectorising the macro likelihood. It is mathematically identical but changes the
  autodiff graph and summation order, which would confound "did removing the
  generated quantities change anything" during verification. Bankable separately.
- Caching the recomputed `log_lik`. A memoised slot reintroduces exactly the
  megabytes this change removes, and copy-on-modify makes an attribute cache
  impossible.

## Impact

- Code: both `inst/stan/*.stan`, `R/fit_stan.R`, `R/log_lik.R`,
  `R/posterior_predict.R`, both `R/kb_fit_weight_*.R`.
- Generated: `src/stanExports_weight_*.{cc,h}`, `NAMESPACE`
  (`log_lik.kb_fit` to `log_lik.kb_fit_weight`), `man/`.
- Data: both simulated datasets, both demo fits, both fixtures — all regenerated.
  `data/` 11.5 MB to 1.5 MB; fixtures 1.5 MB to 260 KB.
- Reader docs: `README.md` re-knit, `vignettes/kelpbio.Rmd`,
  `decisions/architecture.md`, `_pkgdown.yml`, `CLAUDE.md`.
- Breaking, pre-release: `fit$gq` no longer exists; `posterior_predict()` returns
  different values on each call; `log_lik()` no longer dispatches on a bare
  `kb_fit`.
- Dependencies: none. `extras` was already in Imports.
