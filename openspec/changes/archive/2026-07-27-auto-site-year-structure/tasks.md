## 1. Behaviour helper (pure)

- [ ] 1.1 `R/site_year_structure.R`: `site_year_structure(data)` -> `list(on, aliased)` (distinct-values rule); `notify_site_year(status, quiet)` emitting the aliasing warning and the omit message via `cli`.
- [ ] 1.2 `tests/testthat/test-site_year_structure.R`: crossed/aliased/single-year flags; warning + message via snapshot (no MCMC).

## 2. Fitting

- [ ] 2.1 `R/kb_fit_weight_nereo.R`: remove `site_year_on` from the signature and `chk`; call `site_year_structure()` + `notify_site_year()`; pass `status$on` to `assemble_weight_nereo_data()` and `meta`; add the `@details` note.
- [ ] 2.2 `R/params.R`: remove the `@param site_year_on` block.
- [ ] 2.3 `tests/testthat/test-kb_fit_weight_nereo.R`: assert `formals()` has no `site_year_on`.

## 3. Prediction consistency

- [ ] 3.1 `R/weight_nereo_linpred.R`: gate `re_sy` on `isTRUE(fit$meta$site_year_on)`.
- [ ] 3.2 `tests/testthat/test-weight_nereo_linpred.R`: a fit with `meta$site_year_on = FALSE` adds no site:year contribution.

## 4. Docs + demo

- [ ] 4.1 `decisions/architecture.md`: update the structural-flags bullet, the `meta` table entry, and the glossary; regenerate `decisions/architecture.html`.
- [ ] 4.2 `scripts/demo-api-test.R`: replace the `fit_no_sy` block with single-year (auto-drop) and aliased (warning) subset examples.
- [ ] 4.3 `devtools::document()` to regenerate `man/kb_fit_weight_nereo.Rd` and `man/params.Rd` (no Stan recompile).

## 5. Verify

- [ ] 5.1 `devtools::load_all()`; run the pure tests; drive single-year / aliased / crossed fits (message, warning, silent); confirm `formals(kb_fit_weight_nereo)` has no `site_year_on`; run the demo fitting section.
