## ADDED Requirements

### Requirement: Default Macrocystis weight priors

`kb_priors_weight_macro()` SHALL return a named list of prior objects for the
*Macrocystis pyrifera* weight model with entries `intercept`, `fronds`, `shape`,
`sd_site`, `sd_year`, and `sd_site_year`. It takes no `species` argument. The
defaults are `intercept = normal(0, 2)`, `fronds = normal(1, 0.5)` (centred on 1,
encoding near-proportionality of weight to frond count), `shape =
exponential(0.1)` (the per-frond Gamma shape `alpha`), and `sd_site`,
`sd_year`, `sd_site_year` each `exponential(1)`.

#### Scenario: Returns the default named prior list
- **WHEN** `kb_priors_weight_macro()` is called
- **THEN** it returns a named list with `intercept` and `fronds` as `normal`
  priors and `shape`, `sd_site`, `sd_year`, and `sd_site_year` as `exponential`
  priors

#### Scenario: List is editable and round-trips into a fit
- **WHEN** a user modifies one entry (e.g. `p$sd_site <-
  kb_prior_exponential(2)`) and passes `p` to `kb_fit_weight_macro(priors = p)`
- **THEN** the supplied entry overrides the default and unspecified entries keep
  their defaults
