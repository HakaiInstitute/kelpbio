## Context

`kb_predict_weight()` and `kb_predict_weight_by()` are plain functions that branch on `meta$species` and expose a generic `predictor` argument. This was chosen deliberately in `namespace-weight-by-species`, whose `design.md` states the model-level entry points "keep their names and will branch on `meta$species` only when a second species exists. No branch is added now (YAGNI; nereo is the only species)." That deferral is now void: the fit is already subclassed (`kb_fit_weight_nereo`, `kb_fit_weight_macro`), and the prediction engine already dispatches internally through the `.weight_linpred()` generic and its siblings (`.weight_add_noise`, `.weight_deviance`, `.fit_descriptor`, `.weight_terms`). Only the two user-facing verbs remain shared, with a `predictor` argument that is `diameter` for one species and `fronds` for the other.

## Goals / Non-Goals

**Goals:** - Make the two prediction verbs species-accurate at the call site: `diameter` for *Nereocystis*, `fronds` for *Macrocystis*, with the wrong-species argument rejected. - Use the idiomatic S3 mechanism (one generic, method-specific arguments) rather than a `...`-smuggling workaround, keeping the package within tidyverse/Posit API conventions. - Provide one shared generic doc plus per-species method detail docs. - Preserve all prediction behaviour and the `kb_predictions` contract unchanged.

**Non-Goals:** - No change to the numeric predictions, the sampler, the fit-object contract, or the `posterior_*` generics. - No renaming of the verbs themselves (they stay `kb_predict_weight` / `kb_predict_weight_by`, per the model-named-verb decision). - The `new_data` verb keeps `new_data` (a data frame whose column is already species-named); its species difference is validation and docs, not a new argument.

## Decisions

### S3 generics dispatching on the fit, not `...` validation

The verbs become generics on the fit's class:

``` r
kb_predict_weight_by <- function(fit, ...) UseMethod("kb_predict_weight_by")

kb_predict_weight_by.kb_fit_weight_nereo <- function(fit, by = NULL, diameter = NULL, ...,
                                                     new_levels = c("average", "sample"),
                                                     conf_level = 0.95,
                                                     estimate = stats::median, sig_fig = 3) {
  rlang::check_dots_empty()
  .kb_predict_weight_by(fit, by, diameter, new_levels, conf_level, estimate, sig_fig)
}
kb_predict_weight_by.kb_fit_weight_macro <- function(fit, by = NULL, fronds = NULL, ...) { ... }
```

- **Why over `...`-smuggling (the user's first idea):** the tidyverse design guide reserves `...` for forwarding or arbitrary-length same-role values, not a single required argument. Smuggling `diameter`/`fronds` through `...` loses the function signature, autocomplete, and clean `@param` docs, and forces manual name validation. S3 method formals are discoverable, self-documenting, and the standard pattern (`predict.lm` vs `predict.glm`, `augment.lm` vs `augment.glm`).
- **Why the generic carries `...`:** so each method may add its own formals and still pass `R CMD check` S3-consistency, exactly the broom pattern.
- **Shared body:** each method delegates to an internal `.kb_predict_weight_by()` (today's function body) after mapping its species argument to the internal grid values, so there is no logic duplication across methods.

### Wrong-predictor validation is largely free, with a friendly hint

A *Nereocystis* method has no `fronds` formal, so `kb_predict_weight_by(nereo, fronds = 5)` lands in `...` and `rlang::check_dots_empty()` errors. Each method additionally inspects `...` names and, when it sees the other species' predictor, aborts with a `cli` message ("`fronds` is the *Macrocystis* predictor; use `diameter` for a *Nereocystis* fit") rather than the generic dots error.

### Documentation: one generic topic, per-species method topics

The generic topic documents the shared arguments (`by`/`new_data`, `new_levels`, `representative_site`, `conf_level`, `estimate`, `sig_fig`) once. Each method topic uses `@inheritParams` for the shared set and adds its own `@param diameter` or `@param fronds` and the species `@details`. This mirrors broom's per-method documentation and satisfies the "one main doc plus species detail docs" goal without duplicating the shared argument prose.

## Risks / Trade-offs

- More API surface (a generic plus two methods per verb, and method help pages) → mitigated by the thin-method / shared-internal-impl split; the extra help pages are the intended per-species docs, not accidental sprawl.
- Breaking change: existing calls using `predictor =` stop working → acceptable pre-release (kelpbio ships via R-universe, no CRAN deprecation cycle owed); update the vignette, README, and demo in the same change. No `lifecycle` deprecation shim, given no external users depend on `predictor` yet.
- Bundled pre-fit objects and fixtures are unaffected (no re-fit): this changes only the call surface and dispatch, not the stored draws.

## Migration Plan

1.  Add the generics and per-species methods, extract the shared internal impls, add wrong-predictor validation.
2.  Update roxygen to the generic-plus-method doc structure; `document()` to regenerate `man/` and `NAMESPACE`.
3.  Update `vignettes/kelpbio.Rmd`, `README`, and `scripts/demo-api-test.R` to `diameter` / `fronds`.
4.  Update tests and any snapshot referencing `predictor`; add a wrong-predictor error test.
5.  Sync the `predictions` delta into `openspec/specs/predictions/spec.md` and archive the change.

## Open Questions

- Resolved: `kb_predict_weight()` (the `new_data` verb) also becomes a formal S3 generic with per-species methods, for documentation and dispatch symmetry with `kb_predict_weight_by()`, even though its signature (`new_data`) does not change. Its two methods differ only in validation and species `@details`, delegating to a single shared internal implementation.