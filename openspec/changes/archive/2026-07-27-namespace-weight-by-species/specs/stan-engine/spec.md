## MODIFIED Requirements

### Requirement: Stan models compile at install and are exposed as `stanmodels`

Stan sources in `inst/stan/` SHALL be pre-compiled at `R CMD INSTALL` and exposed as `stanmodels$<name>`, where `<name>` is the snake_case source filename. The *Nereocystis* weight model SHALL live in `inst/stan/weight_nereo.stan` and be reachable as `stanmodels$weight_nereo`.

#### Scenario: Weight model is compiled and exposed
- **WHEN** the installed package is loaded
- **THEN** `kelpbio::stanmodels$weight_nereo` exists and is a compiled Stan model object (S4 `stanmodel`)

#### Scenario: Stan source filename maps to the model name
- **WHEN** `inst/stan/weight_nereo.stan` is present at install time
- **THEN** the compiled model is reachable as `stanmodels$weight_nereo` (snake_case filename, no spaces/dashes/leading digits)

### Requirement: The weight model follows the engine conventions

The bundled `inst/stan/weight_nereo.stan` SHALL implement the full *Nereocystis* allometric weight structure -- a quadratic log-diameter mean with site intercept, site slope (on log diameter), and site:year random effects, and a Student-t(4) likelihood -- with priors passed as data, a likelihood guard, and `log_lik`/`yrep` generated quantities. The mean (`log_eWeight`) SHALL be defined once, in `transformed parameters`, and reused by both the likelihood and the generated quantities.

#### Scenario: Declared parameters are present after sampling
- **WHEN** `rstan::sampling()` is called on `stanmodels$weight_nereo` with a valid data list
- **THEN** the fit exposes `bWeight`, `bDiameter`, `bDiameter2`, the SDs, the per-site effects, and the `log_lik` / `yrep` generated quantities
