## Why

The prediction verbs `kb_predict_weight()` and `kb_predict_weight_by()` are single shared functions that branch internally on `meta$species` and expose a generic `predictor` argument for the curve grid. This was a deliberate deferral: the `namespace-weight-by-species` change kept the verbs shared and species-agnostic "only when a second species exists. No branch is added now (YAGNI; nereo is the only species)." *Macrocystis* now exists, so the deferral has expired, and the generic `predictor` argument names neither species accurately (it is `diameter` for *Nereocystis* and `fronds` for *Macrocystis*).

## What Changes

- **BREAKING**: `kb_predict_weight()` and `kb_predict_weight_by()` become S3 generics that dispatch on the fit's species subclass (`kb_fit_weight_nereo`, `kb_fit_weight_macro`), matching the internal `.weight_linpred()` dispatch and the broom `augment()`/`predict()` convention of one generic with method-specific arguments.
- **BREAKING**: the generic `predictor` argument of `kb_predict_weight_by()` is replaced by per-species formals: `diameter` on the *Nereocystis* method and `fronds` on the *Macrocystis* method. Passing the wrong-species predictor (for example `fronds` to a *Nereocystis* fit) errors with a `cli` message naming the correct argument, rather than being silently accepted.
- The shared verb body stays factored into a single internal implementation the methods delegate to, so behaviour (grid generation, `by`, `new_levels`, `representative_site`, summary arguments, the `kb_predictions` output) is unchanged apart from the predictor argument name.
- Documentation adopts a one-generic-topic-plus-per-species-method structure: the generic topic documents the shared arguments (`new_data`/`by`, `new_levels`, `representative_site`, `conf_level`, `estimate`, `sig_fig`) via `@inheritParams`; each method topic adds its `diameter`/`fronds` `@param` and the species-specific details.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `predictions`: the two prediction verbs become species-dispatched S3 generics, and the `kb_predict_weight_by()` grid argument is renamed from the generic `predictor` to the per-species `diameter` / `fronds`.

## Impact

- `R/kb_predict_weight.R` and `R/kb_predict_weight_by.R`: each becomes a generic plus two subclass methods delegating to a shared internal implementation (`.kb_predict_weight()` / `.kb_predict_weight_by()`). Wrong-predictor validation added.
- `man/`: the two verbs gain per-method topics (generic doc plus `kb_fit_weight_nereo` / `kb_fit_weight_macro` method docs); `NAMESPACE` regenerated for the new S3 methods.
- Reader docs referencing the verbs: `vignettes/kelpbio.Rmd`, `README`, and `scripts/demo-api-test.R` updated to the species-named arguments.
- Tests: `tests/testthat/test-kb_predict_weight.R`, `test-kb_predict_weight_by.R`, and any snapshot exercising the `predictor` argument updated to the new signatures and the wrong-predictor error.
- No change to the sampler, the fit-object contract, the `kb_predictions` object, the `posterior_*` generics, or the numerical predictions; this is an API-surface and dispatch change.