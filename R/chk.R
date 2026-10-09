# A fit is checked at the head of every function that takes one, since S3
# dispatch alone does not catch a non-fit passed in directly.

.chk_kb_fit <- function(
  x,
  class = "kb_fit",
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit(x, class)) {
    return(invisible(x))
  }
  constructors <- paste0(class, "_*()")
  cli::cli_abort(
    c(
      "{.arg {x_name}} must be a {.cls {class}} object.",
      i = "Supported fits are created by the {.code {constructors}} functions."
    ),
    call = call
  )
}

.chk_kb_fit_grouped <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_kb_fit_grouped(x)) {
    return(invisible(x))
  }
  .chk_kb_fit(x, x_name = x_name, call = call)
  cli::cli_abort(
    c(
      "{.arg {x_name}} is a {.cls {class(x)[1]}} object, whose model has no grouping factors.",
      i = "Grids are built for weight, size, density, and cover biomass fits."
    ),
    call = call
  )
}

.chk_new_data_weight_nereo <- function(
  x,
  x_name = chk::deparse_backtick_chk(substitute(x))
) {
  if (.vld_new_data_weight_nereo(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{x_name} must be a data frame.")
  }
  if (!"diameter_mm" %in% names(x)) {
    cli::cli_abort("{x_name} must have a {.field diameter_mm} column.")
  }
  .chk_positive_measure(x$diameter_mm, x_name = column_xname(x_name, "diameter_mm"))
  .chk_density(x$stipes_m2, x_name = column_xname(x_name, "stipes_m2"))
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
  .chk_finite(x, x_name)
  cli::cli_abort("{x_name} must be greater than 0.")
}

.chk_finite <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_finite(x)) {
    return(invisible(x))
  }
  cli::cli_abort("{x_name} must be finite.", call = call)
}

.chk_rows <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_rows(x)) {
    return(invisible(x))
  }
  cli::cli_abort("{x_name} must have at least one row.", call = call)
}

.chk_new_data_groups <- function(
  x,
  x_name = "`new_data`",
  call = rlang::caller_env()
) {
  if (.vld_new_data_groups(x)) {
    return(invisible(x))
  }
  groups <- intersect(.group_vars(), names(x))
  col <- groups[vapply(x[groups], anyNA, logical(1))][1]
  cli::cli_abort(
    c(
      "{column_xname(x_name, col)} must not have missing values.",
      i = "To predict for a new {col}, give it a name or leave out the {.field {col}} column."
    ),
    call = call
  )
}

.chk_frond_count <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_frond_count(x)) {
    return(invisible(x))
  }
  .chk_positive_measure(x, x_name = x_name)
  cli::cli_abort("{x_name} must be a whole number.")
}

# Run after checking x is numeric with no missing values.
.chk_frond_reaches_1m <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_frond_reaches_1m(x)) {
    return(invisible(x))
  }
  cli::cli_abort(c(
    "{x_name} must be at least 1.",
    i = "The model describes plants with at least one frond reaching 1 m above the holdfast.",
    i = "Remove plants with 0 fronds, and leave them out of the density counts too."
  ))
}

.chk_density <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_density(x)) {
    return(invisible(x))
  }
  if (!is.numeric(x)) {
    cli::cli_abort("{x_name} must be numeric.")
  }
  .chk_finite(x, x_name)
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
    "{column_xname(x_name, 'stipes_m2')} must have one value per site-year.",
    x = "Conflicting values in site-year{?s} {.val {bad}}."
  ))
}

