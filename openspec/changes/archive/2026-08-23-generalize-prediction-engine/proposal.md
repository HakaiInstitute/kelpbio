## Why

`generalize-fit-generics` lifted the public methods to `kb_fit` so a sub-model
registers methods rather than public methods. It left one thing behind, and said
so in its own non-goals: the curve machinery stays weight-named, and
`validate_by_weight()` branches on `meta$species` by string, "which contradicts
`decisions/species-as-variant.md` and should be fixed when a second model needs
the curve path".

Density and size both need the curve path. They also need two things the engine
has never had: a constructor that is not weight-specific, and an offset, because
density is a rate (counts over a surveyed area) rather than a per-plant
measurement.

Doing this first keeps the density change from mixing a refactor of working
weight code with new-model work, so a regression in the weight paths stays
isolated and provable.

## What Changes

- `summarise_weight_predictions()` becomes `summarise_predictions()` in its own
  file, taking the response and predictor names from `meta` instead of the
  hard-coded `"weight"` and `%||% "diameter"`.
- `validate_by_weight(by, species)` becomes `validate_by(fit, by)` plus a
  `.chk_by()` internal generic. The shared membership check stays in the
  function; which *combinations* a fit offers is decided by dispatch. This
  removes the last `meta$species` string branch in the package.
- `build_by_grid()` moves to its own file and tolerates a fit with no continuous
  predictor, and a fit with neither predictor nor grouping, so one builder serves
  a curve model, a grouped-points model and an intercept-only model.
- `weight_by_linpred()` becomes `by_linpred()`, model-agnostic.
- `new_kb_fit_weight()` becomes `new_kb_fit()`, taking `model` and `species` to
  build the three class tiers.
- New `.offset()` internal generic: the log-scale offset of a rate model. Weight
  returns `0`, so it is live but inert here. Threaded through `.linpred_obs()`
  and `data_linpred()` via an `offset` argument.
- `fit_stan()` wraps its `rstan::get_stancode()` capture in `as.character()`.

## Capabilities

### Modified Capabilities

- `dispatch-errors`: `.offset` and `.chk_by` join the enumerated internal
  generics, and the one deliberate total default is named.

No other capability changes: this change is behaviour-preserving, and the offset
becomes observable only when a model carries one.

## Decisions

**`.chk_by()` rather than a `.valid_by()` returning the allowed combinations.**
Returning data and generating the message centrally would have been tidier, but
the *Nereocystis* year-alone rejection carries a three-line explanation of why
year enters only through the interaction, and that message is pinned by a test.
Making it data rather than code would either flatten the message or push a
message template into the generic. The rule is one line per model; the message is
worth keeping verbatim.

**`.offset()` is a generic with a terminal-abort default, not a helper returning
`0`.** A default of `0` would be correct for five of the six sub-models, which is
exactly what makes it dangerous: a density model whose method was never written
would silently report a rate as though it were a count. The one-line weight
method is a cheap price for that.

**The offset is applied to the `rvar`, not the draws matrix.** A
length-`nrow(grid)` vector added to a `D x N` matrix recycles down columns and
silently gives the wrong answer, which `decisions/prediction-engine.md` names as
the reason the engine uses `rvar` at all. Adding it inside `.linpred_obs()` and
`data_linpred()`, while the linear predictor is still an `rvar` over grid rows,
makes the broadcast elementwise by construction.

**`.linpred()` stays offset-free.** The mean has one definition per model; the
offset is a property of the grid, not of the mean.

**The model is not stored in `meta`.** The class already carries it, and a second
copy could disagree. This also leaves the existing fixtures and bundled fits
valid, so no rebuild is needed.

## Non-goals

- No new sub-model, no Stan changes, and no behaviour change.
- The density-versus-count reporting rule (prediction verbs report the rate, the
  base-R and `rstantools` generics report the response as modelled) is stated in
  `decisions/prediction-engine.md` but not yet in the `predictions` spec: it is
  unobservable until a model carries an offset, so it lands with `add-density`.
- `kb_predictions` still assumes a non-`NULL` predictor attribute. `build_by_grid()`
  handles a predictor-free fit, but the plotting path does not yet, and cannot be
  tested until a predictor-free model exists. `add-density` picks it up.
- `summarise_predictions()` takes the predictor and response names from `meta`.
  That holds only while the data column and the reported quantity coincide, which
  is true for weight and false for density and the size distribution. The
  mechanism is decided but not implemented here; see "Deferred" in `design.md`.

## Impact

- Code: `R/summarise_predictions.R`, `R/by_linpred.R`, `R/validate_by.R`,
  `R/build_by_grid.R`, `R/new_kb_fit.R`, `R/offset.R` (new);
  `R/kb_predict_weight.R`, `R/kb_predict_weight_by.R`, `R/linpred.R`,
  `R/fit_stan.R`, `R/kb_fit_weight_{nereo,macro}.R` (modified).
- Generated: `NAMESPACE` gains five method registrations (`.chk_by` x 3,
  `.offset` x 2).
- `DESCRIPTION`: `dplyr (>= 1.1.0)`, which `cross_join()` already required
  unversioned.
- Tests: new `test-summarise_predictions.R`, `test-by_linpred.R`,
  `test-validate_by.R`, `test-build_by_grid.R`, `test-new_kb_fit.R`,
  `test-offset.R`; the moved-function tests leave `test-kb_predict_weight_by.R`;
  `test-abort.R` gains the internal-generic discovery test that
  `4d3e374`'s message described but did not add.
- Docs: `decisions/prediction-engine.md` (the `newdata::xnew_data` grid claim was
  never implemented; the offset is recorded), `decisions/architecture.md`,
  `CLAUDE.md`, `openspec/config.yaml` (`rhat = 1.05` disagreed with the code's
  `1.01`).
- No behaviour change: 47 quantities over both weight fixtures are equal at
  `tolerance = 0` against the pre-refactor build. See `design.md`.
