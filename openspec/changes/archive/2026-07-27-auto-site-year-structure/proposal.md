## Why

`kb_fit_weight_nereo()` exposes `site_year_on` as a user toggle for the site:year
random effect. A team discussion and the `scripts/sim-site-year-prior.R` simulation
established that users should not choose the random-effect structure, and that
dropping the site:year effect is catastrophic for prediction to new site-years
whenever the true site:year SD is non-zero (aliased design, true SD 0.5:
elpd_newyear ~ -173 dropped vs ~ -97/-120 kept), while the regularizing prior
handles weak support gracefully. The structure should be determined from the data,
not the user. See `decisions/architecture.md` and `scripts/sim-site-year-prior.R`.

## What Changes

- Remove `site_year_on` from the public `kb_fit_weight_nereo()` signature and docs.
- Determine the site:year effect from the data: included when the data span more
  than one year; omitted when they do not (the interaction is then confounded with
  the site effect); included with a warning when years are present but no site was
  sampled in more than one year (an aliased design where the site vs site:year split
  is not identifiable). The determination is recorded in `meta$site_year_on`.
- Emit a concise `cli` warning on the aliased case and an informational message on
  the omit case (suppressed by `quiet = TRUE`).
- Make predictions consistent with the fitted structure: when the effect was
  omitted, `.weight_nereo_linpred()` adds no site:year variation (previously it
  always added the term, reintroducing the prior-only `bSiteYear` draws).
- The Stan `site_year_on` data flag is unchanged; it is now set internally from the
  data rather than from the user (no Stan recompile).

## Capabilities

### Modified Capabilities
- `fitting`: the site:year effect is data-determined; `site_year_on` is no longer a
  user argument.
- `stan-engine`: document the `site_year_on` data flag that gates the site:year term
  (set internally by the fitting layer).
- `predictions`: predictions respect whether the fit retained the site:year effect.

## Impact

- R: `R/site_year_structure.R` (new), `R/kb_fit_weight_nereo.R`,
  `R/weight_nereo_linpred.R`, `R/params.R`.
- No `inst/stan/` change and no Stan recompile; the bundled `fit_weight_hakai_nereo`
  is not refit (the Hakai data spans years and is not aliased).
- Tests: new `test-site_year_structure.R`; additions to `test-weight_nereo_linpred.R`
  and `test-kb_fit_weight_nereo.R`.
- Docs/demo: `decisions/architecture.md`, `scripts/demo-api-test.R`.

## Out of Scope

- No change to prior families or the site:year prior default.
- No error for `by = c("site", "year")` on single-year fits (graceful degrade).
- Other models and the biomass pipeline.
