## MODIFIED Requirements

### Requirement: Parameter summaries

`tidy()` and `coef()` SHALL return a tibble with columns `term`, `estimate`, `lower`, and `upper`, one row per population-level term and standard deviation of the fitted model, with `conf_level` (default 0.95) compatibility limits, `estimate` (default `median`), and `sig_fig` (default 3). `include_random_effects = TRUE` (default `FALSE`) SHALL add the per-level group effects, each term naming its level, as in `site_effect[<site>]`, `year_effect[<year>]`, and `site_year_effect[<site>,<year>]`. `coef()` SHALL return what `tidy()` returns.

#### Scenario: Default rows
- **WHEN** `tidy(fit)` is called
- **THEN** it returns the population-level terms and SDs, without per-level group effects

#### Scenario: Summary options are honoured
- **WHEN** `tidy(fit, conf_level = 0.9, estimate = mean, sig_fig = 4)` is called
- **THEN** it returns posterior means with 90% compatibility limits to 4 significant figures

#### Scenario: Group effects are named by level
- **WHEN** `tidy(fit, include_random_effects = TRUE)` is called on a fit with site effects
- **THEN** each site effect's term is `site_effect[` followed by its site name and `]`, one per fitted site
