## ADDED Requirements

### Requirement: Density is resolved per prediction row

For a *Nereocystis* weight fit with the density term (`meta$density_on` is `TRUE`), every prediction path (`kb_predict_weight()`, `kb_predict_weight_by()`, `predict()`, `augment()`, `fitted()`, `residuals()`, `log_lik()`, and the `posterior_*()` generics) SHALL resolve each row's density in this order: a non-missing `density` value in the row; otherwise the recorded density of the row's site-year, when that site-year was in the fitted data with a recorded value; otherwise the fitted mean density. The resolved density SHALL be standardised with the stored `meta$density_mean` and `meta$density_sd`. `new_data` MAY carry a `density` column (numeric, non-negative, `NA` allowed); it SHALL be validated when present and ignored for a fit without the density term.

#### Scenario: Supplied density is used
- **WHEN** `kb_predict_weight(fit, new_data)` is called with a `density` value in a row
- **THEN** that row's prediction uses the supplied density

#### Scenario: A fitted site-year uses its recorded density
- **WHEN** a row has no `density` value and its `site` and `year` are a fitted site-year with recorded density
- **THEN** the row uses that recorded density, so predictions at the observed data match the fit

#### Scenario: Otherwise the fitted mean is used
- **WHEN** a row has no `density` value and its site-year has no recorded density (a new site-year, an absent `site` or `year` column, or a fitted site-year recorded as `NA`)
- **THEN** the row uses the fitted mean density (standardised density `0`)

#### Scenario: Curves follow the same rule
- **WHEN** `kb_predict_weight_by(fit, by = c("site", "year"))` is called
- **THEN** each site-year curve uses that site-year's recorded density, and curves for `by = NULL`, `"site"`, or `"year"` use the fitted mean density

#### Scenario: Density is ignored for a fit without the term
- **WHEN** `new_data` carries `density` and the fit's `meta$density_on` is `FALSE`
- **THEN** predictions are unaffected by the column
