# predictions

## ADDED Requirements

### Requirement: Predictions respect the fitted site:year structure

Predictions SHALL reflect whether the fit retained the site:year effect. When the fit omitted the effect (`meta$site_year_on` is `FALSE`), the prediction engine `.weight_nereo_linpred()` and all verbs and generics built on it SHALL add no site:year contribution or variation, for any `new_levels` value; the prior-only `bSiteYear` / `sSiteYear` draws SHALL NOT be reintroduced.

#### Scenario: Omitted site:year adds no variation
- **WHEN** predictions are formed from a fit whose `meta$site_year_on` is `FALSE`
- **THEN** the site:year term contributes nothing to the linear predictor, and `new_levels = "sample"` adds no site:year between-year variation (only the site intercept and site-slope effects vary)

#### Scenario: Retained site:year behaves as specified
- **WHEN** predictions are formed from a fit whose `meta$site_year_on` is `TRUE`
- **THEN** the site:year term is resolved per row and per `new_levels` as specified by the other prediction requirements
