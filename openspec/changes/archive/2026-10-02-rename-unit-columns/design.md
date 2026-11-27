## Context

Input columns are plain names with fixed units, backed by median-based plausibility
warnings (`column_units`, `warn_implausible_units()`, `warn_outside_range()`). Hakai
Institute's survey files also use unitless names (`Sbulb_max`, `stipeD`, `bladeW`),
with units in a separate data dictionary, and they mix units across similar
measurements (sub-bulb diameter in mm, lengths in cm). Every kelpbio input is renamed
or derived from those files in a manipulation step, so the kelpbio name is where the
unit is fixed.

## Decisions

### Suffix the unit on measured columns only

A column measured in a unit takes a short suffix: `diameter_mm`, `weight_kg`,
`stipes_m2`, and in the density change `area_m2`. Counts (`fronds`, and the density
counts `stipes` and `plants`) and grouping columns (`site`, `year`) are unsuffixed,
since they have no unit to get wrong. Alternatives: plain names (the status quo),
rejected because the unit is invisible where data are prepared; or suffixing every
column (`fronds_n`), rejected as noise.

### `stipes_m2` for the Nereocystis density covariate

The covariate is stipe density, stipes per m². `stipes_m2` names what is counted and
pairs with the density model's `stipes` count and its per-m² predictions, which are
the values a user would supply here. Alternatives: `density_m2` (reads as a density in
m²), `density_per_m2` (unambiguous but longer).

### The predictor argument follows its column

`kb_predict_weight_by()`'s *Nereocystis* argument `diameter` becomes `diameter_mm`.
The argument supplies values for the predictor column, and the returned curve has a
column of the same name, so one name serves the input, the argument, and the output.
`.chk_wrong_predictor()` already names the correct argument from `meta$predictor`,
so it follows the rename unchanged. Alternative: keep the argument `diameter` with
the column `diameter_mm`. Rejected: two names for one quantity.

### Effect, parameter, and prior names do not change

`bDensity`, the prior entry `density`, the `density_on` flag, and the summary term
name the density effect, not the input column, and have no unit. They stay. The
weight effect names are likewise unchanged.

### No deprecation path

The package is at `0.0.0.9000` with no released users, so the old names are simply
missing columns and error as such. A lifecycle shim (accept `diameter`, warn, rename)
would be permanent code for a one-time migration.

### Warnings stay

The suffix reduces unit mistakes; it does not prevent them. The plausibility and
out-of-range warnings stay, keyed by the new names, and still name the unit in
words.

## Risks

- Every bundled fit stores its data and `meta$response` / `meta$predictor`, so the
  pre-fits and fixtures must be rebuilt (`scripts/build.R --fits`, MCMC). The
  draws are otherwise unchanged in distribution, since only names change.
- A missed reference to an old name would surface as a missing-column error or a
  silent `NULL` column read. Mitigation: grep for each old name as a quoted string,
  a `$` access, and an `aes()` mapping, and run the full test suite.
