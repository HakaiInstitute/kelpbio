## Context

The cover biomass models are the analysis project's `stan/nereo/cover/cover-offset.stan`
and `stan/macro/cover/cover-offset.stan`, identical except for the floor and tide
priors. The route to the production form (floor, linear cover, normal residuals,
effects on the canopy term only) is recorded in the analysis project's
`decisions/cover-biomass-model.md`. Unlike the other sub-models, the response is
itself an estimate with uncertainty: the in situ wet biomass of each surveyed plot,
from the size, weight, and density models.

## Decisions

### The response is a separate biomass argument

The in situ biomass is a separate data frame, `biomass`, taken second, rather than
response columns appended to the survey data. Its columns are `site`, `year`,
`estimate`, `lower`, and `upper`, those of a `kb_predictions` object, so the output
of the planned `kb_predict_biomass()` passes in unchanged and users do no joining.
A plain data frame with those columns serves users with their own estimates, so one
argument covers both routes; response columns in `data` are an error rather than a
second route, since two input contracts would add no capability.

The fit pairs surveys with biomass by `site` and `year`, the package's resolution,
and requires one biomass row per site-year. Surveys with no biomass are dropped
with a message naming their site-years, as the analysis fits only surveys with a
paired estimate; an error would force users to filter first. `biomass` precedes
`priors`, an exception to the rule that `priors` is second in every fit function,
because it is required input data rather than a modelling choice.

`kb_predictions` objects now record their `conf_level`, so the fit reads the level
of a biomass prediction's limits from it; a plain data frame takes the name-only
`conf_level`, else 0.95, the prediction verbs' default, and a `conf_level` that
contradicts the recorded level errors. The log-scale SD is
`(log(upper) - log(lower)) / (2 * qnorm(1 - (1 - conf_level) / 2))`, as the
analysis computes at 95%.

The fit stores the paired surveys as its data, so `augment()` shows the in situ
biomass beside the fitted values. Predicting at the observed data replaces
`estimate`, `lower`, and `upper` with the prediction, as every verb does.

### Parameters and priors

`bCanopy` (wet kg per m² of tide-corrected canopy at a typical site and year),
`bFloor` (wet kg/m² at zero cover, common to all sites and years), `bTide`
(fractional increase in canopy area per metre of tide), `bScaling`, `sSite`, and
`sYear`. The analysis's `sScaling` is renamed `bScaling`: it multiplies the
supplied SDs and is not itself an SD, so the package rule gives it the `b` prefix.

The priors match the analysis. `bCanopy` is LogNormal(2, 1), passed as the
`canopy` entry, a `kb_prior_normal()` on the log scale, since the package has no
lognormal prior constructor and the log scale is where its hyperparameters are
read. `bFloor`, `bTide`, and `bScaling` are Normal truncated at zero: floor
Normal(0, 0.1) for *Nereocystis* and Normal(0.4, 0.3) for *Macrocystis* (no
*Macrocystis* survey has zero canopy, so the floor is an extrapolated intercept and
needs an informative prior); tide Normal(0.276, 0.04) and Normal(0.227, 0.03), from
surface-canopy tide observations; scaling Normal(1, 0.5). The calibration data
carry no information on `bTide`, which reproduces its prior, so the roxygen states
that the tide correction is set by the prior.

### Site and year effects only

The analysis tested a site:year effect and found it small, not supported by LOO,
and not convergent under the normal likelihood; the calibration data also hold one
survey per site-year in both species, so a site:year effect would be confounded
with the residual. The cover biomass models therefore carry site and year effects only and
never a site:year effect, whatever the data span. The effects scale the canopy term
and leave the floor common, as in production.

### One Stan file; the zero-canopy branch dropped

Both species use `inst/stan/cover_biomass.stan`; the priors come in as data. The analysis
branches on `canopy_area_m2 > 0` to evaluate `log(bFloor)` exactly at zero canopy; the
general expression gives the same value there, so the branch is dropped.

### Expected value and predictive draws

The residual SD is the in situ estimation error, not process variation, so the
expected biomass of a plot is the calibration mean `mu`, the inverse of the log
link, with no lognormal retransformation. `posterior_predict()` draws replicate in
situ estimates, which need each row's precision: at the observed data it comes from
the data, and `new_data` must supply `lower` and `upper`. The internal noise generic
therefore receives the prediction rows; every other model ignores them.

### Curves over tide-corrected cover

`kb_predict_cover_biomass_by()` predicts over tide-corrected cover directly (default 0 to 1),
not over canopy area and tide, since a curve needs one predictor and cover is the
quantity the calibration is linear in.

## Risks

- Two-stage inference: the in situ estimates enter as independent, though they
  share site effects and the coastwide allometry in their own models, so the
  calibration intervals are too narrow by an unquantified amount. Recorded as the
  analysis's largest outstanding shortcut; not addressed here.
- The tide correction rests on its prior; a user changing the `tide` prior changes
  every prediction proportionally to tide height.
