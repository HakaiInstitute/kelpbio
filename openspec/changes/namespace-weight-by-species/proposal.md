## Why

kelpbio was built with a `species = "nereocystis"` argument and one
`inst/stan/weight.stan`, on the rule "species enters as data, not a variant".
The validated analysis models contradict that rule: the weight model is
Student-t on a log-diameter quadratic for *Nereocystis* but Gamma on log-fronds
for *Macrocystis* (different response, predictor, likelihood, functional form,
random-effect structure, and parameters). A single function with a `species`
argument would silently change its required data columns, prior set, and
returned parameters by species, which is the mode-argument anti-pattern. Species
belongs as a function/`.stan` variant, not a data argument. See
`decisions/species-as-variant.md`.

## What Changes

- Rename the public weight API to be species-explicit: `kb_fit_weight()` ->
  `kb_fit_weight_nereo()`, `kb_priors_weight()` -> `kb_priors_weight_nereo()`,
  `kb_check_data_weight()` -> `kb_check_data_weight_nereo()`. Drop the `species`
  argument; the species is fixed by the function and recorded in `meta$species`.
- Extract the species- and model-agnostic fitting mechanics into a shared
  internal engine `fit_stan()` (sampler invocation, control merge, warmup/thin
  math, core resolution, draws-to-rvars extraction, generated-quantity split,
  diagnostics). The species wrapper supplies only validation, priors, assembled
  Stan data, the compiled model, and the parameter vector. Add `chk_sampler_args()`.
- Rename `inst/stan/weight.stan` -> `inst/stan/weight_nereo.stan`
  (`stanmodels$weight` -> `stanmodels$weight_nereo`); content unchanged.
- Rename the bundled objects: `data_weight_hakai` -> `data_weight_hakai_nereo`,
  `data_weight_sim` -> `data_weight_sim_nereo`, `fit_weight` ->
  `fit_weight_hakai_nereo`.
- Keep the S3 class model-level (`c("kb_fit_weight", "kb_fit")`); the ~25 methods
  and accessors are unchanged. Species lives in `meta$species`.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `fitting`: the weight fit function is species-explicit and delegates to a
  shared engine.
- `priors`: the default-prior constructor is species-explicit.
- `data`: the bundled datasets and pre-fit model carry the species (and source)
  in their names.
- `stan-engine`: the compiled model is `stanmodels$weight_nereo`.

## Impact

- New `R/fit_stan.R`; `chk_sampler_args()` in `R/chk.R`. Renamed
  `R/kb_fit_weight_nereo.R`, `R/kb_priors_weight_nereo.R`,
  `R/kb_check_data_weight_nereo.R`, `R/assemble_weight_nereo_data.R`,
  `R/weight_nereo_linpred.R`, `R/{data_weight_hakai_nereo,data_weight_sim_nereo,fit_weight_hakai_nereo}.R`.
- `inst/stan/weight_nereo.stan` rename triggers an rstantools recompile
  (`devtools::install()`); `R/stanmodels.R` and `src/stanExports_*` regenerated.
- Bundled `.rda` re-saved under new object names (objects renamed, not re-fit:
  the model is unchanged so existing fits/fixtures stay numerically valid).
- Predict/method layer keeps its names and dispatches on class `kb_fit_weight`;
  internal calls updated to the renamed helpers. No species branching yet.
- Docs/specs/vignette/README/demos and tests/snapshots updated to the new names.

## Non-goals

- No *Macrocystis* model code, `.stan`, datasets, or `meta$species` branching in
  the predict/tidy/residuals layer (added when macro lands).
- The other five models (size, density, blade, wetdry, carbon).
- No change to sampler behaviour, the fit-object contract, or prediction
  semantics; this is a rename plus an internal refactor.
