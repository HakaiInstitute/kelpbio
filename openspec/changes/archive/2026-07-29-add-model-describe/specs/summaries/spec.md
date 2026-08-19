## MODIFIED Requirements

### Requirement: Summary and print methods

`summary(x)` SHALL return a classed `summary_kb_fit` object collecting fit-level metadata and a per-term posterior summary table (with its own `print` method), laid out as a fit-metadata header, a coefficient table, and a diagnostics footer. `print(x)` and the summary object SHALL render the same fit-metadata header from a single shared renderer, so the two cannot diverge. The header SHALL be a per-fit glance and SHALL NOT include the model's likelihood family or its fixed- and random-effect structure; that structure is fixed by species and is rendered instead by `kb_model_describe()`. The header SHALL comprise the model and species, the predictor centering reference, the observation and group counts, the sampler configuration, the convergence verdict, a prior-only note when applicable, and a footer pointing to `kb_model_describe(fit)`. The group counts in the data line convey the grouping factors and their level counts (and thereby whether the `site:year` effect was retained), so the grouping structure remains visible without a dedicated random-effects line. `print(x)` SHALL display only that header, without embedding raw MCMC numbers, so it is snapshot-testable.

The `summary_kb_fit` coefficient table SHALL carry columns `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, with the diagnostic columns taken from the stored fit diagnostics (the same source as `converged()`/`glance()`). It SHALL show population-level terms and random-effect SDs, including the per-level group deviations only when `include_random_effects = TRUE` (default `FALSE`, matching `tidy()`). Its `print` method SHALL render the shared header, the coefficient table, and a diagnostics footer defining the columns and reporting the divergent-transition count.

#### Scenario: print shows stable metadata
- **WHEN** `print(fit)` is called
- **THEN** it shows the shared per-fit header (model, species, centering reference, observation and group counts, sampler configuration, convergence, and a pointer to `kb_model_describe()`), with no likelihood-family or fixed/random-structure lines, no coefficient table, and no raw MCMC numerics, identical to the header shown by `print(summary(fit))`

#### Scenario: summary returns metadata and a diagnostic table
- **WHEN** `summary(fit)` is called
- **THEN** it returns a `summary_kb_fit` object carrying the per-fit header metadata (model, species, centering, observation and group counts, sampler draws, convergence) and a `coefficients` tibble with columns `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, whose `print` method renders the header, table, and diagnostics footer

#### Scenario: summary omits group-level deviations by default
- **WHEN** `summary(fit)` is called
- **THEN** the per-level deviations (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`) are omitted and the random-effect SDs are retained; `summary(fit, include_random_effects = TRUE)` adds the per-level rows

#### Scenario: Macro header reports the Gamma family and macro structure
- **WHEN** the *Macrocystis* Gamma family and effect structure are needed
- **THEN** they are reported by `kb_model_describe(macro_fit)`, not the `print()` header; the header shows the slim per-fit metadata, with the grouping still visible through the data-line group counts (`site`, `year`, `site:year`)
