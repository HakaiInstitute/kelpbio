# Stan code of a fit

The Stan source code of the fitted model, without comments.

## Usage

``` r
kb_stancode(fit, ...)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

## Value

A `kb_stancode` object, which prints as formatted code. Use
[`as.character()`](https://rdrr.io/r/base/character.html) for the plain
string.

## See also

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`fitted.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md),
[`kb_samples()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_samples.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit.md),
[`posterior_linpred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit.md),
[`posterior_predict.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
kb_stancode(fit_weight_sim_nereo)
#> data {
#>   int<lower=0> n_obs;
#>   int<lower=1> n_site;
#>   int<lower=1> n_year;
#>   array[n_obs] int<lower=1, upper=n_site> site;
#>   array[n_obs] int<lower=1, upper=n_year> year;
#>   vector<lower=0>[n_obs] diameter_mm;
#>   vector<lower=0>[n_obs] weight_kg;
#>   real<lower=0> diameter_ref;
#>   real prior_intercept_mean;
#>   real<lower=0> prior_intercept_sd;
#>   real prior_diameter_power_mean;
#>   real<lower=0> prior_diameter_power_sd;
#>   real prior_weight_floor_mean;
#>   real<lower=0> prior_weight_floor_sd;
#>   real<lower=0> prior_sd_site_rate;
#>   real<lower=0> prior_sd_year_rate;
#>   real<lower=0> prior_sd_site_year_rate;
#>   real<lower=0> prior_sd_residual_rate;
#>   int<lower=0, upper=1> prior_only;
#>   int<lower=0, upper=1> floor_on;
#> }
#> transformed data {
#>   vector[n_obs] log_x = log(diameter_mm) - log(diameter_ref);
#>   vector[n_obs] log_weight = log(weight_kg);
#>   array[n_obs] int sy_idx;
#>   for (i in 1:n_obs) {
#>     sy_idx[i] = site[i] + (year[i] - 1) * n_site;
#>   }
#> }
#> parameters {
#>   real intercept;
#>   real<lower=0> diameter_power;
#>   real<lower=0> weight_floor;
#>   real<lower=0> sd_site;
#>   real<lower=0> sd_year;
#>   real<lower=0> sd_site_year;
#>   real<lower=0> sd_residual;
#>   vector[n_site] z_site;
#>   vector[n_year] z_year;
#>   matrix[n_site, n_year] z_site_year;
#> }
#> transformed parameters {
#>   vector[n_site] site_effect = z_site * sd_site;
#>   vector[n_year] year_effect = z_year * sd_year;
#>   matrix[n_site, n_year] site_year_effect = z_site_year * sd_site_year;
#> }
#> model {
#>   intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
#>   diameter_power ~ normal(prior_diameter_power_mean, prior_diameter_power_sd);
#>   weight_floor ~ normal(prior_weight_floor_mean, prior_weight_floor_sd);
#>   sd_site ~ exponential(prior_sd_site_rate);
#>   sd_year ~ exponential(prior_sd_year_rate);
#>   sd_site_year ~ exponential(prior_sd_site_year_rate);
#>   sd_residual ~ exponential(prior_sd_residual_rate);
#>   z_site ~ std_normal();
#>   z_year ~ std_normal();
#>   to_vector(z_site_year) ~ std_normal();
#>   if (prior_only == 0) {
#>     vector[n_obs] log_alpha = intercept + site_effect[site] + year_effect[year]
#>       + to_vector(site_year_effect)[sy_idx];
#>     vector[n_obs] log_mu = log(floor_on * weight_floor
#>       + exp(log_alpha + diameter_power * log_x));
#>     log_weight ~ normal(log_mu, sd_residual);
#>   }
#> }
```
