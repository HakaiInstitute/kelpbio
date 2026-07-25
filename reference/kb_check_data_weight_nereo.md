# Validate Nereocystis Weight Model Data

Check that `data` contains the columns required to fit the *Nereocystis
luetkeana* weight model, with appropriate types and values.

## Usage

``` r
kb_check_data_weight_nereo(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
)
```

## Arguments

- data:

  A data frame of weight observations (see
  `kb_check_data_weight_nereo()` for the required columns).

- x_name:

  A string naming `data` in error messages.

## Value

`data`, invisibly.

## Details

Required columns: numeric `diameter` (\> 0), numeric `weight` (\> 0),
and factor or character `site` and `year`, with no missing values.

Diameter and weight may be in any units, provided prediction data use
the same units as the fitted data.

## See also

Other data:
[`data_weight_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/data_weight_sim_nereo.md),
[`fit_weight_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_nereo.md)

## Examples

``` r
data <- data.frame(
  diameter = c(20, 35), weight = c(0.5, 2.1),
  site = factor(c("a", "b")), year = factor(c("2020", "2021"))
)
kb_check_data_weight_nereo(data)
```
