# The fit-object constructor shared by every sub-model. `model` and `species`
# build the three class tiers (kb_fit_<model>_<species>, kb_fit_<model>, kb_fit),
# so a method can be registered at whichever tier its body is invariant at.
#
# The model is deliberately not stored in meta: the class already carries it, and
# a second copy could disagree with it. Species is stored because it is displayed,
# never dispatched on. See decisions/species-as-variant.md.
#
# `offset` and `terms` are required arguments rather than optional `meta_extra`
# entries, and rather than internal generics. Only their values vary between
# sub-models, never the code that reads them, so they are data (see the
# "meta versus dispatch" section of decisions/architecture.md); making them
# required is what keeps a sub-model that fails to declare one failing loudly, at
# fit time. Facts that only some models have (`predictor`, `predictor_ref`) stay
# optional and travel in `meta_extra`.
#
# The arguments are not validated here. This constructor is internal and every
# caller is one of the package's own kb_fit_*() functions, so a malformed
# declaration is an authoring error the tests catch once, not a user error that
# could reach it at runtime.
new_kb_fit <- function(
  core,
  data,
  priors,
  model,
  species,
  offset,
  terms,
  prior_only,
  nthin,
  meta_extra = list()
) {
  species_tag <- c(nereocystis = "nereo", macrocystis = "macro")[[species]]

  meta <- c(
    list(
      species = species,
      prior_only = prior_only,
      priors = priors,
      stancode = core$stancode,
      site_levels = levels(factor(data$site)),
      year_levels = levels(factor(data$year)),
      nthin = nthin,
      offset = offset,
      terms = terms
    ),
    meta_extra
  )

  structure(
    list(
      draws = core$draws,
      diagnostics = core$diagnostics,
      data = data,
      meta = meta
    ),
    class = c(
      paste0("kb_fit_", model, "_", species_tag),
      paste0("kb_fit_", model),
      "kb_fit"
    )
  )
}
