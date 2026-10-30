## Why

The analysis project replaced the cover calibration's censored Normal with a Gamma likelihood and added a presence hurdle for surveys with no plants counted.
A censored Normal implies negative biomass and is hard to explain; a Gamma is never negative and its residuals are standard deviance residuals.
kelpbio follows the analysis project's model code, so its cover calibration changes to match.

## What Changes

- The cover calibration's likelihood, both species, becomes a Gamma with mean `mu` (unchanged: `biomass_floor + cover_slope * exp(site_effect + year_effect) * cover`) and a coefficient of variation `sqrt(cv_residual^2 + weight_cv^2)`, where `weight_cv` is the survey's CV of biomass from plant weight (the SD of its biomass draws over their mean).
  The constant residual SD `sd_residual` and its prior entry are removed, and `cv_residual` takes an Exponential(1) prior, the family of the other spread terms, in place of the analysis project's half-Normal(0, 1).
- When the data hold a survey with no plants counted, for either species, the fit adds a presence part: the probability that a survey holds plants is logit-linear in percent tide-corrected cover, `presence_intercept + presence_cover_slope * 100 * cover`, and biomass is Gamma only where plants are present.
  Without such a survey the presence part is omitted and absent from every summary.
- The fit warns when every empty survey has a percent cover at or below every occupied survey's, since the presence slope is then set by its prior.
- New prior entries `presence_intercept` (Normal(0, 2)) and `presence_cover_slope` (Normal(0, 20)), for both species.
  The *Nereocystis* `biomass_floor` prior widens from Normal(0, 0.1) to Normal(0, 0.2).
- Where the presence part is fitted, the expected biomass of a plot (`kb_predict_cover_calibration()`, `posterior_epred()`, `fitted()`) is the presence probability times `mu`.
  Canopy totals (`kb_predict_biomass_canopy()`) are unchanged: they apply `mu` at full cover, without the presence probability.
- `log_lik()`, `residuals()`, `posterior_predict()`, and `pp_check()` use the Gamma, or the presence part and the Gamma.

## Non-goals

- No intercept-only presence part: a constant probability below 1 at full cover would lower the totals.
- No mixed-canopy term (added to and removed from the analysis project in October 2026).
- No change to the mean function, tide correction, group effects, or canopy totals.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the likelihood, the presence part and when it is fitted, the separation warning, and the prior entries.
- `predictions`: the expected biomass, replicates, and log-likelihood of a cover calibration fit.
- `summaries`: `pp_check()` replicates of a cover calibration fit.

## Impact

- `inst/stan/cover_calibration.stan` (refit of `fit_cover_calibration_sim_*` and the cover fixtures with `--fits=cover_calibration`).
- The observation family for the cover calibration (`R/obs_family.R`, `R/distributions.R`), expected values, data assembly, priors, docs, and tests.
- kelpbiodata's cover reference fits need rebuilding; kelpbioshiny's prior inputs gain the presence entries and lose `sd_residual`.
- Closes HakaiInstitute/kelpbio#66.
