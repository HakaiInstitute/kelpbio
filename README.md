
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
carbon from field measurements. Its main use is the total biomass of
each site and year: drone-mapped canopy, the biomass counted by in situ
surveys of plots, and a calibration model that relates the two.
Estimates are for the peak season; a site and year may hold several
plots, and a plot several surveys. “Plant” is used for convenience for
one individual (sporophyte), identified by its holdfast. See
`vignette("kelpbio")` for the workflow.

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
with random effects for year, site, and site-by-year.

The model is fitted to a data frame of `diameter_mm`, `weight_kg`,
`site`, and `year`. A small simulated dataset is included with the
package:

``` r
library(kelpbio)

head(data_weight_sim_nereo)
#> # A tibble: 6 × 4
#>   diameter_mm weight_kg site       year 
#>         <dbl>     <dbl> <fct>      <fct>
#> 1        26.6     0.59  otter_cove 2019 
#> 2        11.8     0.129 otter_cove 2019 
#> 3        22.8     0.644 otter_cove 2019 
#> 4        37.1     1.71  otter_cove 2019 
#> 5        36.5     1.34  otter_cove 2019 
#> 6        25.9     0.242 otter_cove 2019
```

Fit the model with `kb_fit_weight_nereo()`:

``` r
fit <- kb_fit_weight_nereo(data_weight_sim_nereo, seed = 1)
```

Fitting compiles and samples the Stan model, so a pre-fit model on this
dataset is included with the package for quick exploration:

``` r
fit <- fit_weight_sim_nereo
```

Check convergence with `glance()` and summarise the model terms with
`tidy()`:

``` r
glance(fit)
#> # A tibble: 1 × 10
#>       n     K nchains niters nthin ess_bulk ess_tail  rhat perc_divergent
#>   <int> <int>   <int>  <dbl> <int>    <dbl>    <dbl> <dbl>          <dbl>
#> 1   420     7       3    500     2     629.     646.  1.00              0
#> # ℹ 1 more variable: converged <lgl>

tidy(fit)
#> # A tibble: 7 × 4
#>   term           estimate   lower  upper
#>   <chr>             <dbl>   <dbl>  <dbl>
#> 1 intercept        -0.932 -1.43   -0.397
#> 2 diameter_power    3.26   3.04    3.51 
#> 3 weight_floor      0.125  0.106   0.145
#> 4 sd_site           0.342  0.143   0.716
#> 5 sd_year           0.307  0.0902  1.01 
#> 6 sd_site_year      0.13   0.0112  0.34 
#> 7 sd_residual       0.45   0.422   0.482
```

Predict the weight-diameter curve for each site at a grid from
`kb_new_data()` and plot it with `kb_plot_predictions()`:

``` r
kb_predict_weight(fit, kb_new_data(fit, by = "site")) |>
  kb_plot_predictions()
```

![](man/figures/README-weight-curve-1.png)<!-- -->

Predict weight at new diameters with `kb_predict_weight()`. It returns a
table with a point estimate and `conf_level` compatibility limits for
each row:

``` r
new_data <- data.frame(diameter_mm = c(20, 35, 50, 65, 80), site = "otter_cove")

set.seed(1)
kb_predict_weight(fit, new_data)
#> <kb_predictions> predictor: diameter_mm | response: weight_kg | by: site
#> # A tibble: 5 × 5
#>   diameter_mm site       estimate  lower upper
#>         <dbl> <chr>         <dbl>  <dbl> <dbl>
#> 1          20 otter_cove    0.361  0.278  0.5 
#> 2          35 otter_cove    1.52   1      2.33
#> 3          50 otter_cove    4.56   2.89   7.11
#> 4          65 otter_cove   10.5    6.57  16.7 
#> 5          80 otter_cove   20.6   12.7   33.4
```

The fitted object exposes the standard `rstantools` generics
(`posterior_predict()`, `log_lik()`, and others), so it composes
directly with `bayesplot` and `loo`.

## Citation

If you use kelpbio in your work, please cite it. Use `citation()` to get
a formatted citation and BibTeX entry:

``` r
citation("kelpbio")
#> To cite kelpbio in publications use:
#> 
#>   Dalgarno S (2026). _kelpbio: Bayesian Kelp Biomass Estimation_. R
#>   package version 0.0.0.9000,
#>   <https://github.com/HakaiInstitute/kelpbio>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {kelpbio: Bayesian Kelp Biomass Estimation},
#>     author = {Seb Dalgarno},
#>     year = {2026},
#>     note = {R package version 0.0.0.9000},
#>     url = {https://github.com/HakaiInstitute/kelpbio},
#>   }
```

## Licensing

Copyright 2026 Tula Foundation.

The code is released under the [MIT License](LICENSE.md).