.chk_new_data_weight_macro <- function(
  x,
  x_name = chk::deparse_backtick_chk(substitute(x))
) {
  if (.vld_new_data_weight_macro(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{x_name} must be a data frame.")
  }
  if (!"fronds" %in% names(x)) {
    cli::cli_abort("{x_name} must have a {.field fronds} column.")
  }
  .chk_frond_count(x$fronds, x_name = column_xname(x_name, "fronds"))
}

.chk_new_data_size <- function(
  x,
  x_name = chk::deparse_backtick_chk(substitute(x))
) {
  if (.vld_new_data_size(x)) {
    return(invisible(x))
  }
  cli::cli_abort("{x_name} must be a data frame.")
}

.chk_new_data_density <- function(
  x,
  x_name = chk::deparse_backtick_chk(substitute(x))
) {
  if (.vld_new_data_density(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{x_name} must be a data frame.")
  }
  .chk_positive_measure(x$area_m2, x_name = column_xname(x_name, "area_m2"))
}

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

# Composed fits are paired draw by draw.
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

.chk_representative_site <- function(
  fit,
  representative_site,
  call = rlang::caller_env()
) {
  if (.vld_representative_site(representative_site, fit$meta$site_levels)) {
    return(invisible(representative_site))
  }
  .with_call(
    {
      chk::chk_character(representative_site)
      chk::chk_not_empty(representative_site)
    },
    call
  )
  bad <- setdiff(representative_site, fit$meta$site_levels)
  cli::cli_abort(
    c(
      "Invalid {.arg representative_site} value{?s}: {.val {bad}}.",
      i = "Available site{?s}: {.val {fit$meta$site_levels}}."
    ),
    call = call
  )
}

.chk_summary_args <- function(
  conf_level,
  estimate,
  sig_fig,
  call = rlang::caller_env()
) {
  .with_call(
    {
      chk::chk_number(conf_level)
      chk::chk_range(conf_level)
      chk::chk_function(estimate)
      chk::chk_whole_number(sig_fig)
      chk::chk_gt(sig_fig, value = 0)
      .chk_finite(sig_fig, "`sig_fig`")
    },
    call
  )
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

.chk_sampling_dots <- function(x, call = rlang::caller_env()) {
  if (.vld_sampling_dots(x)) {
    return(invisible(x))
  }
  bad <- intersect(rlang::names2(x), names(SAMPLING_RESERVED))
  use <- unique(stats::na.omit(SAMPLING_RESERVED[bad]))
  cli::cli_abort(
    c(
      "{.arg {bad}} cannot be passed to the sampler: kelpbio sets {?it/them} itself.",
      i = if (length(use)) "Use {.arg {use}} instead.",
      i = if (anyNA(SAMPLING_RESERVED[bad])) "The fit keeps every parameter."
    ),
    call = call
  )
}

.chk_sampler_args <- function(
  prior_only,
  chains,
  niters,
  nthin,
  cores,
  seed = NULL,
  progress,
  progress_dir = NULL,
  call = rlang::caller_env()
) {
  .with_call(
    {
      chk::chk_flag(prior_only)
      chk::chk_whole_number(chains)
      chk::chk_gt(chains, value = 0)
      .chk_finite(chains, "`chains`")
      chk::chk_whole_number(niters)
      # The sampler diagnostics need at least two draws per chain.
      chk::chk_gte(niters, value = 2)
      .chk_finite(niters, "`niters`")
      chk::chk_whole_number(nthin)
      chk::chk_gt(nthin, value = 0)
      .chk_finite(nthin, "`nthin`")
      .chk_progress(progress)
      .chk_progress_dir(progress_dir)
      if (!is.null(cores)) {
        chk::chk_whole_number(cores)
        chk::chk_gt(cores, value = 0)
        .chk_finite(cores, "`cores`")
      }
      if (!is.null(seed)) {
        chk::chk_whole_number(seed)
        # Passed to Stan as an integer.
        chk::chk_range(seed, c(-.Machine$integer.max, .Machine$integer.max))
      }
    },
    call
  )
  invisible(NULL)
}

# The `...` of kb_new_data(): named values for the fit's predictor and for any
# grouping factor not in `by`. Contextual bundle like .chk_sampler_args(): no
# single-boolean .vld_ partner.
.chk_grid_dots <- function(fit, dots, by, call = rlang::caller_env()) {
  predictor <- fit$meta[["predictor"]]
  hint <- if (is.null(predictor)) {
    "Supply values for {.arg site} or {.arg year}."
  } else {
    "Supply the predictor {.arg {predictor}}, or values for {.arg site} or {.arg year}."
  }
  nms <- rlang::names2(dots)
  if (any(nms == "")) {
    cli::cli_abort(
      c("Values in {.arg ...} must be named.", i = hint),
      call = call
    )
  }
  repeated <- unique(nms[duplicated(nms)])
  if (length(repeated)) {
    cli::cli_abort("Supply {.arg {repeated}} once.", call = call)
  }
  bad <- setdiff(nms, c(predictor, .group_vars()))
  if (length(bad)) {
    cli::cli_abort(
      c("A {fit$meta$species} {.cls {class(fit)[2]}} grid has no column {.arg {bad}}.", i = hint),
      call = call
    )
  }
  both <- intersect(nms, by)
  if (length(both)) {
    cli::cli_abort(
      c(
        "{.arg {both}} is named in {.arg by} and given values.",
        i = "{.arg by} takes every fitted level; values in {.arg ...} take the levels supplied."
      ),
      call = call
    )
  }
  if (!is.null(predictor) && predictor %in% nms) {
    x_name <- paste0("`", predictor, "`")
    chk::chk_numeric(dots[[predictor]], x_name = x_name)
    chk::chk_not_empty(dots[[predictor]], x_name = x_name)
    chk::chk_not_any_na(dots[[predictor]], x_name = x_name)
    if (!is.null(fit$meta$predictor_range)) {
      chk::chk_range(dots[[predictor]], fit$meta$predictor_range, x_name = x_name)
    } else if (identical(predictor, "fronds")) {
      .chk_frond_count(dots[[predictor]], x_name)
    } else {
      .chk_positive_measure(dots[[predictor]], x_name)
    }
  }
  for (group in intersect(.group_vars(), nms)) {
    x <- dots[[group]]
    if (!(is.character(x) || is.factor(x) || is.numeric(x))) {
      cli::cli_abort(
        "{.arg {group}} must be a character, factor, or numeric vector.",
        call = call
      )
    }
    chk::chk_not_empty(x, x_name = paste0("`", group, "`"))
    chk::chk_not_any_na(x, x_name = paste0("`", group, "`"))
  }
  invisible(fit)
}

# Without this, predicting at the data of a zero-observation fit fails with a
# posterior broadcast error inside .linpred(). `hint` is for callers that could
# have been given new data instead.
.chk_fit_rows <- function(data, prior_only, call = rlang::caller_env()) {
  if (.vld_fit_rows(data, prior_only)) {
    return(invisible(data))
  }
  cli::cli_abort(
    c(
      "{.arg data} must have at least one row.",
      i = "Set {.code prior_only = TRUE} to sample from the priors alone."
    ),
    call = call
  )
}

.chk_observed_data <- function(fit, hint = NULL, call = rlang::caller_env()) {
  if (.vld_observed_data(fit)) {
    return(invisible(fit))
  }
  cli::cli_abort(
    c("A zero-observation fit has no observed data.", i = hint),
    call = call
  )
}

.chk_sensitivity_fit <- function(fit, call = rlang::caller_env()) {
  if (.vld_sensitivity_fit(fit)) {
    return(invisible(fit))
  }
  if (isTRUE(fit$meta$prior_only)) {
    cli::cli_abort(
      "A prior-only fit has no likelihood, so its prior sensitivity cannot be assessed.",
      call = call
    )
  }
  cli::cli_abort(
    "A zero-observation fit has no likelihood, so its prior sensitivity cannot be assessed.",
    call = call
  )
}

.chk_loo_fit <- function(fit, call = rlang::caller_env()) {
  if (.vld_loo_fit(fit)) {
    return(invisible(fit))
  }
  if (isTRUE(fit$meta$prior_only)) {
    cli::cli_abort(
      "A prior-only fit has no likelihood, so it cannot be cross-validated.",
      call = call
    )
  }
  cli::cli_abort(
    "A zero-observation fit has no likelihood, so it cannot be cross-validated.",
    call = call
  )
}


# Validate new_data's predictor column.
.chk_new_data <- function(fit, new_data) {
  UseMethod(".chk_new_data")
}

#' @export
.chk_new_data.default <- function(fit, new_data) {
  .abort_no_method(fit, call = NULL)
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

# Wet/dry has no predictor or groups, so any data frame will do.
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

# `x_name` names the data frame; column messages name the column within it.
.chk_cover_survey <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_cover_survey(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{x_name} must be a data frame.")
  }
  chk::chk_superset(
    names(x),
    c("canopy_area_m2", "plot_area_m2", "tide_height_m"),
    x_name = x_name
  )
  nm <- column_xname(x_name, "canopy_area_m2")
  chk::chk_numeric(x$canopy_area_m2, x_name = nm)
  chk::chk_not_any_na(x$canopy_area_m2, x_name = nm)
  .chk_finite(x$canopy_area_m2, nm)
  chk::chk_gte(x$canopy_area_m2, value = 0, x_name = nm)
  .chk_positive_measure(x$plot_area_m2, x_name = column_xname(x_name, "plot_area_m2"))
  if (any(x$canopy_area_m2 > x$plot_area_m2)) {
    cli::cli_abort(c(
      "{nm} must not exceed {.field plot_area_m2}.",
      i = "The canopy is the area delineated within the plot."
    ))
  }
  nm <- column_xname(x_name, "tide_height_m")
  chk::chk_numeric(x$tide_height_m, x_name = nm)
  chk::chk_not_any_na(x$tide_height_m, x_name = nm)
  .chk_finite(x$tide_height_m, nm)
}

# The data check shared by both cover species.
.chk_cover_biomass_data <- function(data, biomass, x_name, call = rlang::caller_env()) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("canopy_area_m2", "plot_area_m2", "tide_height_m", "site", "year"),
    x_name = x_name
  )
  # The response comes from `biomass`; columns of the same name in `data` would
  # be ambiguous once the two are joined.
  in_data <- intersect(c("estimate", "lower", "upper"), names(data))
  if (length(in_data)) {
    cli::cli_abort(
      c(
        "{x_name} must not have the column{?s} {.field {in_data}}.",
        i = "Supply the in situ biomass through {.arg biomass}."
      ),
      call = call
    )
  }
  .chk_cover_survey(data, x_name)
  .chk_group_columns(data, x_name)
  warn_implausible_units(data, x_name)
  warn_group_names(data, x_name)
  if (!is.null(biomass)) {
    .chk_plot_biomass(biomass, call = call)
  }
  invisible(data)
}

.chk_measure_columns <- function(x, cols, x_name, count = FALSE, zero = FALSE) {
  for (col in cols) {
    nm <- column_xname(x_name, col)
    chk::chk_numeric(x[[col]], x_name = nm)
    chk::chk_not_any_na(x[[col]], x_name = nm)
    .chk_finite(x[[col]], nm)
    if (zero) {
      chk::chk_gte(x[[col]], value = 0, x_name = nm)
    } else {
      chk::chk_gt(x[[col]], value = 0, x_name = nm)
    }
    if (count) {
      chk::chk_whole_numeric(x[[col]], x_name = nm)
    }
  }
  invisible(x)
}

# The wet/dry data of either species.
.chk_wetdry_data <- function(data, x_name) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("wet_mass_g", "dry_mass_g"),
    x_name = x_name
  )
  .chk_measure_columns(data, c("wet_mass_g", "dry_mass_g"), x_name)
  # The ratio must lie in (0, 1) for the Beta likelihood.
  if (any(data$dry_mass_g >= data$wet_mass_g)) {
    cli::cli_abort(
      "{column_xname(x_name, 'dry_mass_g')} must be less than {.field wet_mass_g}."
    )
  }
  warn_dry_wet_ratio(data, x_name)
  warn_implausible_units(data, x_name)
  invisible(data)
}

