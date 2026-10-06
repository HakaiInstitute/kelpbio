## Why

Each model's observation distribution is stated three times in R: once each for
the pointwise log-likelihood, the deviance residuals, and the posterior-predictive
noise. Each statement re-extracts the same draws and re-derives the same
distribution parameters from the linear predictor (the Weibull scale from the
mean, the negative binomial size from the overdispersion, the zero-inflation
probability from its logit, the Beta shapes from the mean and precision). Nothing
ties the three copies together, and the tests compare each one against a
re-derivation of itself rather than against the Stan model, so a parameterisation
change in one place can pass review and CI while the others go stale.

The *Nereocystis* weight `log_lik()` is also on a different scale from the other
models: it is the density of log weight, while *Macrocystis* weight is the
density of weight and cover biomass already subtracts its Jacobian. A
`loo::loo_compare()` across those scales is wrong by the sum of log weights.

## What Changes

- Each model states its observation distribution once: a family (one of the
  extras-style distributions, `lnorm`, `gamma`, `weibull`, `gamma_pois`,
  `gamma_pois_zi`, `gamma_pois_zt`, `beta`) and the family's parameters for each
  draw. `log_lik()`, `residuals()`, `augment()`, and `posterior_predict()` all
  evaluate that one statement.
- `log_lik()` is the log density of the recorded response on its recorded scale
  for every model. *Nereocystis* weight changes from the density of log weight to
  the density of weight, each value lower by `log(weight_kg)`. No other model's
  `log_lik()` changes, and no residual changes.
- `posterior_predict()` draws observation noise one posterior draw at a time, so
  the draws under a given seed change. Their distribution is unchanged.
- A test checks every model's R likelihood against its Stan model, so the two
  statements of the likelihood cannot drift apart.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: "Draws, likelihood, and priors" states that `log_lik()` is the
  log density of the recorded response on its recorded scale, so pointwise
  log-likelihoods of models of the same response are comparable.

## Non-goals

- Changes to any Stan model, prior, or fitted draw: no `--fits` rebuild.
- Changes to `posterior_epred()`, `posterior_linpred()`, the prediction verbs,
  or the biomass compositions. The expected response stays a separate,
  `rvar`-based statement (`decisions/prediction-engine.md`).
- Computing the likelihood or replicates in Stan `generated quantities`; the
  reasons are in `design.md`.
- Quantile (PIT) residuals for the count models; they belong with the planned
  `pp_check()` diagnostics.
- Moving the local Weibull, zero-truncated negative binomial, and Beta functions
  into the extras package. This change makes that a swap of table entries.

## Impact

- R: a new internal generic with one method per model replaces the three
  per-model generics behind `log_lik()`, `residuals()`/`augment()`, and
  `posterior_predict()`; local `ran_weibull()` and `ran_beta()` join the existing
  extras-style functions. About 100 fewer lines.
- Tests: the per-model likelihood, residual, and predictive tests stay as
  regression checks; new tests for the family table and the Stan agreement; the
  internal-generic abort snapshot changes (left for review, not accepted).
- Docs: the `log_lik()` roxygen states the scale; `decisions/architecture.md`,
  `decisions/species-as-variant.md`, and `CLAUDE.md` list the new generic in
  place of the three.
