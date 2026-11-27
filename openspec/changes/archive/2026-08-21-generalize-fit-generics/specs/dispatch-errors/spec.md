## ADDED Requirements

### Requirement: Internal generics abort rather than fall through

The public method bodies live on `kb_fit` and delegate whatever varies to internal
generics (`.linpred`, `.epred`, `.log_lik`, `.deviance`, `.add_noise`,
`.terms`, `.chk_new_data`). Because those methods accept any `kb_fit`, dispatch no
longer rejects a fit whose model has registered no methods, so each internal generic
SHALL have a `.default` that aborts terminally. None SHALL have a total default
returning a plausible value: a sub-model added without its methods must fail
loudly, not compute a wrong number.

The message SHALL be phrased entirely in terms the caller can see: the class of
the object, and the `kb_fit_*()` name pattern. It SHALL NOT name the internal
generic, the quantity that generic produces, or its argument, and SHALL NOT
enumerate constructors. One internal generic serves several public verbs, so any
name drawn from it describes something the user never called: a reader who called
`residuals()` and is told there is no "linear predictor" cannot tell whether they
made a mistake. The constructors that happen to carry one of its methods likewise
do not delimit which fits the package supports. The message SHALL therefore be
self-contained and unattributed, the calling frame being a shared internal helper
rather than the verb the user called.

#### Scenario: A fit whose model has no methods errors on any verb that needs one

- **WHEN** `log_lik()`, `residuals()`, `fitted()` or `tidy()` is called on a `kb_fit` subclass with no methods registered
- **THEN** it errors rather than returning a value

#### Scenario: The error names only the class and the fit family

- **WHEN** an internal generic's default is reached
- **THEN** the message names the object's class and refers to the `kb_fit_*()` fitting functions by pattern, naming no generic, quantity, argument or individual constructor
