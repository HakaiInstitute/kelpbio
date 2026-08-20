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

### Requirement: Summary object and print

The `summary_kb_fit` coefficient table SHALL carry columns `term`, `estimate`,
`lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, with the diagnostic columns taken
from the stored fit diagnostics (the same source as `converged()`/`glance()`). It
SHALL show population-level terms and random-effect SDs, including the per-level
group deviations only when `include_random_effects = TRUE` (default `FALSE`,
matching `tidy()`). Its `print` method SHALL render the shared header, the
coefficient table, and a diagnostics footer defining the columns and reporting the
sampler diagnostics: the divergence rate, the treedepth-saturation rate, and the
minimum E-BFMI across chains. The footer is the drill-down surface for the two
diagnostics `glance()` omits.
