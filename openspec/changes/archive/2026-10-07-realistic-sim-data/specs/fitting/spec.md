## MODIFIED Requirements

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
- **THEN** the effect for that site is returned, and the variables are named `bSite[<site>]` and `bSiteYear[<site>,<year>]`

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo`, `data_weight_sim_macro`, `data_size_sim_nereo`, `data_size_sim_macro`, `data_density_sim_nereo`, `data_density_sim_macro`, `data_wetdry_sim_nereo`, `data_wetdry_sim_macro`, `data_carbon_sim_nereo`, `data_carbon_sim_macro`, `data_cover_biomass_sim_nereo`, `data_cover_biomass_sim_macro`, `data_plot_biomass_sim_nereo`, and `data_plot_biomass_sim_macro`, and small pre-fits `fit_weight_sim_nereo`, `fit_weight_sim_macro`, `fit_size_sim_nereo`, `fit_size_sim_macro`, `fit_density_sim_nereo`, `fit_density_sim_macro`, `fit_wetdry_sim_nereo`, `fit_wetdry_sim_macro`, `fit_carbon_sim_nereo`, `fit_carbon_sim_macro`, `fit_cover_biomass_sim_nereo`, and `fit_cover_biomass_sim_macro`, for examples and tests, not inference. The bundled datasets and the data stored in the pre-fits SHALL use the input column names above. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

For each species, the weight, size, density, cover survey, and in situ plot biomass datasets SHALL be simulated from one set of true site-year values, with parameter values near those estimated from the Hakai Institute surveys, so that plot biomass composed from the bundled weight, size, and density fits is of realistic magnitude and agrees with the bundled in situ plot biomass at the same site-years. The in situ plot biomass SHALL be the true plot biomass with estimation error. The sites SHALL have invented names that match no real survey site. The data sources SHALL cover different site-years, as in field programmes: density at most site-years, size at most of those, weight at a subset that includes sites never harvested, and drone surveys at a subset, each paired with in situ plot biomass. Every harvested *Nereocystis* site-year SHALL be density-surveyed, and its weight data SHALL carry that site-year's `stipes_m2`.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method

#### Scenario: Composed and in situ plot biomass agree
- **WHEN** `kb_predict_plot_biomass()` is called with a species' bundled weight, size, and density fits
- **THEN** at the site-years in that species' bundled in situ plot biomass, the median ratio of its estimates to the in situ estimates lies between 0.5 and 2

#### Scenario: Data sources have gaps
- **WHEN** the site-years of a species' bundled weight, size, density, and cover survey datasets are compared
- **THEN** weight covers fewer site-years than density, at least one density-surveyed site has no weight data, size misses at least one density-surveyed site-year, and every cover survey site-year has an in situ plot biomass

## ADDED Requirements

### Requirement: Ambiguous group names are flagged

The data checks, and so the fit functions, SHALL warn when a `site` or `year` value contains `,`, `[`, or `]`, since flattened parameter names such as `bSiteYear[<site>,<year>]` then cannot be parsed back into their levels. The warning SHALL name the column and the offending values, and SHALL NOT stop the check or the fit.

#### Scenario: A site name with a comma warns
- **WHEN** data have a site named `"North Reef, inner"`
- **THEN** a warning names `site` and that value, and the data still pass

#### Scenario: Plain names raise no warning
- **WHEN** the site and year values contain none of `,`, `[`, or `]`, including names with spaces
- **THEN** no group-name warning is issued
