## Context

The density models are the analysis project's `stan/nereo/density/density-nereo.stan`
(zero-inflated negative binomial on `stipe_count`) and
`stan/macro/density/density-macro.stan` (negative binomial on `n_plants`), each with
an expected count of `area * exp(log density)`. The rationale for the likelihoods
(zero inflation for the annual *Nereocystis* but not the perennial *Macrocystis*,
no N-mixture detection layer) is in the analysis project's
`docs/density-model-design.md`. kelpbio adapts them as it adapted weight and size:
priors as data, `site_year_on` and `prior_only` flags, no month effect, a local mean
in the `model` block, no generated quantities. Density is the first model to use
the log-area offset already built into the prediction engine
(`decisions/prediction-engine.md`).

## Decisions

### Class tier and verbs follow size

Classes are `c("kb_fit_density_<species>", "kb_fit_density", "kb_fit")`, with
model-named verbs `kb_predict_density()` and `kb_predict_density_by()`. `.epred`
(`exp(lp)`), `.chk_new_data`, `.fit_descriptor`, `predict()`, and the verb methods
register at `kb_fit_density`; `.epred` is overridden for *Nereocystis* (zero
inflation). The species methods supply `.linpred`, `.log_lik`, `.deviance`, and
`.add_noise`. The two `.linpred` methods share the size models' body: an intercept
plus resolved site, year, and site:year effects, with no predictor.

### Columns: species counts and `area_m2`

The response is `stipes` (*Nereocystis*) or `plants` (*Macrocystis*), with
`area_m2` as survey effort. The names follow what is counted: Hakai Institute's
*Nereocystis* survey records stipes per bin (`stipeD`), and its *Macrocystis*
survey records plants. `area_m2` follows the unit-suffix convention, and the fit
records it as `meta$offset`, so the engine adds `log(area_m2)` on every path.
Alternatives: a shared `count` (hides what was counted), or the analysis names
`stipe_count` / `n_plants` (mixed styles).

One row is one transect. The model has no transect effect, so rows are exchangeable
within a site-year; the roxygen says to aggregate bins to transects first, as the
analysis does.

### Expected count at rows, density per m² by group

The offset is read from the grid, so each verb's scale is fixed by its rows:

- `kb_predict_density()` and the `posterior_*()` generics predict the expected
  count on the supplied transect area. `new_data` must carry `area_m2`; an absent
  column errors and points to `kb_predict_density_by()`. Alternative: default a
  missing `area_m2` to 1, rejected because the output scale would then depend on
  which columns were supplied.
- `kb_predict_density_by()` predicts on a generated grid with `area_m2 = 1`, so it
  reports density per m². Its `kb_predictions` response is `stipes_m2` or
  `plants_m2`, so the plot's y-axis reads as a density, and the `area_m2` helper
  column is dropped from the returned frame. `stipes_m2` is also the name of the
  *Nereocystis* weight model's density covariate, so the two can be matched in the
  biomass step.

### Expected value includes zero inflation

For *Nereocystis* the expected count is `(1 - zi) * exp(mu)`, the analysis
`prediction` term and the quantity biomass needs. `posterior_linpred(transform =
TRUE)` returns `exp(mu)`, the mean of a transect holding stipes. This is the same
split as the *Nereocystis* weight lognormal and the *Macrocystis* size truncation.
For *Macrocystis* `exp(mu)` is the mean.

### Parameter names

- `bStipes` (*Nereocystis*) and `bPlants` (*Macrocystis*): the intercept, named
  after the response column as `bWeight`, `bDiameter`, and `bFronds` are. With
  `log(area_m2)` entering at a fixed coefficient of 1, it is the log expected count
  per m² at a typical site and year, so `exp(bStipes)` is a density. For
  *Nereocystis* it is the density on transects holding stipes; the expected density
  also carries `1 - zi`. `kb_model_describe()` and the roxygen gloss it as log
  stipes (or plants) per m². Alternative: the analysis `bDensity` for both species,
  rejected because it breaks the response-named intercept rule and shares a name
  with the *Nereocystis* weight model's density slope, which the biomass step uses
  alongside the density fit.
- `bDispersion`: overdispersion, `phi = 1 / bDispersion`, matching the *Macrocystis*
  size model and the `extras` `theta` convention. The analysis calls it
  `sDispersion`; kelpbio reserves the `s` prefix for random-effect SDs.
- `bZeroInflation`: the zero-inflation probability on the logit scale, one value for
  all transects. Named in words like `bShape` and `bDispersion`. Alternative: the
  analysis `bZi`.

### Default priors depart from the analysis

All SD priors are Exponential(1), and the *Nereocystis* zero-inflation prior is
Normal(0, 2) on the logit scale, matching the Normal(0, 2) intercept prior. The
analysis uses Exponential(0.5) for the *Nereocystis* site and year SDs and
Normal(0, 5) for zero inflation, chosen for its own data (407 transects, 18% zeros).
kelpbio defaults must suit smaller datasets: with 2 to 4 years the year SD is
partly prior-informed, and Normal(0, 5) puts 56% of its mass on zero-inflation
probabilities below 0.05 or above 0.95 (Normal(0, 2): 14%), so a dataset with few
zeros would be pulled to an extreme. Exponential(1) still allows a 20-fold change in
density per SD on the log scale.

### Likelihood helpers come from extras

`extras` has the zero-inflated and plain gamma-Poisson functions
(`log_lik_gamma_pois_zi(x, lambda, theta, prob)`, `res_gamma_pois_zi()`,
`ran_gamma_pois_zi()`, and the `gamma_pois` equivalents) with `theta = bDispersion`,
so no internal helpers are needed, unlike size.

### Stan likelihood

The offset enters as `log(area_m2)` computed in `transformed data`, and the count
uses `neg_binomial_2_log_lpmf(y | log_mu, 1 / bDispersion)`. The *Nereocystis*
zero inflation is vectorised by splitting zero and non-zero indices in `transformed
data`: zeros contribute `log_sum_exp(log(zi), log1m(zi) + NB(0))`, the rest
`log1m(zi) + NB(y)`.

## Risks

- Zero inflation is weakly identified when few transects are empty. Mitigation:
  the Normal(0, 2) prior keeps `bZeroInflation` moderate, and the simulated
  *Nereocystis* data include about 20% zeros.
- `phi = 1 / bDispersion` grows large as counts approach Poisson. The *Macrocystis*
  size model uses the same parameterisation without difficulty.
- Dropping the month effect folds within-season survey timing into site:year and
  the dispersion, which can widen density intervals relative to the analysis.
- Two more pre-fits take `data/` from about 2.7 to 4.1 MB, against the 5 MB budget.
  Moving bundled objects to `kelpbiodata` is left for later.
