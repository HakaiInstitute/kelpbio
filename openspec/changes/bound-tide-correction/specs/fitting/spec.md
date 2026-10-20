## MODIFIED Requirements

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, and `kb_predict_biomass_canopy()` on its `new_data`, SHALL warn when a column's median is implausible for the unit its name states: `diameter_mm` below 10 or above 200 (millimetres), `weight_kg` above 100 (kilograms), `survey_area_m2` below 1 or above 5000 (square metres), `plot_area_m2` below 1 or above 1,000,000 (square metres), `classified_area_m2` below 10 or above 1,000,000,000 (square metres), `tide_height_m` below -1 or above 5 (metres), or `wet_mass_g` or `dry_mass_g` above 1000 (grams). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: Diameter in centimetres is flagged
- **WHEN** *Nereocystis* data have `diameter_mm` in centimetres (median about 3)
- **THEN** a warning names `diameter_mm`, its median, and millimetres, and the data still pass

#### Scenario: Weight in grams is flagged
- **WHEN** either species' data have `weight_kg` in grams
- **THEN** a warning names `weight_kg`, its median, and kilograms

#### Scenario: Area in square centimetres is flagged
- **WHEN** survey data have `survey_area_m2` in square centimetres (median about 400,000)
- **THEN** a warning names `survey_area_m2`, its median, and square metres, and the data still pass

#### Scenario: Tide height in centimetres is flagged
- **WHEN** survey data have `tide_height_m` in centimetres (median about 60)
- **THEN** a warning names `tide_height_m`, its median, and metres, and the data still pass

#### Scenario: Sample masses in milligrams are flagged
- **WHEN** wet/dry data have `wet_mass_g` in milligrams (median about 4000)
- **THEN** a warning names `wet_mass_g`, its median, and grams, and the data still pass

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued

## ADDED Requirements

### Requirement: Surveys past the tide limit are flagged

The cover calibration fits SHALL warn when a survey with positive canopy has more than a 5% probability, under the tide slope's prior truncated to its support, of a tide height at or above one over the tide slope, giving the number of such surveys and saying that there the survey enters as fully covered rather than with the canopy measured. The warning SHALL NOT stop the fit. A survey with positive canopy whose tide height is at or above one over the tide slope SHALL enter the fit as fully covered; a survey with no canopy SHALL keep zero cover. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: A survey flown at 3.5 m warns
- **WHEN** a *Nereocystis* cover calibration is fitted with the default priors and one survey with canopy has `tide_height_m` of 3.5
- **THEN** a warning gives one survey, and the fit proceeds

#### Scenario: Surveys at ordinary tides raise no tide warning
- **WHEN** every survey has `tide_height_m` at or below 2, including negative tide heights
- **THEN** no tide warning is issued

#### Scenario: A survey past the tide limit is fully covered
- **WHEN** the log-likelihood of a cover calibration fit is computed at a survey whose tide height is at or above one over a draw's tide slope
- **THEN** that draw's value is finite and equals the log-likelihood at full cover
