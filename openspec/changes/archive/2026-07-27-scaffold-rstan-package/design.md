## Context

kelpbio is a usethis-template R package with no Bayesian engine. The full engine design lives in `decisions/engine-choice.md` (rstantools setup, pre-compilation mechanics, priors-as-data, `prior_only`, marginal/typical generated quantities, §14 checklist) and the simplified model in `openspec/specs/stan-engine/spec.md`. This change implements that engine setup. It is the foundation every later model change depends on, and the riskiest/slowest part of the package (first compile 10-20 min, C++17 toolchain, rstan/StanHeaders version coupling, historical Apple-Silicon fragility) — so it is isolated and validated on its own with a single real model.

## Goals / Non-Goals

**Goals:**
- A reproducible rstan/rstantools build: `inst/stan/*.stan` compiled at `R CMD INSTALL`, exposed as `stanmodels$<name>`, samplable via `rstan::sampling()`.
- The real (simplified) `inst/stan/weight.stan` as the compile smoke-test, written to the engine conventions so Change B can wrap it without touching Stan.
- Cross-platform CI proving the build off the author's machine.

**Non-Goals:**
- Any `kb_` user-facing function (fitting, validation, priors API, predictions, plotting) — Change B.
- Bundled `data/` datasets — Change B.
- The full weight model (quadratic term, site:diameter slope, site:year RE) — a later `upgrade-weight-model` change.

## Decisions

- **Use `rstantools::rstan_create_package(auto_config = TRUE)` over the existing directory**, then reconcile the generated `DESCRIPTION`/`NAMESPACE` by hand (keep the existing author/ORCID, set a real Title/Description and license, pin `rstan`/`StanHeaders (>= 2.32.0)`). Rationale: this is the supported rstantools path and generates the `configure`/`Makevars`/`R/stanmodels.R` machinery correctly; `auto_config = TRUE` keeps `src/stanExports_*` regenerated on Stan edits during development. Alternative considered: hand-rolling the Stan build — rejected as error-prone and unsupported.
- **Ship the real simplified `weight.stan` as the smoke-test, not a throwaway model.** The slice's purpose is to validate the build with the actual model; a placeholder would be discarded work and would not exercise the priors-as-data / `prior_only` / generated-quantities conventions. The `kb_` wrapper that calls it is deferred to Change B, so this change introduces the Stan source but no R API — a clean seam.
- **Weight smoke-test model structure** (per `openspec/specs/stan-engine/spec.md`): `log(weight) ~ student_t(4, bWeight + bSite[site] + bDiameter * log(diameter/30), sWeight)` with non-centered `bSite = z_bSite * sSite`. Priors-as-data: `prior_intercept_mu/sd`, `prior_slope_mu/sd`, and **separate** `prior_sd_site_rate` and `prior_sd_residual_rate` (resolving the docs' single-shared-rate ambiguity, since the model has two SD priors). `int<lower=0> nObs` and an `int<lower=0,upper=1> prior_only` flag guarding the likelihood. `generated quantities` produce `typical` (REs zeroed) and `marginal` (`normal_rng(0, sSite)`) terms on the observed grid.
- **CI on macOS/Linux/Windows via `r-lib/actions`** with aggressive package-library caching keyed on the DESCRIPTION hash, so the 10-20 min compile is paid once per dependency change.

## Risks / Trade-offs

- `rstan_create_package()` clobbers the existing template `DESCRIPTION`/`NAMESPACE` → commit before running; review the diff and re-merge author/ORCID/Title/Description/license by hand; commit after.
- Slow, memory-heavy first compile (10-20 min, ~4 GB) → budget it as an explicit install checkpoint; cache the library in CI; this change pays it once so Change B's fast tests run against a fixture.
- Apple-Silicon / source-install fragility (C++17, stale `~/.R/Makevars` with `CXX14FLAGS`, `stan/version.hpp not found`) → use CRAN binaries for rstan/StanHeaders; verify no `CXX14` override in `~/.R/Makevars`; keep the rstan getting-started link in README.
- rstan/StanHeaders version skew → pin both as a matched pair; cache key includes the DESCRIPTION hash so skew invalidates cleanly.
- `devtools::load_all()` does not recompile Stan → all install/sampling verification uses `devtools::install()`; documented in the engine doc and `config.yaml`.

## Migration Plan

1. Commit current state.
2. Run `rstan_create_package(auto_config = TRUE)`; review and reconcile generated files; commit.
3. Add `inst/stan/weight.stan`; `devtools::install()`; smoke-test sampling.
4. Add CI; confirm green cross-platform.

Rollback: revert to the pre-scaffold commit (the change is self-contained in build files + one Stan source).

## Open Questions

- None blocking. (`auto_config = FALSE` + manual `rstan_config()` may be revisited at stable-release time to drop the rstantools runtime dependency; not now.)