# The carbon data of either species.
.chk_carbon_data <- function(data, x_name) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("sample_mass_mg", "carbon_mass_ug"),
    x_name = x_name
  )
  .chk_measure_columns(data, c("sample_mass_mg", "carbon_mass_ug"), x_name)
  # The carbon fraction must lie in (0, 1) for the Beta likelihood.
  if (any(carbon_fraction(data) >= 1)) {
    cli::cli_abort(c(
      "{column_xname(x_name, 'carbon_mass_ug')} must be less than the sample mass.",
      i = "Check that {.field carbon_mass_ug} is in micrograms and {.field sample_mass_mg} in milligrams."
    ))
  }
  warn_carbon_fraction(data, x_name)
  invisible(data)
}

.chk_group_columns <- function(x, x_name) {
  if (all(vapply(x[c("site", "year")], .vld_group_column, logical(1)))) {
    return(invisible(x))
  }
  for (col in c("site", "year")) {
    nm <- column_xname(x_name, col)
    chk::chk_character_or_factor(x[[col]], x_name = nm)
    chk::chk_not_any_na(x[[col]], x_name = nm)
  }
  invisible(x)
}

.chk_plot_biomass <- function(
  x,
  x_name = "`biomass`",
  call = rlang::caller_env()
) {
  if (.vld_plot_biomass(x)) {
    return(invisible(x))
  }
  chk::chk_data(x, x_name = x_name)
  chk::chk_superset(
    names(x),
    c("site", "year", "estimate", "lower", "upper"),
    x_name = x_name
  )
  .chk_group_columns(x, x_name)
  .chk_biomass_estimate(x, x_name)
  .chk_biomass_response(x, x_name, call = call)
  dup <- unique(site_year_key(x$site, x$year)[
    duplicated(site_year_key(x$site, x$year))
  ])
  cli::cli_abort(
    c(
      "{x_name} must have one row per site-year.",
      i = "Repeated: {.val {dup}}."
    ),
    call = call
  )
}

