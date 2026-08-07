## Why

Calling one of kelpbio's own generics on an object it has no method for currently
falls through to base R's dispatch failure, for example
`no applicable method for 'kb_stancode' applied to an object of class "c('kb_fit_other', 'kb_fit')"`.
That message exposes the internal class vector, names the generic rather than the
argument, and does not point the reader at the fitting functions. Every kelpbio
function that takes a fit already aborts through `.chk_kb_fit()` and `cli` once
dispatch reaches a method (see the header comment in `R/chk.R`), so the
dispatch-failure path is the one remaining route to an unbranded error.

`kb_model_describe()` briefly shipped a `.default` method with a `cli` message. It
was removed in the `add-model-describe` change so that the generic matched its
siblings, on the understanding that the convention would be settled once, here,
for all of them.

## What Changes

- Add a `.default` method to each generic kelpbio owns: `kb_model_describe()`,
  `kb_stancode()`, `kb_predict_weight()`, `kb_predict_weight_by()`, and
  `samples()`. Each aborts via `cli` with a message naming the argument and the
  class it expected, and directing the reader to the fitting functions.
- Reuse the existing `.chk_kb_fit()` and `.chk_kb_fit_weight()` validators for the
  message wording, so a wrong-class object reports the same text whether it is
  caught by dispatch or by a method's entry validation.
- Stop naming constructors in fixed text. The supported constructors are derived
  from the generic's registered methods, and the parent-class checks refer to the
  fitting functions by name pattern, so adding a sub-model does not require
  editing an error message. This also corrects `.chk_kb_fit()`, which accepts any
  `kb_fit` but named only the two weight constructors.
- Cover the dispatch-failure path in the test suite for each generic, replacing
  the current assertion against base R's `"no applicable method"` text in
  `test-kb_model_describe.R`.

No user-facing function signature, return value, or successful-call behaviour
changes. This is not a breaking change: calls that previously errored still error,
with different message text.

## Capabilities

### New Capabilities

- `dispatch-errors`: the error raised when a generic kelpbio owns is called on an
  object it has no method for. Stated once and applied to every such generic,
  rather than repeated as a scenario in each capability that happens to own one.

### Modified Capabilities

None. No existing requirement states what happens on dispatch failure, so no
current spec statement becomes false.

## Non-goals

- External generics stay untouched. `tidy()`, `glance()`, `augment()`,
  `summary()`, `autoplot()`, `fitted()`, `residuals()`, `predict()`, `nobs()`,
  `coef()`, `log_lik()`, `prior_summary()`, the `posterior_*` generics, and the
  `universals` generics are owned by other packages. A `.default` on any of them
  would capture dispatch for every other package's objects, so their wrong-class
  behaviour is left to the owning package.
- Internal generics (`.weight_linpred()`, `.weight_terms()`, `.weight_deviance()`,
  `.weight_add_noise()`, `.chk_new_data()`, `.fit_descriptor()`) are out of scope.
  They are unexported and only ever reached with an already-validated fit.
  `.fit_descriptor.default()` keeps its silent fallback, which serves a different
  purpose.
- No change to entry validation inside existing methods. The `.chk_` calls at the
  head of each method stay as they are.

## Impact

- Code: `R/kb_model_describe.R`, `R/kb_stancode.R`, `R/kb_predict_weight.R`,
  `R/kb_predict_weight_by.R`, `R/samples.R`. Possibly one shared abort helper.
- Generated: `NAMESPACE` gains five `S3method(<generic>,default)` entries.
- Tests: the five mirrored test files.
- Dependencies: none. `cli`, `chk`, and `rlang` are already imported.
