## Why

The wet biomass per m² of a surveyed site-year is the quantity the sub-models exist
to produce, and the in situ response the cover biomass calibration is fitted to.
The analysis project computes it as stipe (or plant) density times the mean plant
weight, integrating the weight allometry over the site-year's size distribution
(`functions-biomass-{nereo,macro}.R`, `predict-biomass-drone-survey-*.R`).
kelpbio has the three component fits but no way to combine them.

## What Changes

- New verb `kb_predict_plot_biomass(weight, size, density, wetdry = NULL,
  carbon = NULL, ..., measure = c("wet", "dry", "carbon"))` taking a weight, a
  size, and a density fit of the same species, and optionally a wet/dry and a
  carbon fit, and returning a `kb_predictions` object with one row per site-year
  surveyed for density: `site`, `year`, `weight_support` and `size_support`
  (the data each fit has for the site-year: `"site-year"`, `"site, year"`,
  `"site"`, `"year"`, or `"none"`), and `estimate`,
  `lower`, and `upper` summarising the expected biomass of the chosen measure: wet
  (kg/m², the default), dry (kg/m², needs `wetdry`), or carbon (g C/m², needs
  `wetdry` and `carbon`).
- Per draw, biomass is the expected density per m² of the site-year times the
  mean plant weight, the expected weight at size averaged over the site-year's
  size distribution, truncated above at the largest size in the size fit's data.
  Dry biomass is wet biomass times the expected dry:wet ratio, and carbon biomass
  is dry biomass times the expected carbon fraction, per draw.
- Weight and size at a site-year their fits did not observe are resolved by the
  usual rules: fitted site and year effects where available, otherwise
  `new_levels` (`"sample"`, the default, or `"average"`) or `representative_site`.
- For a *Nereocystis* weight fit with the density effect, each site-year uses its
  observed stipe density in the density fit's data.
- Name-only `n_plants` (default 100) sets the number of plants integrated per draw.
- The fits supplied must share a species and a number of draws, and the fits a
  measure needs must be supplied; otherwise it errors.
- Rows naming the same new site, year, or site-year share one sampled effect, in
  every verb; each row's interval is unchanged.
- A console progress bar (`progress`) and a pollable record (`progress_dir`)
  for the prediction, read by `kb_progress()`, which replaces `kb_fit_progress()`
  and reads both fit and prediction progress.
- *Macrocystis* plant sizes are looked up in each draw's cumulative distribution
  rather than through `stats::qnbinom()`: the same counts, several times faster.
- `kb_predictions` objects record their `conf_level`, so a biomass prediction
  carries the level of its limits.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the progress reader is `kb_progress()`.
- `predictions`: a requirement for plot biomass, one for the interval level a
  prediction records, and group resolution gains shared effects for rows naming
  one new level.

## Non-goals

- Predicting at site-years not surveyed for density, or at supplied `new_data`;
  a later row-wise verb can add this.
- Blade biomass (no blade fraction model yet), and a month dimension.
- The analysis's cumulative-blade-length route for *Nereocystis* site-years
  without sub-bulb diameters.
- Correlation between the component fits, which are fitted independently.

## Impact

- New: `R/kb_predict_plot_biomass.R` and internal helpers for the truncated size
  draws and the integration, with tests.
- `kb_predictions` gains an interval-level attribute; existing outputs otherwise
  unchanged.
- `_pkgdown.yml` and the demo gain the verb; README and vignette deferred.
- The cover biomass branch rebases onto this one, drops its own copy of the
  interval-level change, and adds an end-to-end test and demo.
