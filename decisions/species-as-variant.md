# Decision: species is a model variant (per-function + per-.stan), not a data argument

Status: accepted (2026-06)

## Context

kelpbio fits six sub-models (weight, size, density, blade, wetdry, carbon) for
two species, *Nereocystis luetkeana* (nereo) and *Macrocystis pyrifera* (macro).
The package began nereo-only with a `species = "nereocystis"` argument and a
single `inst/stan/weight.stan`, on the working assumption (recorded in the old
`config.yaml` rule "Species enters as data, not a variant") that a species is
just a different dataset fed to one shared model.

Inspecting the validated analysis project (`hakai-kelp-biomass-25`) overturns
that assumption. The models differ structurally across species, not just in
data:

- Weight: nereo is Student-t on a quadratic in centred log-diameter with a
  site-slope random effect; macro is Gamma (shape proportional to frond count)
  on a linear function of log-fronds, with no site slope. Different response
  column, predictor column, likelihood family, functional form, random-effect
  structure, and parameter set.
- Size: different predictor (`sbulb_max` vs `fronds_1m`) and likelihood/params.
- Density: same zero-inflated likelihood but different columns (`stipe_count`
  vs `n_plants`).
- wetdry / carbon: structurally identical across species.

A single `kb_fit_weight(data, species)` would force the function's required data
columns, prior set, and returned parameters to branch on `species`. A mode
argument that silently changes a function's input contract and output shape is
the anti-pattern tidyverse design avoids (cf. `map_dbl()`/`map_chr()` over a
type argument). The `family =` analogy to `glm()` does not hold here: `glm()`
keeps one formula+data interface and only swaps the likelihood, whereas here the
interface itself changes.

## Decision

Species is a variant axis, handled uniformly across all six models:

- Each species gets its own public fit function `kb_fit_<model>_<species>()`
  (e.g. `kb_fit_weight_nereo()`), its own `kb_priors_<model>_<species>()` and
  `kb_check_data_<model>_<species>()`, and its own `inst/stan/<model>_<species>.stan`.
- The species-agnostic mechanics (sampler invocation, control merge, warmup/thin
  math, core resolution, draws-to-rvars extraction, generated-quantity split,
  convergence diagnostics) live in one shared internal engine, `fit_stan()`. Each
  species wrapper supplies only what differs: validated data, resolved priors,
  assembled Stan data, the compiled model, and the parameter vector.
- The S3 class stays model-level (`c("kb_fit_<model>", "kb_fit")`), NOT
  per-species, so the method/accessor surface is shared. The species is recorded
  in `meta$species`; prediction, tidy, and residual code branch on `meta$species`
  only where the linear predictor genuinely differs.
- Uniformity wins over local optimisation: even where a model is structurally
  identical across species (wetdry, carbon), the species-suffixed function is
  kept so users learn one rule and `meta$species` is always available for the
  biomass composition (which requires all six fits to share a species).

This reverses the prior "species enters as data, not a variant" rule in
`config.yaml`, updated to match.

## Consequences

- Adding a species is additive: a new `.stan`, a new wrapper, and (where the
  mean differs) a new `.<model>_<species>_linpred()` builder, with no change to
  existing species functions or the shared engine.
- API surface grows from six fit functions to six per species. The cost is
  accepted: the functions have honest, fixed data contracts and match how Hakai
  biologists think ("I have nereo data" / "I have macro data").
- `kb_predict_biomass()` validates that the six fits it composes share
  `meta$species`.
- Per-species priors and data validators are independent, so species can carry
  different sensible defaults without conditional logic.
