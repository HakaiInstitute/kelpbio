## Why

With `new_levels = "sample"`, a row of `new_data` with no `site` or `year` column draws its own new site, year, and site:year effect, independent of every other row.
Each row's interval is right, but a quantity combined across rows from the draws is not: a curve's effect varies along its length, and a sum or difference across rows has an interval that is too narrow (0.48 times the width for the sum of 30 rows of one site's weight curve).
The same rows with one named new year share one draw, so an absent column and a named new level disagree.
Raised in Joe Thorley's review of HakaiInstitute/kelpbio#73 (item J1).

## What Changes

- **BREAKING** An absent `site` or `year` column SHALL be one new level shared by every row, as if every row named the same new level.
  Under `new_levels = "sample"` the rows share one sampled effect; under `"average"` nothing changes.
- Each row's own distribution is unchanged, so prediction tables and plots summarising each row are unchanged up to Monte Carlo noise.
- Rows that should be independent new sites or years are requested by naming them separately.
- A missing value in a `site` or `year` column still errors; its hint suggests a name such as `"new"`.
- The `new_levels` documentation states that rows without a `site` or `year` column share one new site or year.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: the `Groups are resolved per row` requirement.

## Non-goals

- No change to how fitted levels, named new levels, or `representative_site` are resolved.
- No change to `kb_new_data()` output: grouping factors not in `by` stay absent.
- Missing values in `site` or `year` are not accepted as new levels.
- No model or fit changes, so no refits.

## Impact

- Group resolution for predictions (the grid indices and the random-effect resolvers).
- `kb_predict_mean_weight()` on a grid without a `year` column (for example `kb_new_data(size, by = "site")`), whose default is `"sample"`: its sites now share one new year.
- `new_levels` roxygen in `R/params.R`, the missing-value error hint, and the predictions tests; snapshots made under `"sample"` with an absent column may shift within Monte Carlo noise.
