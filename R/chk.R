# Checkers paired with .vld_ in vld.R: abort via cli on failure, else return the
# input invisibly. A fit is checked at the head of every function that takes one,
# since S3 dispatch alone does not catch a non-fit passed in directly.

.chk_kb_fit <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    c(
      "{.arg {x_name}} must be a {.cls kb_fit} object.",
      i = "Supported fits are created by the {.code kb_fit_*()} functions."
    ),
    call = call
  )
}

.chk_kb_fit_weight <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit_weight(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    c(
      "{.arg {x_name}} must be a {.cls kb_fit_weight} object.",
      i = "Supported fits are created by the {.code kb_fit_weight_*()} functions."
    ),
    call = call
  )
}

.chk_kb_fit_size <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit_size(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    c(
      "{.arg {x_name}} must be a {.cls kb_fit_size} object.",
      i = "Supported fits are created by the {.code kb_fit_size_*()} functions."
    ),
    call = call
  )
}

.chk_kb_fit_density <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit_density(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    c(
      "{.arg {x_name}} must be a {.cls kb_fit_density} object.",
      i = "Supported fits are created by the {.code kb_fit_density_*()} functions."
    ),
    call = call
  )
}

.chk_kb_fit_wetdry <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit_wetdry(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    c(
      "{.arg {x_name}} must be a {.cls kb_fit_wetdry} object.",
      i = "Supported fits are created by the {.code kb_fit_wetdry_*()} functions."
    ),
    call = call
  )
}

.chk_kb_fit_carbon <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit_carbon(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    c(
      "{.arg {x_name}} must be a {.cls kb_fit_carbon} object.",
      i = "Supported fits are created by the {.code kb_fit_carbon_*()} functions."
    ),
    call = call
  )
}

.chk_new_data_weight_nereo <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_new_data_weight_nereo(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{.arg {x_name}} must be a data frame.")
  }
  if (!"diameter_mm" %in% names(x)) {
    cli::cli_abort("{.arg {x_name}} must have a {.field diameter_mm} column.")
  }
  .chk_positive_measure(x$diameter_mm, x_name = kb_xname(x_name, "diameter_mm"))
  .chk_density(x$stipes_m2, x_name = kb_xname(x_name, "stipes_m2"))
}

.chk_positive_measure <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_positive_measure(x)) {
    return(invisible(x))
  }
  if (!is.numeric(x)) {
    cli::cli_abort("{x_name} must be numeric.")
  }
  if (anyNA(x)) {
    cli::cli_abort("{x_name} must not have missing values.")
  }
  cli::cli_abort("{x_name} must be greater than 0.")
}

.chk_frond_count <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_frond_count(x)) {
    return(invisible(x))
  }
  .chk_positive_measure(x, x_name = x_name)
  cli::cli_abort("{x_name} must be a whole number.")
}

.chk_density <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_density(x)) {
    return(invisible(x))
  }
  if (!is.numeric(x)) {
    cli::cli_abort("{x_name} must be numeric.")
  }
  cli::cli_abort("{x_name} must be greater than or equal to 0.")
}

.chk_density_site_year <- function(data, x_name = deparse(substitute(data))) {
  if (.vld_density_site_year(data)) {
    return(invisible(data))
  }
  recorded <- !is.na(data$stipes_m2)
  key <- site_year_key(data$site, data$year)[recorded]
  n_distinct <- tapply(data$stipes_m2[recorded], key, function(x) {
    length(unique(x))
  })
  bad <- names(n_distinct)[n_distinct > 1L]
  cli::cli_abort(c(
    "{kb_xname(x_name, 'stipes_m2')} must have one value per site-year.",
    x = "Conflicting values in site-year{?s} {.val {bad}}."
  ))
}

.chk_new_data_weight_macro <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_new_data_weight_macro(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{.arg {x_name}} must be a data frame.")
  }
  if (!"fronds" %in% names(x)) {
    cli::cli_abort("{.arg {x_name}} must have a {.field fronds} column.")
  }
  .chk_frond_count(x$fronds, x_name = kb_xname(x_name, "fronds"))
}

.chk_new_data_size <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_new_data_size(x)) {
    return(invisible(x))
  }
  cli::cli_abort("{.arg {x_name}} must be a data frame.")
}

