## 1. Implementation

- [x] 1.1 `R/fit_stan.R`: `with_quiet_sampler(expr, quiet)` - when `quiet` is `FALSE`, evaluate `expr` with no handler (rstan's diagnostic warnings propagate); when `TRUE`, keep the existing muffling handler. Pass `quiet = quiet` at the `fit_stan()` call site.
- [x] 1.2 `R/kb_fit_weight_nereo.R` `@details`: rewrite the quiet paragraph - `quiet = FALSE` shows progress and rstan's post-sampling HMC diagnostic warnings; `quiet = TRUE` suppresses both; `converged()`/`glance()`/`summary()` give the structured summary. Drop the implication that treedepth is inspectable post-hoc.
- [x] 1.3 `R/params.R` `@param quiet`: correct it - no longer "suppressed regardless"; FALSE shows progress + diagnostics, TRUE suppresses both.

## 2. Verify

- [x] 2.1 `devtools::document()`; confirm `man/` updated.
- [x] 2.2 Confirm no test asserts a silent `quiet = FALSE` fit (fixtures use `quiet = TRUE`); `devtools::test()` green.
- [x] 2.3 Sanity-check via `load_all()`: a tiny `quiet = TRUE` fit emits no diagnostic warnings; the same fit with `quiet = FALSE` lets rstan's warnings through.
- [x] 2.4 `devtools::check()` clean (modulo pre-existing NOTES).
- [x] 2.5 `openspec validate show-fit-diagnostics --strict` passes.
