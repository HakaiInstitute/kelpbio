## Why

Fits are classed `c("kb_fit_<model>_<species>", "kb_fit_<model>", "kb_fit")`. Only
the weight model exists; five more sub-models (size, density, blade fraction,
wet/dry, carbon) x two species are coming, and the biomass composition needs all
six.

Eight S3 methods sat on `kb_fit_weight` with `.weight_*` internal generics
dispatching on the species leaf. Under that arrangement every new sub-model would
add its own near-identical public method for each of the eight, duplicating the
entry checks, the zero-observation guard and the `D x N` orientation contract six
times over. The generated-quantities change made it worse by *narrowing* `log_lik`
from `kb_fit` to `kb_fit_weight`.

Goal: **adding a sub-model registers methods, not public methods.**

## What Changes

- Seven public methods lift from `kb_fit_weight` to `kb_fit`: `log_lik`,
  `residuals`, `tidy`, `posterior_predict`, `fitted`, `posterior_epred`,
  `posterior_linpred`. `predict` stays at the model tier.
- The five `.weight_*` internal generics become seven bare-named internal generics
  (`.linpred`, `.epred`, `.log_lik`, `.deviance`, `.add_noise`, `.terms`,
  `.chk_new_data`), each with a terminal-abort `.default`.
- `.epred(fit, lp, expectation = TRUE)` carries the response-scale transform.
- `.weight_linpred_obs` / `weight_data_linpred` become `.linpred_obs` /
  `data_linpred`, both model-agnostic.
- Kernel contracts normalised: first argument `fit` throughout; `.deviance`
  returns `D x N` like `.log_lik` with the reduction moved to `residuals()`;
  `.add_noise` loses its unused `grid` argument.
- `.linpred_obs` now asserts every observed row resolves to a fitted level.
- `.linpred` consolidates into `R/linpred.R` (it was the one internal generic split
  across two per-species files); `.epred` gets `R/epred.R`; the random-effect
  resolvers get `R/re_resolve.R`. Every other internal generic stays in the file of
  the public generic it serves, which is where the codebase already had them.

## Capabilities

### Modified Capabilities

- `predictions`: the generics accept any `kb_fit`; `.linpred` is the internal generic;
  `posterior_epred` and `posterior_linpred(transform = TRUE)` are distinguished.
- `summaries`: `fitted()` no longer claims to return an expectation.
- `website`: the reference index names the lifted topics.

### New Capabilities

- `dispatch-errors`: internal generics abort rather than fall through.

## Decisions

**One response-scale generic with a flag, not two generics.** `rstantools` defines
`posterior_linpred(transform = TRUE)` as the inverse link and `posterior_epred()`
as the expectation; they coincide unless the likelihood is a mixture. Two generics
would mean 12 method registrations, 10 of them identical pairs. `.epred`'s
`expectation` flag names a question every model can answer, so a method ignoring
it is idiomatic S3 rather than a density-specific concept leaking into a
package-wide generic -- and because the flag is in the signature the author is
already writing, a zero-inflated model cannot omit the distinction silently.

**No total defaults on the internal generics.** The public methods now accept any `kb_fit`,
so dispatch no longer rejects a model with no methods; the `.default` is the only
remaining guard and must abort.

**These aborts name only the object's class and the `kb_fit_*()` name pattern.**
One internal generic serves several public verbs, so naming the generic, the
quantity it produces, or its argument would describe something the user never
called, and the constructors carrying one of its methods do not delimit which fits
the package supports. `.abort_no_method()` takes `generic = NULL` for this form
rather than the package carrying a second near-duplicate abort helper.

**`predict` stays at the model tier** -- not because it wraps a model-named verb,
but because `predict.kb_fit` would need one fixed argument list, and the first
sub-model whose verb takes a different knob would force it to bare `...`, losing
`rlang::check_dots_empty()`.

## Non-goals

- The curve machinery (`weight_by_linpred`, `validate_by_weight`, `build_by_grid`,
  `summarise_weight_predictions`) stays weight-named: it serves
  `kb_predict_weight_by()`, which stays model-named. `validate_by_weight` branches
  on `meta$species` by string, which contradicts `decisions/species-as-variant.md`
  and should be fixed when a second model needs the curve path.
- No model-agnostic prediction verb.

## Impact

- Code: `R/linpred.R`, `R/epred.R`, `R/re_resolve.R` (new); the seven public method
  files, each also gaining its internal generic's definition and default;
  `R/abort.R`, `R/chk.R`, `R/vld.R`, `R/params.R`.
- Removed: `R/weight_nereo_linpred.R`, `R/weight_macro_linpred.R`.
- Generated: `NAMESPACE` (seven method registrations move), seven `man/*.Rd`
  renamed, `_pkgdown.yml` seven topics.
- Tests: new `test-linpred.R`, `test-epred.R`, `test-re_resolve.R`; each internal
  generic's default tested in the file mirroring its source;
  `test-fitted.R`, `test-residuals.R`, `test-log_lik.R` corrected where they had
  begun passing for the wrong reason.
- Docs: `decisions/species-as-variant.md`, `decisions/architecture.md`,
  `CLAUDE.md`, `openspec/config.yaml`. CLAUDE.md's one-file-per-generic rule needs
  no amendment: this change brings the layout back into line with it.
- Behaviour changes, all narrow: `tidy()`/`coef()`/`summary()` no longer list
  `sSiteYear` / `bSiteYear` for a fit with `meta$site_year_on = FALSE`, those draws
  being prior-only; `kb_model_describe()` now treats a missing flag as on, matching
  `.linpred()`; and `.abort_no_method()`'s fallback hint is reworded, which moves one
  existing snapshot.
- Otherwise no behaviour change: verified bit-identical output.
