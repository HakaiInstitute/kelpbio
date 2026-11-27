## MODIFIED Requirements

### Requirement: Input data

The required columns SHALL be, with `site` and `year` character or factor and no missing values in any required column. A column measured in a unit SHALL name the unit as a suffix (`_mm`, `_kg`, `_m2`); counts and grouping columns carry no suffix.

- *Nereocystis* weight: `diameter_mm` (sub-bulb diameter, mm, > 0), `weight_kg` (kg, > 0), `site`, and `year`.
- *Macrocystis* weight: `fronds` (a positive whole number), `weight_kg` (kg, > 0), `site`, and `year`.
- *Nereocystis* size: `diameter_mm` (maximum sub-bulb diameter, mm, > 0), `site`, and `year`.
- *Macrocystis* size: `fronds` (fronds at 1 m above the holdfast, a positive whole number), `site`, and `year`.

*Nereocystis* weight data MAY include `stipes_m2`, the stipe density (stipes per m²) of the plant's site-year: numeric, `>= 0`, `NA` where not recorded, and at most one distinct value per site-year. Other columns SHALL be ignored. `kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`, `kb_check_data_size_nereo()`, and `kb_check_data_size_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry.

#### Scenario: Valid data passes
- **WHEN** a data check is called on data meeting the requirements
- **THEN** it returns the data invisibly with no message

#### Scenario: A bad column errors naming it
- **WHEN** a required column is missing, of the wrong type, out of range, or contains `NA`
- **THEN** it errors with a message naming the column

#### Scenario: An unsuffixed column name is missing
- **WHEN** *Nereocystis* weight data have `diameter` and `weight` but not `diameter_mm` and `weight_kg`
- **THEN** it errors naming the missing `diameter_mm` column

#### Scenario: A zero frond count errors for size
- **WHEN** *Macrocystis* size data contain a plant with `fronds` of `0`
- **THEN** it errors naming `fronds`, since the model describes plants with at least one frond at 1 m

#### Scenario: Conflicting density within a site-year errors
- **WHEN** two rows of the same site-year carry different `stipes_m2` values
- **THEN** it errors naming the site-year

#### Scenario: Density is optional
- **WHEN** *Nereocystis* weight data have no `stipes_m2` column, or one of all `NA`
- **THEN** the data pass

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included when the data span more than one year and omitted otherwise, for every model. When no site was sampled in more than one year it SHALL be retained with a warning that the site and site:year effects cannot be interpreted separately.

The *Nereocystis* weight model's density effect SHALL be included when at least two distinct site-year values of `stipes_m2` are recorded, with density standardised by its mean and SD over the fitted plants. A row with `NA` takes its site-year's recorded value; site-years with no recorded density take the mean.

An omitted effect SHALL not be fitted, reported, or used in prediction (see summaries and predictions). Informational messages SHALL report an omitted site:year effect, a `stipes_m2` column that yields no density effect, and the number of site-years without recorded density; none is issued when there is no `stipes_m2` column, and all are suppressed by `progress = "none"`.

#### Scenario: Single-year data omit site:year
- **WHEN** the data contain one year
- **THEN** the fit has no site:year effect and, unless `progress = "none"`, a message says so

#### Scenario: Aliased design warns
- **WHEN** the data span several years but no site spans more than one
- **THEN** the site:year effect is retained and a warning is issued

#### Scenario: Density effect follows the recorded values
- **WHEN** *Nereocystis* weight data have no `stipes_m2` column, a column of all `NA` or a single value, or at least two distinct recorded site-year values
- **THEN** the density effect is omitted silently, omitted with a message, or included, respectively

#### Scenario: Unrecorded site-years take the mean
- **WHEN** density is recorded for some site-years and not others
- **THEN** the unrecorded site-years enter at the mean density and a message gives their number

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo`, `data_weight_sim_macro`, `data_size_sim_nereo`, and `data_size_sim_macro`, and small pre-fits `fit_weight_sim_nereo`, `fit_weight_sim_macro`, `fit_size_sim_nereo`, and `fit_size_sim_macro`, for examples and tests, not inference. The bundled datasets and the data stored in the pre-fits SHALL use the input column names above. The simulated *Nereocystis* weight data SHALL include a `stipes_m2` column recorded for every site-year. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, SHALL warn when a column's median is implausible for the unit its name states: `diameter_mm` below 10 or above 200 (millimetres), `weight_kg` above 100 (kilograms), or `stipes_m2` above 100 (stipes per m²). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn_implausible_units.md`.

#### Scenario: Diameter in centimetres is flagged
- **WHEN** *Nereocystis* data have `diameter_mm` in centimetres (median about 3)
- **THEN** a warning names `diameter_mm`, its median, and millimetres, and the data still pass

#### Scenario: Weight in grams is flagged
- **WHEN** either species' data have `weight_kg` in grams
- **THEN** a warning names `weight_kg`, its median, and kilograms

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued
