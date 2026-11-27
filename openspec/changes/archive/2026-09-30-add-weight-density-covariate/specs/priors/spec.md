## MODIFIED Requirements

### Requirement: Default weight priors

`kb_priors_weight_nereo()` SHALL return a named list of prior objects for the full *Nereocystis luetkeana* weight model with entries `intercept`, `power`, `floor`, `density`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`. `power` and `floor` are truncated at zero by the model. `density` is used only when the fit includes the density term.

#### Scenario: Returns the default named prior list
- **WHEN** `kb_priors_weight_nereo()` is called
- **THEN** it returns a named list with `intercept`, `power`, `floor`, and `density` as `normal` priors and `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual` as `exponential` priors

#### Scenario: Defaults match the validated analysis model
- **WHEN** `kb_priors_weight_nereo()` is called
- **THEN** the entries are `intercept = normal(0, 2)`, `power = normal(2, 1)`, `floor = normal(0, 0.5)`, `density = normal(0, 0.5)`, and `sd_site`, `sd_year`, `sd_site_year`, `sd_residual` each `exponential(1)`

#### Scenario: List is editable and round-trips into a fit
- **WHEN** a user modifies one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and passes `p` to `kb_fit_weight_nereo(priors = p)`
- **THEN** the unmodified entries keep their defaults and the modified prior is used
