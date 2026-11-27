## MODIFIED Requirements

### Requirement: Input data

The required columns SHALL be, with no missing or infinite values in any required column. `site` SHALL be character or factor. `year` and `survey_id` SHALL be character, factor, or numeric; a numeric `year` SHALL be whole numbers. Numeric values SHALL be converted to character on entry, so the fit's levels, the stored data, and every output carry them as character; character and factor values SHALL be kept as given. A column measured in a unit SHALL name the unit as a suffix (`_mm`, `_kg`, `_m2`); counts, grouping, and identifier columns carry no suffix. "Plant" SHALL mean, for both species, one individual (sporophyte) identified by its holdfast. The fits work at site-year resolution: weight, size sample, and survey data SHALL give the year of each row in `year`, and no date column SHALL be read.

- *Nereocystis* weight: `diameter_mm` (sub-bulb diameter, mm, > 0), `weight_kg` (kg, > 0), `site`, and `year`.
- *Macrocystis* weight: `fronds` (fronds at 1 m above the holdfast, a positive whole number), `weight_kg` (kg, > 0), `site`, and `year`.
- *Nereocystis* size sample (plants measured to fit the size model): `diameter_mm` (maximum sub-bulb diameter, mm, > 0), `site`, and `year`.
- Wet/dry, both species: `wet_mass_g` (wet mass of a sample, g, > 0) and `dry_mass_g` (its dry mass, g, > 0 and less than `wet_mass_g`). A warning SHALL give the number of samples whose dry:wet ratio lies outside 0.02 to 0.5, the plausible range for kelp tissue, and those samples SHALL be kept.
- Carbon, both species: `sample_mass_mg` (mass of a dried sample, mg, > 0) and `carbon_mass_ug` (carbon measured in it, µg, > 0), the carbon fraction `carbon_mass_ug / 1000 / sample_mass_mg` being less than 1. A warning SHALL give the number of samples whose carbon fraction lies outside 0.10 to 0.50, the plausible range for kelp tissue, and those samples SHALL be kept.
- In situ surveys, both species: one row per survey, with `survey_id` (each value appearing once), `site`, `year`, and `survey_area_m2` (the surveyed area, m², > 0). Surveys of the same site in the same year, including on the same day, SHALL be separate rows with distinct `survey_id` values. `plants` (plants counted, a number `>= 0`) SHALL be present when sizes come from a size fit and absent when they come from a size census. `plot_area_m2` (the plot polygon, m², > 0), `canopy_area_m2` (drone canopy delineated in the plot, m², `>= 0` and at most `plot_area_m2`), and `canopy_tide_height_m` (tide height when the canopy was imaged, m, chart datum) MAY be present; on each row all three SHALL be given or all three missing.
- Size census (every plant a survey counted): one row per counted plant, with `survey_id` matching a survey row, the size (`diameter_mm` for *Nereocystis*, > 0; `fronds` for *Macrocystis*, a positive whole number), and optionally `partial` (logical, no missing values; `TRUE` counts the plant as half). A plant's site and year SHALL be those of its survey.
- Canopy maps, both species: one row per map of a site's canopy, with `site`, `year`, `canopy_area_m2` (canopy area, m², `>= 0`), `canopy_tide_height_m` (tide height when the canopy was imaged, m, chart datum), and `classified_area_m2` (the water area the canopy classification covered, m², > 0 and at least `canopy_area_m2`).
- Cover calibration, both species: `data` is the output of `kb_predict_biomass_in_situ()` at its default `pool_by`, wet biomass per m², each survey with drone cover entering as one observation. It SHALL carry `site`, `year`, `plot_area_m2`, `canopy_area_m2`, `canopy_tide_height_m`, and the `biomass_kg_m2` column of draws. Rows without drone cover SHALL be left out with a message giving their number (suppressed by `progress = "none"`), and the fit SHALL error when no row has drone cover. Data lacking `biomass_kg_m2` (dry or carbon biomass, or total biomass) or a column of draws in it, or lacking the survey columns (summed output), SHALL error naming the missing columns and pointing to `kb_predict_biomass_in_situ()` with its defaults.

