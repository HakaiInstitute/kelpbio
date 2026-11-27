## Context

This change reverses the "species enters as data, not a variant" rule. The
cross-cutting rationale (why species is a structural variant, why per-function +
per-`.stan`, why the S3 class stays model-level) lives in
`decisions/species-as-variant.md`; `config.yaml` is updated to match. This file
captures only the rationale specific to executing the rename and the engine
split.

## Two dispatch axes

- Fit time, by function name: `kb_fit_weight_nereo()` selects the species. The
  wrapper supplies the species-specific pieces (validation, priors, Stan-data
  assembly, compiled model, `param_vars`) and delegates the mechanics to
  `fit_stan()`.
- Post-fit, by `meta$species`: the class is model-level (`kb_fit_weight`), so
  every method/accessor is shared. The linear-predictor builder is named
  `.weight_nereo_linpred()` so a future `.weight_macro_linpred()` is an obvious
  sibling; the model-level entry points (`weight_data_linpred()`, the
  `posterior_*` generics, `kb_predict_weight*`) keep their names and will branch
  on `meta$species` only when a second species exists. No branch is added now
  (YAGNI; nereo is the only species).

## Shared engine boundary

`fit_stan(stanmodel, stan_data, param_vars, gq_vars, chains, niters, nthin,
cores, quiet, ...)` is model- and species-agnostic and returns
`list(draws, gq, diagnostics, stancode)`. `with_quiet_sampler()` and
`resolve_cores()` move into it. `new_kb_fit_weight()` stays model-level and takes
the engine output plus a flexible `meta_extra` list (nereo passes `diameter_ref`
and `nu = 4`; macro will pass its own, e.g. a fronds reference and the Gamma
shape, with no `nu`). This keeps the species-specific metadata out of the shared
constructor.

## No re-fit

The `.stan` source is unchanged (only the filename gains `_nereo`), so the
compiled model is numerically identical. The bundled `.rda` objects and the test
fixture are therefore re-saved under their new names by renaming the in-memory
objects, not by re-running MCMC. A single `devtools::install()` recompile (from
the filename change) is the only build checkpoint.

## Naming

The function suffix and file/object names use the short `_nereo` (matching the
analysis project's `*-nereo` files); `meta$species` records the full
`"nereocystis"`. The pre-fit object is `fit_weight_hakai_nereo` to signal both
the source dataset (Hakai) and the species.
