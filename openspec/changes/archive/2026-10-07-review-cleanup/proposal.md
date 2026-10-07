## Why

A review pass over the whole package found two behaviours to change. The
site:year aliasing warning checks only one direction: it warns when no site spans
several years, but not when every year has a single site, where the site:year
effect is equally inseparable from the year effect. And the prediction verbs
still carry a guard that redirects a `by` argument to `kb_new_data()`, written
for users of an earlier interface that was never released.

## What Changes

- The site:year aliasing warning also fires when no year had more than one site
  sampled, and names the main effect (site, year, or both) the site:year effect
  cannot be separated from. Pinned by `tests/testthat/_snaps/site_year_structure.md`.
- The `by` redirection is removed from `kb_predict_weight()`, `kb_predict_size()`,
  `kb_predict_density()`, and `kb_predict_cover_biomass()`. A `by` argument now
  fails the empty-dots check, and a character `new_data` fails the data-frame
  check, as for any other misplaced argument.

## Non-goals

- No change to when the site:year effect is fitted or omitted.
- No change to the models, priors, or predictions.
