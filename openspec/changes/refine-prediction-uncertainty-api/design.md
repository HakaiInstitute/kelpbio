## Context

The prior iteration of this change made conditioning implicit (inferred from which grid columns were present) and errored on unknown levels. A demo test-drive showed both were wrong: grid-builders such as `newdata::xnew_data()` auto-populate grouping columns at reference levels, so `new_levels` was silently ignored and population bands collapsed; and erroring on a new site forced users to hand-split and bind known vs new rows. This revision supersedes that framing.

## Goals / Non-Goals

**Goals:** independent arguments (no `by` + `new_data` collision); a new level predicts (sampled) rather than errors; a mix of known and new groups resolves in one call; `new_data = NULL` matches base R; the review bug fixes; real data.

**Non-Goals:** no Stan/recompile change; no third `new_levels` value; size model deferred; biomass composition untouched.

## Decisions

- **Two verbs, independent arguments.** `kb_predict_weight()` (new data; `predict()` wraps it) and `kb_predict_weight_by()` (curve summary). `by` lives only on `_by`; `new_data` only on the bare verb. This removes the mutually-exclusive-argument smell the way the tidyverse does (`fct_lump_n`/`fct_lump_prop`, `slice_*`), rather than via a runtime error.
- **Per-row, per-factor resolution** in the shared `.weight_linpred()`: known level → condition; new level or absent column → `new_levels`. Unifies the absent-column and new-level cases and removes the error. `resolve_re1()`/`resolve_re2()` assemble a mixed conditioned/drawn rvar.
- **`new_levels` default `"sample"`** so an unseen group carries honest between-group uncertainty; `"average"` is opt-in (typical group, not a calibrated interval for the new group).
- **Single engine preserved** (`decisions/prediction-engine.md`): both verbs, the generics, and `augment()` call `.weight_linpred()`; the cross-model contract is recorded in that ADR.

## Risks / Trade-offs

- [Breaking, pre-1.0 on R-universe] → land rename + signature change together; tests pin the new shapes; no deprecation cycle.
- [`kb_predict_weight(NULL)` now returns observed data, not a curve] → intended (base R alignment); the curve is `kb_predict_weight_by()`.
- [Real data: 28 sites × 7 years] → many site:year panels; the `max_facets` cap and per-row resolution both matter. Fixture stays on small sim data for speed/stability.
- [Shipping real survey data publicly] → confirm clearance before release (HakaiInstitute org package).
