No Stan sources change, so no `devtools::install()` checkpoint is needed for the
code work. The refit in section 5 does need the installed package.

## 1. Diagnostics at fit time

- [x] 1.1 Add `perc_of(n, total)` to `R/fit_stan.R`: `NA_real_` for a non-positive denominator, `100 * n / total` otherwise
- [x] 1.2 Add `sampler_diagnostics(stanfit)` to `R/fit_stan.R`, taking the divergence and treedepth counts and the shared denominator from `rstan::get_divergent_iterations()` / `get_max_treedepth_iterations()`, and E-BFMI from `min(rstan::get_bfmi())`
- [x] 1.3 Replace the inline `get_sampler_params()` / `purrr::map_dbl()` divergence count in `fit_stan()` with `sampler_diagnostics()`, keeping `ndivergent` and adding `perc_divergent`, `perc_max_treedepth`, `ebfmi`

## 2. Verdict and report row

- [x] 2.1 `R/converged.R`: add `max_perc_divergent = 0.2`, tighten `rhat` to 1.01, validate both, and require the divergence rate at or below the threshold (inclusive, so `0` is satisfiable)
- [x] 2.2 `R/converged.R`: require at least one finite Rhat, so an all-`NA` diagnostic vector reports `FALSE` rather than passing
- [x] 2.3 `R/glance.R`: add the `perc_divergent` column between `rhat` and `converged`, pass `max_perc_divergent` through to `converged()`, and guard `min`/`max` against an all-`NA` vector
- [x] 2.4 `R/params.R`: add `@param max_perc_divergent`; update `@param rhat` if its wording implies the old default

## 3. Summary and print

- [x] 3.1 `R/summary.R`: carry `perc_divergent`, `perc_max_treedepth`, and `ebfmi` on the `summary_kb_fit` object in place of `ndivergent`
- [x] 3.2 `R/print.R`: replace the divergent-transition count line with the three-diagnostic footer, rounding at the display boundary with `signif(3)`

## 4. Documentation

- [x] 4.1 `converged.kb_fit` roxygen: state the three thresholds and their defaults, note that divergences enter the verdict but treedepth and E-BFMI do not, and note that a rate is over retained draws when `nthin > 1`
- [x] 4.2 `glance.kb_fit` `@return`: document `perc_divergent`
- [x] 4.3 `summary.kb_fit` `@details`: describe the new footer. Also correct the stale claim that the `print` header renders the likelihood family and the fixed/random-effect structure, which it has not since the header was slimmed
- [x] 4.4 Re-knit `README.Rmd` after the refit (the `glance()` output gains a column and every number changes) and check `vignettes/kelpbio.Rmd` for the same

## 5. Refit the shipped objects

Resolved without the `gq` removal. Raising `nthin` multiplies the sampling
iterations while holding the saved draw count fixed, so all four objects clear
the thresholds at their existing sizes. 4 chains x 500 with longer chains was
tried first and left the demo nereo fit marginal on two of three seeds even at
`adapt_delta = 0.999`; measurements in the design.

- [x] 5.1 Try 4 chains x 500 draws and measure; record the result in the design
- [x] 5.2 Establish that the package default `adapt_delta = 0.95` is not implicated (full-length defaults give rhat 1.0042, ESS 1171)
- [x] 5.3 ~~Rebase on the `gq` removal change~~ - not needed, `nthin` removed the dependency
- [x] 5.4 `data-raw/fit_weight_sim_*.R` at 3 chains x 500, `nthin = 2`, `adapt_delta = 0.999`; `make-fixtures.R` at 2 x 300, `nthin = 5`, `adapt_delta = 0.999`
- [x] 5.5 Run `KELPBIO_REBUILD_FITS=true Rscript scripts/build.R`
- [x] 5.6 All four objects clear the thresholds: demo Rhat 1.0052 / 1.0072, fixtures 1.0062 / 1.0068, no divergences except the macro fixture at 0.167% (gate 0.2%). Fixtures unchanged at 1.5 MB; `data/` grew 6.9 -> 11.4 MB with the larger demo draw counts, which the `gq` removal will recover

## 6. Tests

- [x] 6.1 `test-fit_stan.R`: cover `perc_of()` including the empty-denominator `NA`, and assert a fixture's diagnostics carry all five fields
- [x] 6.2 `test-converged.R`: the divergence gate at, below, and above the threshold; `max_perc_divergent = 0`; the all-`NA` Rhat guard
- [x] 6.3 `test-glance.R`: the new column name and position, and that `perc_divergent` agrees with the stored diagnostics
- [x] 6.4 `test-summary.R` / `test-print.R`: re-record the affected snapshots, including the new footer
- [x] 6.5 Re-record the `kb_plot_predictions` vdiffr snapshot (the plotted predictions change with the refit)
- [x] 6.6 `test-accessors.R`: the hardcoded `nchains == 2L` follows the refit's chain count

## 7. Verification and completion

- [x] 7.1 `devtools::test()` green with no orphaned snapshots
- [x] 7.2 `Rscript scripts/build.R` for the routine document / style / test pass
- [x] 7.3 Drift check: specs against code, reader docs against code
- [x] 7.4 Archive the change, syncing the `summaries` and `fitting` deltas
- [x] 7.5 Opened as #9, stacked on `add-generic-default-errors` (the `gq` change is no longer a prerequisite)
