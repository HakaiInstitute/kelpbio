# Design

## Proof that it is a pure refactor

Four functions were renamed and moved, one gained a new argument, the fit
constructor was generalised, and a new internal generic was threaded through both
shared linear-predictor entry points. None of that should change a number.

Verified against the installed pre-refactor build (which predates this branch),
on both weight fixtures, at `tolerance = 0`: **47 of 47 quantities equal**.

| quantity | nereo | macro |
|---|---|---|
| `fitted` | equal | equal |
| `residuals` | equal | equal |
| `log_lik` | equal | equal |
| `nobs` | equal | equal |
| `posterior_epred` (observed) | equal | equal |
| `posterior_epred` (grid) | equal | equal |
| `posterior_epred` (`new_levels = "sample"`, seeded) | equal | equal |
| `posterior_linpred` | equal | equal |
| `posterior_linpred(transform = TRUE)` | equal | equal |
| `posterior_predict` (seeded) | equal | equal |
| `tidy` | equal | equal |
| `tidy(include_random_effects = TRUE)` | equal | equal |
| `coef` | equal | equal |
| `glance` | equal | equal |
| `augment` | equal | equal |
| `kb_predict_weight` (observed) | equal | equal |
| `kb_predict_weight` (grid) | equal | equal |
| `kb_predict_weight` (`representative_site`) | equal | equal |
| `kb_predict_weight_by` (every valid `by`) | equal | equal |
| `kb_predict_weight_by` (`new_levels = "sample"`, seeded) | equal | equal |
| `kb_predictions` attributes | equal | equal |

The two seeded comparisons matter most: `posterior_predict()` and the `"sample"`
paths draw fresh random effects, so equality under a fixed seed shows the number
and order of RNG draws is unchanged, not merely the deterministic arithmetic.

The `kb_predictions` attribute row is the check on `summarise_predictions()`
reading `meta` rather than its former hard-coded `"weight"` and
`%||% "diameter"`: the attributes carried on the result are unchanged for both
species, and the two species genuinely differ in the predictor, so the assertion
bites.

## Two things the implementation found

**The stored `stancode` carried a temp-file name.** `rstan::get_stancode()`
returns the source with a `model_name2` attribute set to the temporary file the
model was compiled from (`filefe2e1d9afd24`). It changes on every compile, so a
rebuilt fit could never be byte-identical to an identical one, and a shipped
object in `data/` carried a path fragment from whichever machine last built it.
`as.character()` on the capture drops it. The stored `rvar` cache environments
still churn bytes on every write, so rebuilds are not yet byte-reproducible; this
removes the only part that was semantically wrong.

**The internal-generic defaults were untested, and one is deliberately total.**
Commit `4d3e374` ("Test the internal-generic defaults once, from the
registrations") removed the same test from seven files, and its message describes
a replacement in `test-abort.R` that discovers the generics from the namespace and
pins the set with `expect_setequal`. That replacement was never added: the commit
touched seven files, none of them `test-abort.R`. The property was left covered
only incidentally, through the four public verbs that happen to reach a default.

The discovery test is added here, since this change adds two generics that should
be covered by it. Written as described, it immediately failed on
`.fit_descriptor`, whose default returns `list(predictor = NA_character_, groups =
integer(0))` rather than aborting.

That is not a bug. `.fit_descriptor` supplies `print()`'s header fields, so a
missing method degrades a display rather than computing a wrong number, and
`decisions/architecture.md` records the `NA` fields as intended. But the
`dispatch-errors` requirement reads as universal ("each internal generic SHALL
have a `.default` that aborts terminally. None SHALL have a total default"), and
enumerates seven generics that do not include `.fit_descriptor`, so the spec was
silent on the case rather than permitting it.

The test therefore pins **two** sets: the generics that must abort, and the ones
allowed a value. A new generic cannot join either silently, because
`expect_setequal` fails until it is classed as one or the other. The spec is
amended to match.

## Why `validate_by()` keeps the message and delegates only the rule

`.chk_by()` decides which combinations of the grouping factors a fit offers;
`validate_by()` keeps the membership check. The split is uneven on purpose. The
membership check produces the same message for every model, so centralising it
removes duplication. The combination rule does not: the *Nereocystis* rejection
explains that year enters only through the site:year interaction and lists the
three available groupings, and that wording is pinned by a test. A
`.valid_by()` returning the allowed combinations would have to either flatten
that message or carry a message template into the generic.

The result is that each model states its rule in one method and the string
`"nereocystis"` no longer appears in any prediction code path.

## Why the offset lands here rather than with the density model

It is inert for weight: `.offset.kb_fit_weight` returns `0`, so both settings of
the new `offset` argument give bit-identical results, which the proof above
covers. Adding it here means `add-density` registers one method and passes
`offset = FALSE` in its two verbs, rather than also changing the shape of the two
shared entry points every existing path runs through.

The alternative was to defer it and let `add-density` do both. Rejected because
the entry-point change is the part that can break the weight paths, and that risk
is worth isolating in a change whose whole claim is that no number moved.

## Deferred: the reported quantity is a property of the verb, not the fit

`summarise_predictions()` takes the predictor and response names from `meta`,
which is what the `fitting` spec requires them to exist for, and what
`build_by_grid()` already does. That is right for weight and wrong from the next
sub-model on, for a reason worth writing down before it is rediscovered.

`kb_response` currently does two jobs. It is the column name used to locate the
response in a user's `observed` data frame for the overlay
(`R/kb_plot_predictions.R:160`), and it is the key into `kb_axis_label()`'s switch
for the axis title (`:174`). For weight the two coincide: column `weight`, label
"Wet weight". They stop coinciding at once:

- **Density.** The data column is `count`; the reported quantity is a rate,
  counts per unit area. `meta$response = "count"` gives the axis title "Count".
  Setting `meta$response = "density"` instead is not available, because the
  `observed` overlay would then look for a column that does not exist.
- **Size distribution.** `kb_predict_size()` and `kb_predict_size_dist()` are two
  verbs on the *same* fit class reporting different quantities: an expected size,
  and a probability density over a size grid.

The second case rules out the obvious alternative of an internal generic on the
fit class. `.prediction_labels.kb_fit_density` would serve density, but nothing
dispatching on `kb_fit_size_macro` can distinguish the two size verbs.

Decided mechanism, to be implemented in `add-density`: `summarise_predictions()`
gains `predictor` and `response` arguments defaulting to `fit$meta$predictor` and
`fit$meta$response`. The verb knows the quantity it reports, so the verb supplies
it; the defaults keep one source for the data column name and leave every weight
call site unchanged. Whether the axis label also needs its own attribute,
separate from the column name, is a `kb_predictions` question for the same change.

Not done here because all three candidate mechanisms are identical for weight, and
this change's claim is that no number moved.
