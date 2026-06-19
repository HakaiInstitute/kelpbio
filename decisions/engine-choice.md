# Decision: Bayesian engine is rstan + rstantools (not cmdstanr / instantiate)

Status: accepted (2026-06)

## Context

kelpbio ships Bayesian Stan models inside an R package for a non-technical
audience (biologists) and a companion Shiny app, distributed as binaries via the
Hakai R-universe. The binding requirement is "install and it just works": no
separate Stan toolchain, no per-user compilation, works on shinyapps.io.

## Decision

Use `rstan` + `rstantools`. Stan sources live in `inst/stan/` and are
**pre-compiled at `R CMD INSTALL`** into the package's Rcpp `.so`, exposed as the
`stanmodels` list and sampled via `rstan::sampling()`. Prior hyperparameters are
passed through the Stan `data` block (the prior family is fixed at compile time).

## Rationale

Two cmdstanr-based alternatives were weighed (June 2026):

- **cmdstanr at runtime** (ship source, compile per user): a one-time
  `install_cmdstan()` (~150 MB toolchain), explicit Stan-version management, and
  it does not work on shinyapps.io. Unsuitable for non-technical users.
- **`instantiate`** (pre-compiled CmdStan models; "rstantools for the cmdstanr
  era", the direction the Stan team favours) is the strongest alternative. The
  disqualifier is binary distribution: CmdStan is absent from CRAN/R-universe
  build servers, so models are not baked into the macOS/Windows binaries and the
  package must be source-installed with CmdStan present. That breaks the
  "binary just works" property.

`rstan` + `rstantools` compiles via the standard R C++ toolchain, which
R-universe build servers already have, so R-universe ships a working binary with
the models baked in and zero Stan toolchain for users or the Shiny deployment.
The models here (Student-t, Weibull, NB/ZINB, Beta, non-centered random effects)
need nothing the current `rstan` (>= 2.32) lacks, so the Stan-version lag that
motivates cmdstanr does not bite.

## Consequences

- Recompile is triggered by editing a `.stan` file, upgrading rstan/StanHeaders,
  or changing `Makevars`. `devtools::load_all()` does not pick up Stan changes;
  use `devtools::install()`. (These are restated as rules in `config.yaml`.)
- Runtime flexibility comes from priors-as-data, binary structural flags, and
  separate Stan files per major variant; species enters as data, not a variant.
- Revisit `instantiate` only if a newer Stan feature becomes necessary, rstan's
  compile cost becomes a real bottleneck, or the audience shifts to
  CmdStan-equipped users.
