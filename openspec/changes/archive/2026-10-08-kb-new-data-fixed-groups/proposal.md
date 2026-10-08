## Why

`kb_new_data()` takes grouping factors only through `by`, which gives every
fitted level. A grid for every site in one year, or one site across chosen
years, could only be built by adding the column by hand.

## What Changes

- `kb_new_data()`'s `...` also takes levels of `site` and `year` not named in
  `by`, crossed with the rest of the grid. A level the fit has not seen, such
  as a future year, is accepted and resolved at prediction by `new_levels`.
- Naming a factor in both `by` and `...`, or an unknown name in `...`, errors
  with the columns the grid can take.

## Non-goals

- No change to `by`, the predictor sequence, or how predictions resolve levels.
