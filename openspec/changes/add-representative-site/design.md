## Context

A new site in `new_data` is currently handled by `new_levels`: `"sample"` draws a
fresh effect from `Normal(0, sd)`, `"average"` holds it at zero. Users want a
third option, predicting a new site as if it behaves like one or more known
reference sites. A weight-model site touches three random effects: `bSite`
(intercept), `bSiteDiameter` (slope), and `bSiteYear` (site:year interaction).

## Goals / Non-Goals

**Goals:** let `kb_predict_weight()` (and the `posterior_*` generics) borrow a
reference site's estimated site main effects for new sites, with the reference
site's posterior uncertainty.

**Non-Goals:** no change to the `site:year` interaction handling, no Stan change,
nothing added to `kb_predict_weight_by()`.

## Decisions

**Two complementary arguments, not one overloaded one.** `representative_site`
governs the site main effects (`bSite`, `bSiteDiameter`); `new_levels` governs the
`site:year` interaction and remains the sole control when `representative_site =
NULL`. Because `new_levels` is still needed when `representative_site` is set (for
the interaction), folding both into a single overloaded argument (e.g.
`new_levels` accepting site names) would be wrong, not merely less clean. Two
arguments each with a single, distinct job is the correct tidyverse design here,
and it is backward compatible.

**Engine is the single source.** The behaviour lives in `resolve_re1()` (gains a
`rep_idx` argument): for unknown rows, when `rep_idx` is non-`NULL` it assigns
`rowMeans(draws_of(param)[, rep_idx])` (recycled across the unknown columns)
instead of the `new_levels` draw/zero. `.weight_linpred()` passes `rep_idx`
(computed from `match(representative_site, meta$site_levels)`) to the two
site-level `resolve_re1()` calls only; `resolve_re2()` (site:year) is untouched.
`.weight_linpred_obs()` keeps the default `NULL`, so `fitted()`/`residuals()`/
`augment()` are unaffected.

**Validation is shared.** `.chk_representative_site(fit, representative_site)` in
`R/chk.R` is called at every public entry, so the `cli` error is defined once.

**Surface mirrors `new_levels`.** Exposed on `kb_predict_weight()`,
`predict.kb_fit_weight()`, and `posterior_epred/linpred/predict` (everywhere
`new_levels` already appears), excluding `kb_predict_weight_by()`. Omitting it
from the `posterior_*` generics would leave an asymmetry with `new_levels`; the
engine change makes the extra surface nearly free.

## Risks / Trade-offs

- Borrowed reference effects use the reference site's posterior, so the new-site
  interval is narrower than a calibrated new-site interval. Mitigation: documented
  in `@details`.
- `representative_site` is weight/site-specific. Other (future) sub-models would
  need their own analogue. Acceptable: this change is scoped to the weight model.