Other columns SHALL be ignored. `kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`, `kb_check_data_size_sample_nereo()`, `kb_check_data_wetdry_nereo()`, `kb_check_data_wetdry_macro()`, `kb_check_data_carbon_nereo()`, `kb_check_data_carbon_macro()`, `kb_check_data_cover_calibration_nereo()`, and `kb_check_data_cover_calibration_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry. `kb_check_data_in_situ(data, size_census = NULL)` SHALL check a survey table, and with `size_census` also the size census, the join by `survey_id`, and the absence of a `plants` column; `kb_check_data_size_census_nereo()` and `kb_check_data_size_census_macro()` SHALL check a size census alone. `kb_check_data_canopy()` SHALL check canopy maps, the `new_data` of `kb_predict_biomass_canopy()`, with the errors that function gives.

#### Scenario: Canopy maps are checked as the canopy prediction checks them
- **WHEN** `kb_check_data_canopy()` is called on canopy maps whose `canopy_area_m2` exceeds `classified_area_m2`, or that lack `canopy_tide_height_m`
- **THEN** it errors naming the column, as `kb_predict_biomass_canopy()` does for the same `new_data`

#### Scenario: Valid data passes
- **WHEN** a data check is called on data meeting the requirements
- **THEN** it returns the data invisibly with no message

#### Scenario: A bad column errors naming it
- **WHEN** a required column is missing, of the wrong type, out of range, or contains `NA`
- **THEN** it errors with a message naming the column

#### Scenario: An unsuffixed column name is missing
- **WHEN** *Nereocystis* weight data have `diameter` and `weight` but not `diameter_mm` and `weight_kg`
- **THEN** it errors naming the missing `diameter_mm` column

#### Scenario: A zero frond count errors for counted plants
- **WHEN** a *Macrocystis* size census contains a plant with `fronds` of `0`
- **THEN** it errors naming `fronds`, since the model describes plants with at least one frond at 1 m

#### Scenario: Weight data take a year
- **WHEN** *Nereocystis* weight data have `site` and `year`
- **THEN** they pass, and the fit's site-years are the combinations of `site` and `year` in the data

#### Scenario: A numeric year is converted
- **WHEN** weight, size sample, or survey data have `year` as whole numbers such as `2021`
- **THEN** they pass, and the fit's year levels and the stored data hold `"2021"`

#### Scenario: A fractional year errors
- **WHEN** a `year` column holds a number that is not whole, such as `2021.5`
- **THEN** it errors naming `year`

#### Scenario: A numeric survey identifier is converted
- **WHEN** survey data and a size census give `survey_id` as numbers
- **THEN** they pass, census rows join to their surveys by those values, and outputs carry `survey_id` as character

#### Scenario: Data with a date and no year error
- **WHEN** weight, size sample, or survey data have a `date` column and no `year` column
- **THEN** it errors naming the missing `year` column

#### Scenario: Zero plants are valid for a tallied survey
- **WHEN** survey data contain a survey with `plants` of `0`
- **THEN** the data pass

#### Scenario: A tally with a size census errors
- **WHEN** `kb_check_data_in_situ(data, size_census)` is called with a `data` holding a `plants` column
- **THEN** it errors stating that counts come from the size census rows

#### Scenario: A census plant with no survey errors
- **WHEN** a size census row's `survey_id` matches no survey row
- **THEN** it errors naming the unmatched `survey_id` values

#### Scenario: Partial drone columns error
- **WHEN** a survey row has `canopy_area_m2` but a missing `canopy_tide_height_m` or `plot_area_m2`
- **THEN** it errors naming the missing column

#### Scenario: Canopy larger than its plot errors
- **WHEN** a survey row's `canopy_area_m2` exceeds its `plot_area_m2`
- **THEN** it errors naming `canopy_area_m2`

#### Scenario: A surveyed area above the plot area warns
- **WHEN** a survey row's `survey_area_m2` exceeds its `plot_area_m2`
- **THEN** a warning names both columns, and the data still pass

#### Scenario: A repeated survey identifier errors
- **WHEN** survey data have two rows with the same `survey_id`
- **THEN** it errors naming the repeated `survey_id` values

#### Scenario: Repeat surveys in a site-year pass
- **WHEN** survey data have two rows with the same `site` and `year` and distinct `survey_id` values
- **THEN** the data pass, with one survey per row

#### Scenario: A dry mass not below the wet mass errors
- **WHEN** wet/dry data contain a sample whose `dry_mass_g` is greater than or equal to its `wet_mass_g`
- **THEN** it errors naming `dry_mass_g`

#### Scenario: An implausible dry:wet ratio warns
- **WHEN** a sample's dry:wet ratio lies outside 0.02 to 0.5
- **THEN** a warning gives the number of such samples, and the data still pass with every sample kept

#### Scenario: Carbon above the sample mass errors
- **WHEN** carbon data have a `carbon_mass_ug` above `sample_mass_mg` once converted to milligrams, as a sample mass in grams produces
- **THEN** it errors naming `carbon_mass_ug` and the expected units

#### Scenario: An implausible carbon fraction warns
- **WHEN** a sample's carbon fraction lies outside 0.10 to 0.50
- **THEN** a warning gives the number of such samples, and the data still pass with every sample kept

#### Scenario: Survey biomass passes straight into the calibration
- **WHEN** `kb_fit_cover_calibration_nereo()` is given `kb_predict_biomass_in_situ()` output with its defaults
- **THEN** it fits the rows with drone cover, and the fit stores each survey's biomass as the mean (`biomass_kg_m2`) and SD (`biomass_sd_kg_m2`) of its draws, not the draws

#### Scenario: Rows without drone cover are left out
- **WHEN** some rows of the calibration data have missing drone columns
- **THEN** those rows are not fitted, and a message gives their number

#### Scenario: Dry or summed biomass errors
- **WHEN** the calibration data are `kb_predict_biomass_in_situ()` output with `measure = "dry"`, `per_area = FALSE`, or a `pool_by`
- **THEN** it errors naming the missing columns (`biomass_kg_m2`, or the survey's drone columns) and pointing to the defaults

#### Scenario: Zero canopy is valid for the calibration
- **WHEN** the calibration data contain a survey with `canopy_area_m2` of `0`
- **THEN** the data pass

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, and `kb_predict_biomass_canopy()` on its `new_data`, SHALL warn when a column's median is implausible for the unit its name states: `diameter_mm` below 10 or above 200 (millimetres), `weight_kg` above 100 (kilograms), `survey_area_m2` below 1 or above 5000 (square metres), `plot_area_m2` below 1 or above 1,000,000 (square metres), `classified_area_m2` below 10 or above 1,000,000,000 (square metres), `canopy_tide_height_m` below -1 or above 5 (metres), or `wet_mass_g` or `dry_mass_g` above 1000 (grams). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn.md`.

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
- **WHEN** survey data have `canopy_tide_height_m` in centimetres (median about 60)
- **THEN** a warning names `canopy_tide_height_m`, its median, and metres, and the data still pass

