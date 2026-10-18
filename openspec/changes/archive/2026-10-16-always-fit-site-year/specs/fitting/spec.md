## MODIFIED Requirements

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included for every model with a site:year effect (weight, size, and density; wet/dry and carbon have no random effects, and cover biomass has site and year effects but never a site:year effect), whatever years and sites the data cover. When no site was sampled in more than one year, which includes data from a single year, or no year had more than one site sampled, it SHALL be retained with a warning naming the main effect (site, year, or both) from which the site:year effect cannot be separated.

An omitted effect SHALL not be reported or used in prediction (see summaries and predictions).

#### Scenario: Single-year data fit site:year with a warning
- **WHEN** the data contain one year and more than one site
- **THEN** the fit has a site:year effect and a warning names the site effect

#### Scenario: One site in one year warns of both effects
- **WHEN** the data contain one site and one year
- **THEN** the fit has a site:year effect and a warning names the site and year effects

#### Scenario: Aliased design warns
- **WHEN** the data span several years but no site spans more than one
- **THEN** the site:year effect is retained and a warning names the site effect

#### Scenario: One site over several years warns
- **WHEN** the data span several years but every year has a single site
- **THEN** the site:year effect is retained and a warning names the year effect

#### Scenario: Cover biomass never fits site:year
- **WHEN** a cover biomass model is fitted to data spanning several years
- **THEN** the fit has site and year effects, no site:year effect, and no site:year message or warning
