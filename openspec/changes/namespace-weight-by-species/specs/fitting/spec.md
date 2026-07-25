## MODIFIED Requirements

### Requirement: Fit the Nereocystis weight model

`kb_fit_weight_nereo(data, priors, prior_only, chains, niters, nthin, cores, quiet, ...)` SHALL fit the full *Nereocystis luetkeana* allometric weight model (quadratic log-diameter mean with site intercept, site slope, and site:year random effects) via `stanmodels$weight_nereo` and return an object of class `c("kb_fit_weight", "kb_fit")`. The species is fixed by the function (there is no `species` argument); it is recorded as `"nereocystis"` in `meta$species`. The sampler invocation, draw extraction, and diagnostics are delegated to the shared internal engine `fit_stan()`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight_nereo()` is called on valid weight data
- **THEN** it returns an object of class `c("kb_fit_weight", "kb_fit")` with `meta$species` equal to `"nereocystis"`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight_nereo()` is called with an invalid argument (e.g. bad `data`, a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling (a family mismatch reports that a family change needs a different model variant)
