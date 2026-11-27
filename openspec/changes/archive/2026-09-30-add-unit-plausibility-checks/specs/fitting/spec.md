## ADDED Requirements

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, SHALL warn when a column's median is implausible for its expected unit: `diameter` below 10 or above 200 (millimetres), `weight` above 100 (kilograms), or `density` above 100 (stipes per m²). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn_implausible_units.md`.

#### Scenario: Diameter in centimetres is flagged
- **WHEN** *Nereocystis* data have `diameter` in centimetres (median about 3)
- **THEN** a warning names `diameter`, its median, and millimetres, and the data still pass

#### Scenario: Weight in grams is flagged
- **WHEN** either species' data have `weight` in grams
- **THEN** a warning names `weight`, its median, and kilograms

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued
