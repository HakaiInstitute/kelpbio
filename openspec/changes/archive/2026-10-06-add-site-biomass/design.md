## Context

The analysis project computes site-year totals in
`predict-cover-total-{nereo,macro}.R`. Because the cover relationship is linear
in cover, the biomass per m² of bed (canopy at full cover) is
`bFloor + bCanopy * exp(site + year)`, and a survey's total is that times its
tide-corrected canopy area. Site and year effects absent from the calibration are
drawn once from their fitted distributions. Dry, carbon, nitrogen, and blade
totals scale the wet total by per-draw ratios from the size integration, because
the analysis ratios vary by month. kelpbio works at site-year resolution, and its
wet/dry and carbon models are intercept-only, so the conversions here are single
per-draw factors with no integration.

## Decisions

### The floor is included, over the mapped canopy

The cover model's floor is the canopy-independent biomass of a plot. The
analysis's production total includes it and applies it over the mapped canopy,
taken as the bed extent; its "detected" total (floor at zero) is reported only as
a comparison, and the floor is about 7% of a typical *Macrocystis* total and 1%
of a *Nereocystis* one. One estimand keeps the API simple; a name-only
`floor = FALSE` can be added later without breaking code. Applying the floor over
the whole area within the site boundary was rejected: it would add floor biomass to every square
metre of open water in the site, which can be large where the site is much larger
than the bed.

### Totals reuse the cover model's mean

The bed biomass per m² is the cover model's expected biomass at a fully covered
unit plot at zero tide height (`canopy_area_m2 = plot_area_m2 = 1`,
`tide_height_m = 0`), so it comes from the existing `.linpred()` and `.epred()`
methods rather than a second statement of the model (`decisions/prediction-engine.md`).
The tide-corrected canopy area applies the same correction as the mean, on the
same `bTide` draws. The mean and the
canopy area share each draw's site and year effects and `bTide`.

### `site_area_m2` is optional and caps the canopy

Tide correction scales the mapped canopy up, so in principle the corrected canopy
could exceed the area it was mapped within. The cover calibration caps it at
`plot_area_m2`, which matters for small, densely covered dive plots. At the scale
of a site the cap does not bind in the analysis's inventory, so the area within the site
boundary is optional: supplied, it caps the corrected canopy and catches a canopy
larger than its site; absent, there is no cap. It is named `site_area_m2` rather
than reusing `plot_area_m2`, since a site (tens of thousands of m²) is a
different quantity from a calibration plot (a few hundred).

### `new_data` is required

A site total needs the canopy mapped over the site. The cover fit's own data are
calibration plots of a few hundred m², so totals at them would not be site
totals; unlike the other prediction verbs, `new_data` has no `NULL` default.

### Units: kg and kg C

Site totals span about 2 kg to 300,000 kg wet and 0.03 to 10,500 kg C in the
analysis's drone inventory; grams would give carbon totals in the millions. Plot
biomass stays in g C/m² per unit area. The response names carry the unit
(`biomass_kg`, `dry_biomass_kg`, `carbon_biomass_kg`).

### Sums on the draws

A regional or coastwide total is the sum of site totals on each draw, summarised
afterwards; summing the rows' medians or limits gives the wrong interval, and the
function returns no draws to sum later. `sum_by` names grouping columns of
`new_data` (any column, such as a user's `region`), and `character(0)` sums all
rows. Grouping columns must be character or factor with no missing values, the rule
`site` and `year` already follow: a factor orders the output (regions north to
south), a numeric key can split on floating-point differences, and a missing
value would silently form a group of its own. Rows for the same site-year in one
group would double count, since each
total covers the site's mapped canopy, so that case warns. Alternatives: return
draws (a second output shape for one verb), or a separate summing function (one
more verb for one argument's worth of behaviour).

### `"sample"` by default, effects shared by site and year

As for plot biomass, every row is a particular site-year, so an unseen site or
year needs the interval for that site or year, not the typical one. Rows naming
the same new site or year share one draw of its effect (the resolver already does
this), so a sum over a new site's surveys is consistent, as in the analysis.

### `cover_support` rather than calibration flags

The analysis records `site_calibrated` and `year_calibrated`. One column with the
vocabulary of plot biomass's `weight_support` and `size_support` (`"site, year"`,
`"site"`, `"year"`, `"none"`) reads the same across the two functions; the cover
model has no site:year effect, so `"site-year"` does not occur.

## Risks / Trade-offs

- [A site far larger than the canopy is ignored apart from the cap] →
  the mapped canopy is the bed by construction; documented in the verb's details.
- [Sums over many surveys of new sites can be dominated by the sampled effects]
  → `cover_support` shows which rows rest on pooling; `"average"` is available.
