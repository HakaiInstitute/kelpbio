## MODIFIED Requirements

### Requirement: Input data

The required columns SHALL be, with `site` (where required) character or factor, `year` (where required) character, factor, or whole-number numeric, and no missing or infinite values in any required column. This applies to the `site` and `year` of cover biomass `biomass` too. A numeric `year` SHALL name the level of the same digits, so 2020 and `"2020"` are one year, and the fit SHALL hold it, in its stored data and its year effects, as a factor whose levels follow numeric order. A column measured in a unit SHALL name the unit as a suffix (`_mm`, `_kg`, `_m2`); counts and grouping columns carry no suffix.

- *Nereocystis* weight: `diameter_mm` (sub-bulb diameter, mm, > 0), `weight_kg` (kg, > 0), `site`, and `year`.
- *Macrocystis* weight: `fronds` (a positive whole number), `weight_kg` (kg, > 0), `site`, and `year`.
- *Nereocystis* size: `diameter_mm` (maximum sub-bulb diameter, mm, > 0), `site`, and `year`.
- *Macrocystis* size: `fronds` (fronds at 1 m above the holdfast, a positive whole number), `site`, and `year`.
- *Nereocystis* density: `stipes` (stipes counted on a transect, a whole number `>= 0`), `area_m2` (area surveyed, m², > 0), `site`, and `year`.
- *Macrocystis* density: `plants` (plants counted on a transect, a whole number `>= 0`), `area_m2` (area surveyed, m², > 0), `site`, and `year`.
- Wet/dry, both species: `wet_mass_g` (wet mass of a sample, g, > 0) and `dry_mass_g` (its dry mass, g, > 0 and less than `wet_mass_g`). A warning SHALL give the number of samples whose dry:wet ratio lies outside 0.02 to 0.5, the plausible range for kelp tissue, and those samples SHALL be kept.
- Carbon, both species: `sample_mass_mg` (mass of a dried sample, mg, > 0) and `carbon_mass_ug` (carbon measured in it, µg, > 0), the carbon fraction `carbon_mass_ug / 1000 / sample_mass_mg` being less than 1. A warning SHALL give the number of samples whose carbon fraction lies outside 0.10 to 0.50, the plausible range for kelp tissue, and those samples SHALL be kept.
- Cover biomass, both species: `data` holds the drone surveys, `canopy_area_m2` (canopy delineated in the plot, m², `>= 0`), `plot_area_m2` (plot area, m², > 0 and at least `canopy_area_m2`), `tide_height_m` (tide height at the survey, m, chart datum), `site`, and `year`, and no `estimate`, `lower`, or `upper` column. The in situ wet biomass (kg/m²) is a separate data frame, the fit functions' required second argument `biomass` (before `priors`): `site` and `year`, one row per site-year, and `estimate` (> 0) with its compatibility limits `lower` and `upper` (`0 < lower <= estimate <= upper`, `lower < upper`), the columns of a `kb_predictions` object, so a biomass prediction passes in unchanged. Each survey SHALL be paired with the biomass of its site-year. Surveys with none SHALL be dropped with a message giving their number and site-years (suppressed by `progress = "none"`), and the fit SHALL error when no survey is paired. The level of the limits SHALL be the one a `kb_predictions` object records, else the name-only `conf_level`, else 0.95; a `conf_level` that contradicts the recorded level SHALL error. A `kb_predictions` object recording a response other than wet biomass (`biomass_kg_m2`) SHALL error.

*Nereocystis* weight data MAY include `stipes_m2`, the stipe density (stipes per m²) of the plant's site-year: numeric, `>= 0`, `NA` where not recorded, and at most one distinct value per site-year. Other columns SHALL be ignored. `kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`, `kb_check_data_size_nereo()`, `kb_check_data_size_macro()`, `kb_check_data_density_nereo()`, `kb_check_data_density_macro()`, `kb_check_data_wetdry_nereo()`, `kb_check_data_wetdry_macro()`, `kb_check_data_carbon_nereo()`, `kb_check_data_carbon_macro()`, `kb_check_data_cover_biomass_nereo()`, and `kb_check_data_cover_biomass_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry. The cover biomass checks SHALL also check `biomass` when it is supplied.

#### Scenario: Valid data passes
- **WHEN** a data check is called on data meeting the requirements
- **THEN** it returns the data invisibly with no message

#### Scenario: A numeric year is a level
- **WHEN** a data check or fit function is given `year` as whole numbers
- **THEN** it is accepted, and the fit's stored data and year effects hold `year` as a factor with the levels the same years give as character

#### Scenario: A numeric year pairs with a character year
- **WHEN** cover biomass surveys give a site-year's year as 2020 and `biomass` gives it as `"2020"`
- **THEN** the survey is paired with that biomass

#### Scenario: A fractional year errors
- **WHEN** `year` in `data` or `biomass` holds a value that is not a whole number, such as 2020.5
- **THEN** it errors naming the column

#### Scenario: A bad column errors naming it
- **WHEN** a required column is missing, of the wrong type, out of range, or contains `NA`
- **THEN** it errors with a message naming the column

#### Scenario: An unsuffixed column name is missing
- **WHEN** *Nereocystis* weight data have `diameter` and `weight` but not `diameter_mm` and `weight_kg`
- **THEN** it errors naming the missing `diameter_mm` column

#### Scenario: A zero frond count errors for size
- **WHEN** *Macrocystis* size data contain a plant with `fronds` of `0`
- **THEN** it errors naming `fronds`, since the model describes plants with at least one frond at 1 m

#### Scenario: Zero counts are valid for density
- **WHEN** density data contain a transect with a count of `0`
- **THEN** the data pass

#### Scenario: A non-positive area errors
- **WHEN** density data contain an `area_m2` of `0` or less
- **THEN** it errors naming `area_m2`

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

#### Scenario: Zero canopy is valid for cover biomass
- **WHEN** cover biomass data contain a survey with `canopy_area_m2` of `0`
- **THEN** the data pass

#### Scenario: Canopy larger than its plot errors
- **WHEN** cover biomass data contain a survey whose `canopy_area_m2` exceeds its `plot_area_m2`
- **THEN** it errors naming `canopy_area_m2`

#### Scenario: Limits that do not bracket the estimate error
- **WHEN** cover biomass `biomass` contains a site-year whose `lower` exceeds `estimate`, whose `upper` is below it, or whose `lower` equals `upper`
- **THEN** it errors naming the offending limit

#### Scenario: Repeated site-years in the biomass error
- **WHEN** cover biomass `biomass` has two rows for one site-year
- **THEN** it errors naming the site-year

#### Scenario: A biomass prediction passes straight in
- **WHEN** `biomass` is a `kb_predictions` object with `site` and `year` columns
- **THEN** the fit pairs it with the surveys and uses the interval level it records

#### Scenario: A dry or carbon biomass prediction errors
- **WHEN** `biomass` is a `kb_predictions` object of dry or carbon plot biomass
- **THEN** it errors naming the recorded response and pointing to wet biomass

#### Scenario: Surveys without biomass are dropped
- **WHEN** some surveys' site-years have no row in `biomass`
- **THEN** those surveys are not fitted, and a message gives their number and site-years

#### Scenario: Conflicting density within a site-year errors
- **WHEN** two rows of the same site-year carry different `stipes_m2` values
- **THEN** it errors naming the site-year

#### Scenario: Density is optional
- **WHEN** *Nereocystis* weight data have no `stipes_m2` column, or one of all `NA`
- **THEN** the data pass
