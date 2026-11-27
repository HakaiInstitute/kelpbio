## MODIFIED Requirements

### Requirement: Glance and convergence

`glance(x, ..., rhat, esr, max_perc_divergent)` and
`converged(x, ..., rhat, esr, max_perc_divergent)` SHALL report model-level
summaries and a convergence verdict using exposed thresholds. The thresholds
default to `rhat = 1.01`, `esr = 0.1`, and `max_perc_divergent = 0.2`, where `esr`
is the effective sample **rate** (`ess_bulk / ndraws`) and `max_perc_divergent` is
the percentage of saved post-warmup draws that ended in a divergent transition.
All three are arguments so they can be tightened. The divergence comparison is
inclusive (`<=`), so `max_perc_divergent = 0` enforces zero tolerance rather than
being unsatisfiable. `esr` is preferred over an absolute ESS because the rate
is stable under changes to the number of saved iterations. The `rhat` default
follows the 1.01 recommendation of Vehtari et al. (2021), whose rank-normalized
split/folded Rhat is the statistic `posterior::rhat()` computes.

The verdict SHALL require all three conditions: every Rhat below `rhat`, every
effective sample rate above `esr`, and the divergence rate at or below
`max_perc_divergent`. Divergent transitions are included because they indicate the
sampler failed to explore part of the posterior, so the draws may be biased
whatever Rhat and ESS report. Treedepth saturation SHALL NOT enter the verdict (it
is an efficiency concern, not a validity one), and E-BFMI SHALL NOT enter it
either (it is per-chain and in practice co-occurs with divergences); both are
reported instead.

The verdict SHALL require at least one finite Rhat, so a fit whose diagnostics are
entirely missing reports `FALSE` rather than passing on no evidence. An individual
`NA` Rhat SHALL still be skipped, since a legitimately constant parameter must not
fail a fit.

#### Scenario: glance one-row summary
- **WHEN** `glance(fit)` is called
- **THEN** it returns a one-row tibble with columns `n`, `K`, `nchains`, `niters`, `nthin`, `ess`, `rhat`, `perc_divergent`, and `converged`

#### Scenario: glance reports the reportable core only
- **WHEN** `glance(fit)` is called on a fit with treedepth saturation or low E-BFMI
- **THEN** neither appears as a column; they are reported by `print(summary(fit))`, keeping the one-row summary narrow enough for a report table

#### Scenario: converged honours thresholds
- **WHEN** `converged(fit, rhat = 1.01, esr = 0.1, max_perc_divergent = 0.2)` is called
- **THEN** it returns a single logical, `TRUE` only if all Rhat `<` `rhat`, all effective sample rates `>` `esr`, and the divergence rate `<=` `max_perc_divergent`

#### Scenario: A well-mixed fit with divergences does not pass
- **WHEN** `converged(fit)` is called on a fit with acceptable Rhat and ESS whose divergence rate exceeds `max_perc_divergent`
- **THEN** it returns `FALSE`, and `glance(fit)` shows the rate in `perc_divergent` beside `converged = FALSE`

#### Scenario: Zero tolerance is satisfiable
- **WHEN** `converged(fit, max_perc_divergent = 0)` is called on a fit with no divergent transitions
- **THEN** it returns `TRUE`, the comparison being inclusive so that a zero threshold admits a zero rate

#### Scenario: Missing diagnostics do not pass silently
- **WHEN** `converged(fit)` is called on a fit with no finite Rhat
- **THEN** it returns `FALSE`

### Requirement: Summary and print methods

`summary(x)` SHALL return a classed `summary_kb_fit` object collecting fit-level metadata and a per-term posterior summary table (with its own `print` method), laid out as a fit-metadata header, a coefficient table, and a diagnostics footer. `print(x)` and the summary object SHALL render the same fit-metadata header from a single shared renderer, so the two cannot diverge. The header SHALL be a per-fit glance and SHALL NOT include the model's likelihood family or its fixed- and random-effect structure; that structure is fixed by species and is rendered instead by `kb_model_describe()`. The header SHALL comprise the model and species, the predictor and how it enters the model (for the weight models, the geometric-mean value it is centered at), the observation and group counts, the sampler configuration, the convergence verdict, a prior-only note when applicable, and a footer pointing to `kb_model_describe(fit)`. The predictor line SHALL be self-describing (naming the transform in its text rather than relying on its label) and SHALL be omitted for a model with no predictor. The group counts in the data line convey the grouping factors and their level counts (and thereby whether the `site:year` effect was retained), so the grouping structure remains visible without a dedicated random-effects line. `print(x)` SHALL display only that header, without embedding raw MCMC numbers, so it is snapshot-testable.

The `summary_kb_fit` coefficient table SHALL carry columns `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, with the diagnostic columns taken from the stored fit diagnostics (the same source as `converged()`/`glance()`). It SHALL show population-level terms and random-effect SDs, including the per-level group deviations only when `include_random_effects = TRUE` (default `FALSE`, matching `tidy()`). Its `print` method SHALL render the shared header, the coefficient table, and a diagnostics footer defining the columns and reporting the sampler diagnostics: the divergence rate, the treedepth-saturation rate, and the minimum E-BFMI across chains. That footer is the drill-down surface for the two diagnostics `glance()` omits.

#### Scenario: print shows stable metadata
- **WHEN** `print(fit)` is called
- **THEN** it shows the shared per-fit header (model, species, the predictor and its transform, observation and group counts, sampler configuration, convergence, and a pointer to `kb_model_describe()`), with no likelihood-family or fixed/random-structure lines, no coefficient table, and no raw MCMC numerics, identical to the header shown by `print(summary(fit))`

#### Scenario: summary returns metadata and a diagnostic table
- **WHEN** `summary(fit)` is called
- **THEN** it returns a `summary_kb_fit` object carrying the per-fit header metadata (model, species, the predictor and its transform, observation and group counts, sampler draws, convergence) and a `coefficients` tibble with columns `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, whose `print` method renders the header, table, and diagnostics footer

#### Scenario: summary omits group-level deviations by default
- **WHEN** `summary(fit)` is called
- **THEN** the per-level deviations (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`) are omitted and the random-effect SDs are retained; `summary(fit, include_random_effects = TRUE)` adds the per-level rows

#### Scenario: Macro header reports the Gamma family and macro structure
- **WHEN** the *Macrocystis* Gamma family and effect structure are needed
- **THEN** they are reported by `kb_model_describe(macro_fit)`, not the `print()` header; the header shows the slim per-fit metadata, with the grouping still visible through the data-line group counts (`site`, `year`, `site:year`)
