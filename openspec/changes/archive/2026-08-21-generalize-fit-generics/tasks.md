## 1. Fix the abort machinery first

- [x] 1.1 `.fit_constructors()`: `ls(ns, all.names = TRUE)` so dot-prefixed internal generics are visible at all, and `startsWith()` rather than a regex so a leading `.` is literal
- [x] 1.2 `.abort_no_method()` takes `generic = NULL` for the internal-generic form, which names only the object's class and the `kb_fit_*()` pattern, rather than adding a near-duplicate helper. Those aborts pass `call = NULL`, since the immediate caller is a shared entry point rather than the verb the user called

## 2. Internal generics

- [x] 2.1 Rename `.weight_linpred_obs` / `.weight_linpred` / `weight_data_linpred` / `.weight_deviance` / `.weight_log_lik` / `.weight_terms` / `.weight_add_noise` to their bare names (64 call sites)
- [x] 2.2 Each generic, its default and both species methods live in the file of the public generic it serves: `.log_lik` in `R/log_lik.R`, `.deviance` in `R/residuals.R`, `.terms` in `R/tidy.R`, `.add_noise` in `R/posterior_predict.R`, `.chk_new_data` in `R/chk.R`
- [x] 2.3 `R/linpred.R`: `.linpred` (the one generic that was split across two per-species files) plus the shared entry points `.linpred_obs` and `data_linpred`
- [x] 2.4 `R/epred.R`: `.epred`, its default, and `.epred.kb_fit_weight` at the model tier
- [x] 2.5 `R/re_resolve.R`: the four resolvers, with their contract written down
- [x] 2.6 Delete `R/weight_{nereo,macro}_linpred.R`; the curve helpers move in with `kb_predict_weight_by()`
- [x] 2.7 Normalise the first argument to `fit`; `.deviance` returns `D x N`; `.add_noise` drops its unused `grid`

## 3. Guard

- [x] 3.1 `.vld_observed_levels()` / `.chk_observed_levels()`, called from `.linpred_obs` and `data_linpred(new_data = NULL)`

## 4. Lift the public methods

- [x] 4.1 Seven methods to `kb_fit`, `.chk_kb_fit`, `@param` naming the `kb_fit` class
- [x] 4.2 `fitted`/`posterior_epred` use `.epred()`; `posterior_linpred(transform = TRUE)` uses `.epred(expectation = FALSE)`
- [x] 4.3 `predict` stays at `kb_fit_weight`
- [x] 4.4 `_pkgdown.yml`: seven topic renames; `document()`

## 5. Tests

