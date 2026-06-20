## 1. Example/test data objects

- [x] 1.1 Rename `data-raw/kb_data_weight.R` -> `data-raw/data_weight_hakai.R`; update the object name and `usethis::use_data()` call to `data_weight_hakai`; rebuild `data/data_weight_hakai.rda` and remove `data/kb_data_weight.rda`.
- [x] 1.2 Rename `R/kb_data_weight.R` -> `R/data_weight_hakai.R`; update the documented object name, title, and `@description` (no decision rationale); keep `@format` and `@family data`.
- [x] 1.3 Add `data-raw/data_weight_sim.R`: simulate `diameter`/`weight`/`site`/`year` from the weight-model structure with a fixed `set.seed()`, small enough for fast tests; save via `usethis::use_data(data_weight_sim)`. Confirm it passes `kb_check_data_weight()`.
- [x] 1.4 Add `R/data_weight_sim.R` documenting `data_weight_sim` (mirror the Hakai dataset doc; `@description` states it is simulated for tests/examples, not for inference).
- [x] 1.5 Add `data-raw/fit_weight.R`: fit `kb_fit_weight(data_weight_sim)` with reduced `chains`/`niters` and `rstan::sampling(seed=)`; save via `usethis::use_data(fit_weight)`. (Requires the installed package: uses the compiled `stanmodels$weight`.)
- [x] 1.6 Add `R/fit_weight.R` documenting `fit_weight` (`@description` states it is a slim example fit, not for inference; `@family data`).
- [x] 1.7 Verify object sizes with `tools::checkRdaFiles("data")`. `fit_weight` is 0.85 MB (the <500 KB target was not achievable while retaining the `log_lik`/`yrep` generated quantities the `log_lik()`/`posterior_predict()` examples need; 0.85 MB stays under the 1 MB data-directory check threshold and the fit converges). Downsampled to 2 rows per site-year cell, 2 chains x 400 draws.
- [x] 1.8 Update all references to `kb_data_weight` across `R/`, `tests/`, README, and vignettes to `data_weight_hakai` (or `data_weight_sim` where a fast object is appropriate); confirm `grep -rn "kb_data_weight\b" R tests vignettes README*` is empty (the two remaining bare refs are in the `kb_fit_weight` example, rewritten in task 2.4).
- [x] 1.9 Update the `data` test (`tests/testthat/test-kb_data_weight*.R`) and fixtures to cover the renamed and new exported objects.

## 2. Add runnable @examples

- [x] 2.1 Add `@examples` using `fit_weight` / `data_weight_sim` to `kb_predict_weight`, `kb_predict_weight_by`, `kb_plot_predictions`, `kb_stancode`.
- [x] 2.2 Add `@examples` to the S3 methods: `tidy`, `glance`, `augment`, `coef`, `converged`, `summary`, `predict`, `autoplot`, `posterior_predict`, `posterior_epred`, `posterior_linpred`, `log_lik`, `prior_summary`, `samples`.
- [x] 2.3 Add one shared example to the accessor group (`nobs`, `nchains`, `niters`, `npars`, `nterms`, `pars`, `rhat`, `esr`, `estimates`) via its `@rdname`.
- [x] 2.4 In `kb_fit_weight`'s example, wrap only the live `kb_fit_weight()` call in `if (interactive())`; show downstream calls on `fit_weight`.

## 3. Documentation content cleanup

- [x] 3.1 Strip decision/rationale/in-session-context text from `params.R` (`niters`, `cores`), `coef.R`, `glance.R`, `converged.R`, `augment.R`, `predict.R`, `summary.R`, `kb_predict_weight.R`, and any other file found in the pass; keep behavioural "how" statements.
- [x] 3.2 Split the over-long `@description` on `kb_predict_weight`, `kb_predict_weight_by`, `kb_plot_predictions` into a short `@description` plus `@details` (conditioning / `new_levels` / metadata-inference mechanics in `@details`).
- [x] 3.3 Standardise every `@param` description (in `params.R` and non-inherited per-function params) to end with a period; tighten the longest `params.R` entries (`new_levels`).
- [x] 3.4 Add `@seealso` links across `@family` boundaries (e.g. `augment` <-> `kb_predict_weight`).

## 4. Inline-comment trim

- [x] 4.1 Trim `R/weight_linpred.R`: compress the `.weight_linpred` header to the essential point; one-line the per-helper blocks; drop the `rvar_index1` comment that restates the code.
- [x] 4.2 Tighten the kept "why" comments in `R/kb_fit_weight.R` (`niters`->`iter`, `with_quiet_sampler`).
- [x] 4.3 Trim multi-line essays in `R/chk.R`, `R/glance.R`, `R/print.R` to one-line intent comments.

## 5. Regenerate and verify

- [x] 5.1 `devtools::document()`; `man/*.Rd` and `NAMESPACE` updated (old `kb_data_weight.Rd` removed; `data_weight_hakai`/`data_weight_sim`/`fit_weight` docs present); `\link` warnings clear on re-document.
- [x] 5.2 `devtools::run_examples()`: every example runs without error; only `kb_fit_weight()` is gated by `if (interactive())`. `devtools::test()` is green (226 PASS, 0 FAIL).
- [x] 5.3 `devtools::check()`: 0 errors, 0 warnings, 1 NOTE. The NOTE (`newdata` in Imports but unused) is pre-existing and out of scope (declared for the planned grid engine). No missing-examples note, no broken `\link`, no data-size note. (Run with `vignettes = FALSE`; the full check needs Pandoc, absent in this environment.)
- [x] 5.4 `openspec validate improve-docs-and-example-data --strict` passes.
