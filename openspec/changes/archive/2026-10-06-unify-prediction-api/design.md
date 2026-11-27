## Context

The prediction API grew one model at a time around weight, the only model with a
continuous predictor. Each model got a row-wise verb and a `_by` verb, and each
drew the line between them differently:

| Model | `kb_predict_<model>()` | `_by()` |
|---|---|---|
| Weight | at supplied predictor values | curves over a predictor sequence, per group |
| Size | at supplied site/year rows | one value per group (the same estimates) |
| Density | count on a transect of `area_m2` | density per m², per group |
| Wet/dry, carbon | one population value | none |

The defaults for `new_levels` also differed (`"sample"` versus `"average"`). The
engine itself (`decisions/prediction-engine.md`) is unchanged: one `.linpred()`
mean per model, resolved per row.

## Goals / Non-Goals

**Goals:** one meaning for every verb; one way to ask for groups or curves; one
`new_levels` default; less code on the prediction path.

**Non-goals:** generic verbs, `_by` wrappers, paging plots (see `proposal.md`).

## Decisions

### Predict at rows; build the rows separately

Every verb predicts at `new_data`, and `kb_new_data()` builds the grid for groups
and curves. This follows modelr (`data_grid()` then `add_predictions()`) and
tidymodels (`predict(fit, new_data)` returns one row per input row), and the
tidyverse design guide's advice against arguments that cannot be used together.

Alternatives considered:
- One verb per model taking `by` only, with arbitrary rows through
  `posterior_epred()` plus a summariser: the common question, the expected weight of
  each measured plant with limits, would take two calls and an `rstantools`
  generic.
- One verb taking either `new_data` or `by`: one call for both, but mutually
  exclusive arguments guarded only by an error.
- Two verbs everywhere, each with one fixed meaning: fixes the inconsistency but
  keeps twice the verbs, and the row-wise verb stays nearly redundant for size
  and density.

The cost is a second function for group predictions. Each verb's examples show the
same three calls (observed data, `kb_new_data()` by site, own rows), the old `by =`
habit errors with the equivalent call, and most less experienced users reach
predictions through the app, where the call is hidden.

### Remove the `_by` verbs outright

There are no users outside the package's own app, which updates in step, so the
verbs are removed rather than deprecated. Wrappers defined as exactly
`kb_predict_<model>(fit, kb_new_data(fit, by, ...))` can be added later without
breaking code; removing verbs later would break it, so starting without them is
the safer order.

### `kb_new_data()`

Named after the argument it feeds, so the call reads
`kb_predict_size(fit, kb_new_data(fit, by = "site"))`. Alternatives: `kb_grid()`
(shorter, but says nothing about its use) and `kb_data_grid()` (modelr's name).

The species predictor is passed through `...` as a named argument
(`diameter_mm = 20:60`) and checked against the fit's predictor, so the call keeps
the column name the user knows. This replaces species dispatch: `kb_predict_weight_by()`
was the only verb that needed S3 methods, because its predictor argument was named
differently per species. An argument with a fixed name (`values =`) would need no
check but would hide which column is varied.

The grid holds only grouping and predictor columns. Users may add columns (for
example `stipes_m2`) or build their own grid, for example with
`tidyr::expand_grid()`; `kb_new_data()` is a convenience, not a requirement.

### Curves are marked by the grid

`kb_plot_predictions()` cannot tell a curve from the data alone: weight predictions
at the observed data also have a varying predictor, and a line through them would
be meaningless. `kb_new_data()` therefore marks its grid, the verbs carry the mark
into the `kb_predictions` object, and the plot draws a ribbon only for marked
predictions over a varying predictor. The mark is an attribute, kept by dplyr
verbs such as `filter()`. A grid built without `kb_new_data()` is drawn as point
ranges.

### Density is always per m²

The verb's unit does not depend on its input. Letting `area_m2` choose the unit
(counts when present, density when absent) would make `kb_predict_density(fit)`
return counts at the observed data but density at a grid, with the response column
and axis title following the input. Nothing is lost: the expected count is linear
in area, so the expected count on a transect, and its limits, are the per-m² values
times the area. The draw generics keep `area_m2` (default 1 m²), because simulated
counts are not linear in area. An `area_m2` column passed to the verb is ignored
without a message, and the response column (`stipes_m2`, `plants_m2`) states the
unit.

### `"average"` as the `new_levels` default

With a grid that has no `site` column, the typical site is what users usually mean,
and `"average"` makes predictions deterministic without a seed. The tradeoff: a
prediction for a site the fit never saw gets an interval for the typical site, not
one that includes between-site variation; the documentation directs that case to
`new_levels = "sample"`. Alternatives: `"sample"` everywhere (grids would need
`"average"` passed explicitly), or `"sample"` for the draw generics only (brms's
behaviour, but two defaults again).

`kb_predict_plot_biomass()` is the exception and keeps `"sample"`. It takes no
`new_data`: its rows are always particular surveyed site-years, never the typical
site, so a site-year the weight or size fit did not observe needs the interval
for that site-year. Its limits also become each survey's measurement error in a
cover biomass fit, where `"average"` would understate the error of exactly the
site-years that rest on pooling.

### What stays

- Model-named verbs, for legibility at the call site when a pre-fit model is loaded
  (`decisions/prediction-engine.md`).
- `predict()` methods, one-line wrappers giving base R users the expected call.
- `max_facets`, which guards against unreadable plots, including in the app.
- The offset machinery, now used only by the draw generics.

### Internal simplification

- The verbs become plain functions that check the fit class, instead of S3 generics
  with one method and an erroring default. Error messages are unchanged.
- `.epred()` receives only `rvar`s; `posterior_epred()` and `posterior_linpred()`
  convert to a matrix afterwards. This removes the `is_rvar()` branches and the
  rule that method bodies avoid functions such as `plogis()` that do not accept an
  `rvar`.
- The `kb_predictor_units` and `kb_response_units` attributes, which no verb sets,
  are removed with their branches in the plot labels.

## Risks / Trade-offs

- [Group predictions take two calls] → identical examples on every verb page, the
  redirecting error for `by =`, and wrappers can be added later.
- [The new default narrows intervals for unseen sites] → documented on every verb;
  plot biomass, whose rows are specific site-years, keeps `"sample"`.
- [Snapshot and test churn across the prediction suite] → the change is behaviour-
  only at the API surface; the engine and fitted draws are unchanged, so no refit.

## Migration Plan

`decisions/prediction-engine.md` is rewritten: the "Cross-model prediction contract"
and the offset paragraphs describe one verb per model, `kb_new_data()`, density per
m², and the single default. The app's `_by` calls and mocks move to
`kb_new_data()` in kelpbioshiny. The cover biomass branch rebases onto this change.
