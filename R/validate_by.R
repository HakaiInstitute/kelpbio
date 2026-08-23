# Validate the `by` grouping axis of a `_by` prediction verb. The set of grouping
# factors is common to every sub-model (.group_vars()); which combinations of them
# a particular fit offers depends on its fitted effect structure, which is what
# .chk_by() decides.
validate_by <- function(fit, by) {
  if (is.null(by)) {
    by <- character(0)
  }
  chk::chk_character(by)
  valid <- .group_vars()
  bad <- setdiff(by, valid)
  if (length(bad)) {
    cli::cli_abort(c(
      "Invalid {.arg by} value{?s}: {.val {bad}}.",
      i = "Available grouping factors: {.val {valid}}."
    ))
  }
  .chk_by(fit, by)
  by
}

# Which combinations of the grouping factors a fit can be grouped by. Separate
# from validate_by()'s membership check so each model states only its own rule,
# and so the rule is chosen by dispatch rather than by reading meta$species.
#
# No total default: a model whose available groupings were never stated would
# otherwise silently accept a grouping its linear predictor cannot honour.
.chk_by <- function(fit, by) {
  UseMethod(".chk_by")
}

#' @export
.chk_by.default <- function(fit, by) {
  .abort_no_method(x = fit, call = NULL)
}

# Nereocystis weight has no year main effect: year enters only through the
# site:year interaction, so year on its own is not an available grouping.
#' @export
.chk_by.kb_fit_weight_nereo <- function(fit, by) {
  if ("year" %in% by && !"site" %in% by) {
    cli::cli_abort(c(
      "{.code by = \"year\"} is not available for the Nereocystis weight model.",
      i = "Year enters only through the site:year interaction (no year main effect).",
      i = "Use {.code by = NULL}, {.val site}, or {.code c(\"site\", \"year\")}."
    ))
  }
  invisible(by)
}

# Macrocystis weight has a year main effect, so every combination is available.
#' @export
.chk_by.kb_fit_weight_macro <- function(fit, by) {
  invisible(by)
}
