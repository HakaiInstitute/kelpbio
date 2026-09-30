## Why

A code review of the weight-model stack found that prediction accepted invalid
predictor values (negative, zero, missing, or non-numeric diameters; fractional
frond counts) and returned `NA`, a floor-only weight, or a base R error. It also
found that effects the data switched off still appeared in `samples()` and the
accessors, and counted toward `converged()`, though they were sampled from their
priors alone.

## What Changes

- `new_data` predictor values are validated: *Nereocystis* `diameter` numeric,
  greater than 0, no missing values; *Macrocystis* `fronds` a positive whole
  number. Errors name the column.
- `samples()`, `rhat()`, `esr()`, `estimates()`, `npars()`, `nterms()`, `pars()`,
  `glance()`, and `converged()` cover only the effects the fit estimated.

## Capabilities

### Modified Capabilities

- `predictions`: `new_data` predictor validation.
- `summaries`: omitted effects are absent from the draws, accessors, and the
  convergence verdict.

## Non-goals

- Dropping omitted effects from the stored draws (reading through the fitted
  terms works for existing fits without a refit).

## Impact

- `R/vld.R`, `R/chk.R`, `R/samples.R`, `R/accessors.R`, `R/glance.R`,
  `R/converged.R`, two new helpers.
