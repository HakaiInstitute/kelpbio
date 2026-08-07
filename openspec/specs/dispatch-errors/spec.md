# dispatch-errors Specification

## Purpose
TBD - created by archiving change add-generic-default-errors. Update Purpose after archive.
## Requirements
### Requirement: Branded error when a kelpbio generic has no method for an object

Every generic kelpbio defines SHALL raise a `cli` error when called on an object it
has no method for, rather than allowing base R's `no applicable method` dispatch
failure to surface. This applies to `kb_model_describe()`, `kb_stancode()`,
`kb_predict_weight()`, `kb_predict_weight_by()`, and `samples()`.

The message SHALL name the offending argument and the class the generic requires,
and SHALL match the message raised when the same object is rejected by a method's
entry validation, so the two paths cannot report a wrong class differently. The
error SHALL be attributed to the generic as the user called it, not to the internal
default method.

The message SHALL direct the reader to the fitting functions without naming any
constructor in fixed text, so that adding a sub-model does not require editing an
error message or this requirement. Where the generic accepts a specific set of
fits, the supported constructors SHALL be derived from the methods registered for
that generic. Where it accepts any fit, the message SHALL refer to the fitting
functions by name pattern rather than enumerating them.

`kb_stancode()` and `samples()` accept any `kb_fit`. `kb_model_describe()`,
`kb_predict_weight()`, and `kb_predict_weight_by()` accept a `kb_fit_weight`.

Generics owned by other packages are out of scope: `tidy()`, `glance()`,
`augment()`, `summary()`, `autoplot()`, `fitted()`, `residuals()`, `predict()`,
`nobs()`, `coef()`, `log_lik()`, `prior_summary()`, the `posterior_*` generics, and
the `universals` generics SHALL NOT be given a default method, because doing so
would capture dispatch for every other package's objects.

#### Scenario: Non-fit object passed to a fit-level generic

- **WHEN** `kb_stancode(1)` or `samples(1)` is called
- **THEN** it errors via `cli` with a message stating the argument must be a `kb_fit` object and referring to the `kb_fit_*()` fitting functions by pattern

#### Scenario: Object that is not a weight fit passed to a weight generic

- **WHEN** `kb_model_describe(x)`, `kb_predict_weight(x)`, or `kb_predict_weight_by(x)` is called on an `x` that does not inherit from `kb_fit_weight`
- **THEN** it errors via `cli` with a message stating the argument must be a `kb_fit_weight` object and referring to the `kb_fit_weight_*()` fitting functions by pattern

#### Scenario: Supported constructors track the registered methods

- **WHEN** a new sub-model registers a method for one of these generics
- **THEN** the constructors named in that generic's error message include it, with no edit to the error text

#### Scenario: Wrong-class error text is identical across both paths

- **WHEN** the same wrong-class object is rejected by dispatch and by a method's entry validation
- **THEN** both report the same message text

#### Scenario: A weight fit with no species method still errors

- **WHEN** a generic is called on an object that inherits from `kb_fit_weight` but matches no registered species method
- **THEN** it errors rather than returning a value, so no call can silently succeed with nothing computed

#### Scenario: The error names the generic the user called

- **WHEN** any of these generics errors on an unsupported object
- **THEN** the condition is attributed to the generic call, not to the default method

