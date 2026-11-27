## Why

The input columns that carry a unit (`diameter`, `weight`, `density`) do not name it, so
a user preparing data from survey files, where similar measurements are recorded in
different units (sub-bulb diameter in mm, stipe and blade lengths in cm), has to look
up the documentation to know which unit each column expects. Naming the unit in the
column makes the contract visible at the point of data preparation. The package is
unreleased, and renaming now, before the density models add an area column, costs one
rebuild of the bundled fits instead of two.

## What Changes

- **BREAKING** Input columns are renamed: `diameter` to `diameter_mm`, `weight` to
  `weight_kg`, and the *Nereocystis* weight covariate `density` to `stipes_m2` (stipes
  per m²). This applies to fit data, the data checks, and `new_data`.
- **BREAKING** The `diameter` argument of `kb_predict_weight_by()` (*Nereocystis*) is
  renamed `diameter_mm`, matching the column it supplies values for.
- Prediction outputs, messages, warnings, and errors use the new column names.
- The bundled simulated datasets and pre-fits are rebuilt with the new columns.
- Columns with no unit (`fronds`, `site`, `year`) are unchanged, as are parameter
  names (`bDensity`), prior entries (`density`), and term labels.
- No deprecation path: the package is unreleased, so the old names error as missing
  columns.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: input data, the data-determined density effect, bundled objects, and
  the implausible-unit warnings name the renamed columns.
- `predictions`: the prediction verbs, density resolution, the plotting layer
  example, the out-of-range warning, and `new_data` validation name the renamed
  columns and argument.

## Non-goals

- Renaming unitless columns (`fronds`, `site`, `year`) or adding unit suffixes to
  counts.
- Renaming parameters, prior entries, or summary terms (`bDensity`, `density`).
- Accepting the old names with a deprecation warning.
- Converting units or accepting other units: units stay fixed, and the
  plausibility warnings stay.
- The density models and their `area_m2` column (the next change).

## Impact

- Data checks, `new_data` checks, `column_units`, `warn_implausible_units()`,
  `warn_outside_range()`, density resolution, fit `meta` (`response`, `predictor`),
  prediction grids, and `kb_plot_predictions()` axis defaults.
- `kb_predict_weight_by()` signature (*Nereocystis* method).
- `data-raw/` scripts, `data/` objects, and `tests/testthat/fixtures/` rebuilt
  (`scripts/build.R --fits`, MCMC).
- Snapshots (`chk`, `print`, `summary`, `kb_model_describe`, `warn_*`, plots),
  roxygen, specs, and the demo scripts. README and vignette follow in the final
  docs pass.
