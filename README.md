
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kelpbio <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/HakaiInstitute/kelpbio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/HakaiInstitute/kelpbio/actions/workflows/R-CMD-check.yaml)
[![R-universe
version](https://hakaiinstitute.r-universe.dev/kelpbio/badges/version)](https://hakaiinstitute.r-universe.dev/kelpbio)
[![R-universe
status](https://hakaiinstitute.r-universe.dev/kelpbio/badges/checks)](https://hakaiinstitute.r-universe.dev/kelpbio)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

kelpbio fits Bayesian hierarchical models to estimate kelp biomass and
carbon from field measurements.

## Installation

Install the pre-built binary from the Hakai R-universe (macOS and
Windows):

``` r
install.packages(
  "kelpbio",
  repos = c("https://hakaiinstitute.r-universe.dev", getOption("repos"))
)
```

Install from source (Linux, or to build from GitHub):

``` r
# install.packages("pak")
pak::pak("HakaiInstitute/kelpbio")
```

Source builds require a C++ toolchain:

- Linux: `sudo apt install build-essential`
- Windows: [Rtools](https://cran.r-project.org/bin/windows/Rtools/)
- macOS: `xcode-select --install`

## Usage

kelpbio fits each biomass component with its own `kb_fit_*()` function.
The allometric weight model relates wet weight to sub-bulb diameter,
with random effects for site and site-by-year.

The model is fitted to a data frame of `diameter`, `weight`, `site`, and
`year`. A small simulated dataset ships with the package:

``` r
library(kelpbio)

head(data_weight_sim_nereo)
#> # A tibble: 6 × 4
#>   diameter weight site  year 
#>      <dbl>  <dbl> <fct> <fct>
#> 1     38.7  0.255 site1 2019 
#> 2     52.7  0.264 site1 2019 
#> 3     37.4  0.245 site1 2019 
#> 4     46.8  0.273 site1 2019 
#> 5     31.5  0.122 site1 2019 
#> 6     61.4  0.831 site1 2019
```

Fit the model with `kb_fit_weight_nereo()`:

``` r
fit <- kb_fit_weight_nereo(data_weight_sim_nereo, seed = 1)
```

Fitting compiles and samples the Stan model, so a pre-fit model on this
dataset ships with the package for quick exploration:

``` r
fit <- fit_weight_sim_nereo
```

Check convergence with `glance()` and summarise the model terms with
`tidy()`:

``` r
glance(fit)
#> # A tibble: 1 × 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <dbl> <int> <dbl> <dbl> <lgl>    
#> 1    46    10       2    400     1  197.  1.01 TRUE

tidy(fit)
#> # A tibble: 7 × 4
#>   term          estimate    lower  upper
#>   <chr>            <dbl>    <dbl>  <dbl>
#> 1 bWeight        -1.48   -1.62    -1.3  
#> 2 bDiameter       2.56    2.14     2.97 
#> 3 bDiameter2     -0.0132 -0.67     0.713
#> 4 sSite           0.107   0.00744  0.354
#> 5 sSiteDiameter   0.225   0.00777  0.871
#> 6 sSiteYear       0.0911  0.00611  0.227
#> 7 sWeight         0.209   0.152    0.295
```

Predict the weight-diameter curve for each site with
`kb_predict_weight_by()` and plot it with `kb_plot_predictions()`:

``` r
kb_predict_weight_by(fit, by = "site") |>
  kb_plot_predictions()
```

![](man/figures/README-weight-curve-1.png)<!-- -->

The fitted object exposes the standard `rstantools` generics
(`posterior_predict()`, `log_lik()`, and others), so it composes
directly with `bayesplot` and `loo`. See `vignette("kelpbio")` for model
checking.

## Citation

<!-- Citation guidance to follow once the `kb_` API is available. -->

## Licensing

Copyright 2026 Tula Foundation.

The code is released under the [MIT License](LICENSE.md).
