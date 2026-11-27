## MODIFIED Requirements

### Requirement: The weight model follows the engine conventions

The bundled `inst/stan/weight_nereo.stan` SHALL implement the full allometric weight structure -- a Packard three-parameter power mean with a common floor and year, site, site:year, and optional density effects on its scale, and a Normal likelihood on log weight -- with priors passed as data and a likelihood guard, per `decisions/engine-choice.md` and the model catalogue in `decisions/bboutools-api-review.md`. The mean (`log_eWeight`) SHALL be a local in the `model` block, computed only when the likelihood is evaluated, so rstan does not save it with the draws. There SHALL be no `generated quantities` block: the pointwise log-likelihood and the posterior-predictive replicates are computed in R from the stored draws, because storing them scales as `2 x nObs x ndraws` and dominates the fit object. The site:year contribution to the mean SHALL be gated by a `site_year_on` (0/1) value in the data block, so a single compiled model serves both the full structure and the site:year-omitted structure; that value is set by the fitting layer from the data, not by the user. The density contribution SHALL likewise be gated by a `density_on` (0/1) data value, with the standardised density passed as a data vector.

#### Scenario: The mean follows the full allometric structure

- **WHEN** the linear predictor for an observation is formed in the `model` block with `site_year_on = 1`
- **THEN** it is `log(bFloor + alpha * (diameter / diameter_ref)^bPower)` with `log(alpha) = bWeight + bDensity * density + bYear[year] + bSite[site] + bSiteYear[site, year]` (`density` standardised), where `bFloor` and `bPower` are positive so expected weight is monotone in diameter, the random effects scale only the size-dependent part and leave the floor common, and `diameter_ref` is passed as data (the geometric mean of the observed diameter, so the diameter unit is immaterial), with `bSite`, `bYear`, and `bSiteYear` non-centered (`z_* * s_*`); `log(weight)` is Normal with this mean and SD `sWeight`

#### Scenario: The site:year term is gated by a data flag

- **WHEN** the data list sets `site_year_on = 0`
- **THEN** the `bSiteYear` contribution is removed from `log_eWeight` (the `bSiteYear` / `sSiteYear` parameters are still declared and sampled from their priors, but do not enter the mean or the likelihood)

#### Scenario: The density term is gated by a data flag

- **WHEN** the data list sets `density_on = 0`
- **THEN** the `bDensity` contribution is removed from `log(alpha)` (`bDensity` is still declared and sampled from its prior, but does not enter the mean or the likelihood)

#### Scenario: Prior hyperparameters are read from the data block

- **WHEN** the data list supplies `prior_intercept_mu`/`prior_intercept_sd`, `prior_power_mu`/`prior_power_sd`, `prior_floor_mu`/`prior_floor_sd`, `prior_density_mu`/`prior_density_sd`, and the four rates `prior_sd_site_rate`, `prior_sd_year_rate`, `prior_sd_site_year_rate`, and `prior_sd_residual_rate`
- **THEN** sampling uses those values for the corresponding priors without recompilation (the prior family is fixed at compile time)

#### Scenario: Prior-only fit ignores the likelihood

- **WHEN** the data list sets `prior_only = 1`
- **THEN** the model samples the parameters from their priors and the likelihood contributes nothing

#### Scenario: Zero observations are accepted

- **WHEN** the data list sets `nObs = 0` (no observed rows, `nSite`/`nYear >= 1`)
- **THEN** the model samples without error (the likelihood loop is a no-op)
