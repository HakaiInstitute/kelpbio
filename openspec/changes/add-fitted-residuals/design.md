## Context

The weight model is fit on `log(weight)` with `student_t(nu = 4, log_eWeight,
sWeight)`. `augment()` currently reports a raw response residual (`weight -
fitted`, kg), which fans out with the fitted value for this multiplicative model
and reads as misspecified even when the fit is fine on the log scale. The base
`stats::fitted()` / `stats::residuals()` generics are not implemented.

The analysis project (`hakai-kelp-biomass-25`, `models-weight-nereo.R`) defines
the residual as `extras::res_student(log(weight), fit, sd = sWeight, theta = 1 /
nu)` (deviance residual, `type = "dev"` default) and plots `residuals(analysis)$
estimate` as the "Deviance Residual".

## Goals / Non-Goals

**Goals:**
- `fitted()` and `residuals()` returning plain numeric vectors that append to the
  data, matching the broad ecosystem shape (response-scale fitted; per-draw then
  summarised) and the analysis project's residual definition.

**Non-Goals:**
- No `type` argument on `residuals()` (deviance only).
- No Stan model change.

## Decisions

**Deviance residual via `extras::res_student()`, R-side, not Stan GQ.** Computing
it in the generated quantities block would mean re-deriving the deviance formula
in Stan and storing a `draws x nObs` array in every fit, and would risk drifting
from the validated `extras` definition. The residual is cheap elementwise
arithmetic over the stored draws, so the R-side path is computed on demand from
`.weight_linpred()` (the log-scale mean) and `sWeight`, calling
`extras::res_student()` per draw and summarising with the posterior median. This
reproduces `residuals(analysis)$estimate` exactly. `extras` ships on the
poissonconsulting R-universe (the kelpbio distribution channel) with trivial
dependencies.

**`fitted()` on the response scale.** Base R, brms, and rstanarm all return
fitted values on the response scale (E[y]); only the residual needs the log
scale, and the deviance residual already encodes it. `fitted()` is the posterior
median of `posterior_epred()` at the observed data, so it equals the existing
`augment()$fitted`. The fitted-vs-residual plot uses a log x-axis (or
`log(diameter)`) for readability without the accessor being log-scale.

**`augment()` delegates and drops intervals.** `augment()` calls `stats::fitted()`
and `stats::residuals()` directly and appends only those two columns, so they
cannot drift from the methods. It no longer computes `lower`/`upper` (or takes
`conf_level`); prediction intervals come from `kb_predict_weight()`. This changes
the `residual` column from response to deviance (breaking, pre-1.0).

**`nu` stored in `meta`.** The residual needs `theta = 1 / nu`. `nu = 4` is a
fixed constant in `weight.stan`; `new_kb_fit_weight()` records `meta$nu` so the R
side does not hard-code it. Existing shipped/fixture fits predate the field, so
`fit_weight` and the test fixture are rebuilt (no Stan recompile).

## Risks / Trade-offs

- New `extras` dependency. Mitigation: it is a small Poisson package on the same
  R-universe kelpbio ships through; the alternative (re-deriving the deviance
  formula in Stan or R) is worse for correctness.
- Breaking change to `augment()$residual`. Mitigation: pre-1.0; the deviance
  residual is the intended diagnostic and `fitted()` still exposes the response
  fitted value.