- [x] 5.1 Each internal generic's default tested in the file mirroring its source
- [x] 5.2 `test-linpred.R`: the two former per-species files consolidated, plus the `.linpred_obs` guard
- [x] 5.3 `test-re_resolve.R`: known/unknown levels, `"average"` zeroing, `"sample"` drawing, `rep_idx` averaging
- [x] 5.4 `test-abort.R`: a public verb on a fit with no methods aborts, and the internal-generic message form
- [x] 5.5 Correct `test-fitted.R`, `test-residuals.R` and `test-log_lik.R`, which had begun passing for the wrong reason
- [x] 5.6 Assert `posterior_epred()` and `posterior_linpred(transform = TRUE)` agree, documenting that they coincide by model property
- [x] 5.7 One new snapshot entry in `_snaps/abort.md`, reviewed and accepted. The existing `kb_stancode` entry also changed (`.abort_no_method()`'s fallback hint was reworded); that is a user-visible message change, not covered by the bit-identical claim
- [x] 5.8 `test-site_year_on.R`: the flag reader, and that `.linpred()` and `kb_model_describe()` agree for `TRUE` / `FALSE` / missing
- [x] 5.9 `test-tidy.R`: a dropped site:year effect is not reported as an estimate

## 6. Docs, specs, records

- [x] 6.1 `decisions/species-as-variant.md`: the three-tier rule (overwritten, live document)
- [x] 6.2 `decisions/architecture.md`: six references
- [x] 6.3 `CLAUDE.md`: the OOP sketch, and that `decisions/` are live documents. The one-file-per-generic rule needs no amendment
- [x] 6.4 `openspec/config.yaml`: the mean now lives in `.linpred()`
- [x] 6.5 `predictions`, `summaries`, `website` deltas; new `dispatch-errors` requirement
- [x] 6.6 Fix three pre-existing errors: `representative_site` claimed both species borrow intercept *and* slope (macro has no slope); `fitted`, `posterior_epred`, `posterior_predict` and the `predictions` spec claimed an "expected weight" the Student-t on log weight does not have; and `kb_model_describe()` read `meta$site_year_on` with `isTRUE()` while `.linpred()` read it with `isFALSE()`, so a legacy fit with no flag was described as having no site:year term while its predictions included one. Both now read `.site_year_on()` (`R/site_year_on.R`), the single reader
- [x] 6.7 Retire "kernel" as vocabulary, including from the pre-existing prose in `decisions/`, `openspec/config.yaml` and a code comment. These are methods, in the file named for their generic, so no replacement noun is needed
- [x] 6.8 Regenerate `decisions/architecture.html` (Quarto ships with Positron; the file is gitignored, a local preview only)
- [x] 6.9 `summaries`: `.terms()` omits a dropped random effect, so `tidy`/`coef`/`summary` no longer report prior-only `sSiteYear` / `bSiteYear` as estimates, and agree with `kb_model_describe()`

## 7. Verification

- [x] 7.1 `devtools::test()` green
- [x] 7.2 Bit-identical output vs pre-refactor, both fixtures, 14 quantities, `tolerance = 0`
- [x] 7.3 `openspec validate --specs` and `--changes`
- [x] 7.4 `KELPBIO_FULL_CHECK=true`: R CMD check 0 errors / 0 warnings / 0 notes, and pkgdown builds with no reference-index complaint, so the seven topic renames are consistent. One pre-existing pkgdown accessibility warning remains (missing alt-text on the README plot), unrelated to this change
- [x] 7.5 Archive the change and open the PR stacked on #10

## 8. Critical-review follow-ups

Found by a review of the implemented change; fixed in the same PR.

- [x] 8.1 `kb_model_describe()` and `.linpred()` read `meta$site_year_on` with opposite polarity (see 6.6); `.site_year_on()` is now the single reader
- [x] 8.2 `posterior_epred`, `posterior_predict` and the `predictions` spec still claimed an expectation the Student-t on log weight does not have (see 6.6)
- [x] 8.3 `.terms()` reported prior-only `sSiteYear` / `bSiteYear` as estimates (see 6.9)
- [x] 8.4 `test-linpred.R` was the two per-species files concatenated: a dispatch test that compared an expression to itself, two duplicated `test_that()` names, a stray mid-file header. `validate_by_weight()` tests move to the file mirroring their source, and `build_by_grid()` / `weight_by_linpred()` / `data_linpred()` gain the direct tests they never had
- [x] 8.5 `.fit_constructors()` used `ls(ns)`, which hides dot-prefixed names (1.1 claimed this was done; it was not)
- [x] 8.6 One wording for the supported-fits hint: `.chk_kb_fit()` / `.chk_kb_fit_weight()` now match `.abort_no_method()`. Moves six snapshots
- [x] 8.7 `c("site", "year")` was a literal in three places on the model-agnostic path; `.group_vars()` / `.fit_levels()` are the one source, with the reason the set is exhaustive written down
- [x] 8.8 The two `.linpred` methods opened with the same 16 lines of level matching; `.grid_indices()` does it once
- [x] 8.9 Only `log_lik()` and `posterior_predict()` guarded a zero-observation fit; the rest failed inside the rvar arithmetic with a broadcast error. `.chk_observed_data()` sits at the two shared observed-data entry points
- [x] 8.10 `decisions/prediction-engine.md` was never updated by the lift, and `architecture.md` had been through a substitution that renamed the function and left the file paths
- [x] 8.11 `summarise_weight_predictions()` hard-coded `exp()`, so the response scale had two definitions; it takes `fit` and calls `.epred()`. `.epred()`'s dual input contract (rvar or `D x N` matrix) is stated
- [x] 8.12 `.log_lik` / `.deviance` were four bodies with two shapes; `.per_draw()` holds the loop and the `D x N` orientation
- [x] 8.13 Two-fit loops carry `info = species`; `resolve_re2()`'s `"sample"` branch gains the test 5.3 claimed
- [x] 8.14 `validate_by_weight()` no longer defaults `species`
- [x] 8.15 `augment()` resolved the observed linear predictor twice
- [x] 8.16 Four lifted topics still described themselves as the weight model's; `man/` regenerated, which also caught two `.Rd` left stale by 8.2
- [ ] 8.17 Deferred: the `posterior_*` methods carry `representative_site`, a site-specific knob, in a fixed argument list at the `kb_fit` tier, which is the objection used to keep `predict` at the model tier. Reconcile the two when a sub-model needs a different knob
- [ ] 8.18 Deferred: pkgdown reports missing alt-text on the README plot. Pre-existing, unrelated to this change
