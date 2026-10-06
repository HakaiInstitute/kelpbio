No Stan or fit-structure change: no `rstan_config()`, `devtools::install()`
checkpoint, or `--fits` rebuild is needed.

## 1. Pure pieces

- [x] 1.1 Per-survey wet total draws: bed biomass per m² from the cover model's `.linpred()`/`.epred()` at a fully covered unit plot of each row's site and year, times the tide-corrected canopy area (capped at `site_area_m2` where supplied) on the same draws; tests against a hand computation from the draws
- [x] 1.2 `cover_support` per row from the cover fit's site and year levels; tests
- [x] 1.3 Grouped per-draw sums for `sum_by` (including `character(0)`), ordered by factor levels, with the overlapping site-year warning; `sum_by` columns character or factor with no missing values; tests
- [x] 1.4 Validation: `canopy_area_m2`, `tide_height_m`, `site`, `year`, and an optional `site_area_m2` (at least the canopy) in `new_data`; `site_area_m2` in `column_units` and the implausible-unit warnings; `sum_by` columns present, model classes, the fits `measure` needs, shared species, equal draw counts (reusing `.chk_same_species()` / `.chk_same_ndraws()`); `.vld_`/`.chk_` pairs and error snapshots

## 2. Verb

- [x] 2.1 `kb_predict_site_biomass()` with roxygen (three examples: observed surveys, own surveys with a new site, `sum_by = "year"` with carbon); `measure` conversions per draw; summary to a `kb_predictions` object with `biomass_kg` / `dry_biomass_kg` / `carbon_biomass_kg` responses
- [x] 2.2 Structure and invariant tests on the fixtures: one row per survey, total equals bed biomass x canopy area per draw, scaling with canopy area, dry/carbon conversions, sums on draws vs sum of medians, `"sample"` at least as wide as `"average"` for an unseen site, seed reproducibility, errors
- [x] 2.3 `kb_plot_predictions()` axis titles for the three totals

## 3. Docs and archive

- [x] 3.1 `_pkgdown.yml`; the cover section of `scripts/demo-api-test.R` (totals per survey, by year, carbon, and from the end-to-end cover fit)
- [x] 3.2 Note for kelpbioshiny (separate repo): the mocked `kb_predict_biomass_total()` becomes `kb_predict_site_biomass()`
- [x] 3.3 Check the specs and reader docs against the code; `openspec archive add-site-biomass --yes`
