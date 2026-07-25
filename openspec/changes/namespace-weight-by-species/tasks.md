# Tasks

## Pure helpers (no recompile)
- [x] Add shared engine `R/fit_stan.R` (`fit_stan()`, `with_quiet_sampler()`,
      `resolve_cores()`).
- [x] Add `.chk_sampler_args()` to `R/chk.R`; fix the `{.fun}` hint in
      `.chk_kb_fit_weight()`.
- [x] Rename + rewrite `R/kb_fit_weight_nereo.R` as a thin wrapper over
      `fit_stan()`; `new_kb_fit_weight()` takes engine output + `meta_extra`,
      drops the `species` argument.
- [x] Rename `kb_priors_weight_nereo()`, `kb_check_data_weight_nereo()`,
      `assemble_weight_nereo_data()`, `.weight_nereo_linpred()`; drop `species`.
- [x] Update `R/params.R` (remove `@param species`, fix priors xref) and the
      predict/method layer's internal calls to the renamed helpers.

## Stan + data (recompile checkpoint)
- [x] Rename `inst/stan/weight.stan` -> `inst/stan/weight_nereo.stan`;
      regenerate `R/stanmodels.R` and `src/stanExports_*` via
      `rstantools::rstan_config()`; drop stale `weight` artifacts.
- [x] Rename bundled objects (`data_weight_hakai_nereo`,
      `data_weight_sim_nereo`, `fit_weight_hakai_nereo`); re-save `.rda` by
      renaming objects (no re-fit); update `data-raw/` scripts and R doc stubs.

## Docs, specs, tests
- [x] Update `NAMESPACE` exports; main specs (`fitting`, `priors`, `data`,
      `stan-engine`); vignette; README; `scripts/demo-weight-*.R`.
- [x] Add ADR `decisions/species-as-variant.md`; update `config.yaml` and
      `decisions/engine-choice.md`.
- [x] Rename test files + snapshots to mirror; update fixture builders.
- [ ] `devtools::document()` to regenerate `man/` (install-gated: recompiles the
      renamed Stan model on load).
- [ ] `devtools::install()` then `devtools::test()`; review snapshots.
