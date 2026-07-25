# Simulated Nereocystis Weight Dataset

A small simulated dataset of sub-bulb diameter and wet weight (columns
`diameter`, `weight`, `site`, `year`), for fast tests and runnable
examples. It is simulated from the weight-model structure (site
intercept, site slope, and site:year random effects over a wide diameter
range), not real survey data, and is not intended for inference. Built
by `data-raw/data_weight_sim_nereo.R`.

## Usage

``` r
data_weight_sim_nereo
```

## Format

A data frame with columns:

- diameter:

  Sub-bulb diameter (mm), a positive number.

- weight:

  Wet weight (kg), a positive number.

- site:

  Survey site, a factor (10 levels).

- year:

  Survey year, a factor (4 levels).

## See also

[fit_weight_sim_nereo](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_nereo.md)
for a fit to this dataset.

Other data:
[`fit_weight_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_nereo.md),
[`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md)
