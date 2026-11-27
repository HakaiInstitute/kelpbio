## MODIFIED Requirements

### Requirement: One prediction verb per model

Each model SHALL have one prediction verb, `kb_predict_<model>()`, returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). For a model with grouping factors the verb SHALL take `new_data` and predict at its rows, in their order, or at the observed data when `new_data = NULL`. The returned object SHALL hold the input columns plus the summary columns. Predictions per group or over a predictor sequence SHALL be made by passing a grid from `kb_new_data()` as `new_data`.

- Weight: `kb_predict_weight(fit, new_data)` predicts expected weight (kg). `new_data` SHALL have the species predictor column (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*). New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` predicts expected size, the mean of the size distribution: sub-bulb diameter (mm) for *Nereocystis*, and fronds at 1 m for *Macrocystis*, among plants with at least one. `new_data` needs no columns.
- Density: `kb_predict_density(fit, new_data)` predicts expected density, stipes (*Nereocystis*) or plants (*Macrocystis*) per m², in a response column named `stipes_m2` or `plants_m2`. It SHALL NOT read an `area_m2` column, so the estimate is per m² at the observed data too. For *Nereocystis* it includes the probability that a transect holds no stipes.
- Cover biomass: `kb_predict_cover_biomass(fit, new_data)` predicts the expected wet biomass (kg/m²) of a plot from its `canopy_area_m2`, `plot_area_m2`, and `tide_height_m`, which `new_data` SHALL carry.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so the verb takes no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.

`predict()` on a fit SHALL return the same result as the model's verb with the same arguments.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)`, `kb_predict_size(fit)`, or `kb_predict_cover_biomass(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Density at the observed data is per square metre
- **WHEN** `kb_predict_density(fit)` is called
- **THEN** it returns one prediction per observed transect, whose `estimate` equals `augment(fit)$fitted` divided by the transect's `area_m2`, up to rounding

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size or density, `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` for cover biomass)
- **THEN** predictions are returned at exactly those rows, in their order

#### Scenario: Density ignores the transect area
- **WHEN** `kb_predict_density()` is called at the same site and year with `area_m2` of 10 and of 20
- **THEN** the two estimates are equal

#### Scenario: Zero cover predicts the floor
- **WHEN** `kb_predict_cover_biomass()` is called at `canopy_area_m2 = 0`
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
