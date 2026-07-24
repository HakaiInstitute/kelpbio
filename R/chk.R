# Checkers paired with .vld_ in vld.R: abort via cli on failure, else return the
# input invisibly. A fit is checked at the head of every function that takes one,
# since S3 dispatch alone does not catch a non-fit passed in directly.

.chk_kb_fit <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_kb_fit(x)) {
    return(invisible(x))
  }
  cli::cli_abort(c(
    "{.arg {x_name}} must be a {.cls kb_fit} object.",
    i = "See {.fun kb_fit_weight_nereo}."
  ))
}

.chk_kb_fit_weight <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_kb_fit_weight(x)) {
    return(invisible(x))
  }
  cli::cli_abort(c(
    "{.arg {x_name}} must be a {.cls kb_fit_weight} object.",
    i = "See {.fun kb_fit_weight_nereo}."
  ))
}

.chk_new_data_weight_nereo <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_new_data_weight_nereo(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{.arg {x_name}} must be a data frame.")
  }
  cli::cli_abort("{.arg {x_name}} must have a {.field diameter} column.")
}

.chk_representative_site <- function(fit, representative_site) {
  if (.vld_representative_site(representative_site, fit$meta$site_levels)) {
    return(invisible(representative_site))
  }
  chk::chk_character(representative_site)
  chk::chk_not_empty(representative_site)
  bad <- setdiff(representative_site, fit$meta$site_levels)
  cli::cli_abort(c(
    "Invalid {.arg representative_site} value{?s}: {.val {bad}}.",
    i = "Available site{?s}: {.val {fit$meta$site_levels}}."
  ))
}

# Shared summary-argument validation for the report-view functions (kb_predict_*,
# tidy, summary).
.chk_summary_args <- function(conf_level, estimate, sig_fig) {
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)
  chk::chk_gt(sig_fig, value = 0)
  invisible(NULL)
}

.chk_progress <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_progress(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    "{.arg {x_name}} must be one of {.val bar}, {.val verbose}, or {.val none}."
  )
}

.chk_progress_dir <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_progress_dir(x)) {
    if (is.null(x) || file.access(x, mode = 2L) == 0L) {
      return(invisible(x))
    }
    cli::cli_abort("{.arg {x_name}} must be a writable directory.")
  }
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort("{.arg {x_name}} must be a directory path or {.code NULL}.")
  }
  cli::cli_abort(
    "{.arg {x_name}} must be a path to an existing directory, or {.code NULL}."
  )
}

# Shared sampler-argument validation for every kb_fit_* wrapper.
.chk_sampler_args <- function(
  prior_only,
  chains,
  niters,
  nthin,
  cores,
  seed = NULL,
  progress,
  progress_dir = NULL
) {
  chk::chk_flag(prior_only)
  chk::chk_whole_number(chains)
  chk::chk_gt(chains, value = 0)
  chk::chk_whole_number(niters)
  chk::chk_gt(niters, value = 0)
  chk::chk_whole_number(nthin)
  chk::chk_gt(nthin, value = 0)
  .chk_progress(progress)
  .chk_progress_dir(progress_dir)
  if (!is.null(cores)) {
    chk::chk_whole_number(cores)
    chk::chk_gt(cores, value = 0)
  }
  if (!is.null(seed)) {
    chk::chk_whole_number(seed)
  }
  invisible(NULL)
}
