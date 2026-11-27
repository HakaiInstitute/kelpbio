## Context

The likelihood, deviance residuals, and posterior-predictive noise are computed in
R from the stored draws. The public methods live on `kb_fit` and delegate to three
internal generics, `.log_lik()`, `.deviance()`, and `.add_noise()`, with one method
per model (`decisions/species-as-variant.md`). Each method extracts the model's
non-mean parameters from `fit$draws`, maps the link-scale mean to the
distribution's parameters, and calls an extras-style `log_lik_*()`, `res_*()`, or
random-generation function. The local Weibull, zero-truncated negative binomial,
and Beta functions are already named and parameterised as extras functions would
be. The mapping is therefore written three times per model, about 27 methods in
all.

## Decisions

### Compute in R from stored draws, not in Stan `generated quantities`

Kept from the current design, recorded here because this change commits to it
further:

- Fits store extracted draws, and `data/` holds slim pre-fit models. A
  `log_lik[N]` in `generated quantities` adds `D x N` values to every fit, pre-fit,
  and fixture.
- Any `.stan` edit forces a `--fits` rebuild. The residual sign fixes in
  `res_weibull()` and `res_beta()` were R edits; in Stan each would have been a
  full refit.
- Deviance residuals need the saturated log-likelihood, found by bisection for the
  zero-truncated negative binomial and the Beta. That is awkward in Stan and
  cannot be unit-tested without sampling.
- `rstan::gqs()` avoids storing the values but needs a compiled
  generated-quantities model per model and draws reshaped to stanfit form, the
  plumbing `decisions/prediction-engine.md` rejected for prediction.

The cost is that the likelihood is stated in both Stan and R. The Stan agreement
test below closes that gap.

### One internal generic per model's observation distribution

`.obs_family(fit, grid)` replaces `.log_lik()`, `.deviance()`, and `.add_noise()`.
Each method returns a list:

- `family`: the extras-style distribution name.
- `response(data)`: the response in the observed data, on its recorded scale.
  A function, so replicates at new data without the response never read it.
- `pars(mu_d, d)`: the family's named parameters for draw `d`, given that draw's
  link-scale mean over the grid's rows.

```r
.obs_family.kb_fit_size_nereo <- function(fit, grid) {
  shape <- .draw_vec(fit, "bShape")
  list(
    family = "weibull",
    response = function(data) data$diameter_mm,
    pars = function(mu_d, d) {
      list(shape = shape[d], scale = weibull_scale(exp(mu_d), shape[d]))
    }
  )
}
```

`log_lik.kb_fit()`, `residuals.kb_fit()`, `augment.kb_fit()`, and
`posterior_predict.kb_fit()` each evaluate the matching function from the family
table over the draws with `.per_draw()`. Wet/dry and carbon share one Beta-mean
helper, as they do now.

Alternatives considered:

- Keep the three generics: the current state, with three unlinked copies of each
  mapping.
- Store the family name in `meta` and dispatch only the parameter mapping. The
  meta-versus-dispatch rule (`decisions/architecture.md`) would put a frozen name
  in `meta`, but the name and the mapping must agree, and two homes for one fact
  can disagree. Both stay in the one method.
- A brms-style family object holding the functions themselves. The lookup table
  below gives the same result with less machinery.

`.obs_family()` keeps a `.default` that aborts, and joins the aborting set in
`test-abort.R`.

### An explicit family table, not name construction

`.family_fun(type, family)` looks up `log_lik`, `res`, or `ran` in a literal list
of the functions in use, rather than building a name with `paste0()` and `get()`.
Every function the package evaluates stays visible and greppable, and moving a
local function into extras is a change to one table entry.

### `lnorm` on the response for *Nereocystis* weight and cover biomass

Both models are Normal on the log response in Stan. As the `lnorm` family on the
recorded response:

- `extras::log_lik_lnorm()` is the density of the response, so the Jacobian is
  included without model-specific code. Cover biomass already subtracts it by
  hand; *Nereocystis* weight does not, which is the one user-visible value change.
- `extras::res_lnorm()` equals `extras::res_norm()` on the log scale (the
  Jacobian cancels in the deviance), so residuals are unchanged.
- `extras::ran_lnorm()` is `exp()` of the current Normal draw.

### Replicates are drawn one posterior draw at a time

`.add_noise()` currently makes one vectorised random call over the whole
`D x N` matrix, recycling each draw's parameters down the columns. Under
`.obs_family()` the replicates use the same per-draw `pars()` as the likelihood
and residuals, through `.per_draw()`. That is D calls of length N, a little slower
and acceptable for thousands of draws. It also keeps the draw orientation in the
one helper that already owns it, where the recycling used to be repeated in every
method.

Alternatives: expand every parameter to a `D x N` matrix and make one vectorised
call per function. That keeps the current random stream for some models, but
loses the per-draw scalar shortcut in `res_gamma_pois_zt()`, which computes the
saturated likelihood once per distinct count, and brings back column recycling as
a per-model concern.

Consequence: `posterior_predict()` under a fixed seed returns different draws
than before. The spec promises reproducibility under a seed, not
particular values, and no snapshot pins MCMC numerics.

### The expected response stays out of the family

`.epred()` works on `rvar`s, takes the `expectation` switch between median and
mean, and feeds the prediction verbs and the biomass compositions. Folding it into
the family would bring `rvar` code into an otherwise matrix path. It remains the
one other place a mapping is repeated (the truncated mean, the zero-inflation
factor, the lognormal mean), covered by its own scenarios in the `predictions`
spec.

### Guard the R likelihood against the Stan model

For each fixture, capture the Stan data by re-running its fit function on the
stored data and priors with the sampler mocked out, and build stanfits with
`chains = 0`, once with the likelihood and once with `prior_only = 1`. At a few
random unconstrained parameter vectors, evaluate `rstan::log_prob()` under both;
the difference is the Stan likelihood there, and the Jacobian terms cancel.
`rstan::constrain_pars()` gives the same values on the constrained scale,
transformed parameters included, which replace the fixture's draws for the R
side. Random values avoid rebuilding the non-centred `z_*` parameters, which fits
do not store. `~` statements drop terms that do not depend on parameters, so the
difference equals the row sum of `log_lik()` up to a constant: the test checks
that `rowSums(log_lik(fit)) - (lp_full - lp_prior)` is the same across draws. No
sampling is run, but the test needs the compiled models, so it is
`skip_on_cran()`.

## Risks / Trade-offs

- [Indirection: a reviewer reads a family name and a parameter mapping rather than
  the density call] → The mapping is the part that can be wrong; the density
  functions are library code with their own tests.
- [A changed random stream breaks a test that fixes a seed and compares values] →
  Such tests are updated to compare distributions or reproducibility, not values.
- [A family whose `pars()` returns a parameter of the wrong length silently
  recycles] → The table test evaluates every model's family at a fixture and
  checks each parameter is length 1 or N.
