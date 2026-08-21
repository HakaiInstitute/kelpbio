# Decision: species is a model variant (per-function + per-.stan), not a data argument

Status: accepted (2026-06); class structure revised (2026-07) from a model-level
class to a per-species subclass (see the Decision and the note below).

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
    `.epred.kb_fit_weight` (both weight species use a log link). wetdry and carbon,
    being structurally identical across species, will register at this tier
    throughout.
  - **`kb_fit_<model>_<species>`** for methods that do vary: `.linpred`,
    `.log_lik`, `.deviance`, `.add_noise`, `.terms`, `.chk_new_data`.

  So no method branches on `meta$species` (kept for display/reference), and
  **adding a sub-model registers methods, not public methods**. Each internal generic
  aborts through its `.default` rather than returning a plausible value, so a
  sub-model added without its methods fails loudly instead of silently. This uniform rule is applied to
  every model even where a variant-plus-field scheme would suffice (weight), so
  the design is consistent, and it is required anyway for models whose species
  differ in response type (size is continuous for *Nereocystis*, a count for
  *Macrocystis*), which are genuinely different types, not one type with a family.
- Uniformity wins over local optimisation: even where a model is structurally
  identical across species (wetdry, carbon), the species-suffixed function is
  kept so users learn one rule and `meta$species` is always available for the
  biomass composition (which requires all six fits to share a species).

This reverses the prior "species enters as data, not a variant" rule in
`config.yaml`, updated to match.

## Consequences

- Adding a species is additive: a new `.stan`, a new wrapper (which classes the
  fit `kb_fit_<model>_<species>`), and methods for what differs (e.g.
  `.linpred.kb_fit_<model>_<species>`), with no change to existing species
  functions, the shared engine, or the public methods. In file terms it is two new
  methods, each added to the file of the generic it implements, with no new public
  file.
- API surface grows from six fit functions to six per species. The cost is
  accepted: the functions have honest, fixed data contracts and match how Hakai
  biologists think ("I have nereo data" / "I have macro data").
- `kb_predict_biomass()` validates that the six fits it composes share
  `meta$species`.
- Per-species priors and data validators are independent, so species can carry
  different sensible defaults without conditional logic.
