## Why

`kb_predict_mean_weight()` and `kb_predict_biomass_survey()` take one `representative_site` and require every named site to be fitted in both the weight and the size fit. A reference weight fit (such as the coastwide *Nereocystis* fit) combined with a size fit to a user's own surveys shares no sites, so the argument cannot be used in the case it is most needed: the survey sites are new to the weight fit but fitted in the size fit.

## What Changes

- `representative_site` in `kb_predict_mean_weight()` and `kb_predict_biomass_survey()` also accepts a list named by the verb's fit arguments, `weight` and `size`, each element giving the representative sites for that fit. An element left out or `NULL` follows `new_levels` for that fit.
- A character vector keeps its current meaning: the same sites for every fit with site effects, fitted in each.
- A list that is unnamed, names something other than `weight` or `size`, or names `size` when `size` is a size census errors, naming the problem. Each element is checked against its own fit, and an invalid name errors listing that fit's sites.
- `kb_predict_biomass_canopy()` is unchanged: it takes one fit, so `representative_site` stays a character vector.

## Non-goals

- No per-site mapping (different representative sites for different new sites in one call); separate calls cover that.
- No change to how a representative site's effects are resolved (`openspec/specs/predictions/spec.md`, "Groups are resolved per row").
- No change to the wet/dry and carbon fits, which have no site effects.
- No refit: fits and fixtures are unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: "Derived verbs share their arguments and output" defines the per-fit form; "Mean weight" and "Survey biomass" check each element against its own fit.

## Impact

- `R/kb_predict_mean_weight.R`, `R/kb_predict_biomass_survey.R`, `R/mean_weight_draws.R`, and the validators in `R/vld.R` and `R/chk.R`.
- Roxygen for `representative_site` in the derived verbs (`R/params.R`).
- Tests and error snapshots for the two verbs and the validators.
- kelpbioshiny can offer a weight-only representative site on the Survey biomass page.
