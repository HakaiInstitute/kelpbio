## Context

The weight model and its S3 surface are implemented. The documentation is sound
on fundamentals (central `R/params.R` with `@inheritParams params`, technical
register, Title-Case period-free titles, `@family` grouping, `@exportS3Method`)
but diverges from the `bboutools` / `ssdtools` / tidyverse conventions in four
ways: a sparse `@examples` surface, decision-rationale text in user-facing
descriptions, over-long `@description` blocks on the prediction/plot functions,
and verbose narrative inline comments. Runnable examples are blocked: the only
example dataset is the confidential Hakai data and no fit object ships with the
package (the 2.7 MB `tests/testthat/fixtures/weight_fit.rds` is not installed).

## Goals / Non-Goals

**Goals:**
- Ship a simulated dataset and a slim pre-fit object so examples run at
  `R CMD check` and tests can use installed objects.
- Bring weight-model roxygen and inline comments in line with the reference
  packages and the documentation rules in `openspec/config.yaml`.
- User-facing doc text states how the implementation works, not why it was chosen.

**Non-Goals:**
- No change to model structure, priors, sampling, or the prediction engine.
- No new sub-models; no vignette rewrite beyond dataset references.

## Decisions

**Rename `kb_data_weight` to `data_weight_hakai`, and drop the `kb_` prefix from
all exported data and example-fit objects.** The package ships two weight
datasets plus a pre-fit example, so an unqualified `kb_data_weight` would be
ambiguous against the simulated set; the `_hakai` / `_sim` suffixes name the
source. The `kb_` prefix is reserved for functions, so the data and fit objects
(`data_weight_hakai`, `data_weight_sim`, `fit_weight`) drop it to read distinctly
from the `kb_` function surface (e.g. the `fit_weight` object versus the
`kb_fit_weight()` function). This is a breaking rename of exported objects;
acceptable pre-1.0 (version `0.0.0.9000`).

**Simulated dataset generated from the weight model structure, seeded.** Build
`data_weight_sim` in `data-raw/data_weight_sim.R` by drawing `site`/`year`
levels and simulating `weight` from the quadratic log-diameter mean plus random
effects and Student-t noise, with a fixed `set.seed()` in the build script (the
data object is a static artifact). Small enough for fast tests; large enough that
`kb_fit_weight()` converges. It must pass `kb_check_data_weight()`.

**Ship a pre-fit `fit_weight`, not fit-in-examples.** Examples for the S3
methods and predictions need a fit. Fitting in every example is too slow for
check. Build `fit_weight` once in `data-raw/fit_weight.R` with
reduced `chains`/`niters` and `rstan::sampling(seed=)`, on `data_weight_sim`.
The fit object stores extracted draws (not the stanfit), so it is small; keep it
well under ~500 KB and verify with `tools::checkRdaFiles()`. Examples then use
`fit_weight` directly and run instantly. Only `kb_fit_weight()`'s own
example wraps the live fit in `if (interactive())`.

**Strip rationale from user-facing docs; keep it in `decisions/` and design.md.**
Per the repo's one-fact-one-home rule, naming rationale, convention-justification,
and in-session context do not belong in roxygen. Descriptions and details state
behaviour and usage. Where a comment restated an ADR (engine, prediction-engine),
it is cut to a pointer or removed.

**Moderate inline-comment trim.** Keep comments that explain a non-obvious why
(e.g. the `niters`->`iter` translation, the `with_quiet_sampler` rationale);
delete comments that narrate what the next line does.

## Risks / Trade-offs

- Breaking rename of `kb_data_weight` -> any external reference breaks. Mitigation:
  grep `R/`, `tests/`, `data-raw/`, vignettes, README; update all; the package is
  pre-1.0 and not yet on the R-universe index.
- `fit_weight` fitted on tiny simulated data may not converge -> example
  output (e.g. `glance()`) could show non-convergence. Mitigation: size the
  simulated data and `niters` so the example fit converges; this is a build-time,
  not user-time, check.
- A shipped pre-fit object can go stale if the fit-object structure changes.
  Mitigation: the build script is committed and rerun via the data-raw workflow;
  tests load the object and exercise the accessors, catching drift.

## Migration Plan

1. Add `data_weight_sim` and `fit_weight` (additive).
2. Rename `kb_data_weight` -> `data_weight_hakai` and update all references.
3. Rewrite roxygen + trim comments; regenerate `man/` and `NAMESPACE`.
4. `devtools::check()` clean, then archive the change.
