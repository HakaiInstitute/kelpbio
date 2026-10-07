# The fit-object constructor shared by every sub-model; `model` and `species`
# build the three class tiers. The model is not stored in meta, since the class
# carries it. `offset` and `terms` are required so a sub-model that omits one
# fails at fit time (decisions/architecture.md). Arguments are not validated:
# every caller is one of the package's own kb_fit_*() functions.
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

  # [[ ]] rather than $: a tibble warns on $ for an absent column, and wet/dry
  # data carry no site or year.
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
      site_levels = site_levels,
      year_levels = year_levels,
      # The data's grouping structure (print()/summary() "Data:"), not the
      # model's effects.
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

# Label the per-level effects with their levels, which follow the Stan indices
# (both from factor() on the same data). A zero-row prior-only fit's unnamed
# placeholder level is left unlabelled.
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
