## MODIFIED Requirements

### Requirement: Omitted effects are not reported

An effect the fit omitted (site:year for single-year data, or the weight floor of a power-law fit) SHALL NOT appear in `tidy()`, `coef()`, `summary()`, or `kb_model_describe()`, since its draws never met the data.

#### Scenario: An omitted effect is absent
- **WHEN** a fit omitted the site:year or floor term
- **THEN** its terms appear in none of `tidy()`, `summary()`, or `kb_model_describe()`, including under `include_random_effects = TRUE`

### Requirement: Model description

`kb_model_describe(fit)` SHALL print the fitted model in notation using the package's parameter names (the same terms as `tidy()`), with no Greek letters or R formula syntax, and `kb_model_describe(fit, prose = TRUE)` the same model as a methods paragraph; both SHALL return the lines invisibly. The description SHALL reflect the fit, not the defaults: its stored priors, its predictor reference, and only the effects it fitted. Priors truncated at zero SHALL be marked `T[0, ]`. The content for each model is pinned by `tests/testthat/_snaps/kb_model_describe.md`.

#### Scenario: The description follows the fit
- **WHEN** a fit used custom priors or omitted an effect
- **THEN** the description shows those priors and leaves the omitted effect out

### Requirement: Draws, accessors, and convergence cover only estimated effects

`kb_samples()`, `as_draws()`, `nvariables()`, `variables()`, `glance()`, `kb_converged()`, and `kb_sensitivity()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, its diagnostics SHALL NOT affect the convergence verdict, and it SHALL NOT appear in the sensitivity table.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `kb_samples(fit)` or `posterior::as_draws(fit)` is called on a fit that omitted the site:year effect
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `kb_converged()` is unaffected

#### Scenario: An omitted effect has no sensitivity row
- **WHEN** `kb_sensitivity(fit)` is called on a fit that omitted the floor or site:year effect
- **THEN** the table has no row for that effect or its prior
