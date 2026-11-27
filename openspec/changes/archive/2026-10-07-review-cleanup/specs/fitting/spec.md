## MODIFIED Requirements

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included when the data span more than one year and omitted otherwise, for every model with a site:year effect (weight, size, and density; wet/dry and carbon have no random effects, and cover biomass has site and year effects but never a site:year effect). When no site was sampled in more than one year, or no year had more than one site sampled, it SHALL be retained with a warning naming the main effect (site, year, or both) from which the site:year effect cannot be separated.

The *Nereocystis* weight model's density effect SHALL be included when at least two distinct site-year values of `stipes_m2` are recorded, with density standardised by its mean and SD over the fitted plants. A row with `NA` takes its site-year's recorded value; site-years with no recorded density take the mean.

An omitted effect SHALL not be fitted, reported, or used in prediction (see summaries and predictions). Informational messages SHALL report an omitted site:year effect, a `stipes_m2` column that yields no density effect, and the number of site-years without recorded density; none is issued when there is no `stipes_m2` column, and all are suppressed by `progress = "none"`.

#### Scenario: Single-year data omit site:year
- **WHEN** the data contain one year
- **THEN** the fit has no site:year effect and, unless `progress = "none"`, a message says so

#### Scenario: Aliased design warns
- **WHEN** the data span several years but no site spans more than one
- **THEN** the site:year effect is retained and a warning names the site effect

#### Scenario: One site over several years warns
- **WHEN** the data span several years but every year has a single site
- **THEN** the site:year effect is retained and a warning names the year effect

#### Scenario: Cover biomass never fits site:year
- **WHEN** a cover biomass model is fitted to data spanning several years
- **THEN** the fit has site and year effects, no site:year effect, and no site:year message or warning

#### Scenario: Density effect follows the recorded values
- **WHEN** *Nereocystis* weight data have no `stipes_m2` column, a column of all `NA` or a single value, or at least two distinct recorded site-year values
- **THEN** the density effect is omitted silently, omitted with a message, or included, respectively

#### Scenario: Unrecorded site-years take the mean
- **WHEN** density is recorded for some site-years and not others
- **THEN** the unrecorded site-years enter at the mean density and a message gives their number
