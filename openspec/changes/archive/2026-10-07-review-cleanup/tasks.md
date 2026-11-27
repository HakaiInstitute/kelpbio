## 1. Site:year aliasing

- [x] 1.1 `site_year_structure()` returns the aliased main effects; `notify_site_year()` names them
- [x] 1.2 Tests for one site over several years and single-site years; snapshot of both warnings

## 2. Remove the `by` redirection

- [x] 2.1 Remove `.chk_by_habit()`, its calls in the four verbs, its test and snapshot, and the demo-script line

## 3. Without spec impact (same PR)

- [x] 3.1 Error attribution: shared checks run inside `.with_call()`, so errors name the function called; one zero-observation message
- [x] 3.2 Sampler arguments kelpbio sets (`iter`, `thin`, `pars`, ...) error when passed through `...`
- [x] 3.3 Plot biomass resolves the weight group effects once over all site-years

## 4. Close

- [x] 4.1 `openspec validate review-cleanup --strict`; `devtools::document()`; tests green
- [x] 4.2 Archive the change
