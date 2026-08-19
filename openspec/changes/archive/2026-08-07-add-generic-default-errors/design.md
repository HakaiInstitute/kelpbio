## Context

kelpbio defines five generics of its own: `kb_model_describe()`, `kb_stancode()`,
`kb_predict_weight()`, `kb_predict_weight_by()`, and `samples()`. Two dispatch on
`kb_fit` (`kb_stancode`, `samples`); three dispatch on the species subclasses
`kb_fit_weight_nereo` / `kb_fit_weight_macro`. None has a `.default` method, so an
unsupported object produces base R's dispatch failure rather than a `cli` message.

The header comment in `R/chk.R` records the existing convention: a fit is checked
with `.chk_kb_fit()` at the head of every function that takes one, "since S3
dispatch alone does not catch a non-fit passed in directly". That covers the case
where dispatch succeeds. It cannot cover the case where dispatch itself fails,
which is what this change addresses.

`R/chk.R` already contains `.chk_wrong_predictor(fit, ..., call = rlang::caller_env())`,
so passing an explicit `call` through an internal helper is an established pattern
in this package.

## Goals / Non-Goals

**Goals:**

- One branded, argument-named error for every dispatch failure on a kelpbio-owned
  generic.
- Identical message text whether a wrong-class object is caught by dispatch or by
  a method's entry validation, so the two paths cannot drift apart.
- The reported call is the generic as the user wrote it, not the `.default` method.

**Non-Goals:**

- External and internal generics, as set out in the proposal's Non-goals.
- Any change to entry validation inside existing methods.

## Decisions

### Reuse the existing validators for message text

`.default` calls `.chk_kb_fit()` (for `kb_stancode`, `samples`) or
`.chk_kb_fit_weight()` (for the three weight generics) rather than composing a new
message. A wrong-class object then reads the same whether dispatch failed or a
method's entry check caught it, and the wording has one home.

Alternative considered: a bespoke message per generic naming the generic itself
("`kb_stancode()` is not defined for <lm>"). Rejected because it duplicates
wording that `.chk_kb_fit()` already owns and, by naming the function rather than
the argument, departs from the chk vocabulary used everywhere else in the package.

### A terminal abort after the validator, not a fallthrough

For the three species-dispatched generics, `.chk_kb_fit_weight()` passing does not
mean a method exists: a `kb_fit_weight` subclass added without its own method would
satisfy the check and then fall off the end of `.default`, returning the fit
invisibly instead of erroring. `.default` therefore ends in an unconditional abort
through a shared helper. This is a correctness requirement, not a defensive extra.

### `.abort_no_method()` in `R/abort.R`

The terminal abort lives in one internal helper in a new `R/abort.R`, mirrored by
`tests/testthat/test-abort.R`.

It is named `.abort_` rather than `.chk_` deliberately. The package convention is
that every bespoke `.chk_<name>()` has a matching pure predicate `.vld_<name>()`;
"a method is registered for this class" is not a validity property of the object,
so there is no honest predicate to pair, and an `.abort_` name keeps the `.vld_` /
`.chk_` contract intact. It is not appended to `R/chk.R` because that file's header
declares it holds checkers paired with `.vld_`.

### Pass `call` so the error points at the generic

`.default` passes `call = rlang::current_env()` to the validator and to
`.abort_no_method()`, so the condition reports `kb_stancode(x)` rather than
`kb_stancode.default(x)`. This requires an optional `call = rlang::caller_env()`
parameter on `.chk_kb_fit()` and `.chk_kb_fit_weight()`. The default reproduces
what `cli::cli_abort()` already infers for the current callers, so existing errors
are unchanged, and `.chk_wrong_predictor()` sets the precedent for the signature.

`current_env()` is correct here, not `caller_env()`, and the distinction was
settled by experiment rather than assumption. `UseMethod()` dispatches without
pushing a frame of its own, so the method's own execution environment carries the
generic call as the user wrote it: passing `current_env()` renders
`Error in kb_stancode(1)`, while `caller_env()` points past it and renders the
condition with no call at all. This holds whether the generic is called at top
level or from inside another function.

### Derive the constructor hint instead of naming constructors

kelpbio will grow a fit function per sub-model per species (size, density, blade
fraction, wet/dry, carbon), so any error message listing constructors in fixed text
is a maintenance liability, and the two existing `.chk_` hints were already
inaccurate: `.chk_kb_fit()` accepts any `kb_fit` but named only the two weight
constructors.

Two mechanisms replace the fixed text. `.abort_no_method()` derives the supported
constructors from the methods registered for the generic it was given, so the hint
follows the method table. This works because a fit subclass is named after its
constructor: `kb_fit_weight_nereo()` returns an object of class
`kb_fit_weight_nereo`, so a method's class is directly usable as the function to
point at. Intersecting the derived classes with the namespace exports drops parent
classes such as `kb_fit`, which no constructor is named after. For the
parent-class checks in `.chk_kb_fit()` and `.chk_kb_fit_weight()`, where no generic
is in hand, the hint names the family by pattern (`kb_fit_*()`,
`kb_fit_weight_*()`) rather than enumerating members.

Alternatives considered. Scanning the exports for `^kb_fit_` was rejected: it
matches `kb_fit_progress()`, which is not a constructor, so it would need an
exclusion list that is itself a thing to maintain. A hand-maintained registry
constant was rejected as still requiring an edit per sub-model, which is the
problem being solved. `utils::.S3methods()` and the namespace's S3 methods table
both return the same answer as the namespace scan; the scan was chosen because it
adds no dependency on `utils`.

### No roxygen topic for the `.default` methods

Each `.default` carries a bare `#' @export` and no documentation, as the previous
`kb_model_describe.default()` did. An S3 method registered through `S3method()`
needs no topic of its own, and a `@rdname` entry would add an error-only path to
the generic's usage section for no reader benefit.

## Risks / Trade-offs

- Adding a `call` parameter to two shared validators touches every method that
  validates a fit → the message text is untouched, and only the attributed call
  moves, from the validator itself to whoever called it, which is the tidyverse
  convention. One existing snapshot changes as a result: `.chk_kb_fit_weight(1)`
  invoked directly at top level now reports a bare `Error:` rather than
  `Error in .chk_kb_fit_weight()`, because at top level there is no caller to
  blame. No user-facing path changes, since the `.chk_` calls inside existing
  methods are only reachable once dispatch has already confirmed the class.
- `samples` is a common name, so kelpbio's generic may mask another package's →
  masking already changes behaviour without a `.default`; the branded message
  naming `kb_fit` and the `kb_fit_*` constructors makes the cause easier to
  recognise than base R's dispatch error, so this improves the failure mode rather
  than worsening it.
- Five near-identical `.default` methods invite drift → they share the validator
  and the abort helper, so each body is two calls and there is no message text to
  keep in step.
