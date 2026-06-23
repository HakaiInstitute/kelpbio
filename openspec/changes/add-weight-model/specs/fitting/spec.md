## ADDED Requirements

### Requirement: Fit the weight model

`kb_fit_weight(data, species, priors, prior_only, chains, iter, nthin, cores, quiet, ...)` SHALL fit the site-intercept-only weight model via `stanmodels$weight` and return an object of class `c("kb_fit_weight", "kb_fit")`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight()` is called on valid weight data
- **THEN** it returns an object of class `c("kb_fit_weight", "kb_fit")`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight()` is called with an invalid argument (e.g. bad `data`, unknown `species`, a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling (family mismatch reports that a family change needs a different model variant)

### Requirement: Fit object stores draws, not the stanfit

The returned `kb_fit` SHALL store extracted posterior draws (a `posterior` draws object) plus sampler diagnostics, the input data, and resolved metadata — and SHALL NOT retain the live `stanfit`.

#### Scenario: Draws and diagnostics are retained, stanfit discarded
- **WHEN** the fit object is inspected
- **THEN** it exposes posterior draws (including `bWeight30`, `bDiameter`, `sSite`, `sWeight`, and per-site `bSite`) and diagnostics, and contains no live `stanfit`

### Requirement: Prior-only and zero-observation fits

`kb_fit_weight()` SHALL support fitting from the priors alone.

#### Scenario: prior_only ignores the data
- **WHEN** `kb_fit_weight(data, prior_only = TRUE)` is called
- **THEN** the resulting draws reflect the priors only (a fit on permuted responses yields the same prior-only distribution)

#### Scenario: Empty data is accepted under prior_only
- **WHEN** `kb_fit_weight()` is given a zero-row data frame with `prior_only = TRUE`
- **THEN** it returns a valid `kb_fit_weight` object sampled from the priors

### Requirement: Sampler control

`kb_fit_weight()` SHALL expose `chains`, `iter`, `nthin`, `cores`, and `quiet` as first-class arguments and forward other arguments to `rstan::sampling()` via `...`.

#### Scenario: Defaults and parallelism
- **WHEN** `kb_fit_weight()` is called with defaults
- **THEN** it fits `chains = 4` with warmup defaulting to match `iter`, fits chains in parallel by default (`cores = NULL`), and silences rstan output when `quiet = TRUE`
