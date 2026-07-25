# Stan Source for a Model Fit

The Stan source code of the fitted model, with comments stripped for a
clean read. The raw source (comments included) is stored on the fit in
`fit$meta$stancode`.

## Usage

``` r
kb_stancode(fit, ...)

# S3 method for class 'kb_fit'
kb_stancode(fit, ...)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  Unused.

## Value

A `kb_stancode` object: the comment-stripped Stan source string, which
prints as readable code. Use
[`as.character()`](https://rdrr.io/r/base/character.html) for the plain
string.

## See also

Other generics:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`converged.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/converged.kb_fit.md),
[`fitted.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit_weight.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit_weight.md),
[`posterior_linpred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit_weight.md),
[`posterior_predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit_weight.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit_weight.md),
[`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
kb_stancode(fit_weight_sim_nereo)
#> data {
#>   int<lower=0> nObs;
#>   int<lower=1> nSite;
#>   int<lower=1> nYear;
#>   array[nObs] int<lower=1, upper=nSite> site;
#>   array[nObs] int<lower=1, upper=nYear> year;
#>   vector<lower=0>[nObs] diameter;
#>   vector<lower=0>[nObs] weight;
#>   real<lower=0> diameter_ref;
#>   real prior_intercept_mu;
#>   real<lower=0> prior_intercept_sd;
#>   real prior_diameter_mu;
#>   real<lower=0> prior_diameter_sd;
#>   real prior_diameter2_mu;
#>   real<lower=0> prior_diameter2_sd;
#>   real<lower=0> prior_sd_site_rate;
#>   real<lower=0> prior_sd_site_diameter_rate;
#>   real<lower=0> prior_sd_site_year_rate;
#>   real<lower=0> prior_sd_residual_rate;
#>   int<lower=0, upper=1> prior_only;
#>   int<lower=0, upper=1> site_year_on;
#> }
#> transformed data {
#>   real nu = 4.0;
#>   real log_diameter_ref = log(diameter_ref);
#>   vector[nObs] log_diameter = log(diameter) - log_diameter_ref;
#>   vector[nObs] log_diameter_sq = log_diameter .* log_diameter;
#>   vector[nObs] log_weight = log(weight);
#>   array[nObs] int sy_idx;
#>   for (i in 1:nObs) {
#>     sy_idx[i] = site[i] + (year[i] - 1) * nSite;
#>   }
#> }
#> parameters {
#>   real bWeight;
#>   real bDiameter;
#>   real bDiameter2;
#>   real<lower=0> sSite;
#>   real<lower=0> sSiteDiameter;
#>   real<lower=0> sSiteYear;
#>   real<lower=0> sWeight;
#>   vector[nSite] z_bSite;
#>   vector[nSite] z_bSiteDiameter;
#>   matrix[nSite, nYear] z_bSiteYear;
#> }
#> transformed parameters {
#>   vector[nSite] bSite = z_bSite * sSite;
#>   vector[nSite] bSiteDiameter = z_bSiteDiameter * sSiteDiameter;
#>   matrix[nSite, nYear] bSiteYear = z_bSiteYear * sSiteYear;
#>   vector[nObs] log_eWeight = bWeight + bSite[site]
#>     + (bDiameter + bSiteDiameter[site]) .* log_diameter
#>     + bDiameter2 * log_diameter_sq
#>     + site_year_on * to_vector(bSiteYear)[sy_idx];
#> }
#> model {
#>   bWeight ~ normal(prior_intercept_mu, prior_intercept_sd);
#>   bDiameter ~ normal(prior_diameter_mu, prior_diameter_sd);
#>   bDiameter2 ~ normal(prior_diameter2_mu, prior_diameter2_sd);
#>   sSite ~ exponential(prior_sd_site_rate);
#>   sSiteDiameter ~ exponential(prior_sd_site_diameter_rate);
#>   sSiteYear ~ exponential(prior_sd_site_year_rate);
#>   sWeight ~ exponential(prior_sd_residual_rate);
#>   z_bSite ~ std_normal();
#>   z_bSiteDiameter ~ std_normal();
#>   to_vector(z_bSiteYear) ~ std_normal();
#>   if (prior_only == 0) {
#>     log_weight ~ student_t(nu, log_eWeight, sWeight);
#>   }
#> }
#> generated quantities {
#>   vector[nObs] log_lik;
#>   vector[nObs] yrep;
#>   for (i in 1:nObs) {
#>     log_lik[i] = student_t_lpdf(log_weight[i] | nu, log_eWeight[i], sWeight);
#>     yrep[i] = exp(student_t_rng(nu, log_eWeight[i], sWeight));
#>   }
#> }
```
