# Fit a Nereocystis Weight Model

Fit an allometric weight model for *Nereocystis luetkeana* via Stan.

## Usage

``` r
kb_fit_weight_nereo(
  data,
  priors = NULL,
  ...,
  prior_only = FALSE,
  chains = 4L,
  niters = 1000L,
  nthin = 1L,
  cores = NULL,
  seed = NULL,
  progress = c("bar", "verbose", "none"),
  progress_dir = NULL
)
```

## Arguments

- data:

  A data frame of weight observations (see
  [`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md)
  for the required columns).

- priors:

  A named list of prior objects (see
  [`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)),
  or `NULL` to use the defaults. Supplied entries override the
  corresponding defaults; unspecified entries keep their defaults.

- ...:

  Additional arguments passed to
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html),
  including a `control` list (merged over the `adapt_delta = 0.95`
  default); see the `control` argument of
  [`rstan::stan()`](https://mc-stan.org/rstan/reference/stan.html) for
  the available entries.

- prior_only:

  A flag specifying whether to sample from the priors only (the
  likelihood is switched off), for prior predictive checks.

- chains:

  A whole number of MCMC chains.

- niters:

  A whole number of saved post-warmup draws per chain (warmup defaults
  to match).

- nthin:

  A whole number giving the thinning interval.

- cores:

  A whole number of cores for parallel chains, or `NULL` to use
  `getOption("mc.cores")` (falling back to `chains`), capped at the
  available cores.

- seed:

  A whole number passed to
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html)
  to make the fit reproducible, or `NULL` (the default). When `NULL`, a
  seed is drawn from R's RNG, so a preceding
  [`set.seed()`](https://rdrr.io/r/base/Random.html) also makes the fit
  reproducible; an explicit `seed` takes precedence over the RNG state.

- progress:

  A string, one of `"bar"` (the default, a console progress bar),
  `"verbose"` (rstan's per-iteration output and diagnostic warnings), or
  `"none"` (silent). Controls fit-time console output only.

- progress_dir:

  A string giving an existing directory in which to write a pollable
  progress artifact (read by
  [`kb_fit_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_progress.md)),
  or `NULL` (the default) to write none.

## Value

An object of class `c("kb_fit_weight", "kb_fit")`.

## Details

The response is log wet weight, modelled with a Student-t likelihood (4
degrees of freedom, for robustness to outliers). Expected log weight is
a quadratic (allometric) function of log sub-bulb diameter, centered at
its geometric mean so the intercept is the expected log weight at a
typical diameter. The intercept and the allometric slope vary by site,
and the intercept also varies by `site:year`.

`niters` is the number of saved post-warmup draws per chain; warmup
defaults to match `niters` and the post-warmup phase is thinned by
`nthin`. The returned object stores the extracted posterior draws
(including the `log_lik` and `yrep` generated quantities), diagnostics,
data, and metadata.

`progress` controls fit-time console output. The default `"bar"` shows a
progress bar; `"verbose"` streams rstan's per-iteration output and its
post-sampling diagnostic warnings; `"none"` is silent. `progress`
changes only console output, never the fit; inspect convergence with
[`converged()`](https://poissonconsulting.github.io/universals/reference/converged.html)
/ [`glance()`](https://generics.r-lib.org/reference/glance.html) /
[`summary()`](https://rdrr.io/r/base/summary.html) in every mode.

Supply `progress_dir` (an existing directory) to have the fit write a
pollable progress artifact there, which
[`kb_fit_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_progress.md)
reads to report the completed fraction from another R process (for
example, to drive a progress indicator while the fit runs in the
background).

Chains run in parallel by default (`cores = NULL` uses
`getOption("mc.cores")`, falling back to `chains`, capped at the
available cores). Set `options(mc.cores = 1)` (or pass `cores = 1`) on
shared servers, in containers, or inside another parallel context.

The sampler runs with a conservative `adapt_delta = 0.95` by default,
which reduces divergences at the cost of slightly longer runtime.
Override it, or set any other sampler control, by passing a `control`
list through `...`, e.g.
`kb_fit_weight_nereo(data, control = list(adapt_delta = 0.99))`; only
the entries supplied are changed. See the `control` argument of
[`rstan::stan()`](https://mc-stan.org/rstan/reference/stan.html) for the
full set of tunable entries (e.g. `adapt_delta`, `max_treedepth`).

The site:year effect is set from the data: it is dropped when the data
span a single year (then confounded with the site effect) and included
otherwise. When no site spans more than one year it is kept with a
warning, since `sSite` and `sSiteYear` are not then separately
identified.

## Examples

``` r
if (interactive()) {
  fit <- kb_fit_weight_nereo(data_weight_sim_nereo)
  tidy(fit)
}
# A pre-fit example model is included with the package:
tidy(fit_weight_sim_nereo)
#> # A tibble: 7 × 4
#>   term          estimate   lower  upper
#>   <chr>            <dbl>   <dbl>  <dbl>
#> 1 bWeight        -1.47   -1.66   -1.24 
#> 2 bDiameter       2.5     2.28    2.74 
#> 3 bDiameter2      0.0749 -0.156   0.313
#> 4 sSite           0.27    0.176   0.459
#> 5 sSiteDiameter   0.313   0.169   0.62 
#> 6 sSiteYear       0.0962  0.0521  0.149
#> 7 sWeight         0.161   0.141   0.185
```