.chk_new_data_density <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_new_data_density(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{.arg {x_name}} must be a data frame.")
  }
  if (!"area_m2" %in% names(x)) {
    cli::cli_abort(c(
      "{.arg {x_name}} must have an {.field area_m2} column.",
      i = "Its rows predict the count on a transect of that area; use {.fn kb_predict_density_by} for density per m\u00b2."
    ))
  }
  .chk_positive_measure(x$area_m2, x_name = kb_xname(x_name, "area_m2"))
}

# The fits a composition combines must describe one species.
.chk_same_species <- function(fits, call = rlang::caller_env()) {
  if (.vld_same_species(fits)) {
    return(invisible(fits))
  }
  species <- vapply(fits, function(f) .species_label(f$meta$species), character(1))
  cli::cli_abort(
    c(
      "The fits must be of one species.",
      i = "{.arg {names(fits)}} {?is/are} {.val {species}}."
    ),
    call = call
  )
}

# The fits a composition combines are paired draw by draw, so their draw counts
# must match.
.chk_same_ndraws <- function(fits, call = rlang::caller_env()) {
  if (.vld_same_ndraws(fits)) {
    return(invisible(fits))
  }
  n <- vapply(fits, function(f) posterior::ndraws(f$draws), numeric(1))
  cli::cli_abort(
    c(
      "The fits must have the same number of posterior draws.",
      i = "{.arg {names(fits)}} {?has/have} {n} draws."
    ),
    call = call
  )
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

# Reject the other species' predictor argument (a Macrocystis `fronds` on a
# Nereocystis fit, or vice versa) with a message naming the correct argument.
# Contextual bundle like .chk_sampler_args(): no single-boolean .vld_ partner.
# Extra dots beyond the predictor are left to the method's rlang::check_dots_empty().
.chk_wrong_predictor <- function(fit, ..., call = rlang::caller_env()) {
  right <- c(nereocystis = "diameter_mm", macrocystis = "fronds")[[
    fit$meta$species
  ]]
  wrong <- setdiff(c("diameter_mm", "fronds"), right)
  if (wrong %in% rlang::names2(rlang::list2(...))) {
    cli::cli_abort(
      c(
        "{.arg {wrong}} is not the predictor argument for a {fit$meta$species} fit.",
        i = "Use {.arg {right}} to supply the predictor sequence."
      ),
      call = call
    )
  }
  invisible(fit)
}

# Every path that predicts at the stored data needs rows to predict at. Without
# this the failure surfaces as a posterior broadcast error from inside .linpred().
.chk_observed_data <- function(fit, call = rlang::caller_env()) {
  if (.vld_observed_data(fit)) {
    return(invisible(fit))
  }
  cli::cli_abort(
    c(
      "A zero-observation fit has no observed data to predict at.",
      i = "Supply {.arg new_data}, or fit the model to data."
    ),
    call = call
  )
}


# Validate new_data's predictor column.
.chk_new_data <- function(fit, new_data) {
  UseMethod(".chk_new_data")
}

#' @export
.chk_new_data.default <- function(fit, new_data) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.chk_new_data.kb_fit_weight_nereo <- function(fit, new_data) {
  .chk_new_data_weight_nereo(new_data)
}

#' @export
.chk_new_data.kb_fit_weight_macro <- function(fit, new_data) {
  .chk_new_data_weight_macro(new_data)
}

# Both size species take the same new_data (no predictor column).
#' @export
.chk_new_data.kb_fit_size <- function(fit, new_data) {
  .chk_new_data_size(new_data)
}

# Wet/dry has no predictor or groups, so, like size, any data frame will do: each
# row predicts the population ratio.
#' @export
.chk_new_data.kb_fit_wetdry <- function(fit, new_data) {
  .chk_new_data_size(new_data)
}

# Carbon, like wet/dry, has no predictor or groups.
#' @export
.chk_new_data.kb_fit_carbon <- function(fit, new_data) {
  .chk_new_data_size(new_data)
}

# Both density species take the same new_data (the transect area).
#' @export
.chk_new_data.kb_fit_density <- function(fit, new_data) {
  .chk_new_data_density(new_data)
}
