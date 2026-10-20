## Context

The fits work at site-year resolution, so a `date` on the weight, size, survey, and plant tables is reduced to its year at entry (`with_year()`, `date_year()`); its only other use is the survey key `site` + `plot_id` + `date`, which also joins counted plants to their survey. Field programmes record surveys in two ways, and the analysis project's data show both:

- *Nereocystis*: plants are tallied per survey and a sample is measured, mostly not linked to a count. Of 2654 size records, 15% have no transect and only 54% match a count survey by site, date, and transect; 30% are revisits of tagged plants. Of 416 count surveys, 119 have any measured plant, and the median share of a survey's plants measured is 0.
- *Macrocystis*: every plant on a transect side is measured (`macro_density.csv`, one row per plant with its fronds at 1 m; `c_p_t == "P"` marks a plant on the transect edge, the source of `partial`).

## Goals / Non-Goals

**Goals:**
- One time column, `year`, in every input table, as in every output and `new_data`.
- A survey key that does not depend on how plots are named and allows repeat surveys.
- Table names that say what each size table is for.

**Non-Goals:** see the proposal.

## Decisions

### `year` replaces `date`

`date` carries no information the fits use beyond the year. Taking `year` directly removes the `Date` class requirement, the "a date given as text" error, and the date/year agreement check, and matches the columns of canopy `new_data` and of `kb_predict_biomass_survey()` output, which the cover calibration already takes. A `date` column left on a table is ignored like any other extra column.

Field data usually hold years as whole numbers, so `year` is also accepted as numeric, wherever it is read (input tables and `new_data`, including canopy rows), and converted to character on entry. Inside the package the year stays a character level, as it is today, so fitted levels, `pool_by`, and outputs need no second type; character and factor years pass through unchanged, keeping a factor's level order for `pool_by`. A non-whole number errors rather than being truncated, since it is more likely a misplaced column than a year. Alternative: require character or factor, as for `site`; rejected as friction for nearly every user, who would convert a column whose meaning is unambiguous.

### `survey_id` keys surveys

A required `survey_id`, unique per survey row, replaces `site` + `plot_id` + `date`. Within a year the old key needed a distinct date for each survey of a plot, so two dives on one plot on one day could not be entered; a plot identifier was also required even where a programme surveys a site rather than named plots. `survey_id` is the only join between a survey and its census rows, so census rows need no `site` or `year` and cannot disagree with their survey. `plot_id` is dropped from the contract and the docs; a user's plot or transect column passes through as an extra column and can still be named in `pool_by`. `region` stays the documented example of such a column. `survey_id` may be character, factor, or numeric (programmes often number surveys) and is converted to character on entry, so the join and the outputs see one type.

### Two size tables, named by role (option A)

`size_sample` is a sample of plants measured to fit the size model (`site`, `year`, `diameter_mm`), not linked to any survey; `size_census` is every plant a survey counted (`survey_id`, size, optional `partial`). The mode of `kb_predict_biomass_survey()` stays set by what `size` is: a size fit (tallied surveys, `plants` per survey) or a `size_census` table.

Alternatives:
- (B) One `size` table, its role set by whether it is fitted or passed to `kb_predict_biomass_survey()`. Census rows would then need `survey_id` plus `site` and `year`, and a check that the two agree; the same name for two different sampling designs hides which one a table follows.
- (C) A datasheet-shaped `kb_predict_biomass_survey(weight, survey, plants, size = NULL)`: one plant table keyed by `survey_id`, and an optional per-survey count; a count makes the measured plants a sample (needs a size fit), no count makes them a census. It mixes protocols in one call and cannot undercount, but needs every measured plant linked to a survey. The *Nereocystis* data above fail that: most size records are not linked to a count. Requiring counts on every survey, the variant that avoids the per-row switch, was rejected since users would have to total them and the package to check the totals.
- A bare `census` name: rejected, as it overlaps "survey" in meaning.

`kb_fit_size_nereo()` and `fit_size_sim_nereo` keep their names: the fit is a size model whichever table it came from, and its `data` argument is the `size_sample` table.

### `kb_check_data_survey(data, size_census = NULL)`

The second argument is renamed from `plants` to the table it checks, which also frees `plants` to mean only the survey's count column.

### Rebuilds

Fits store their input data, so the weight, size, and cover calibration pre-fits and fixtures (whose data are survey biomass output carrying the survey columns) are rebuilt; wet/dry and carbon have no date or site and are unchanged. No Stan source changes, so the draws change only through the rebuilt simulated data; refits are acceptable under the project's practice of sequencing them last.

## Risks / Trade-offs

- [Every existing script and kelpbioshiny sheet breaks] → nothing is released; the app follow-up is filed separately, and the errors name the missing `year` or `survey_id` column.
- [A numeric `year` comes back as character in outputs] → stated in the docs; it is the type the fits already use for levels.
- [Repeat surveys of one plot are no longer recognisable as such] → they were only distinguished by date before, and the fits never used plot identity; a plot column passes through for `pool_by`.
- [A `survey_id` reused across years or sites by a programme that numbers surveys per site] → uniqueness is checked across the whole table, and the error lists the repeated identifiers.
