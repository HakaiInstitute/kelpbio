## Why

kelpbio bundled the real Hakai survey data (`data_weight_hakai_nereo`) and a fit
named `fit_weight_hakai_nereo` that was actually fit to the *simulated* downsample.
The name misled users into expecting the real fitted Hakai model (it exposes
`site1`..`site6`, not the real sites). An inference-grade Hakai fit is large (the
stored `log_lik`/`yrep` scale with the number of observations) and, together with the
confidential client data, belongs in a separate companion data package, not the
public code package.

## What Changes

- Rename the bundled example fit `fit_weight_hakai_nereo` -> `fit_weight_sim_nereo`
  (it is, and always was, a fit to the simulated data; only the name was wrong).
- Remove the real `data_weight_hakai_nereo` from kelpbio. The real data and an
  inference-grade fit move to a companion data package (`kelpbiodata`), set up
  separately.
- kelpbio bundles only simulated data (`data_weight_sim_nereo`) and the slim
  simulated fit (`fit_weight_sim_nereo`), for examples and tests.
- Repoint every example, both demo scripts, the vignette, and tests to the
  simulated objects.

## Capabilities

### Modified Capabilities
- `data`: the bundled-data contract now ships only a simulated dataset and a
  simulated fit; the real Hakai data and an inference-grade fit are not bundled here.

## Impact

- Removed: `R/data_weight_hakai_nereo.R`, `man/data_weight_hakai_nereo.Rd`,
  `data/data_weight_hakai_nereo.rda`, `data-raw/data_weight_hakai_nereo.R`,
  `tests/testthat/test-data_weight_hakai_nereo.R`.
- Renamed to `*_sim_nereo`: the fit object `.rda` (re-saved, not refit), its R doc,
  man page, data-raw script, and test file.
- Repointed: the ~20 generic `@examples`, `scripts/demo-api-test.R`,
  `scripts/demo-weight-client.R`, `vignettes/kelpbio.Rmd`.
- No Stan/model change; no change to fit or prediction logic.

## Out of Scope

- Setting up the `kelpbiodata` companion package.
- Building a genuine inference-grade Hakai fit (lives in `kelpbiodata`).
