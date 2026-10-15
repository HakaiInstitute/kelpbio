#' Resolve User Priors Against Defaults
#'
#' Merge a user-supplied (possibly partial) prior list into the model defaults.
#' `NULL` returns the defaults unchanged; otherwise each supplied entry replaces
#' the corresponding default while unspecified entries keep their default. Names
#' must be a subset of the defaults, and each entry must match the family
#' (class) of the default it replaces (the prior family is fixed).
#'
#' @param priors A named list of prior objects, or `NULL` for the defaults.
#' @param defaults The default named prior list (e.g. from [kb_priors_weight_nereo()]).
#' @param call The call named in errors: the fit function the user called.
#'
#' @return A named list of prior objects with the same names as `defaults`.
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

  extra <- setdiff(names(priors), names(defaults))
  if (length(extra)) {
    cli::cli_abort(c(
      "Unknown prior{?s} in {.arg priors}: {.field {extra}}.",
      i = "Valid entries are {.field {names(defaults)}}."
    ), call = call)
  }

  out <- defaults
  for (nm in names(priors)) {
    prior <- priors[[nm]]
    family <- class(defaults[[nm]])[1]
    if (!inherits(prior, family)) {
      cli::cli_abort(c(
        "Prior {.field {nm}} has the wrong family.",
        i = "Expected {.cls {family}}, not {.cls {class(prior)[1]}}.",
        i = "The prior family is fixed; a family change needs a different model."
      ), call = call)
    }
    out[[nm]] <- prior
  }
  out
}