#### Scenario: Sample masses in milligrams are flagged
- **WHEN** wet/dry data have `wet_mass_g` in milligrams (median about 4000)
- **THEN** a warning names `wet_mass_g`, its median, and grams, and the data still pass

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued

### Requirement: Surveys past the tide limit are flagged

The cover calibration fits SHALL warn when a survey with positive canopy has more than a 5% probability, under the tide slope's prior truncated to its support, of a tide height at or above one over the tide slope, giving the number of such surveys and saying that there the survey enters as fully covered rather than with the canopy measured. The warning SHALL NOT stop the fit. A survey with positive canopy whose tide height is at or above one over the tide slope SHALL enter the fit as fully covered; a survey with no canopy SHALL keep zero cover. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: A survey flown at 3.5 m warns
- **WHEN** a *Nereocystis* cover calibration is fitted with the default priors and one survey with canopy has `canopy_tide_height_m` of 3.5
- **THEN** a warning gives one survey, and the fit proceeds

#### Scenario: Surveys at ordinary tides raise no tide warning
- **WHEN** every survey has `canopy_tide_height_m` at or below 2, including negative tide heights
- **THEN** no tide warning is issued

#### Scenario: A survey past the tide limit is fully covered
- **WHEN** the log-likelihood of a cover calibration fit is computed at a survey whose tide height is at or above one over a draw's tide slope
- **THEN** that draw's value is finite and equals the log-likelihood at full cover
