## Why

`samples()` is the one kelpbio export without the `kb_` prefix that is not a
generic owned by another package, so it breaks the naming rule and clashes with
bboutools' `samples()` when both are attached.

## What Changes

- **BREAKING** `samples()` is renamed `kb_samples()`; it still returns
  `posterior::as_draws(fit)`.
- `kb_samples()`, `kb_stancode()`, and `kb_model_describe()` become plain
  functions that check the fit class. Their output and error messages are
  unchanged.

## Non-goals

- No change to `posterior::as_draws()` or to what the draws contain.
