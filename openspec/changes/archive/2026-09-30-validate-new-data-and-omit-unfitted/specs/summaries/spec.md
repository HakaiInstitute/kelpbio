## ADDED Requirements

### Requirement: Draws, accessors, and convergence cover only estimated effects

`samples()`, `rhat()`, `esr()`, `estimates()`, `npars()`, `nterms()`, `pars()`, `glance()`, and `converged()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, and its diagnostics SHALL NOT affect the convergence verdict.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `samples(fit)` is called on a fit that omitted the density or site:year effect
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `converged()` is unaffected
