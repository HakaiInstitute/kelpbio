## MODIFIED Requirements

### Requirement: Omitted effects are not reported

An effect the fit omitted (the weight floor of a power-law fit) SHALL NOT appear in `tidy()`, `coef()`, `summary()`, or `kb_model_describe()`, since its draws never met the data.

#### Scenario: An omitted effect is absent
- **WHEN** a fit omitted the floor term
- **THEN** its terms appear in none of `tidy()`, `summary()`, or `kb_model_describe()`, including under `include_random_effects = TRUE`

### Requirement: Draws, accessors, and convergence cover only estimated effects

`kb_samples()`, `as_draws()`, `nvariables()`, `variables()`, `glance()`, `kb_converged()`, and `kb_sensitivity()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, its diagnostics SHALL NOT affect the convergence verdict, and it SHALL NOT appear in the sensitivity table.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `kb_samples(fit)` or `posterior::as_draws(fit)` is called on a fit that omitted the weight floor
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `kb_converged()` is unaffected

#### Scenario: An omitted effect has no sensitivity row
- **WHEN** `kb_sensitivity(fit)` is called on a fit that omitted the floor effect
- **THEN** the table has no row for that effect or its prior
