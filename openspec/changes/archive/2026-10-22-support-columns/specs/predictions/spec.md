## MODIFIED Requirements

### Requirement: One prediction verb per model

Each model SHALL have one prediction verb, `kb_predict_<model>()`, returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). For a model with grouping factors the verb SHALL take `new_data` and predict at its rows, in their order, or at the observed data when `new_data = NULL`. The returned object SHALL hold the input columns plus the summary columns and, when the rows have both `site` and `year` columns, a support column naming the data the fit has for each row's site and year (`weight_support`, `size_support`, or `cover_support`, with the values given under Mean weight and Canopy biomass), placed before the summary columns. Predictions per group or over a predictor sequence SHALL be made by passing a grid from `kb_new_data()` as `new_data`.

- Weight: `kb_predict_weight(fit, new_data)` predicts expected weight (kg). `new_data` SHALL have the species predictor column (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*). New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` predicts expected size, the mean of the *Nereocystis* sub-bulb diameter distribution (mm). `new_data` needs no columns.
- Cover calibration: `kb_predict_cover_calibration(fit, new_data)` predicts the expected wet biomass per m² of a plot from its `canopy_area_m2`, `plot_area_m2`, and `tide_height_m`, which `new_data` SHALL carry.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so the verb takes no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.

`predict()` on a fit SHALL return the same result as the model's verb with the same arguments.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)`, `kb_predict_size(fit)`, or `kb_predict_cover_calibration(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size, `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` for the cover calibration)
- **THEN** predictions are returned at exactly those rows, in their order

#### Scenario: Zero cover predicts the floor
- **WHEN** `kb_predict_cover_calibration()` is called at `canopy_area_m2 = 0`
- **THEN** the prediction is the same for every site and year

#### Scenario: Group predictions come from a grid
- **WHEN** `kb_predict_size(fit, kb_new_data(fit, by = "site"))` is called
- **THEN** it returns one row per fitted site, and `kb_new_data(fit)` gives a single row for the typical site and year

#### Scenario: Wet/dry returns one population estimate
- **WHEN** `kb_predict_wetdry(fit)` is called
- **THEN** it returns one row whose `estimate` equals each value of `augment(fit)$fitted`

#### Scenario: Carbon returns one population estimate
- **WHEN** `kb_predict_carbon(fit)` is called
- **THEN** it returns one row whose `estimate` equals each value of `augment(fit)$fitted`

#### Scenario: predict() matches the verb
- **WHEN** `predict(fit, new_data)` and `kb_predict_<model>(fit, new_data)` are called with the same arguments
- **THEN** they return identical results

#### Scenario: A missing predictor errors
- **WHEN** weight `new_data` lacks the species predictor
- **THEN** it errors naming the correct column

#### Scenario: Rows with a site and a year carry their support
- **WHEN** `kb_predict_weight(fit, new_data)` is called with `new_data` holding `site` and `year`
- **THEN** each row has a `weight_support` naming the data the weight fit has for its site and year, and `new_data` without both columns gets no support column

### Requirement: Pooling over groups

`kb_predict_biomass_survey()` and `kb_predict_biomass_canopy()` SHALL take a name-only `pool_by`. With `NULL` (the default) they SHALL return one row per input row with the support columns. With a character vector of input columns they SHALL return one row per combination of those columns present, with those columns, the support columns when the columns include both `site` and `year` (every row of such a group shares one site and year, so one support), the summary columns, and the response column, ordered by the columns' factor levels or, for character columns, alphabetically ignoring case; `character(0)` SHALL give one row for all rows. On each draw, biomass SHALL be summed in kg within each group and, for survey biomass with `per_area = TRUE`, divided by the group's summed `survey_area_m2`. Each `pool_by` column SHALL be character or factor with no missing values; another column, or one the input does not have, SHALL error naming it. A sampled new site or year effect SHALL be shared by every row of that level, so a sum carries the among-site variation once per site.

#### Scenario: Sums are taken on the draws
- **WHEN** `pool_by = "year"` is given
- **THEN** it returns one row per year whose draws are the sum of that year's row draws, so its `estimate` is the median of the summed draws rather than the sum of the row medians

#### Scenario: Per-area sums divide by the summed area
- **WHEN** survey biomass is summed with `pool_by = c("site", "year")` and `per_area = TRUE`
- **THEN** each draw is the site-year's total kg over its summed `survey_area_m2`

#### Scenario: Groups follow factor levels
- **WHEN** `pool_by = "region"` names a factor column
- **THEN** the rows follow its level order, and a numeric or partly missing `region` errors naming the column

#### Scenario: Site-year pools keep their support
- **WHEN** `pool_by = c("site", "year")` is given
- **THEN** each row keeps the support columns of its site-year, and `pool_by = "year"` returns none