.chk_biomass_response <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_biomass_response(x)) {
    return(invisible(x))
  }
  cli::cli_abort(
    c(
      "{x_name} must be wet biomass ({.field biomass_kg_m2}), not {.field {attr(x, 'kb_response')}}.",
      i = "Predict it with {.code kb_predict_plot_biomass(measure = \"wet\")}."
    ),
    call = call
  )
}

.chk_biomass_limits <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_biomass_limits(x)) {
    return(invisible(x))
  }
  if (!all(c("lower", "upper") %in% names(x))) {
    cli::cli_abort(c(
      "{x_name} must have {.field lower} and {.field upper} columns.",
      i = "They are the compatibility limits of the in situ biomass estimate, which set its precision."
    ))
  }
  .chk_positive_measure(x$lower, x_name = column_xname(x_name, "lower"))
  .chk_positive_measure(x$upper, x_name = column_xname(x_name, "upper"))
  cli::cli_abort(
    "{column_xname(x_name, 'lower')} must be less than {.field upper}."
  )
}

.chk_biomass_estimate <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_biomass_estimate(x)) {
    return(invisible(x))
  }
  .chk_biomass_limits(x, x_name)
  .chk_positive_measure(x$estimate, x_name = column_xname(x_name, "estimate"))
  if (any(x$lower > x$estimate)) {
    cli::cli_abort(
      "{column_xname(x_name, 'lower')} must not exceed {.field estimate}."
    )
  }
  cli::cli_abort(
    "{column_xname(x_name, 'upper')} must not be less than {.field estimate}."
  )
}

