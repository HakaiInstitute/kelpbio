## MODIFIED Requirements

### Requirement: Priors

`kb_priors_weight_nereo()`, `kb_priors_weight_macro()`, `kb_priors_size_nereo()`, `kb_priors_size_macro()`, `kb_priors_density_nereo()`, `kb_priors_density_macro()`, `kb_priors_wetdry_nereo()`, `kb_priors_wetdry_macro()`, `kb_priors_carbon_nereo()`, `kb_priors_carbon_macro()`, `kb_priors_cover_biomass_nereo()`, and `kb_priors_cover_biomass_macro()` SHALL return a named list of prior objects, the defaults pinned by `tests/testthat/test-kb_priors_*.R`. The weight, size, wet/dry, carbon, and cover defaults match the analysis-project models; the density defaults are weakly informative round values. Each entry SHALL be named after the parameter it sets, the same name that parameter has in `tidy()`, `coef()`, `summary()`, and `kb_model_describe()`. The entries are:

- *Nereocystis* weight: `intercept`, `diameter_power`, `weight_floor`, `density_slope`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`.
- *Macrocystis* weight: `intercept`, `fronds_slope`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* size: `intercept`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Macrocystis* size: `intercept`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* density: `intercept`, `logit_zero_inflation`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Macrocystis* density: `intercept`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- Wet/dry and carbon, both species: `intercept` and `precision`.
- Cover biomass, both species: `cover_slope` (lognormal), `biomass_floor`, `tide_height_slope`, `error_scaling`, `sd_site`, and `sd_year`.

A list passed to `priors` SHALL override only the entries it contains. `kb_prior_normal()`, `kb_prior_exponential()`, and `kb_prior_lognormal()` SHALL validate their hyperparameters and print as the family with its hyperparameters.

#### Scenario: A partial prior list keeps the other defaults
- **WHEN** a user changes one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and fits with `priors = p`
- **THEN** that entry is used and the others keep their defaults

#### Scenario: A summary term names its prior entry
- **WHEN** `tidy(fit)` reports a parameter
- **THEN** its `term` is the name of the entry in the model's `kb_priors_*()` list that sets its prior

#### Scenario: Invalid hyperparameters error
- **WHEN** `kb_prior_normal(0, sd = -1)`, `kb_prior_exponential(rate = 0)`, or `kb_prior_lognormal(0, sdlog = 0)` is called
- **THEN** it errors

### Requirement: The fit object

A fit SHALL store posterior draws, sampler diagnostics, the input data, and the fit's settings, and SHALL NOT keep the `stanfit` or any per-observation quantity, so its size depends on the number of draws, not observations. Every summary, diagnostic, and prediction SHALL work from a stored fit. A fit with `prior_only = TRUE` SHALL sample from the priors alone and accept zero-row data. A diagnostic rate with no draws behind it SHALL be `NA`, not zero.

The draws SHALL be a `posterior` `draws_rvars` object that works with `posterior` and the tools built on it as soon as kelpbio is attached, including for a bundled pre-fit or a fit read back in a new session. Per-level group effects SHALL be labelled by their levels: site effects by site, year effects by year, and site:year effects by site and year, so they can be indexed by name as well as by position.

#### Scenario: A stored fit is self-contained
- **WHEN** a fit is saved, reloaded in a new session, and summarised or predicted from
- **THEN** every method works without refitting

#### Scenario: Prior-only fits ignore the data
- **WHEN** `prior_only = TRUE`, including with zero-row data
- **THEN** the draws reflect the priors only

#### Scenario: Draws work on load
- **WHEN** kelpbio is attached in a new session and a bundled pre-fit's draws are printed before any other kelpbio function is called
- **THEN** each parameter prints its draws summary, and has the length of its number of levels

#### Scenario: Group effects are labelled by level
- **WHEN** the site effects of a fit are indexed by a site name, or its draws are converted with `posterior::as_draws_df()`
- **THEN** the effect for that site is returned, and the variables are named `site_effect[<site>]` and `site_year_effect[<site>,<year>]`

### Requirement: Ambiguous group names are flagged

The data checks, and so the fit functions, SHALL warn when a `site` or `year` value contains `,`, `[`, or `]`, since flattened parameter names such as `site_year_effect[<site>,<year>]` then cannot be parsed back into their levels. The warning SHALL name the column and the offending values, and SHALL NOT stop the check or the fit.

#### Scenario: A site name with a comma warns
- **WHEN** data have a site named `"North Reef, inner"`
- **THEN** a warning names `site` and that value, and the data still pass

#### Scenario: Plain names raise no warning
- **WHEN** the site and year values contain none of `,`, `[`, or `]`, including names with spaces
- **THEN** no group-name warning is issued
