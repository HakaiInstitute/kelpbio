## MODIFIED Requirements

### Requirement: Omitted effects are not reported

An effect the fit omitted (site:year for single-year data, density when not fitted, or the weight floor of a power-law fit) SHALL NOT appear in `tidy()`, `coef()`, `summary()`, or `kb_model_describe()`, since its draws never met the data.

#### Scenario: An omitted effect is absent
- **WHEN** a fit omitted the site:year, density, or floor term
- **THEN** its terms appear in none of `tidy()`, `summary()`, or `kb_model_describe()`, including under `include_random_effects = TRUE`