# Both cover species take the same new_data (the survey columns).
#' @export
.chk_new_data.kb_fit_cover_biomass <- function(fit, new_data) {
  .chk_cover_survey(new_data, x_name = "`new_data`")
}


.chk_site_surveys <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_site_surveys(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{x_name} must be a data frame.")
  }
  chk::chk_superset(
    names(x),
    c("canopy_area_m2", "tide_height_m", "site", "year"),
    x_name = x_name
  )
  nm <- column_xname(x_name, "canopy_area_m2")
  chk::chk_numeric(x$canopy_area_m2, x_name = nm)
  chk::chk_not_any_na(x$canopy_area_m2, x_name = nm)
  .chk_finite(x$canopy_area_m2, nm)
  chk::chk_gte(x$canopy_area_m2, value = 0, x_name = nm)
  nm <- column_xname(x_name, "tide_height_m")
  chk::chk_numeric(x$tide_height_m, x_name = nm)
  chk::chk_not_any_na(x$tide_height_m, x_name = nm)
  .chk_finite(x$tide_height_m, nm)
  .chk_group_columns(x, x_name)
  # Every other column passed, so site_area_m2 is present and either invalid or
  # smaller than the canopy.
  .chk_positive_measure(x$site_area_m2, x_name = column_xname(x_name, "site_area_m2"))
  cli::cli_abort(c(
    "{column_xname(x_name, 'canopy_area_m2')} must not exceed {.field site_area_m2}.",
    i = "The canopy is the area mapped within the site boundary."
  ))
}

