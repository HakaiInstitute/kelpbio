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

  site_levels <- levels(factor(data[["site"]]))
  year_levels <- levels(factor(data[["year"]]))
  draws <- label_levels(core$draws, site_levels, year_levels)
  diagnostics <- core$diagnostics
  # summarise_draws() rows follow the draws' variables, so relabel them to match.
  if (!is.null(diagnostics$summary)) {
    diagnostics$summary$variable <- flat_variables(draws)
  }

  meta <- c(
    list(
      species = species,
      prior_only = prior_only,
      priors = priors,
      stancode = core$stancode,
      # [[ ]] rather than $ above: a tibble warns on $ for an absent column, and
      # wet/dry data carry no site or year.
      site_levels = site_levels,
      year_levels = year_levels,
      # Recorded rather than recomputed from fit$data, so the group counts a fit
      # reports are a pure metadata read. Describes the data's grouping structure,
      # which is what print()/summary() label as "Data:", not the model's effects.
      site_year_levels = site_year_levels(data),
      nthin = nthin,
      offset = offset,
      terms = terms
    ),
    meta_extra
  )

  structure(
    list(
      draws = draws,
      diagnostics = diagnostics,
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

# Label the per-level effects with their levels, so the draws index by name and
# flatten to site_effect[<site>] and site_year_effect[<site>,<year>]. The levels are in the
# order of the Stan indices: both come from factor() on the same data. A zero-row
# prior-only fit samples one placeholder level that has no name, so an effect
# whose shape does not match the levels is left unlabelled.
label_levels <- function(draws, site_levels, year_levels) {
  labels <- list(
    site_effect = list(site_levels),
    year_effect = list(year_levels),
    site_year_effect = list(site_levels, year_levels)
  )
  for (name in intersect(names(labels), names(draws))) {
    x <- draws[[name]]
    if (!identical(as.integer(dim(x)), lengths(labels[[name]]))) {
      next
    }
    draws[[name]] <- posterior::rvar(
      posterior::draws_of(x),
      dimnames = labels[[name]],
      nchains = posterior::nchains(x)
    )
  }
  draws
}

# The element names of a draws_rvars object (site_effect[a], not site_effect), in the order
# summarise_draws() reports them.
flat_variables <- function(draws) {
  posterior::variables(posterior::as_draws_df(draws))
}

# Observed site-year combinations, as "site:year" labels. Empty for a model whose
# data carry no site or year column.
site_year_levels <- function(data) {
  d <- as.data.frame(data)
  if (!all(c("site", "year") %in% names(d)) || !nrow(d)) {
    return(character(0))
  }
  combos <- unique(site_year_key(d$site, d$year))
  sort(combos)
}
