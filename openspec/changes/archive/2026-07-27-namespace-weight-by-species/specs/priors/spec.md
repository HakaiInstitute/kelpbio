## MODIFIED Requirements

### Requirement: Default weight priors

`kb_priors_weight_nereo()` SHALL return a named list of prior objects for the full *Nereocystis luetkeana* weight model with entries `intercept`, `diameter`, `diameter2`, `sd_site`, `sd_site_diameter`, `sd_site_year`, and `sd_residual`. It takes no `species` argument.

#### Scenario: Returns the default named prior list
- **WHEN** `kb_priors_weight_nereo()` is called
- **THEN** it returns a named list with `intercept`, `diameter`, and `diameter2` as `normal` priors and `sd_site`, `sd_site_diameter`, `sd_site_year`, and `sd_residual` as `exponential` priors

#### Scenario: List is editable and round-trips into a fit
- **WHEN** a user modifies one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and passes `p` to `kb_fit_weight_nereo(priors = p)`
- **THEN** the supplied entry overrides the default and unspecified entries keep their defaults
