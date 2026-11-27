## Context

The analysis project's biomass integration (`functions-biomass-nereo.R`,
`functions-biomass-macro.R`) multiplies the expected density of a site-year by its
mean plant weight. Mean plant weight is computed per MCMC draw by drawing plant
sizes from the fitted size distribution with stratified inverse-CDF sampling and
averaging the expected weight at each size. kelpbio adapts it at site-year
resolution, so the analysis's month effects and month clamping do not apply.
The composition reuses each model's existing mean (`decisions/prediction-engine.md`):
nothing here re-implements a sub-model.

## Decisions

### One row per density-surveyed site-year

Density drives most of the variation in biomass, so a site-year with no density
survey would have its largest component estimated from partial pooling alone.
The analysis restricts the calibration biomass to dive-surveyed site-years for
this reason, and the verb does the same: its rows are the site-years in the
density fit's data. Weight and size are resolved per site-year by the package's
usual rules, and `weight_support` / `size_support` show which estimates rest on
pooling. A row-wise verb over arbitrary site-years is deferred.

### Expected weight, not median

A total needs the mean weight at size. Each weight model's expected response is
used: for *Nereocystis* the lognormal mean `exp(mu + sWeight^2 / 2)`, following its
form (`packard_floor` or `power`); for *Macrocystis* the Gamma mean. This is the
same quantity `posterior_epred()` returns.

### Upper bound from the size data, no lower bound

The size distributions are unbounded above, while plant size has a physiological
ceiling, so the distribution is truncated, and renormalised, at the largest size in
the size fit's data. This follows the analysis rule (`hakai-kelp-biomass-25.Rmd`,
biomass estimation: the largest value on record, 80 mm and 213 fronds) while
following the fits' data. Above the weighed range the allometry is extrapolated, as
in the analysis: *Macrocystis* plants were weighed up to 30 fronds but recorded up
to 213, and bounding at the weighed range would drop the largest plants and bias
biomass down. Alternatives: fixed analysis constants (do not follow the fits), or
the weight fit's maximum (the downward bias above).

There is no lower bound beyond each distribution's own (0 mm for the Weibull, 1
frond for the zero-truncated negative binomial). The analysis truncates
*Nereocystis* below at 3 mm, a bound introduced for its earlier quadratic
allometry, which returned implausibly large weights for sub-millimetre plants. Both
current forms are monotone at small sizes (the `packard_floor` form tends to its
floor, the `power` form to zero), and the analysis reports that plants below the
weighed range carry a negligible share of weight, so the bound changes nothing
material and is dropped.

### Stratified integration with `n_plants`

Per draw and site-year, `n_plants` sizes are taken at the midpoints of equal
probability strata of the truncated distribution (inverse CDF), as the analysis
does. The draws reproduce the distribution at every `n_plants`, so the integral is
deterministic given the draws, with about 0.6% error in mean plant weight at the
default of 100. `n_plants` is a name-only argument for users who want more.
Alternative: numerical quadrature per draw (exact but slower, and not the analysis
method).

### Density covariate from the density data

For a *Nereocystis* weight fit with the density effect, each site-year's covariate
is its observed stipe density in the density fit's data (total stipes over total
area surveyed), standardised as the weight fit was. Every row is density-surveyed,
so the value always exists. The analysis does the same. Alternatives: the weight
data's recorded `stipes_m2` (may differ from the density survey), or the density
fit's predicted density per draw (propagates uncertainty into the covariate but
departs from the analysis).

### Dry and carbon as per-draw conversions

Dry biomass is wet biomass times the expected dry:wet ratio, and carbon biomass is
dry biomass times the expected carbon fraction, as in the analysis. Both ratios are
population-level in kelpbio (pooled over months, no site or year effects), so each
is one value per draw applied to every site-year. The conversion is done on the
draws inside the verb, because a `kb_predictions` object holds only summaries and
multiplying summaries would misstate the interval. The fits are optional arguments
selected by `measure`, so the wet-only call needs only the three composition fits,
and the future site-total verb can take the same arguments. Carbon is reported in
g C/m², as in the analysis report; wet and dry in kg/m².

The pooled ratios carry the month caveat recorded in the wet/dry and carbon
changes: for example, the pooled carbon fraction is about 6% above the July
fraction, so carbon biomass for a July survey is about 6% high unless the carbon
fit is restricted to that season's samples. The roxygen states this.

Alternatives: separate verbs per measure (three verbs with the same five-fit
signature), or a follow-up change (backward compatible, but leaves the signature
unsettled while cover and the site totals build on it).

### Draws are paired one to one

The fits are independent, so draw `d` of each is combined with draw `d` of the
others, and the fits must have the same number of draws, as the analysis requires.
An unequal count errors, naming the counts. Alternative: subsample the larger fits
(valid for independent fits, but silently discards draws).

### Group resolution

`new_levels` (default `"sample"`, as the analysis) and `representative_site` work
as in the row-wise verbs. Because the rows come from the density fit rather than
from the user, `representative_site` applies to every density-surveyed site missing
from the weight or size fit, and each named site must be fitted in both.

Mean plant weight evaluates the weight model at each drawn plant, one prediction
row per plant, all naming the site-year. The package resolved a sampled new level
per row, which would give each plant of an unseen site its own site effect and
average the site uncertainty away. Sampled effects are therefore shared by every
row naming the same new level, for all verbs: a new site is one site, whichever
rows name it, as in the analysis. Each row's interval is unchanged; only the joint
distribution across rows changes. Rows whose grouping column is absent name no
level and still draw their own.

### Progress and speed

At realistic size (90 to 122 density-surveyed site-years, 4000 draws) the
composition takes about 3 s for *Nereocystis* and, before the change below, about
13 s for *Macrocystis*. The companion Shiny app runs predictions in a background
process, so the verb takes the fits' `progress_dir` and writes a record of the
site-years completed; `kb_progress()` reads it, and replaces `kb_fit_progress()`
so one reader serves fits and predictions (`kb_fit_progress()` had no users, so it
is removed rather than deprecated). `progress = "bar"` drives a console bar from
the same per-site-year steps.

Profiling showed 76% of the *Macrocystis* time in `stats::qnbinom()`, an
iterative search. Each draw's frond quantiles are instead looked up in its
cumulative distribution over 1 to the upper bound, built once: identical counts,
about 3.5 times faster. A matrix rewrite of the weight means was considered for
*Nereocystis*, whose time is mostly `posterior` rvar overhead, and rejected: it
would restate each weight model's mean outside `.linpred()`, against
`decisions/prediction-engine.md`, and reintroduce draws-by-rows broadcasting by
hand, for a saving of about 2 s on a 3 s call.

### Interval level on predictions

`kb_predictions` objects record their `conf_level`, so a biomass prediction passed
to the cover biomass fit carries the level of its limits. Moved here from the
cover biomass change, which consumes it.

## Risks

- The component fits share no parameters, so correlation between their errors is
  not represented; the analysis has the same limitation.
- Extrapolating weight above the weighed range rests on the allometry's form; for
  *Macrocystis* that range is large. Recorded, as in the analysis report.
- Sampled new-level effects make results vary between calls unless a seed is set.
