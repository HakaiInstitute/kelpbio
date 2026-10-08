## MODIFIED Requirements

### Requirement: Prediction grids

`kb_new_data(fit, by = NULL, ...)` SHALL return a data frame for use as `new_data` with a weight, size, density, or cover biomass fit: one row per level of the factors named in `by` (`NULL` for a single row with no grouping columns, `"site"`, `"year"`, or `c("site", "year")`, the last taking only the combinations in the fitted data), in the fit's level order. Levels of `site` or `year` not named in `by` MAY be supplied by name in `...` (character, factor, or numeric), and each SHALL be crossed with the rest of the grid; a level the fit has not seen SHALL be accepted and resolved at prediction as a new level. For a weight fit the rows SHALL be crossed with values of the species predictor, supplied as a named numeric vector of any length (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*) and defaulting to 30 evenly spaced values over the observed range, rounded to whole numbers for `fronds`; the predictor column SHALL take the input column's name. For a cover biomass fit the rows SHALL be crossed with values of tide-corrected cover, supplied as `cover` (proportions from 0 to 1) and defaulting to 30 evenly spaced values from 0 to 1, each row being a unit plot at zero tide height with the `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` columns the prediction reads. The grid SHALL hold no `area_m2` column. It SHALL error, naming the valid values, for an unknown `by` value, a `cover` outside 0 to 1, an argument in `...` that is neither the fit's predictor nor `site` or `year` (such as the other species' predictor, or any predictor for a size or density fit), a grouping factor both named in `by` and given values, missing grouping values, or a fit with no grouping factors.

#### Scenario: Curves over a named predictor
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = c(20, 40))` is called on a *Nereocystis* weight fit
- **THEN** it returns two rows per fitted site, with `site` and `diameter_mm` columns

#### Scenario: A single predictor value
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = 50)` is called on a *Nereocystis* weight fit
- **THEN** it returns one row per fitted site, each at 50 mm

#### Scenario: Cover grids agree with survey rows
- **WHEN** `kb_predict_cover_biomass(fit, kb_new_data(fit, by = "site", cover = 0.5))` is called, and `kb_predict_cover_biomass()` at the same sites with `canopy_area_m2 = 50`, `plot_area_m2 = 100`, and `tide_height_m = 0`
- **THEN** the estimates are equal

#### Scenario: A default predictor sequence
- **WHEN** `kb_new_data(fit)` is called on a weight fit
- **THEN** it returns 30 rows spanning the observed range of the species predictor, with no grouping columns

#### Scenario: Site and year take observed combinations
- **WHEN** `kb_new_data(fit, by = c("site", "year"))` is called
- **THEN** it returns one row per site-year in the fitted data

#### Scenario: Supplied levels are crossed into the grid
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = 40, year = 2021)` is called on a *Nereocystis* weight fit
- **THEN** it returns one row per fitted site, each in 2021 at 40 mm

#### Scenario: A wrong predictor argument errors
- **WHEN** `kb_new_data()` is given `fronds` for a *Nereocystis* weight fit, any predictor for a size or density fit, or `year` together with `by = "year"`
- **THEN** it errors naming the columns the grid can take, or the conflict

#### Scenario: A fit without groups errors
- **WHEN** `kb_new_data()` is called on a wet/dry or carbon fit
- **THEN** it errors stating the model has no grouping factors
