# Decision: species is a model variant (per-function + per-.stan), not a data argument

Status: accepted (2026-06)

## Context

kelpbio fits five models (weight, size, wetdry, carbon, and the cover
calibration) for two species, with a size model for *Nereocystis* only, *Nereocystis luetkeana* (nereo) and *Macrocystis pyrifera* (macro).
The package began nereo-only with a `species = "nereocystis"` argument and a
single `inst/stan/weight.stan`, on the working assumption (recorded in the old
`config.yaml` rule "Species enters as data, not a variant") that a species is
just a different dataset fed to one shared model.

Inspecting the validated analysis project (`hakai-kelp-biomass-25`) overturns
that assumption. The models differ structurally across species, not just in
data:

- Weight: nereo is lognormal on a Packard power function of diameter with a
  weight floor; macro is Gamma (constant shape) on a linear function of
  log-fronds. Different response
  column, predictor column, likelihood family, functional form, random-effect
  structure, and parameter set.
- Size: *Nereocystis* measures a sample of plants and models their size
  distribution; *Macrocystis* records every counted plant's fronds, so it has no
  size model.
- wetdry / carbon: structurally identical across species.
- cover_calibration: structurally identical across species; only the default floor and tide
  priors differ.

A single `kb_fit_weight(data, species)` would force the function's required data
columns, prior set, and returned parameters to branch on `species`. A mode
argument that silently changes a function's input contract and output shape is
the anti-pattern tidyverse design avoids (cf. `map_dbl()`/`map_chr()` over a
type argument). The `family =` analogy to `glm()` does not hold here: `glm()`
keeps one formula+data interface and only swaps the likelihood, whereas here the
interface itself changes.

## Decision

Species is a variant axis, handled uniformly across all models:

- Each species gets its own public fit function `kb_fit_<model>_<species>()`
  (e.g. `kb_fit_weight_nereo()`), its own `kb_priors_<model>_<species>()` and
  `kb_check_data_<model>_<species>()`, and its own `inst/stan/<model>_<species>.stan`.
  A model that is structurally identical across species (wetdry, carbon, cover_calibration) has one
  `inst/stan/<model>.stan`, since two identical files would differ in nothing.
- The species-agnostic mechanics (sampler invocation, control merge, warmup/thin
  math, core resolution, draws-to-rvars extraction, convergence diagnostics) live in one shared internal engine, `fit_stan()`. Each
  species wrapper supplies only what differs: validated data, resolved priors,
  assembled Stan data, the compiled model, and the parameter vector.
- Each species is a subclass of the model class:
  `c("kb_fit_<model>_<species>", "kb_fit_<model>", "kb_fit")`, and a method lives
  at the **highest tier of that vector at which its body is invariant**:
  - **`kb_fit`** for the public method bodies, which carry only the shared shape
    (entry check, guards, the `D x N` orientation contract) and delegate whatever
    varies: `log_lik`, `residuals`, `tidy`, `fitted`, and the `posterior_*`
    generics. `predict` is the exception: its argument list cannot be fixed across
    models, since the first sub-model with a different knob would force it to bare
    `...` and lose `rlang::check_dots_empty()`.
  - **`kb_fit_<model>`** for methods that do not vary by species, e.g.
    `.epred.kb_fit_weight` (both weight species use a log link; *Nereocystis*
    overrides it for the lognormal mean) and `.linpred.kb_fit_size`. wetdry,
    carbon, and cover_calibration, being structurally identical across species,
    register at this tier throughout.
  - **`kb_fit_<model>_<species>`** for methods that do vary, e.g. the weight
    `.linpred` and `.chk_new_data` methods and the `.obs_family` methods of the
    weight and size models.

  So no method branches on `meta$species` (kept for display/reference), and
  **adding a sub-model registers methods, not public methods**. Each internal generic
  that feeds a number aborts through its `.default` rather than returning a
  plausible value, so a sub-model added without its methods fails loudly instead
  of silently (`.fit_descriptor`, which supplies only `print()`'s header, is the
  one exception). This uniform rule is applied to
  every model even where a variant-plus-field scheme would suffice (weight), so
  the design is consistent, and a species with no model of a kind (size for
  *Macrocystis*) simply has no class for it.
- Uniformity wins over local optimisation: even where a model is structurally
  identical across species (wetdry, carbon, cover_calibration), the species-suffixed function is
  kept so users learn one rule and `meta$species` is always available for the
  derived verbs (which require their fits to share a species). The
  species functions then share one internal body and Stan file and differ only in
  the species they record (and, for cover_calibration, their default priors).

This reverses the prior "species enters as data, not a variant" rule in
`config.yaml`, updated to match.

## Consequences

- Adding a species is additive: a new `.stan`, a new wrapper (which classes the
  fit `kb_fit_<model>_<species>`), and methods for what differs (e.g.
  `.linpred.kb_fit_<model>_<species>`), with no change to existing species
  functions, the shared engine, or the public methods. In file terms it is two new
  methods, each added to the file of the generic it implements, with no new public
  file.
- API surface grows to one fit function per model and species. The cost is
  accepted: the functions have honest, fixed data contracts and match how Hakai
  biologists think ("I have nereo data" / "I have macro data").
- The derived verbs (`kb_predict_mean_weight()`, `kb_predict_biomass_survey()`,
  `kb_predict_biomass_canopy()`) validate that the fits they combine share
  `meta$species`.
- Per-species priors and data validators are independent, so species can carry
  different sensible defaults without conditional logic.
