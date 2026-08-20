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
- [ ] 4.4 Re-knit `README.Rmd` after the refit (the `glance()` output gains a column and every number changes) and check `vignettes/kelpbio.Rmd` for the same

## 5. Refit the shipped objects

Blocked on the `gq` removal change: 4 chains x 500 draws was tried and leaves the
demo nereo fit marginal against `rhat < 1.01` on two of three seeds even at
`adapt_delta = 0.999`. Full-length fits are the robust answer and are only
affordable once `gq` is off the stored object. Measurements in the design.

- [x] 5.1 Try 4 chains x 500 draws and measure; record the result in the design
- [x] 5.2 Establish that the package default `adapt_delta = 0.95` is not implicated (full-length defaults give rhat 1.0042, ESS 1171)
- [ ] 5.3 Rebase on the `gq` removal change
- [ ] 5.4 `data-raw/fit_weight_sim_*.R` and `tests/testthat/fixtures/make-fixtures.R`: package defaults (4 chains x 1000 draws). Left untouched by the first commit so it carries no refit
- [ ] 5.5 Run `KELPBIO_REBUILD_FITS=true Rscript scripts/build.R` (Stan MCMC; confirm before starting)
- [ ] 5.6 Confirm all four objects clear `rhat < 1.01` with a margin, and that `data/` is no larger than before

## 6. Tests

- [ ] 6.1 `test-fit_stan.R`: cover `perc_of()` including the empty-denominator `NA`, and assert a fixture's diagnostics carry all five fields
- [ ] 6.2 `test-converged.R`: the divergence gate at, below, and above the threshold; `max_perc_divergent = 0`; the all-`NA` Rhat guard
- [ ] 6.3 `test-glance.R`: the new column name and position, and that `perc_divergent` agrees with the stored diagnostics
- [ ] 6.4 `test-summary.R` / `test-print.R`: re-record the affected snapshots, including the new footer
- [ ] 6.5 Re-record the `kb_plot_predictions` vdiffr snapshot (the plotted predictions change with the refit)
- [ ] 6.6 `test-accessors.R`: the hardcoded `nchains == 2L` follows the refit's chain count

## 7. Verification and completion

- [ ] 7.1 `devtools::test()` green with no orphaned snapshots
- [ ] 7.2 `Rscript scripts/build.R` for the routine document / style / test pass
- [ ] 7.3 Drift check: specs against code, reader docs against code
- [ ] 7.4 Archive the change, syncing the `summaries` and `fitting` deltas
- [ ] 7.5 Open the PR stacked on the `gq` removal change and confirm CI is green
