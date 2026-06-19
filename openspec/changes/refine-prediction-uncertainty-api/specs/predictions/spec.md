# predictions

## MODIFIED Requirements

### Requirement: Grouping and uncertainty axes

`kb_predict_weight()` SHALL support a `by` grouping axis and a `new_levels = c("sample", "average")` axis (`"sample"` default), validated with `rlang::arg_match()`. `by` is the grid-builder control: it names the grouping factors the auto-generated grid is expanded over, and the columns present in the resulting grid are the conditioning set. `new_levels` governs the random-effect factors NOT represented as grid columns: `"sample"` draws a new random effect from `Normal(0, s)` (a new, unsampled group), and `"average"` holds them at their central (zero) value (the population-average group, the typical group on the linear-predictor scale). The weight model carries three random effects across two grouping factors: a site intercept and a site slope (both keyed on `site`) and a site:year effect (keyed on `site` and `year`). Its available `by` values are therefore `NULL`, `"site"`, and `c("site", "year")`.

#### Scenario: New group vs population-average group
- **WHEN** `new_levels = "sample"` vs `new_levels = "average"` with `by = NULL`
- **THEN** `"average"` holds all random effects at their central (zero) value (the population-average curve) and `"sample"` draws a new site intercept from `Normal(0, sSite)`, a new site slope from `Normal(0, sSiteDiameter)`, and a new site:year effect from `Normal(0, sSiteYear)`, giving an interval at least as wide as `"average"`

#### Scenario: Per-site curves
- **WHEN** `by = "site"` is supplied
- **THEN** one curve per observed site is returned, holding that site's estimated intercept and slope at their posterior values; under `new_levels = "sample"` the omitted site:year effect is drawn from `Normal(0, sSiteYear)`, and under `"average"` it is held at zero

#### Scenario: Per-site-year curves
- **WHEN** `by = c("site", "year")` is supplied
- **THEN** one curve per observed site-by-year combination is returned, holding the site intercept, site slope, and that site:year effect at their estimated posterior values; `new_levels` is immaterial because every factor is conditioned on

#### Scenario: sample requires an omitted random-effect factor
- **WHEN** `new_levels = "sample"` is requested with `by = c("site", "year")`, which conditions on every random-effect factor and leaves nothing to sample
- **THEN** it errors with an informative `cli` message directing the user to `new_levels = "average"`

#### Scenario: year alone is not a valid grouping for the weight model
- **WHEN** `by = "year"` is supplied
- **THEN** it errors with a `cli` message explaining that year enters the weight model only through the `site:year` interaction (there is no year main effect), so the available groupings are `NULL`, `"site"`, and `c("site", "year")`

#### Scenario: average value documents the central-value meaning
- **WHEN** the meaning of `new_levels = "average"` is documented
- **THEN** the documentation states that the random effects are held at their central (zero) value, yielding the typical (central) group on the linear-predictor scale, not the response-scale arithmetic mean across the group population

### Requirement: Raw prediction draws via rstantools generics

Raw posterior prediction draws SHALL be provided through the `rstantools` generics rather than a bespoke `_samples()` function. `posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-observations (`D x N`) matrix for a `kb_fit_weight`, accepting `newdata` and a `new_levels = c("sample", "average")` axis. These generics SHALL NOT take a `by` argument: conditioning is inferred from the grouping columns present in `newdata`. A grouping column present and matching a known level conditions on that factor at its estimated random effects; a random-effect factor with no corresponding column in `newdata` is handled by `new_levels` (`"sample"` draws a new effect, `"average"` holds it at zero). With `newdata = NULL` the generics SHALL use the observed data and condition on its site and year, so `posterior_epred()`, `posterior_predict()`, and `augment()` agree at the observed data. `kb_predict_weight()` SHALL be the summariser over `posterior_epred()` (one codepath); there is no `kb_predict_weight_samples()`.

#### Scenario: posterior_epred returns the prediction draws
- **WHEN** `posterior_epred(fit, newdata = grid)` is called
- **THEN** it returns a `D x N` matrix of response-scale expected weight (`exp` of the linear predictor), draws as rows and grid rows as columns

#### Scenario: Conditioning inferred from newdata columns
- **WHEN** `newdata` contains a `site` column (and optionally a `year` column) with known levels
- **THEN** the generics condition on those factors at their estimated random effects, and apply `new_levels` only to the random-effect factors with no column present

#### Scenario: newdata = NULL conditions on the observed groups
- **WHEN** any of `posterior_epred()`, `posterior_linpred()`, or `posterior_predict()` is called with `newdata = NULL`
- **THEN** it evaluates at the observed data conditioning on each row's observed site and year, so its central estimate matches `augment()`'s fitted values (`posterior_predict()` additionally adds observation noise, and with `newdata = NULL` returns the stored `yrep`)

#### Scenario: posterior_predict adds observation noise
- **WHEN** `posterior_predict(fit, newdata = grid)` is called
- **THEN** it returns a `D x N` matrix that adds Student-t observation noise (scale `sWeight`) to the expected weight; with `newdata = NULL` it returns the stored `yrep`

#### Scenario: Summary is the summariser over posterior_epred
- **WHEN** `kb_predict_weight()` is compared to `posterior_epred()`
- **THEN** the summary's `estimate`/`lower`/`upper` are the `estimate` and `conf_level` compatibility limits of the `posterior_epred()` draws on the equivalent grid, rounded to `sig_fig`
