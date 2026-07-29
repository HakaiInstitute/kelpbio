## 1. Model descriptor (single source)

- [ ] 1.1 Extend the species `.fit_descriptor()` (or a new `.model_spec()` helper) to expose the structured pieces the equation needs: likelihood line, linear-predictor terms (with the package parameter names), random-effect list (term, group, kind), and the `nu`/centering facts. Keep it the single source the slimmed header and the describe renderer both read.

## 2. kb_model_describe()

- [ ] 2.1 `R/kb_model_describe.R`: generic `kb_model_describe(fit, prose = FALSE)` dispatching on the fit subclass; `chk::chk_flag(prose)`.
- [ ] 2.2 Nereo and macro methods supplying their structural pieces to a shared renderer.
- [ ] 2.3 Notation renderer (`prose = FALSE`): likelihood, linear predictor, random-effect distributions, priors, using package parameter names; response/predictor named without units; `d0`/`f0` from meta; `nu = 4` inline; `site:year` omitted when `site_year_on` is `FALSE`; priors from `meta$priors`.
- [ ] 2.4 Prose renderer (`prose = TRUE`): report-ready methods paragraph from the same descriptor.
- [ ] 2.5 Return the rendered lines invisibly.

## 3. Slim the header

- [ ] 3.1 `R/summary.R` (`.kb_fit_header()`): drop the `family` / `fixed` / `random` fields; keep model, species, centering, groups/nobs, sampler, prior_only, converged.
- [ ] 3.2 `R/print.R` (`.print_kb_fit_header()`): drop the `Family` / `Fixed` / `Random` lines; add a footer pointing to `kb_model_describe(fit)`.
- [ ] 3.3 Confirm `summary()` uses the same slimmed header (single shared renderer) and its coefficient table is unchanged.

## 4. Docs

- [ ] 4.1 roxygen for `kb_model_describe()` (`@family`, `prose` param, return value, examples for both species); `devtools::document()` to regenerate `man/` and `NAMESPACE`.
- [ ] 4.2 Add a `kb_model_describe()` example to `vignettes/kelpbio.Rmd` and `README`; exercise it in `scripts/demo-api-test.R`.

## 5. Tests

- [ ] 5.1 `tests/testthat/test-kb_model_describe.R`: snapshot the notation and prose for nereo and macro; test the `site_year_on`-dropped case; test that custom priors render.
- [ ] 5.2 Update the `print` header snapshots (`tests/testthat/_snaps/print.md`) to the slimmed header.
- [ ] 5.3 `devtools::test()` green.

## 6. Spec sync and archive

- [ ] 6.1 Sync the `summaries` and `model-description` deltas into `openspec/specs/`.
- [ ] 6.2 Archive the change.
