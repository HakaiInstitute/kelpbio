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
- [ ] 5.7 One new snapshot entry in `_snaps/abort.md`, awaiting review

## 6. Docs, specs, records

- [x] 6.1 `decisions/species-as-variant.md`: the three-tier rule (overwritten, live document)
- [x] 6.2 `decisions/architecture.md`: six references
- [x] 6.3 `CLAUDE.md`: the OOP sketch, and that `decisions/` are live documents. The one-file-per-generic rule needs no amendment
- [x] 6.4 `openspec/config.yaml`: the mean now lives in `.linpred()`
- [x] 6.5 `predictions`, `summaries`, `website` deltas; new `dispatch-errors` requirement
- [x] 6.6 Fix two pre-existing doc errors: `representative_site` claimed both species borrow intercept *and* slope (macro has no slope), and `fitted`/`posterior_epred` claimed an "expected weight" the Student-t on log weight does not have
- [x] 6.7 Retire "kernel" as vocabulary, including from the pre-existing prose in `decisions/`, `openspec/config.yaml` and a code comment. These are methods, in the file named for their generic, so no replacement noun is needed
- [ ] 6.8 Regenerate `decisions/architecture.html` (needs Quarto, not on PATH)

## 7. Verification

- [x] 7.1 `devtools::test()` green
- [x] 7.2 Bit-identical output vs pre-refactor, both fixtures, 14 quantities, `tolerance = 0`
- [x] 7.3 `openspec validate --specs` and `--changes`
- [ ] 7.4 `KELPBIO_FULL_CHECK=true` (R CMD check + pkgdown, catches the topic renames)
- [ ] 7.5 Archive the change and open the PR stacked on #10
