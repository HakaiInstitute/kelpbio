## Why

The Stan ecosystem converts a fitted model to draws with `posterior::as_draws()`
(brms and cmdstanr fits implement it). A kelpbio fit gives its draws only
through `samples()`, so users coming from those packages, and tools that call
`as_draws()` on what they are given, need an extra step.

## What Changes

- `posterior::as_draws(fit)` returns the same draws as `samples(fit)`: a
  `draws_rvars` object holding only the effects the fit estimated.
- Because posterior's conversions fall back to `as_draws()`, `as_draws_df()`,
  `as_draws_array()`, `as_draws_matrix()`, `as_draws_list()`,
  `as_draws_rvars()`, and `summarise_draws()` accept a fit directly.
- The demo scripts use `as_draws()` where they show interoperability with
  posterior and bayesplot.

## Non-goals

- `samples()` is kept unchanged.
- No methods for posterior generics without an `as_draws()` fallback
  (`variables()`, `ndraws()`).
