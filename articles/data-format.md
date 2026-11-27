# Data format

## Overview

The data are compiled as one dataset per kind of measurement. Column
names are fixed and carry their units (for example `diameter_mm`); any
additional columns are ignored. Some tables have columns that differ by
species, such as `weight` (e.g., `diameter_mm` vs `fronds`).

Not every dataset is required: a model without data can use a model
pre-fit to a public dataset in kelpbiodata (see [Pre-fit
models](https://hakaiinstitute.github.io/kelpbio/articles/kelpbio.html#pre-fit-models)).
How the datasets combine into biomass is explained in the [Methods
overview](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#overview),
and how the data are expected to be collected in [Survey
design](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#survey-design).

## Two data format choices to highlight:

1.  **Size sample or census.** A *Nereocystis* survey either measures a
    sample of the counted plants or all of them. With a sample, size
    data are provided in `size_sample`, each survey’s total plant count
    is recorded in the `plants` column of `survey_in_situ`, and a size
    model is used to estimate size of unmeasured plants. If every plant
    is measured, sizes are recorded in the `size_census` table and each
    survey’s total plant count is calculated automatically. For
    *Macrocystis*, it is assumed that all plants are measured and sizes
    are recorded in the `size_census` table.
2.  **Site and year, or survey.** These methods are designed to estimate
    annual biomass at each site: the weight, size, and cover calibration
    models have site and year effects, and the tissue models estimate
    one ratio or fraction for all samples. A site can still have in situ
    surveys at more than one plot, or more than once in a year, and have
    canopy mapped more than once in a year. Each in situ survey
    therefore has its own `survey_id` in `survey_in_situ`, which the
    plants of a size census carry, and each canopy map is its own row in
    `survey_canopy`. However, no models estimate seasonal variation
    (i.e., within a year); canopy maps of the same site-year share the
    same biomass per m² of canopy, and in situ surveys of the same
    site-year share the same mean plant weight (see
    [Timing](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#timing)
    for details).

## Datasets

The columns of each dataset, as given by
[`kb_data_columns()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_data_columns.md).
Each site must be spelled the same way in every dataset: the datasets
are joined by site and year, and a misspelled site is read as a new
site.

- weight
- size_sample
- size_census
- survey_in_situ
- survey_canopy
- wetdry
- carbon
- nitrogen

One row per harvested plant, with its size, wet weight, `site`, and
`year`. Used by
[`kb_fit_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_nereo.html),
[`kb_fit_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_macro.html)
and checked by
[`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.html),
[`kb_check_data_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_macro.html).

***Nereocystis***

| Column | Units | Allowed | Example | Description |
|:---|:---|:---|:---|:---|
| `diameter_mm` | mm | \> 0 | `26.8` | The plant diameter, measured as in the size data. |
| `weight_kg` | kg | \> 0 | `0.73` | The plant’s weight. |
| `site` |  | any text | `otter_cove` | The site the plant was sampled at. |
| `year` |  | whole number or text | `2024` | The year the plant was sampled. |

***Macrocystis***

| Column | Units | Allowed | Example | Description |
|:---|:---|:---|:---|:---|
| `fronds` |  | whole number \>= 1 | `5` | The number of fronds reaching 1 m above the holdfast. |
| `weight_kg` | kg | \> 0 | `3.96` | The plant’s weight. |
| `site` |  | any text | `seal_ledge` | The site the plant was sampled at. |
| `year` |  | whole number or text | `2024` | The year the plant was sampled. |

One row per measured plant, with its size, `site`, and `year`. Used by
[`kb_fit_size_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_size_nereo.html)
and checked by
[`kb_check_data_size_sample_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_sample_nereo.html).

| Column | Units | Allowed | Example | Description |
|:---|:---|:---|:---|:---|
| `diameter_mm` | mm | \> 0 | `26.8` | The plant diameter, measured as in the weight data. |
| `site` |  | any text | `otter_cove` | The site the plant was measured at. |
| `year` |  | whole number or text | `2024` | The year the plant was measured. |

One row per counted plant, with its size and the `survey_id` of its
survey; a `partial` plant counts as half. Used by
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.html)
and checked by
[`kb_check_data_size_census_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_nereo.html),
[`kb_check_data_size_census_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_macro.html).

***Nereocystis***

[TABLE]

***Macrocystis***

[TABLE]

One row per in situ survey, with its `survey_id`, `site`, `year`, and
survey area, and, where the canopy was mapped over it, its plot cover.
Used by
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.html)
and checked by
[`kb_check_data_survey_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_in_situ.html).

[TABLE]

One row per canopy map, with its `site`, `year`, and mapped canopy. Used
by
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.html)
and checked by
[`kb_check_data_survey_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_canopy.html).

| Column | Units | Allowed | Example | Description |
|:---|:---|:---|:---|:---|
| `site` |  | any text | `otter_cove` | The site mapped. |
| `year` |  | whole number or text | `2024` | The year of the map. |
| `canopy_area_m2` | m² | \>= 0 and \<= classified_area_m2 | `7528` | The canopy area mapped. |
| `canopy_tide_height_m` | m | any number | `1.0` | The tide height when the canopy was imaged, relative to chart datum, ideally close to 0 m and at most 2 m, or 0 for canopy already corrected for tide. |
| `classified_area_m2` | m² | \> 0 | `18478` | The water area the canopy classification covered, including water where no canopy was found. |

One row per tissue sample, with no site or year. Used by
[`kb_fit_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_nereo.html),
[`kb_fit_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_macro.html)
and checked by
[`kb_check_data_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_nereo.html),
[`kb_check_data_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_macro.html).

| Column | Units | Allowed | Example | Description |
|:---|:---|:---|:---|:---|
| `wet_mass_g` | g | \> 0 | `4.16` | The mass of the tissue sample before drying. |
| `dry_mass_g` | g | \> 0 and \< wet_mass_g | `0.33` | The mass of the tissue sample after drying. |

One row per tissue sample, with no site or year. Used by
[`kb_fit_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_nereo.html),
[`kb_fit_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_macro.html)
and checked by
[`kb_check_data_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_nereo.html),
[`kb_check_data_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_macro.html).

| Column | Units | Allowed | Example | Description |
|:---|:---|:---|:---|:---|
| `sample_mass_mg` | mg | \> 0 | `2.33` | The mass of the dried tissue sample analysed. |
| `carbon_mass_ug` | µg | \> 0 and less than the sample mass | `594` | The mass of carbon measured in the sample. |

One row per tissue sample, with no site or year. Used by
[`kb_fit_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_nereo.html),
[`kb_fit_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_macro.html)
and checked by
[`kb_check_data_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_nereo.html),
[`kb_check_data_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_macro.html).

| Column | Units | Allowed | Example | Description |
|:---|:---|:---|:---|:---|
| `sample_mass_mg` | mg | \> 0 | `2.33` | The mass of the dried tissue sample analysed. |
| `nitrogen_mass_ug` | µg | \> 0 and less than the sample mass | `42.9` | The mass of nitrogen measured in the sample. |

## Checking the data

Each dataset has a `kb_check_data_*()` function that checks the data
against the format expected by the model fitting functions (e.g., column
names and values) and gives an informative error message when a
correction is required. See the [data
checks](https://hakaiinstitute.github.io/kelpbio/reference/index.html#data-checks)
in the reference for details on the format requirements.

``` r

kb_check_data_weight_nereo(data_weight_sim_nereo)

kb_check_data_weight_nereo(data_weight_sim_nereo[, c("diameter_mm", "site")])
#> Error in `kb_check_data_weight_nereo()`:
#> ! `data_weight_sim_nereo[, c("diameter_mm", "site")]` must include 'weight_kg' and 'year'.
```
