#' Resolve User Priors Against Defaults
#'
#' Merge a user-supplied (possibly partial) prior list into the model defaults.
#' `NULL` returns the defaults unchanged; otherwise each supplied entry replaces
#' the corresponding default while unspecified entries keep their default. Names
#' must be a subset of the defaults, and each entry must match the family
#' (class) of the default it replaces (the prior family is fixed).
#'
#' @param priors A named list of prior objects, or `NULL` for the defaults.
#' @param defaults The default named prior list (e.g. from [kb_priors_weight()]).
#'
#' @return A named list of prior objects with the same names as `defaults`.
#' @noRd
resolve_priors <- function(priors, defaults) {
  if (is.null(priors)) {
    return(defaults)
  }
  chk::chk_list(priors)
  chk::chk_named(priors)

  extra <- setdiff(names(priors), names(defaults))
  if (length(extra)) {
    cli::cli_abort(c(
      "Unknown prior{?s} in {.arg priors}: {.field {extra}}.",
      i = "Valid entries are {.field {names(defaults)}}."
    ))
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
      ))
    }
    out[[nm]] <- prior
  }
  out
}
