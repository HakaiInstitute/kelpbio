## ADDED Requirements

### Requirement: Prior constructors are self-validating prior objects

`kb_prior_normal(mean, sd)` and `kb_prior_exponential(rate)` SHALL each return a family-tagged prior object, validating hyperparameters at construction via `chk`.

#### Scenario: Valid construction
- **WHEN** `kb_prior_normal(mean = 0, sd = 2)` is called
- **THEN** it returns a prior object whose family is `normal` and whose hyperparameters are `mean = 0`, `sd = 2`

#### Scenario: Invalid hyperparameter errors
- **WHEN** `kb_prior_normal(0, sd = -1)` or `kb_prior_exponential(rate = 0)` is called
- **THEN** it errors via `chk`/`cli` (`sd > 0`, `rate > 0`)

#### Scenario: Prior object prints its family and hyperparameters
- **WHEN** a prior object is printed
- **THEN** the output shows the family and named hyperparameters (e.g. `normal(mean = 0, sd = 2)`)

### Requirement: Default weight priors

`kb_priors_weight(species)` SHALL return a named list of prior objects for the weight model with entries `intercept`, `diameter`, `sd_site`, and `sd_residual`.

#### Scenario: Returns the default named prior list
- **WHEN** `kb_priors_weight()` is called
- **THEN** it returns a named list with `intercept` and `diameter` as `normal` priors and `sd_site` and `sd_residual` as `exponential` priors

#### Scenario: List is editable and round-trips into a fit
- **WHEN** a user modifies one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and passes `p` to `kb_fit_weight(priors = p)`
- **THEN** the unmodified entries keep their defaults and the modified prior is used
