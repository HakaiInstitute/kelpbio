No Stan sources change in this change, so no `devtools::install()` checkpoint is
required; `devtools::load_all()` and `devtools::test()` are sufficient throughout.

## 1. Shared helpers

- [x] 1.1 Add `call = rlang::caller_env()` as an optional parameter to `.chk_kb_fit()` and `.chk_kb_fit_weight()` in `R/chk.R`, passed through to `cli::cli_abort()`, leaving the message text unchanged
- [x] 1.2 Create `R/abort.R` with the internal `.abort_no_method(generic, x, x_name, call)` helper that unconditionally aborts via `cli`, naming the generic and the class it received
- [x] 1.4 Add `.fit_constructors(generic)` to `R/abort.R`, deriving the supported constructors from the generic's registered methods intersected with the namespace exports
- [x] 1.5 Replace the hardcoded constructor list in both `.chk_` hints with a name-pattern hint (`kb_fit_*()`, `kb_fit_weight_*()`) so no message enumerates constructors in fixed text
- [x] 1.3 Re-record the `tests/testthat/_snaps/chk.md` snapshot for `.chk_kb_fit_weight(1)`: the message text is unchanged, but a top-level call now reports a bare `Error:` because the validator blames its caller and there is none

## 2. Default methods

- [x] 2.1 Add `kb_stancode.default()` in `R/kb_stancode.R`: `.chk_kb_fit()` then `.abort_no_method()`, both with `call = rlang::current_env()` so the error is attributed to the generic call
- [x] 2.2 Add `samples.default()` in `R/samples.R`, same shape as 2.1
- [x] 2.3 Add `kb_model_describe.default()` in `R/kb_model_describe.R`: `.chk_kb_fit_weight()` then `.abort_no_method()`
- [x] 2.4 Add `kb_predict_weight.default()` in `R/kb_predict_weight.R`, same shape as 2.3
- [x] 2.5 Add `kb_predict_weight_by.default()` in `R/kb_predict_weight_by.R`, same shape as 2.3
- [x] 2.6 Give each `.default` a bare `#' @export` with no roxygen topic
- [x] 2.7 Run `devtools::document()` and confirm `NAMESPACE` gains exactly five `S3method(<generic>,default)` entries

## 3. Tests

- [x] 3.1 Create `tests/testthat/test-abort.R` covering `.abort_no_method()` and `.fit_constructors()`, asserting the derived names are exported functions with a registered method rather than a fixed list
- [x] 3.2 Extend `tests/testthat/test-chk.R` to cover the new `call` parameter on both validators
- [x] 3.3 Add a wrong-class error test to the mirrored test file for each of the five generics, snapshotting the `cli` message
- [x] 3.4 Replace the `"no applicable method"` assertion in `tests/testthat/test-kb_model_describe.R` with the branded message
- [x] 3.5 Add a test that a `kb_fit_weight` subclass with no species method errors rather than returning a value
- [x] 3.6 Add a test that the reported condition call is the generic, not the `.default` method

## 4. Verification and completion

- [x] 4.1 Run `devtools::test()` and confirm the full suite is green with no orphaned snapshots
- [x] 4.2 Run `Rscript scripts/build.R` for the routine document / style / test pass
- [x] 4.3 Drift check: specs against code, reader docs against code
- [x] 4.4 Archive the change so `openspec/specs/dispatch-errors/` is created from the delta
- [ ] 4.5 Open the PR stacked on `add-model-describe` and confirm CI is green
