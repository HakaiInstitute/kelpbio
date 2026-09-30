## ADDED Requirements

### Requirement: The model description shows the density term when fitted

For a *Nereocystis* weight fit with `meta$density_on` `TRUE`, `kb_model_describe()` SHALL include `bDensity * density` in the linear predictor for `log(alpha)`, define `density` as stipe density standardised by the stored mean and SD (shown as numbers), list the `bDensity` prior, and mention the density effect in the prose form. For a fit without the term none of these SHALL appear.

#### Scenario: Density fit shows the term
- **WHEN** `kb_model_describe(fit)` is called on a fit with `meta$density_on` `TRUE`
- **THEN** the notation includes `bDensity * density`, a line defining the standardisation with the fit's `density_mean` and `density_sd`, and a `bDensity` prior line

#### Scenario: Fit without density omits the term
- **WHEN** `kb_model_describe(fit)` is called on a fit with `meta$density_on` `FALSE`
- **THEN** no density term, standardisation line, or `bDensity` prior appears
