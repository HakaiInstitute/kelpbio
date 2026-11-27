## Context

The size models are the analysis project's `stan/nereo/size/size-nereo.stan`
(Weibull on `sbulb_max`) and `stan/macro/size/size-macro.stan` (zero-truncated
negative binomial on `fronds_1m`). kelpbio adapts them as it adapted weight:
priors as data, `site_year_on` and `prior_only` flags, no month effect, snake_case
columns, a local mean in the `model` block, no generated quantities.

## Decisions

### Class tier and verbs follow weight

Classes are `c("kb_fit_size_<species>", "kb_fit_size", "kb_fit")`. Public verbs
are model-named (`kb_predict_size()`, `kb_predict_size_by()`), matching the
weight verbs. The species methods
supply `.linpred`, `.log_lik`, `.deviance`, and `.add_noise`; the two
`.linpred` methods share one body that takes the species' intercept. `.epred`,
`.chk_new_data`, `.fit_descriptor`, `predict()`, and the `kb_predict_size*()`
methods register at `kb_fit_size`, since both species take the same arguments.
`.epred` is overridden for *Macrocystis*.

The size models have no continuous predictor, so `meta$predictor` is `NULL` and
`build_by_grid()` already yields grouped points. `new_data` needs no columns: a
zero-column data frame with `n` rows predicts `n` rows for the typical or sampled
group.

### Column names match the weight predictors

The response columns are `diameter` and `fronds`, the same names as the weight
models' predictors, so one survey column feeds both sub-models in the biomass
step. The existing `diameter` unit-plausibility warning then applies to size
data unchanged. The roxygen for the data checks, fit functions, and simulated
data states what each column measures: maximum sub-bulb diameter (mm), and the
number of fronds reaching 1 m above the holdfast. Alternative: the analysis names
`sbulb_max` and `fronds_1m`. Rejected because they differ from the weight columns
that the biomass step must match.

### Parameter names

The intercept is named after the response, as `bWeight` is in the weight models:
`bDiameter` (*Nereocystis*) and `bFronds` (*Macrocystis*). `bFronds` is also the
*Macrocystis* weight slope on log fronds, because a slope is named after its
predictor. The two fits are separate objects, so the names do not collide in the
draws or `tidy()`, and the analysis project has the same overlap. Where both fits
appear together (the biomass composition, a report), the model name
disambiguates. Alternative: a model-named `bSize`, which avoids the overlap but
breaks the response-named intercept pattern.

Every estimated parameter other than a standard deviation takes the `b`
prefix, so the *Nereocystis* Weibull shape is `bShape` and the *Macrocystis*
overdispersion is `bDispersion` (`phi = 1 / bDispersion`); this change also
renames the *Macrocystis* weight model's Gamma shape from `shape` to `bShape`.
Standard deviations keep the `s` prefix. The shape is estimated directly with
`<lower=0>` and an `Exponential(0.1)` prior, matching the *Macrocystis* weight
shape, rather than as the analysis project's log shape with `Normal(1, 1)`.
Alternatives: keep `bLogShape` (matches the analysis prior), or a log-normal
prior on the shape (exactly the analysis prior, but a new prior family).

### Expected size for Macrocystis is the truncated mean

`posterior_epred()` and the prediction verbs report the mean of the
zero-truncated distribution, `mu / (1 - P(0 | mu, phi))`: the expected frond
count of a plant with at least one frond at 1 m, which is what the data and the
biomass integration describe. `posterior_linpred(transform = TRUE)` returns the
untruncated `mu`. This is the same split as the *Nereocystis* weight model
(expected value vs inverse link). Alternative: report `mu`, as the analysis
`prediction` term does. Rejected because `mu` underestimates the mean of the
observed counts, most where counts are small.

The *Nereocystis* Weibull is mean-parameterised, so `exp(lp)` is the mean and the
model-tier `.epred` applies unchanged.

### Likelihood helpers are defined in kelpbio

The Weibull and zero-truncated negative binomial log-likelihood, deviance
residual, and random draws are internal kelpbio helpers built on `stats`, rather
than `extras` functions as for the weight models. `extras` has no Weibull
functions, and its zero-truncated functions are in an unmerged PR
(poissonconsulting/extras#113). A follow-up moves them to `extras` and migrates
kelpbio (issues in both repositories).

The helpers take the `extras` names and parameterisations
(`log_lik_weibull(x, shape, scale)`, `res_gamma_pois_zt(x, lambda, theta)`, ...),
so the migration is a namespace swap. They were checked against the analysis
project's `functions-ppc.R`, which matches the extras PR.

- Weibull: `dweibull()` and `rweibull()` with scale `mu / gamma(1 + 1 / shape)`.
  With the shape fixed, the saturated scale is `x`, so the deviance has the closed
  form `2 * (t^shape - 1 - shape * log(t))`, `t = x / scale`. The residual is
  signed by `x - scale`, not `x - mean`: the deviance is zero at the scale, and
  for shape > 1 the mean lies below it. The analysis project's `res_weibull()`
  signs against the mean, which gives plants between the mean and the scale the
  wrong sign and makes the residual jump at the mean (0.57 at shape 2.5).
- Zero-truncated negative binomial: the log-likelihood is `dnbinom()` minus
  `log(1 - P(0))`. Setting the score to zero shows the saturated `lambda` makes
  the truncated mean equal the count, so it is found by vectorised bisection on
  `(0, x)`, rather than by optimising the likelihood as the extras PR does. The
  two agree to 4e-12, and bisection is about 5 times faster. At `x = 1` the
  saturated log-likelihood is exactly 0. The deviance is zero where the count
  equals the truncated mean, so the residual is signed against the truncated
  mean, as in the PR. Once per draw, the saturated value is computed per distinct
  count. Draws use the inverse CDF on `(P(0), 1)` rather than rejection
  sampling, so they need no loop.

## Risks

- Deviance residuals for the *Macrocystis* size fit need a root per distinct
  count per draw. Mitigation: vectorised bisection, and only `residuals()` and
  `augment()` compute them.
- The Weibull `tgamma(1 + 1 / shape)` can overflow at extreme initial values.
  The analysis moved to a scalar shape for this reason. kelpbio keeps the scalar
  shape and rstan's default initialisation.
