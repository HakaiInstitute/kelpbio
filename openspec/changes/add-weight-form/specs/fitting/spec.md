## ADDED Requirements

### Requirement: Weight functional form

`kb_fit_weight_nereo()` SHALL take `form`, a string naming the mean function of weight in diameter: `"packard"` (the default), a three-parameter power function with a size-independent weight floor, or `"power"`, a power law with no floor. Both forms SHALL share the likelihood, random effects, optional density effect, and prior list. An invalid `form` SHALL error before sampling, listing the available forms. The fit SHALL record its form, and every prediction, likelihood, and residual SHALL use it.

#### Scenario: The default is the Packard form
- **WHEN** `kb_fit_weight_nereo(data)` is called
- **THEN** the fit uses the three-parameter power function and estimates the weight floor

#### Scenario: A power-law fit has no floor
- **WHEN** `kb_fit_weight_nereo(data, form = "power")` is called
- **THEN** the weight floor is not estimated, and expected weight is proportional to a power of diameter

#### Scenario: An unknown form errors
- **WHEN** `kb_fit_weight_nereo(data, form = "cubic")` is called
- **THEN** it errors before sampling, naming `"packard"` and `"power"`
