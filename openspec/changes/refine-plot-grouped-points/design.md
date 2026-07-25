## Context

`kb_plot_predictions()` chose its geom from the x-column type and defaulted `x` to the predictor. With the only implemented model (weight) the predictor is always the numeric `diameter`, so pointrange was an unreachable default and a grouping factor could never reach the x-axis. The reference-diameter-by-site plot a user wanted is geometrically identical to the default density/size plot (one estimate per group, group on the x-axis), so the fix is a single general rule, not a weight special-case.

## Goals / Non-Goals

**Goals:** a ribbon only for a real generated curve; grouped points (pointrange) for held/absent predictors and scattered supplied rows; the grouping factor on the x-axis when there is no curve; faceting that never duplicates the x variable; one rule set that also covers the future density/size models.

**Non-Goals:** no change to `kb_predict_weight_by()` (scalar `diameter` already works); no new geoms beyond ribbon/pointrange; density/size models remain unimplemented.

## Decisions

- **Record curve-ness in metadata, not data shape.** Scattered `kb_predict_weight()` rows and a `kb_predict_weight_by()` grid both have a varying numeric predictor, so the data cannot distinguish them. A `kb_curve` flag is set at construction (TRUE by `_by`, FALSE by the row-wise verb). The geom is then `kb_curve && predictor_varies` → ribbon, else pointrange.
- **Attribute, not S3 subclass.** Curve-vs-points was considered as `kb_predictions` subclasses dispatched on by a generic `kb_plot_predictions()`, and rejected: the render logic does not partition by the distinction (facet inference, `max_facets`, the observed overlay, axis labels, and the x-default are all shared, so dispatch needs a generic + two methods + a shared helper for the common ~90%); a held-constant `_by` curve renders as points anyway, so a subclass would still branch internally; and `kb_predictions` already carries all its plotting metadata (`kb_predictor`, `kb_group_vars`, `kb_response`, units) as attributes, so `kb_curve` belongs with them. Mirrors `ggplot2::autoplot`, which stays one entry point and chooses layers from the object internally. Subclassing would be right only if render paths genuinely diverged or external models needed to add render types.
- **Drop `style` and `facet` entirely.** Style is fully determined by curve-vs-points, so a user-facing argument only invites contradicting the data shape. `facet` is redundant with `x`: the function has only two variable slots (x-axis and facet) and no colour/group aesthetic, so once `x` is chosen the faceting is fixed (`setdiff(group_vars, x)`). The only unique thing `facet` offered was disabling faceting, which is not useful without a colour aesthetic to distinguish overlaid groups. `x` is the single layout knob. (A colour/overlay aesthetic, if wanted later, is a separate, deliberate addition.)
- **Last grouping factor on the x-axis** for grouped points with multiple factors (`c("site", "year")` → year on x, facet by site), generalising to `x = last(group_vars)`, `facet = the rest`.

## Risks / Trade-offs

- [Breaking, pre-1.0 on R-universe] → land the signature change without a deprecation cycle; tests pin the new shapes.
- [`kb_curve` default FALSE] → any future constructor that forgets to opt in renders as points; chosen as the safe default (no spurious connecting line).
