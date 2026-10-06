## Why

The cover biomass model predicts biomass per m² of a surveyed plot, but the
quantity the drone program exists to report is the total biomass (and carbon
stock) of each site in each year, and its sum over sites. The analysis project
computes these totals from the cover-biomass fit and the mapped canopy of every
drone survey (`predict-cover-total-{nereo,macro}.R`); kelpbio has the fit but no
way to produce the totals, and the companion app plans a totals step on top of it.

## What Changes

- New verb `kb_predict_site_biomass(fit, new_data, wetdry = NULL,
  carbon = NULL, ..., measure = c("wet", "dry", "carbon"), sum_by = NULL,
  new_levels = c("sample", "average"), representative_site = NULL, conf_level,
  estimate, sig_fig)` taking a cover biomass fit and drone surveys, and
  returning a `kb_predictions` object of total biomass: wet (kg, the default),
  dry (kg, needs `wetdry`), or carbon (kg C, needs `wetdry` and `carbon`).
- Per draw, a survey's total is the expected biomass per m² of bed (the floor
  plus the canopy term at full cover, with the survey's site and year effects)
  times its tide-corrected canopy area. The floor is included and applies over
  the mapped canopy, which is taken as the bed extent. Dry and carbon totals are
  the wet total times the expected dry:wet ratio, and also the carbon fraction,
  per draw.
- `new_data` holds one row per drone survey of a site: `site`, `year`,
  `canopy_area_m2`, and `tide_height_m`, and optionally `site_area_m2`, the area
  within the site boundary, which caps the tide-corrected canopy. `new_data` is
  required: the cover fit's own data are calibration plots, not sites. Each row
  reports
  `cover_support`: the data the cover fit has for its site and year.
- Name-only `sum_by` sums the survey totals within groups of `new_data` columns
  (for example `"year"`) on every draw before summarising, so regional or
  coastwide totals carry correct limits.
- `new_levels` defaults to `"sample"`, as for plot biomass: every row is a
  particular site-year, and a site or year absent from the calibration needs an
  interval for that site or year. Rows naming one new site or year share its
  effect, so their sum is consistent.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: a requirement for site biomass, and the `new_levels` default
  names `kb_predict_site_biomass()` alongside plot biomass.

## Non-goals

- Totals without the floor (the analysis's "detected" relationship); a name-only
  flag can be added later without breaking code.
- Applying the floor over the whole area within the site boundary rather than the
  mapped canopy.
- Nitrogen and blade totals (no kelpbio models yet), and a month dimension.
- Observation-level variation in the totals: the interval is for the expected
  total, as in the analysis.
- Spatial support finer or coarser than a survey row, other than sums over rows.

## Impact

- New: `R/kb_predict_site_biomass.R` and internal helpers for the per-survey
  total draws and the grouped sums, with tests; `kb_plot_predictions()` gains
  axis titles for the totals; `site_area_m2` joins the unit-suffixed columns
  and their plausibility warnings.
- `_pkgdown.yml`, the demo script (cover section), and the predictions spec.
- kelpbioshiny: the mocked `kb_predict_biomass_total(fit_cover, biomass)` becomes
  `kb_predict_site_biomass(fit, new_data)` (separate repo).
