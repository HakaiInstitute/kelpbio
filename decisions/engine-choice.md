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
  separate Stan files per major variant. Species is one such variant axis: each
  species gets its own `.stan` and its own `kb_fit_<model>_<species>()` wrapper
  (see `decisions/species-as-variant.md`).
- Revisit `instantiate` only if a newer Stan feature becomes necessary, rstan's
  compile cost becomes a real bottleneck, or the audience shifts to
  CmdStan-equipped users.

## Update (2026-07): distribution rationale reaffirmed; a speed scare corrected

A perceived slowdown prompted an investigation. Two things came out of it: the
distribution basis for this decision is stronger than first written, and an
alarming speed measurement turned out to be a measurement artifact.

Runtime, measured cleanly (weight model, `data_submax` filtered to `doy > 140`:
1128 rows, 28 sites, 7 years; 4 chains, 1500 iterations, adapt_delta = 0.95, on
an otherwise idle machine): raw `rstan::sampling()` ~16.4 s, draw extraction plus
summaries ~0.5 s, full `kb_fit_weight_nereo()` ~17 s. An earlier run had reported
~176 s and a "3.7x slower than cmdstan" gap; that rstan number was contaminated
by concurrent background jobs oversubscribing the cores and is retracted. The
engine speed gap versus cmdstan is therefore not established: the cmdstan
reference (~47 s) was also measured uncontrolled (different iteration count,
different environment, `analyse()` post-processing included). A controlled,
sampling-only, matched-iteration comparison would be needed before any
speed-based claim, and none is currently made. The ad-hoc timing scripts used
during this investigation were not retained.

The decision does not rest on speed. It rests on distribution, and that basis was
re-confirmed against current (2026) sources. `instantiate`'s own documentation
states that CmdStan's absence from CRAN/R-universe build servers means models are
not compiled into the macOS/Windows binaries and the package must be installed
from source with CmdStan present; shipping pre-built CmdStan executables is
platform-specific and not portable. Only rstan + rstantools delivers a
binary-just-works install to a toolchain-less user.

Two secondary points settled along the way:
- The Shiny "cmdstanr is non-blocking" argument in `webapp-decision.md` does not
  hold. `cmdstanr$sample()` blocks its calling R session like `rstan::sampling()`
  (native async is unimplemented). kelpbio already runs `rstan::sampling()`
  inside `callr::r_bg()` (the `progress = "bar"` path in `fit_stan()`), matching
  cmdstan's external-process model.
- Vectorising the weight-model mean (gather random effects by observation, no
  per-observation loop) fits ~12% faster at an identical posterior (max mean
  difference 0.09 posterior SDs). Applied to the shipped weight model
  (`inst/stan/weight_nereo.stan`); a candidate optimisation for the other
  sub-models if the same gain holds.

Decision reaffirmed: rstan + rstantools, on distribution grounds, which are
independent of the speed question.