.chk_sum_by <- function(sum_by, data, call = rlang::caller_env()) {
  if (.vld_sum_by(sum_by, data)) {
    return(invisible(sum_by))
  }
  chk::chk_character(sum_by, x_name = "`sum_by`")
  chk::chk_not_any_na(sum_by, x_name = "`sum_by`")
  missing <- setdiff(sum_by, names(data))
  if (length(missing)) {
    cli::cli_abort(
      "{.arg sum_by} names {cli::qty(missing)}column{?s} {.field {missing}} that {.arg new_data} does not have.",
      call = call
    )
  }
  bad <- sum_by[!vapply(data[sum_by], .vld_group_column, logical(1))]
  cli::cli_abort(
    c(
      "{.arg sum_by} column{?s} {.field {bad}} must be character or factor with no missing values.",
      i = "Convert a numeric code with {.fn as.character} or {.fn factor}."
    ),
    call = call
  )
}

.chk_measure_fits <- function(measure, wetdry, carbon, call = rlang::caller_env()) {
  if (measure %in% c("dry", "carbon") && is.null(wetdry)) {
    cli::cli_abort("{.arg wetdry} is required for {measure} biomass.", call = call)
  }
  if (measure == "carbon" && is.null(carbon)) {
    cli::cli_abort("{.arg carbon} is required for carbon biomass.", call = call)
  }
  if (!is.null(wetdry)) {
    .chk_kb_fit(wetdry, "kb_fit_wetdry", call = call)
  }
  if (!is.null(carbon)) {
    .chk_kb_fit(carbon, "kb_fit_carbon", call = call)
  }
  invisible(NULL)
}

.chk_predictions <- function(
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (.vld_predictions(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort(
      "{.arg {x_name}} must be a {.cls kb_predictions} data frame.",
      call = call
    )
  }
  cli::cli_abort(
    "{.arg {x_name}} must have {.field estimate}, {.field lower}, and {.field upper} columns.",
    call = call
  )
}

# `x` is NULL when it could not be inferred from the prediction's metadata.
.chk_plot_x <- function(x, predictions, supplied, call = rlang::caller_env()) {
  if (.vld_plot_x(x, predictions)) {
    return(invisible(x))
  }
  if (supplied) {
    cli::cli_abort(
      "{.arg x} must name a column of {.arg predictions}, not {.val {x}}.",
      call = call
    )
  }
  cli::cli_abort(
    c(
      "Cannot infer the x-axis column from {.arg predictions}.",
      i = "Supply {.arg x}."
    ),
    call = call
  )
}

.chk_log_axis <- function(log_axis, predictions, x, call = rlang::caller_env()) {
  if (.vld_log_axis(log_axis, predictions, x)) {
    return(invisible(log_axis))
  }
  if (!.vld_log_y(predictions)) {
    cli::cli_abort(
      c(
        "A log y-axis needs positive {.field estimate}, {.field lower}, and {.field upper} values.",
        i = "Use {.code log_axis = \"none\"}."
      ),
      call = call
    )
  }
  if (!is.numeric(predictions[[x]])) {
    cli::cli_abort(
      c(
        "A log x-axis needs a numeric x-axis, not {.field {x}}.",
        i = "Use {.code log_axis = \"y\"}."
      ),
      call = call
    )
  }
  cli::cli_abort(
    c(
      "A log x-axis needs positive {.field {x}} values.",
      i = "Predict at positive {.field {x}} values, for example with {.fn kb_new_data}."
    ),
    call = call
  )
}
