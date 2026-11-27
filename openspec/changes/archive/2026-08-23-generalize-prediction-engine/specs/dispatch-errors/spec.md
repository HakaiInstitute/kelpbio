## MODIFIED Requirements

### Requirement: Internal generics abort rather than fall through

The public method bodies live on `kb_fit` and delegate whatever varies to internal
generics (`.linpred`, `.epred`, `.log_lik`, `.deviance`, `.add_noise`,
`.terms`, `.chk_new_data`, `.offset`, `.chk_by`). Because those methods accept any
`kb_fit`, dispatch no longer rejects a fit whose model has registered no methods,
so each internal generic SHALL have a `.default` that aborts terminally. None of
them SHALL have a total default returning a plausible value: a sub-model added
without its methods must fail loudly, not compute a wrong number.

An internal generic that supplies only display metadata MAY instead have a total
default, since a missing method there degrades a printout rather than producing a
wrong number. `.fit_descriptor`, which supplies `print()`'s header fields, is the
only such generic, and its default returns absent fields rather than aborting. The
distinction SHALL be enforced by test over the generics discovered from the
namespace, with both sets pinned, so a generic added to neither set fails rather
than being silently admitted to either.

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

#### Scenario: Every internal generic that feeds a number aborts

- **WHEN** each internal generic discovered in the namespace, other than the display-metadata one, is called on a `kb_fit` subclass with no methods registered
- **THEN** it aborts, and the set of such generics is pinned so one added without a default fails the check rather than going uncovered

#### Scenario: A display-metadata generic may return absent fields

- **WHEN** `.fit_descriptor` is reached for a fit whose model has registered no method
- **THEN** it returns absent header fields rather than aborting, so `print()` still renders, and it is the only generic permitted to do so
