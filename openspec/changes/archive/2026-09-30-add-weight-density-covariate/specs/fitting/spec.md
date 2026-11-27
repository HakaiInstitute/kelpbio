## MODIFIED Requirements

### Requirement: Fit the Nereocystis weight model

`kb_fit_weight_nereo(data, priors, ..., prior_only, chains, niters, nthin, cores, seed, progress, progress_dir)` SHALL fit the *Nereocystis luetkeana* allometric weight model (Packard three-parameter power mean with year, site, and a data-determined site:year random effect on its scale, and an optional stipe density covariate) via `stanmodels$weight_nereo` and return an object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`. The species is fixed by the function (there is no `species` argument); it is recorded as `"nereocystis"` in `meta$species`. There SHALL be no `site_year_on` argument: the site:year effect is determined from the data (see below) and the determination is recorded in `meta$site_year_on`.

The site:year effect SHALL be included when the data span more than one distinct year and omitted otherwise. When years are present but no site was sampled in more than one year (an aliased design in which the site and site:year contributions are not separately identifiable) the effect SHALL be retained and a `cli` warning issued; predictions conditioned on the observed site-years are unaffected, but the individual site and site:year terms and their standard deviations (`sSite`, `sSiteYear`) are prior-driven and SHALL NOT be interpreted separately. When the effect is omitted an informational message SHALL be issued unless `progress = "none"`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight_nereo()` is called on valid weight data
- **THEN** it returns an object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")` with `meta$species` equal to `"nereocystis"`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight_nereo()` is called with an invalid argument (e.g. bad `data`, a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling (a family mismatch reports that a family change needs a different model variant)

#### Scenario: Site:year effect included for multi-year data
- **WHEN** the data span more than one year and at least one site is sampled in more than one year
- **THEN** the site:year effect is included (`meta$site_year_on` is `TRUE`) and no structural message is issued

#### Scenario: Site:year effect omitted for single-year data
- **WHEN** the data contain fewer than two distinct years
- **THEN** the site:year effect is omitted (`meta$site_year_on` is `FALSE`) and, unless `progress = "none"`, an informational message reports the omission

#### Scenario: Aliased design retains the effect with a warning
- **WHEN** the data span more than one year but no site is sampled in more than one year
- **THEN** the site:year effect is retained (`meta$site_year_on` is `TRUE`) and a `cli` warning reports that the site and site:year effects are not separately identifiable and that the estimate reflects the prior

## ADDED Requirements

### Requirement: Optional density covariate in the Nereocystis weight fit

`data` for `kb_fit_weight_nereo()` MAY contain a `density` column: the stipe density (stipes per m²) of the plant's site-year. Density is a site-year value; a row with `NA` takes the value recorded for its site-year in another row, if any. The density term SHALL be included when at least two distinct site-year densities are recorded, and omitted otherwise (no `density` column, all values `NA`, or a single distinct value). The determination SHALL be recorded in `meta$density_on`. When the term is omitted and `data` has a `density` column, an informational message SHALL be issued unless `progress = "none"`.

When the term is included, density SHALL enter the model standardised by the mean and SD of density over the fitted rows whose site-year has a recorded value; both are recorded in `meta` (`density_mean`, `density_sd`), along with the recorded density of each fitted site-year. Rows whose site-year has no recorded density SHALL take standardised density `0` (the mean), and an informational message SHALL report how many site-years were affected, unless `progress = "none"`.

A fit made before this requirement, with no `meta$density_on`, SHALL be treated as having the term omitted.

#### Scenario: No density column omits the term silently
- **WHEN** `kb_fit_weight_nereo()` is called on data without a `density` column
- **THEN** `meta$density_on` is `FALSE`, `bDensity` is not a fitted term, and no density message is issued

#### Scenario: All-NA density omits the term with a message
- **WHEN** the data have a `density` column whose values are all `NA`
- **THEN** `meta$density_on` is `FALSE` and, unless `progress = "none"`, an informational message reports that the density effect is omitted

#### Scenario: Recorded density includes the term
- **WHEN** at least two site-years have distinct recorded densities
- **THEN** `meta$density_on` is `TRUE`, `meta$density_mean` and `meta$density_sd` hold the mean and SD of density over the rows with a recorded site-year value, and `bDensity` is a fitted term

#### Scenario: Unrecorded site-years take the mean
- **WHEN** density is recorded for some site-years and `NA` for all rows of others
- **THEN** the rows of the unrecorded site-years enter with standardised density `0`, and, unless `progress = "none"`, a message reports the number of site-years without recorded density
