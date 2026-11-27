#' Resolve User Priors Against Defaults
#'
#' Merge a user-supplied (possibly partial) prior list into the model defaults.
#' `NULL` returns the defaults unchanged; otherwise each supplied entry replaces
#' the corresponding default while unspecified entries keep their default. Names
#' must be a subset of the defaults, and each entry must match the family
#' (class) of the default it replaces (the prior family is fixed).
#'
#' @param priors A named list of prior objects, or `NULL` for the defaults.
#' @param defaults The default named prior list (for example from [kb_priors_weight_nereo()]).
#' @param call The call named in errors: the fit function the user called.
#'
#' @returns A named list of prior objects with the same names as `defaults`.
#' @noRd
resolve_priors <- function(priors, defaults, call = rlang::caller_env()) {
  if (is.null(priors)) {
    return(defaults)
  }
  .with_call(
    {
      chk::chk_list(priors)
      chk::chk_named(priors)
      chk::chk_unique(names(priors), x_name = "Names of `priors`")
    },
    call
  )

  .chk_prior_entries(priors, defaults, call = call)
  out <- defaults
  out[names(priors)] <- priors
  out
}

# One Stan data field per hyperparameter, `prior_<entry>_<argument>` (e.g.
# prior_sd_site_rate).
prior_data <- function(priors) {
  fields <- purrr::imap(priors, function(prior, entry) {
    hyper <- unclass(prior)
    rlang::set_names(hyper, paste0("prior_", entry, "_", names(hyper)))
  })
  purrr::list_flatten(unname(fields))
}

# The parameters a fit estimates, from its priors: every parameter but the
# per-level `effects` has a prior entry of its own name
# (decisions/parameter-naming.md), in the model's order. `off` names the
# parameters the data or the model form switched off; they are sampled but not
# stored.
fit_parameters <- function(priors, effects = character(0), off = character(0)) {
  list(
    fixed = setdiff(names(priors), off),
    random = setdiff(effects, off)
  )
}

# The per-level group effects of the site:year models.
GROUP_EFFECTS <- c("site_effect", "year_effect", "site_year_effect")
