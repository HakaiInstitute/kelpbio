# bboutools API Review

A critical design review of [bboutools](https://github.com/poissonconsulting/bboutools) against the [tidyverse design guidelines](https://design.tidyverse.org) and *R Packages* (2e), conducted to extract lessons for kelpbio.

bboutools is a mature, well-engineered package (testthat 3e, snapshot tests, pkgdown, `@inheritParams`, automated NEWS). It is the reference for kelpbio's architecture, and most of what it does is worth copying. This document is deliberately adversarial: it isolates the places where bboutools diverges from tidyverse best practice so kelpbio can decide, consciously, whether to follow or improve. Each finding cites the relevant principle, gives a verdict, and states the kelpbio implication.

Severity: **\[H\]** worth changing, **\[M\]** worth a deliberate decision, **\[L\]** minor/cosmetic, **\[+\]** does it right — keep.

> **Superseded in part (generics realignment).** Two recommendations below were later revisited and reversed: the bespoke `kb_predict_*_samples()` split (§1.1, §1.5) and the broom-style `augment()` columns / broom column glossary. The current design provides raw prediction draws through the `rstantools` generics (`posterior_epred`/`posterior_predict`) instead of `_samples()`, uses the house output vocabulary (`term`/`estimate`/`lower`/`upper`; `coef` wraps `tidy`; `bboutools` `glance` columns) rather than broom's, and `augment()` returns `fitted`/`residual`/`lower`/`upper` (no dot prefix). See **`prediction-engine.md`** and **`prediction-engine.md`** for the authoritative surface. The sections below are retained as design history.

------------------------------------------------------------------------

## Stage 1 — API design

### 1.1 Summary-vs-samples output, and where `sig_fig` belongs \[M\]

Every summary/predict function carries `sig_fig = 3` (some `= 5`) and rounds the values in the returned tibble (`signif_cols(coef, sig_fig = sig_fig)`). The first draft of this review called that a smell and recommended dropping `sig_fig`. **That was wrong** and is retracted here.

**`sig_fig` on a summary table is fine — keep it.** The tidyverse "never round returned data" rule guards against destroying the *only* copy of the data. That risk does not exist here: the canonical, full-precision posterior is always separately available via the `_samples()` functions. The summary tibble (`estimate`, `lower`, `upper`) is an explicitly *derived, report-ready view*, and rounding it to a sensible number of significant figures is a reasonable, useful default for a reporting object. So:

- **Functions that return a summary table** (`tidy`, `coef`, the summary `kb_predict_*()`) **carry `sig_fig`** (default `3`, consistent across the family — cf. 1.7). The full-precision data is one call away via `_samples()`.
- **Functions that return samples** (`kb_predict_*_samples()`, `samples()`) **do not take `sig_fig`** — there is nothing to summarise, so rounding is meaningless.

**The one genuine design decision: should `kb_predict_*()` return a summary by default, or always return samples?**

Two coherent designs:

- **(A) Two functions (recommended, bboutools pattern):** `kb_predict_weight()` → summary tibble (carries `conf_level`, `estimate`, `sig_fig`); `kb_predict_weight_samples()` → raw draws. The common "predicted biomass with CIs" case is a single call.
- **(B) Samples-only + always pipe:** `kb_predict_weight()` always returns draws, and the user pipes through `tidy()`/`coef()` (or a summariser) to get a point estimate and CI. Purer and a single source of truth, but it taxes *every* user with a mandatory summarise step and returns a large draws object from the most common call — against the simplicity-for-practitioners philosophy.

**Recommendation: (A).** It keeps the dominant path one call for biologists while still exposing draws as a first-class output. Switching return *shape* is done with a separate function, not a `samples = TRUE` flag (output type-stability; cf. 1.2 — `by`/`uncertainty` are behaviour axes → arguments, summary-vs-draws is a shape change → separate function; brms does the same with `predict()` vs `posterior_predict()`). Implement the default summary as the summariser applied to the draws internally, so there is one codepath and the two functions stay exactly consistent.

Why draws matter regardless of (A)/(B): the derived biomass pipeline multiplies weight × density × area and **cannot** multiply compatibility intervals — it must combine draw-by-draw. Draws are the composition currency; summaries are terminal views. See 1.5 for the draws format.

### 1.2 Combinatorial function proliferation instead of arguments \[H\]

bboutools exposes \~20 `bb_predict_*` functions and \~15 plot functions, including names like `bb_plot_year_trend_calf_cow_ratio()`. The cross-product of {quantity} × {year/trend} × {samples/summary} is encoded in *function names* rather than arguments.

- **Principle:** *Function names* and *Arguments vs functions* — a five-word function name is hard to discover, type, and remember; behaviour that varies along an axis is usually better expressed as an argument than as a new function.
- **Verdict:** The single biggest usability tax in bboutools. It also multiplies the documentation and test surface.
- **kelpbio:** This validates the `by` / `uncertainty` argument design already chosen (see `package-design.md`) — one `kb_predict_weight()` with a `by` axis replaces what bboutools would express as several functions. Hold this line: resist adding `kb_predict_weight_by_site()`-style variants. Keep the `_samples()` suffix split (it returns a genuinely different shape), but express grouping and uncertainty as arguments, never as function-name suffixes.

### 1.3 Boolean flags select model structure \[M\]

`bb_fit_survival(year_trend = FALSE, allow_missing = FALSE, include_uncertain_morts = TRUE, ...)`. `year_trend` changes the *structure* of the model (continuous year effect vs random intercept), and its valid behaviour is entangled with `min_random_year` and `allow_missing` — invalid combinations are caught late, e.g. `` `allow_missing` requires year to be fit as a random effect ``.

- **Principle:** *Enumerate possible options* and *Mutually exclusive arguments* — when an argument selects among named behaviours (especially model structures), prefer a single enum (`arg_match()`) over several booleans whose combinations are constrained. Reject invalid states at the door rather than messaging downstream.
- **Verdict:** A genuine anti-pattern, though softened by the fact that fixed-vs-random is partly data-driven (a deliberate bboutools design choice). The smell is the late constraint-checking across booleans.
- **kelpbio:** Where a structural choice exists, prefer one enum argument (e.g. `family = c("nb", "zinb")` already does this well). Validate combinations at function entry with a clear `cli` error. Avoid stacking booleans whose legal combinations are a subset of the cross-product.

### 1.4 No `arg_match()` / `match.arg()` for enumerable choices \[M\]

bboutools never uses `match.arg()` or `rlang::arg_match()`; choices are encoded as booleans and validated with bespoke `if` logic.

- **Principle:** *Enumerate possible options* — character-vector arguments validated with `rlang::arg_match()` give free validation, self-documenting defaults (first value), and good error messages.
- **kelpbio:** Use `rlang::arg_match()` for `species`, `family`, `uncertainty`, `output_units`, and any future enumerable argument. The default is the first element (already the convention in `package-design.md`, e.g. `uncertainty = c("marginal", "typical")`).

### 1.5 What format should raw draws be returned in? \[M\]

`bb_predict_*_samples()` returns `list(samples = <mcmcarray>, data = <data.frame>)` — an mcmcr array of draws plus the prediction grid.

- **Correction to the first draft of this review (and to `package-design.md`):** I had recommended a "tidy" tibble with one row per draw × prediction. That is wrong for the actual use case. The reason to expose raw draws is so the user can hand them to the established posterior-analysis tooling — **bayesplot, coda, posterior** — and those tools want draws as matrices/arrays with chains and iterations preserved, *not* a long-melted data frame. A one-row-per-draw tibble is awkward for all of them and also heavier to align draw-by-draw in the internal biomass pipeline. bboutools returning an mcmc-style object is the *more* interoperable choice, not the less.
- **Principle:** interoperate with the ecosystem the user already has (the tidyverse "play well with others" stance). The right format here is a standard posterior-draws container, not a bespoke shape.
- **The real decision (open, to make at implementation, not inherited):**
  - **`posterior::draws_*`** — the modern standard underneath bayesplot and the Stan ecosystem; `as_draws_matrix/df/array()` interconvert trivially, coerces to coda, preserves chain/iteration. Natural for an rstan-based package (`posterior::as_draws_array(stanfit)`). Recommended default.
  - **mcmcr** — the Poisson house format bboutools uses; coda-compatible; consistent with the `mcmcr`/`universals` stack kelpbio otherwise mirrors.
  - **plain matrix** (draws × prediction points) — what `bayesplot::ppc_*` consumes directly; simplest, but drops chain structure and needs the grid carried separately.
  - Whichever is chosen, the **prediction grid must travel with the draws** (as the columns'/variables' metadata, an attribute, or bboutools' explicit `list(samples, data)`), so the user can map a draw column back to its site/year/diameter.
- **kelpbio:** Do **not** return a melted per-draw tibble. Return a standard draws object (lean `posterior`, given rstan; mcmcr if house consistency wins) with the grid associated. Defer the final choice to implementation, but rule the tidy-tibble out now. (This supersedes the `*_samples()` description in `package-design.md`, which predates this review.)

### 1.6 Inconsistent object-argument naming \[L–M\]

The fit object is named `survival` / `recruitment` in the `bb_predict_*` wrappers, `object` in the `predict.*` S3 methods, `x` in `tidy`/`augment`/`glance`, and `object` in `summary`/`coef`/`nobs`.

- **Nuance the agents missed:** the `x` vs `object` split is **not** a bboutools defect — it is dictated by the upstream generics (`generics::tidy(x, ...)`, base `summary(object, ...)`, `predict(object, ...)`, `print(x, ...)`). S3 methods must match their generic's first formal. That part is correct and unavoidable.
- **Genuine smell:** the user-facing `bb_predict_survival(survival, ...)` wrapper uses a domain name while its sibling S3 method uses `object`. Two public entry points to the same computation with different first-argument names.
- **Principle:** *Argument names* — consistency across related functions.
- **kelpbio:** For the bespoke `kb_*` functions (not S3 methods), pick one convention for the fit object and apply it everywhere. Recommend `fit` (descriptive, matches `package-design.md` signatures). For S3 methods, match the generic (`x` or `object`) — that is correct and expected. Don't introduce a `kb_predict_weight()` wrapper whose first arg disagrees with `predict.kb_fit_weight()`.

### 1.7 Inconsistent default values across a family \[L\]

`sig_fig` defaults to `3` in most predict functions but `5` in the trend variants.

- **Principle:** *Default values* — defaults should be consistent and predictable across a function family.
- **kelpbio:** Keep shared defaults identical across the `kb_predict_*` family (`conf_level = 0.95`, etc.). Centralise them in an `@inheritParams` donor so they cannot drift. (Moot for `sig_fig`, which 1.1 recommends dropping.)

### 1.8 Validation deferred / incomplete in some entry points \[M\]

`bb_fit_*` and `tidy.*` validate thoroughly with `chk`, but plot methods defer `conf_level`/`estimate` validation to the inner `predict()` call, and the ML fit variants omit some checks present in the Bayesian ones (e.g. `sex_ratio`).

- **Principle:** validate at the boundary; *fail fast* with messages that name the offending argument.
- **kelpbio:** Per the project standard, **every exported function validates all its arguments with `chk` at entry**, even when it delegates internally. No relying on a downstream call to catch a bad `conf_level`. This is a place kelpbio should be stricter than bboutools.

### 1.9 A deprecated argument repeated across many functions; side-effecting deprecation \[L–M\]

`sex_ratio = deprecated()` appears in \~8 predict functions, and in `bb_predict_growth_samples()` the deprecated argument mutates the fit object (`.sex_ratio_bboufit(recruitment) <- sex_ratio`) rather than only warning.

- **Principle:** lifecycle — deprecation paths should warn and pass through, not silently mutate; a single deprecation is easier to reason about than the same one scattered across a family.
- **kelpbio:** New package, so no deprecations yet. When the time comes: use `lifecycle`, keep the deprecation logic in one helper, and never let a deprecated argument cause a side effect beyond the warning.

### 1.10 `estimate = median` (function-valued default) \[L\]

Predict/tidy functions take `estimate = median` — a function passed as the summary statistic.

- **Verdict:** Legitimate and idiomatic (validated with `chk_is(estimate, "function")`). Flexible for sophisticated users.
- **kelpbio:** Fine to keep for parity, but weigh against the audience: biologists may not think to pass a function. Acceptable because the default does the right thing and the argument is ignorable. Keep it out of lead examples (consistent with the simplicity philosophy).

### 1.11 Abbreviated argument names \[L\]

`nthin`, `niters` (no separator, abbreviated).

- **Principle:** *Argument names* — avoid unnecessary abbreviation; prefer readable snake_case.
- **kelpbio:** `package-design.md` already uses `nthin` for parity with the rstan/Stan idiom (`thin`). This is borderline; `nthin` is widely understood in the Stan world. Acceptable, but if introducing new sampler arguments, prefer spelled-out snake_case (`adapt_delta`, not `ad`). Low priority.

### 1.12 Prior specification \[M\]

bboutools takes priors as a **flat named numeric vector** — `priors = c(b0_mu = 3, b0_sd = 10, sAnnual_rate = 1, ...)` — validated to a subset of allowed names, merged with defaults, and passed as nimble constants; `bb_priors_*()` returns the default vector and `model_code(fit)` shows the values substituted into the model.

- **What's good (keep):** a *single* `priors` argument (clean signature), a getter returning editable defaults, partial-override-merged-to-defaults, and `model_code()` transparency.
- **Weaknesses vs best practice:** (1) **stringly-typed, family-invisible** — `c(b0_mu = 3, b0_sd = 10)` reveals neither the distribution family nor that `b0` is the intercept; rstanarm/brms use self-describing prior objects (`normal(0, 2)`). (2) **names leak internal symbols** (`b0`, `bAnnual`, `sMonth`) rather than user concepts. (3) **weak value validation** — no positivity check on SDs/rates; the error surfaces late from nimble.
- **kelpbio (decided):** keep the good bones, fix the rest — a single `priors = NULL` + `kb_priors_*()` getter returning a **named list of self-describing prior objects** (`kb_prior_normal()`, `kb_prior_exponential()`) with **user-facing names** (`intercept`, `sd_site`), **value validation at entry**, **family fixed by the compiled model** (priors-as-data; hyperparameters editable, family-change errors), and resolved priors **recorded in the fit** + shown in `print()`/`glance()` (the `model_code()` analogue, since the Stan source can't show data-passed values). Plus a **`prior_only`** flag (likelihood off) for prior predictive checks — bboutools has no equivalent. See `package-design.md` §Priors and `bayesian-engine.md` §7.

------------------------------------------------------------------------

## Stage 2 — package-level practices

### 2.1 Dependency footprint and `Depends` \[M\]

21 external dependencies (19 Imports + `Depends: nimble, nimbleQuad`). Putting `nimble` in `Depends` attaches it to the search path, which NEWS records as a recurring source of user error.

- **Principle:** *R Packages* (2e) §Dependencies — minimise dependencies; use `Imports`, reserve `Depends` for the rare case a package must be attached.
- **kelpbio:** Keep the dependency set lean. The Stan toolchain belongs in `LinkingTo` (StanHeaders, Rcpp, RcppEigen, BH) and `Imports` (rstan, rstantools, methods), **never `Depends`**. Don't force anything onto the user's search path. Audit each Import against whether it earns its place (the simplicity philosophy applies to the dependency graph too).

### 2.2 File layout: feature-grouped, with one catch-all \[M\]

R/ groups by feature (`fit-*.R`, `predict-*.R`, `plot-year-*.R`) plus `utils.R`, `getters.R`.

- **Context:** *R Packages* (2e) does not *mandate* one-function-per-file — feature-grouping is permitted — but it names one-function-per-file (file named after the function) as the recommended default, and `usethis::use_r()`/`use_test()` are built around it.
- **kelpbio decision — adopt the stricter one-function-per-file convention:**
  - Each exported function lives in its own file named after it: `kb_fit_weight()` → `R/kb_fit_weight.R`, `kb_predict_weight()` → `R/kb_predict_weight.R`, `kb_priors_weight()` → `R/kb_priors_weight.R`.
  - **S3 methods are grouped one file per generic**, named after the generic: `R/print.R`, `R/tidy.R`, `R/glance.R`, `R/augment.R`, `R/coef.R`, `R/predict.R`. Each such file holds the generic re-export (where applicable) plus all of its methods across subclasses (`print.kb_fit`, `print.kb_fit_weight`, …). Mirrored 1:1 by `tests/testthat/test-print.R`, etc.
  - Internal helpers live in the file of the function that uses them, or in a clearly-named helper file (`R/utils-stan.R`), never an undifferentiated `utils.R`.
  - Rationale: trivial navigation (function name = file name), and it makes the 1:1 test correspondence in 2.5 unambiguous. The cost (more, smaller files) is acceptable and `usethis` tooling assumes it.

### 2.3 Examples are all `if (interactive())` \[M\]

Every `@examples` block is wrapped in `if (interactive())`, so examples never execute under `R CMD check`.

- **Principle:** *R Packages* (2e) — examples should run during check (or use `\donttest` for slow ones) so they stay correct; `if (interactive())` makes them untested documentation that can silently rot.
- **Verdict:** A pragmatic choice for bboutools because fitting is slow (nimble compile + MCMC). But it means the examples are never verified.
- **kelpbio:** rstantools pre-compiles the models, and bundled example data is small — but a real fit is still slow. Strategy: make non-fitting examples (`tidy`, `augment`, `kb_predict_*` on the bundled pre-fit `kb_default_weight()`, plots) **runnable** so they are checked; wrap only the genuinely slow `kb_fit_*()` calls in `\donttest{}`. This gives checked examples for most of the surface.

### 2.4 Non-standard `tests/testthat/_problems/` directory \[L\]

A `_problems/` directory holds \~65 extra test files, apparently archived snapshot diffs.

- **Principle:** testthat 3e — review and accept/reject snapshots (`snapshot_accept()`); don't archive broken ones.
- **kelpbio:** Don't replicate this. Keep `tests/testthat/` clean; resolve snapshots rather than parking them.

### 2.5 Test structure and snapshots \[+\]

Tests broadly mirror R/ files (but not 1:1 — 39 test files for 50 R files); testthat 3e; `_snaps/` snapshot tests for print/plot output; high test-line ratio.

- **kelpbio decision — strict 1:1 correspondence:** every `R/<name>.R` has a `tests/testthat/test-<name>.R` with the same base name (`R/kb_fit_weight.R` → `tests/testthat/test-kb_fit_weight.R`). This is the natural consequence of the one-function-per-file rule in 2.2 and the `usethis::use_r()`/`use_test()` workflow, and it removes any ambiguity about where a function's tests live. No orphan test files, no untested R files.
- Keep testthat 3e; snapshot-test `print` methods and plots (vdiffr, or `save_png` + snapshot). Resolve snapshots, never archive them (see 2.4).

### 2.6 roxygen2 quality \[+\] with two gaps

Strong: markdown enabled, `@inheritParams params` used widely (excellent DRY), `@family` for navigation, `@return` everywhere.

- **Gaps:** `@seealso` is sparse (5 files), and the `_PACKAGE` doc is bare (`@keywords internal "_PACKAGE"` with no overview).
- **kelpbio:** Adopt the `@inheritParams` donor pattern (a `params.R` with a dummy `params` function documenting shared arguments — `data`, `fit`, `by`, `uncertainty`, `conf_level`, `species`). Do better than bboutools on cross-linking: use `@seealso`/`@family` to tie `kb_predict_*` ↔ `kb_plot_*` ↔ `augment`, and write a real package-level doc. Put the plain-language `marginal`/`typical` explanation (the outstanding doc obligation) in a `vignette("predictions")` and `@inheritSection` or `@seealso` it from each predict function rather than duplicating.

### 2.7 No lint/style configuration \[L\]

No `.lintr` or styler config.

- **kelpbio:** Optional, but adding `styler` + a light `.lintr` (or an `air`/lintr CI step) enforces the tidyverse style guide mechanically and keeps reviews focused on substance.

### 2.8 README / NEWS / pkgdown / vignettes \[+\]

README generated from `.Rmd` with badges and a worked example; structured `NEWS.md` (fledge-automated); pkgdown site with a reference index organised by topic and separate methods/priors/extensions articles.

- **kelpbio:** Replicate all of it. In particular, the pkgdown reference grouped by topic (Fitting / Predictions / Plotting / Diagnostics) and a methods article are exactly right for a client-facing analytical package. Keep `Authors@R` with ORCIDs.

------------------------------------------------------------------------

## What to copy verbatim

- S3 class-vector pattern: `class(fit) <- c("kb_fit_weight", "kb_fit")`, `$`-access, methods dispatching to the parent.
- `@inheritParams params` donor for shared argument docs.
- testthat 3e + snapshot tests for print/plot.
- fledge-style structured `NEWS.md`; generated README.Rmd; pkgdown with topic-grouped reference and method articles.
- `chk` for validation, `cli` for messages, `lifecycle` for deprecation, `generics` for tidy/glance/augment.
- `Authors@R` + ORCIDs; Apache-2.0 with per-file copyright headers.

## Where kelpbio should consciously diverge

| \# | bboutools | kelpbio | Why |
|---------------|------------------------|-------------------|---------------|
| 1.1 | `sig_fig` on every predict/summary fn | keep `sig_fig` on summary-returning fns (`tidy`/`coef`/summary `kb_predict_*`); omit it from `_samples()` | Summary is a report-ready view; full precision is available via `_samples()`, so rounding the view is fine |
| 1.1 | summary vs samples split | summary-by-default + first-class `_samples()` sibling (not samples-only) | One call for the common case; shape change is a separate function, not a flag |
| — | `augment()` returns data unchanged | real broom `augment()`: data + `.fitted`/`.resid` (+ `.lower`/`.upper`), full precision | Genuinely useful for residual/PPC diagnostics; a gap in bboutools |
| 1.2 | plot generics dispatch on fit *and* data.frame; one plot fn per quantity/dimension | plot fns take prediction/diagnostic data frames only (pipe-based), never fits; one `kb_plot_predictions()` (ribbon/pointrange, auto-facet) | Separation of concerns; no re-exposing predict args on plots; collapses the plot proliferation; PPC/MCMC defer to bayesplot on draws |
| 1.12 | priors = flat named numeric vector (`b0_mu`…), family invisible, weak validation; no prior-only mode | `priors` = named list of self-describing prior objects (user-facing names, family visible/fixed, validated); `prior_only` flag for prior predictive | Legible priors for review; validate at entry; prior predictive checks calibrate the load-bearing SD priors |
| 1.5 | `_samples()` returns `list(mcmcarray, data)` | standard draws object (posterior / mcmcr) + grid; NOT a melted tibble | Interop with bayesplot/coda/posterior; preserves chains; matrix-aligned for the pipeline |
| 1.2 | \~35 predict/plot functions by name | arguments (`by`, `uncertainty`) over function proliferation | Discoverability; smaller surface |
| 1.3/1.4 | boolean flags + bespoke `if` checks; data-driven fixed/random auto-switch (`min_random_year`) | no RE-structure argument at all — each model always fits its full validated RE set; few-level groupings handled by a regularising SD prior (+ informational message), never fixed effects or auto-drop | Validated models, not user model-building; reproducible by inspection; empirically REs don't shift other coefs, so no benefit to dropping |
| 1.6 | wrapper first-arg name ≠ S3 method | one convention (`fit`) for `kb_*`; match generics for methods | Consistency across entry points |
| 1.8 | validation sometimes deferred | every exported function validates all args at entry | Fail fast |
| 2.1 | `Depends: nimble` on search path | Stan deps in `LinkingTo`/`Imports`, nothing in `Depends` | Don't pollute the user's search path |
| 2.2/2.5 | feature-grouped files; ~39 tests for 50 R files | one function per file (named after it); strict 1:1 `test-<name>.R` | Trivial navigation; unambiguous test location |
| 2.3 | all examples `if (interactive())` | runnable examples on pre-fit model; `\donttest{}` only for slow fits | Checked, non-rotting examples |
| 2.4 | `_problems/` snapshot archive | resolve snapshots; keep test dir clean | Standard testthat workflow |

------------------------------------------------------------------------

*Method: full read of bboutools `R/`, `DESCRIPTION`, `NAMESPACE`, `tests/`, `vignettes/`, README and config, June 2026, against design.tidyverse.org and R Packages (2e). Findings reflect the source as read; bboutools is under active development and may have moved on.*