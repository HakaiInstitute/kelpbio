# fitting

## MODIFIED Requirements

### Requirement: Fit the Nereocystis weight model

`kb_fit_weight_nereo(data, priors, prior_only, chains, niters, nthin, cores, seed, quiet, ...)` SHALL fit the *Nereocystis luetkeana* allometric weight model (quadratic log-diameter mean with site intercept, site slope, and a data-determined site:year random effect) via `stanmodels$weight_nereo` and return an object of class `c("kb_fit_weight", "kb_fit")`. The species is fixed by the function (there is no `species` argument); it is recorded as `"nereocystis"` in `meta$species`. There SHALL be no `site_year_on` argument: the site:year effect is determined from the data (see below) and the determination is recorded in `meta$site_year_on`.

The site:year effect SHALL be included when the data span more than one distinct year and omitted otherwise. When years are present but no site was sampled in more than one year (an aliased design in which the site and site:year contributions are not separately identifiable) the effect SHALL be retained and a `cli` warning issued. When the effect is omitted an informational message SHALL be issued unless `quiet = TRUE`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight_nereo()` is called on valid weight data
- **THEN** it returns an object of class `c("kb_fit_weight", "kb_fit")` with `meta$species` equal to `"nereocystis"`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight_nereo()` is called with an invalid argument (e.g. bad `data`, a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling (a family mismatch reports that a family change needs a different model variant)

#### Scenario: Site:year effect included for multi-year data
- **WHEN** the data span more than one year and at least one site is sampled in more than one year
- **THEN** the site:year effect is included (`meta$site_year_on` is `TRUE`) and no structural message is issued

#### Scenario: Site:year effect omitted for single-year data
- **WHEN** the data contain fewer than two distinct years
- **THEN** the site:year effect is omitted (`meta$site_year_on` is `FALSE`) and, unless `quiet = TRUE`, an informational message reports the omission

#### Scenario: Aliased design retains the effect with a warning
- **WHEN** the data span more than one year but no site is sampled in more than one year
- **THEN** the site:year effect is retained (`meta$site_year_on` is `TRUE`) and a `cli` warning reports that the site and site:year effects are not separately identifiable and that the estimate reflects the prior
