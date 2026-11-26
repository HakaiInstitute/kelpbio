## Context

Both biomass verbs pool with one rule: sum the row draws within each `pool_by` group (and, for in situ biomass per m², divide by the summed survey area).
That rule fits in situ surveys, which each sample part of a site, but not canopy maps, which each cover the whole site: two maps of a site-year are two measurements of one standing stock.
The predictions spec already allows several maps per site-year; the scope is one peak-season value per site-year (`decisions/prediction-engine.md`, Methods "Timing").

## Goals / Non-Goals

**Goals:**

- Pooled canopy totals count each site-year's bed once.
- The in situ rule is stated, not changed.
- Bars no longer stack rows that share an x value.

**Non-Goals:**

- A plot identifier for in situ surveys, or averaging of repeat visits to a plot.
- Dodging point ranges.

## Decisions

### Average maps within each group-by-site-year cell, then sum

Rows are grouped by the `pool_by` columns plus `site` and `year`, averaged per draw, and the cell means are summed per draw within each `pool_by` group.
This one rule covers pooling by site and year (a mean of maps), by year or region (a sum of site-year means), and by a column that separates the maps of a site-year (one row per map), with no special case.

Alternatives:

- Maximum per draw, as a "peak": biased upward by mapping and tide-correction noise.
- Error on repeated maps: moves the same averaging onto every user.
- Keep summing with the warning: the result is known to be wrong.

The mean is exact on the draws: the maps of a site-year share each draw's biomass per m² and tide slope, so the mean of their totals is that value times the mean tide-corrected canopy area.

### In situ surveys stay summed

The surveys of a site-year are separate plots or repeat visits to one plot, and the data carry no plot identifier to tell them apart.
Summed biomass over summed area is an area-weighted mean that is right in both cases; averaging all surveys of a site-year would halve the total of two separate plots with `per_area = FALSE`.
The one case the sum gets wrong, a total over a plot surveyed twice, is documented rather than detected.

### Flag partial maps by `classified_area_m2`

Averaging assumes each map covers the whole site; a site flown in parts and entered as several rows would be halved.
The largest `classified_area_m2` of a site-year above 1.5 times the smallest warns.
A map of half the site gives a ratio of 2; different imagery of the whole site rarely differs by half, as the classification covers the same water.
The check runs in `kb_check_data_survey_canopy()` and the canopy verb, pooled or not, since an unpooled partial map is also reported as a site total.

### Dodge bars only

`geom = "bar"` dodges rows that share an x value within a panel; a single row keeps full width.
Point ranges overplot rather than sum, so they do not misstate a value, and are left as they are.

## Risks / Trade-offs

- [Pooled canopy totals change for users with repeated maps] → Intended; pre-release, no deprecation.
- [The 1.5 threshold misses partial maps covering most of the site, or flags whole-site maps with very different classification extents] → It is a warning only, and the message states the whole-site assumption.
- [Dodged bars need a per-row group in the plot] → The rows of a `kb_predictions` object are unique within their grouping columns plus the input columns, so row order is a stable group.
