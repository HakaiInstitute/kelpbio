## MODIFIED Requirements

### Requirement: Canopy biomass

`kb_predict_biomass_canopy(fit, new_data, wetdry = NULL, carbon = NULL, ...)` SHALL take a cover calibration fit and a required `new_data` with one row per map of a site's canopy (a site-year MAY have several, such as flights weeks apart), with `canopy_area_m2` (`>= 0`), `tide_height_m`, `site`, `year`, and `classified_area_m2`, the water area within the site that the canopy classification covered, including water where no canopy was found (`> 0` and at least `canopy_area_m2`), each with no missing values. Per draw, a row's wet total SHALL be the expected biomass per m² of bed, the floor plus the canopy term at full cover with the row's site and year effects, times its tide-corrected canopy area: the canopy divided by one minus the tide slope times the tide height, capped at `classified_area_m2`, and equal to `classified_area_m2` where the canopy is positive and the tide height is at or above one over the tide slope. A row with no canopy SHALL have no corrected canopy at any tide height. The floor SHALL apply over the canopy area only. No observation-level variation SHALL be added. The response column SHALL be `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg`. Each row SHALL carry `cover_support`: `"site, year"` where both its site and its year are in the fit's data, else `"site"` or `"year"` where only one is, else `"none"`. Within a `pool_by` group, more than one row for the same site and year SHALL warn that their totals overlap.

#### Scenario: One total per row
- **WHEN** `kb_predict_biomass_canopy(fit, new_data)` is called
- **THEN** it returns one row per row of `new_data`, in order, with a `cover_support` column and the response column `biomass_kg`

#### Scenario: The total is bed biomass times canopy area
- **WHEN** a row has a fitted site and year and zero tide height
- **THEN** each draw of its total equals the calibration fit's `posterior_epred()` at a fully covered unit plot (`canopy_area_m2 = 1`, `plot_area_m2 = 1`, `tide_height_m = 0`) of that site and year, times the row's `canopy_area_m2`

#### Scenario: Totals scale with canopy area
- **WHEN** two rows differ only in `canopy_area_m2`, with neither capped by `classified_area_m2`
- **THEN** the ratio of their totals equals the ratio of their canopy areas on every draw

#### Scenario: The tide correction divides the canopy
- **WHEN** a row has tide height `t` and its tide-corrected canopy is below `classified_area_m2` on every draw
- **THEN** each draw of its total equals the same row at zero tide height with its canopy divided by one minus that draw's tide slope times `t`

#### Scenario: The classified area caps the corrected canopy
- **WHEN** a row's tide-corrected canopy would exceed its `classified_area_m2`, or its tide height is at or above one over a draw's tide slope
- **THEN** that draw of its total is the bed biomass per m² times `classified_area_m2`

#### Scenario: Missing or inconsistent columns error
- **WHEN** a row's `canopy_area_m2` exceeds its `classified_area_m2`, or `new_data` lacks `canopy_area_m2`, `tide_height_m`, or `classified_area_m2`
- **THEN** it errors naming the column

#### Scenario: Overlapping rows in a sum warn
- **WHEN** a `pool_by` group holds two rows with the same site and year
- **THEN** it warns that their totals overlap and still returns the sum

#### Scenario: An unseen site is sampled by default
- **WHEN** a row names a site absent from the calibration fit's data
- **THEN** its `cover_support` is `"year"` or `"none"`, and its interval under the default `"sample"` is at least as wide as under `"average"`

## ADDED Requirements

### Requirement: The tide correction is bounded

Every prediction from a cover calibration fit (`kb_predict_cover_calibration()`, `kb_predict_biomass_canopy()`, `predict()`, and the `posterior_*()` generics) SHALL be finite at any finite tide height. Where a row with positive canopy has a tide height at or above one over a draw's tide slope, that draw SHALL use full cover for a plot and the classified area for canopy totals; a row with no canopy SHALL keep zero cover and zero canopy. `kb_predict_cover_calibration()` and `kb_predict_biomass_canopy()` SHALL warn when a row of `new_data` with positive canopy is past one over the tide slope on more than 5% of draws, giving the number of such rows and saying that there the corrected canopy is the cap rather than the canopy measured.

#### Scenario: High tides give finite, non-negative predictions
- **WHEN** `kb_predict_cover_calibration()` or `kb_predict_biomass_canopy()` is called at tide heights of 0, 2, 3.5, and 5 m
- **THEN** every draw is finite and non-negative, and the rows past the tide limit on more than 5% of draws warn

#### Scenario: A plot past the tide limit is fully covered
- **WHEN** a row's tide height is at or above one over a draw's tide slope
- **THEN** that draw of `kb_predict_cover_calibration()` equals the same row with `canopy_area_m2` equal to `plot_area_m2` at zero tide height

#### Scenario: No canopy stays zero at any tide
- **WHEN** a row has `canopy_area_m2` of 0 and a tide height above one over every draw's tide slope
- **THEN** its corrected canopy and canopy total are zero on every draw

#### Scenario: Canopy at zero tide height is used as given
- **WHEN** a row has `tide_height_m` of 0, as for canopy already corrected for tide
- **THEN** its corrected canopy equals its `canopy_area_m2`, capped at the plot area or `classified_area_m2`, on every draw

#### Scenario: A negative tide height shrinks the corrected canopy
- **WHEN** a row has a negative tide height
- **THEN** its tide-corrected canopy is smaller than its `canopy_area_m2` on every draw with a positive tide slope, and no tide warning is issued
