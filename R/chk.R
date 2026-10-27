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
      i = "Grids are built for weight, size, and cover calibration fits."
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
  missing <- groups[vapply(x[groups], anyNA, logical(1))]
  if (!length(missing)) {
    return(.chk_id_column(x$year, "year", column_xname(x_name, "year")))
  }
  col <- missing[1]
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
    i = "Remove plants with 0 fronds."
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

# The fits a derived verb combines, NULLs allowed: the conversion fits of the
# right model, all of one species and one number of draws.
.chk_derived_fits <- function(fits, call = rlang::caller_env()) {
  fits <- fits[!vapply(fits, is.null, logical(1))]
  if (!is.null(fits$wetdry)) {
    .chk_kb_fit(fits$wetdry, "kb_fit_wetdry", x_name = "wetdry", call = call)
  }
  if (!is.null(fits$carbon)) {
    .chk_kb_fit(fits$carbon, "kb_fit_carbon", x_name = "carbon", call = call)
  }
  if (!is.null(fits$nitrogen)) {
    .chk_kb_fit(fits$nitrogen, "kb_fit_nitrogen", x_name = "nitrogen", call = call)
  }
  .chk_same_species(fits, call = call)
  .chk_same_ndraws(fits, call = call)
  invisible(fits)
}

# A size census must give the weight fit's predictor.
.chk_census_size <- function(weight, size_census, call = rlang::caller_env()) {
  if (.vld_census_size(weight, size_census)) {
    return(invisible(size_census))
  }
  predictor <- weight$meta$predictor
  cli::cli_abort(
    c(
      "{.arg size} must have a {.field {predictor}} column, the predictor of {.arg weight}.",
      i = "{.arg weight} is a {.val {(.species_label(weight$meta$species))}} weight fit."
    ),
    call = call
  )
}

.chk_n_plants <- function(x, call = rlang::caller_env()) {
  .with_call(
    {
      chk::chk_whole_number(x, x_name = "`n_plants`")
      chk::chk_gte(x, value = 1, x_name = "`n_plants`")
      .chk_finite(x, "`n_plants`")
    },
    call
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

.chk_representative_site_fits <- function(
  representative_site,
  fits,
  call = rlang::caller_env()
) {
  if (.vld_representative_site_fits(representative_site, fits)) {
    return(invisible(representative_site))
  }
  if ("size" %in% names(representative_site) && !"size" %in% fits) {
    cli::cli_abort(
      c(
        "{.arg representative_site} cannot name {.val size} with a size census.",
        i = "A size census has no site effects; name only {.val weight}."
      ),
      call = call
    )
  }
  cli::cli_abort(
    c(
      "{.arg representative_site} must be a character vector or a list named by {.or {.val {fits}}}.",
      i = "For example, {.code list({fits[1]} = \"site_a\")}."
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
      chk::chk_range(conf_level, inclusive = FALSE)
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
    return(invisible(x))
  }
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort("{.arg {x_name}} must be a directory path or {.code NULL}.")
  }
  if (!dir.exists(x)) {
    cli::cli_abort(
      "{.arg {x_name}} must be a path to an existing directory, or {.code NULL}."
    )
  }
  cli::cli_abort("{.arg {x_name}} must be a writable directory.")
}

.chk_sampling_dots <- function(x, call = rlang::caller_env()) {
  if (.vld_sampling_dots(x)) {
    return(invisible(x))
  }
  if (any(rlang::names2(x) == "")) {
    cli::cli_abort(
      c(
        "Arguments in {.arg ...} must be named.",
        i = "They are passed to the sampler, e.g. {.code control = list(adapt_delta = 0.99)}."
      ),
      call = call
    )
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

# The checks every fit runs before assembling Stan data, in order: sampler
# arguments, the model's data check, then rows. Errors name `call`, the fit the
# user called. A multi-argument bundle like .chk_sampler_args(): no .vld_ partner.
.chk_fit_inputs <- function(
  data,
  check_data,
  prior_only,
  chains,
  niters,
  nthin,
  cores,
  seed,
  progress,
  progress_dir,
  call = rlang::caller_env()
) {
  .chk_sampler_args(
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    call = call
  )
  .with_call(check_data(data, x_name = "`data`"), call)
  .chk_fit_rows(data, prior_only, call = call)
  invisible(data)
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

# Size new_data has no predictor column.
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

#' @export
.chk_new_data.kb_fit_nitrogen <- function(fit, new_data) {
  .chk_new_data_size(new_data)
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
    c("canopy_area_m2", "plot_area_m2", "canopy_tide_height_m"),
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
  nm <- column_xname(x_name, "canopy_tide_height_m")
  chk::chk_numeric(x$canopy_tide_height_m, x_name = nm)
  chk::chk_not_any_na(x$canopy_tide_height_m, x_name = nm)
  .chk_finite(x$canopy_tide_height_m, nm)
  if ("biomass_sd_kg_m2" %in% names(x)) {
    nm <- column_xname(x_name, "biomass_sd_kg_m2")
    chk::chk_numeric(x$biomass_sd_kg_m2, x_name = nm)
    chk::chk_not_any_na(x$biomass_sd_kg_m2, x_name = nm)
    .chk_finite(x$biomass_sd_kg_m2, nm)
    chk::chk_gte(x$biomass_sd_kg_m2, value = 0, x_name = nm)
  }
}

# The calibration data shared by both species: survey biomass from
# kb_predict_biomass_in_situ() with each survey's drone cover on its row.
.chk_cover_calibration_data <- function(data, x_name, call = rlang::caller_env()) {
  chk::chk_data(data, x_name = x_name)
  hint <- "Use the output of {.fn kb_predict_biomass_in_situ} with its defaults: wet biomass per m\u00b2, one row per survey."
  if (!"biomass_kg_m2" %in% names(data)) {
    cli::cli_abort(
      c("{x_name} must have a {.field biomass_kg_m2} column.", i = hint),
      call = call
    )
  }
  if (!posterior::is_rvar(data$biomass_kg_m2)) {
    cli::cli_abort(
      c("{column_xname(x_name, 'biomass_kg_m2')} must be a column of draws.", i = hint),
      call = call
    )
  }
  missing <- setdiff(
    c("site", "year", "plot_area_m2", "canopy_area_m2", "canopy_tide_height_m"),
    names(data)
  )
  if (length(missing)) {
    cli::cli_abort(
      c("{x_name} must have the column{?s} {.field {missing}}.", i = hint),
      call = call
    )
  }
  .chk_group_columns(data, x_name)
  .chk_drone_columns(data, x_name)
  draws <- posterior::draws_of(data$biomass_kg_m2)
  if (!all(is.finite(draws)) || any(draws < 0)) {
    cli::cli_abort(
      "{column_xname(x_name, 'biomass_kg_m2')} must hold finite draws of at least 0.",
      call = call
    )
  }
  warn_implausible_units(data, x_name)
  warn_group_names(data, x_name)
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

# The nitrogen data of either species.
.chk_nitrogen_data <- function(data, x_name) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("sample_mass_mg", "nitrogen_mass_ug"),
    x_name = x_name
  )
  .chk_measure_columns(data, c("sample_mass_mg", "nitrogen_mass_ug"), x_name)
  # The nitrogen fraction must lie in (0, 1) for the Beta likelihood.
  if (any(nitrogen_fraction(data) >= 1)) {
    cli::cli_abort(c(
      "{column_xname(x_name, 'nitrogen_mass_ug')} must be less than the sample mass.",
      i = "Check that {.field nitrogen_mass_ug} is in micrograms and {.field sample_mass_mg} in milligrams."
    ))
  }
  warn_nitrogen_fraction(data, x_name)
  invisible(data)
}

.chk_unique_surveys <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_unique_surveys(x)) {
    return(invisible(x))
  }
  id <- id_text(x$survey_id)
  repeated <- unique(id[duplicated(id)])
  cli::cli_abort(c(
    "{column_xname(x_name, 'survey_id')} must identify each survey once.",
    i = "Repeated: {.val {utils::head(repeated, 5)}}."
  ))
}

.chk_drone_columns <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_drone_columns(x)) {
    return(invisible(x))
  }
  cols <- c("plot_area_m2", "canopy_area_m2", "canopy_tide_height_m")
  absent <- setdiff(cols, names(x))
  if (length(absent)) {
    cli::cli_abort(c(
      "{x_name} must have all of {.field {cols}} or none of them.",
      i = "Missing: {.field {absent}}."
    ))
  }
  missing <- is.na(x[cols])
  partial <- rowSums(missing) %in% seq_len(length(cols) - 1L)
  if (any(partial)) {
    col <- cols[colSums(missing[partial, , drop = FALSE]) > 0][1]
    cli::cli_abort(c(
      "{column_xname(x_name, col)} must not be missing where the other drone columns are given.",
      i = "Give {.field {cols}} together, or leave all three missing for a survey without drone cover."
    ))
  }
  d <- x[!missing[, 1L], cols, drop = FALSE]
  .chk_positive_measure(d$plot_area_m2, column_xname(x_name, "plot_area_m2"))
  nm <- column_xname(x_name, "canopy_area_m2")
  chk::chk_numeric(d$canopy_area_m2, x_name = nm)
  .chk_finite(d$canopy_area_m2, nm)
  chk::chk_gte(d$canopy_area_m2, value = 0, x_name = nm)
  if (any(d$canopy_area_m2 > d$plot_area_m2)) {
    cli::cli_abort("{nm} must not exceed {.field plot_area_m2}.")
  }
  nm <- column_xname(x_name, "canopy_tide_height_m")
  chk::chk_numeric(d$canopy_tide_height_m, x_name = nm)
  .chk_finite(d$canopy_tide_height_m, nm)
  invisible(x)
}

.chk_partial <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_partial(x)) {
    return(invisible(x))
  }
  chk::chk_logical(x, x_name = x_name)
  cli::cli_abort("{x_name} must not have missing values.")
}

.chk_census_join <- function(size_census, survey, x_name = deparse(substitute(size_census))) {
  if (.vld_census_join(size_census, survey)) {
    return(invisible(size_census))
  }
  id <- id_text(size_census$survey_id)
  orphan <- !id %in% id_text(survey$survey_id)
  n <- sum(orphan)
  unmatched <- unique(id[orphan])
  cli::cli_abort(c(
    "{n} plant{?s} in {x_name} {cli::qty(n)}match{?es/} no survey.",
    i = "Plants join to their survey by {.field survey_id}.",
    i = "Unmatched {.field survey_id}: {.val {utils::head(unmatched, 5)}}."
  ))
}

# A survey table; with `size_census`, the census, and the join too.
.chk_survey_data <- function(data, size_census, x_name, census_name) {
  chk::chk_data(data, x_name = x_name)
  .chk_rows(data, x_name)
  required <- c("survey_id", "site", "year", "survey_area_m2")
  if (is.null(size_census)) {
    required <- c(required, "plants")
  }
  chk::chk_superset(names(data), required, x_name = x_name)
  .chk_group_columns(data, x_name, c("survey_id", "site", "year"))
  .chk_measure_columns(data, "survey_area_m2", x_name)
  if (is.null(size_census)) {
    .chk_measure_columns(data, "plants", x_name, zero = TRUE)
  } else if ("plants" %in% names(data)) {
    cli::cli_abort(c(
      "{x_name} must not have a {.field plants} column when a size census is given.",
      i = "The counts come from the size census rows."
    ))
  }
  .chk_unique_surveys(data, x_name)
  .chk_drone_columns(data, x_name)
  warn_implausible_units(data, x_name)
  warn_group_names(data, x_name)
  warn_survey_area(data, x_name)
  if (!is.null(size_census)) {
    size <- intersect(c("diameter_mm", "fronds"), names(size_census))
    if (length(size) != 1L) {
      cli::cli_abort(
        "{census_name} must have one of {.field diameter_mm} (Nereocystis) or {.field fronds} (Macrocystis)."
      )
    }
    .chk_size_census_data(size_census, size, census_name)
    .chk_census_join(size_census, data, census_name)
  }
  invisible(data)
}

# A size census, every plant a survey counted; `size` is the species' size
# column.
.chk_size_census_data <- function(data, size, x_name) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(names(data), c("survey_id", size), x_name = x_name)
  .chk_group_columns(data, x_name, "survey_id")
  if (identical(size, "fronds")) {
    nm <- column_xname(x_name, "fronds")
    chk::chk_numeric(data$fronds, x_name = nm)
    chk::chk_not_any_na(data$fronds, x_name = nm)
    .chk_finite(data$fronds, nm)
    .chk_frond_reaches_1m(data$fronds, nm)
    chk::chk_whole_numeric(data$fronds, x_name = nm)
  } else {
    .chk_measure_columns(data, size, x_name)
  }
  if ("partial" %in% names(data)) {
    .chk_partial(data$partial, column_xname(x_name, "partial"))
  }
  warn_implausible_units(data, x_name)
  invisible(data)
}

# Grouping and identifier columns, converted on entry by ids_as_character().
.chk_group_columns <- function(x, x_name, cols = c("site", "year")) {
  for (col in cols) {
    .chk_id_column(x[[col]], col, column_xname(x_name, col))
  }
  invisible(x)
}

# `site` is character or factor; `year` may also be whole numbers, and
# `survey_id` any finite numbers.
.chk_id_column <- function(x, col, x_name = deparse(substitute(x))) {
  if (.vld_id_column(x, col)) {
    return(invisible(x))
  }
  numeric_ok <- col %in% c("year", "survey_id")
  if (numeric_ok && is.numeric(x)) {
    chk::chk_not_any_na(x, x_name = x_name)
    .chk_finite(x, x_name)
    chk::chk_whole_numeric(x, x_name = x_name)
  }
  if (numeric_ok && !is.character(x) && !is.factor(x)) {
    cli::cli_abort("{x_name} must be character, factor, or numeric.")
  }
  chk::chk_character_or_factor(x, x_name = x_name)
  chk::chk_not_any_na(x, x_name = x_name)
  invisible(x)
}

# Both cover species take the same new_data (the survey columns).
#' @export
.chk_new_data.kb_fit_cover_calibration <- function(fit, new_data) {
  .chk_cover_survey(new_data, x_name = "`new_data`")
}

.chk_canopy_maps <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_canopy_maps(x)) {
    return(invisible(x))
  }
  if (!is.data.frame(x)) {
    cli::cli_abort("{x_name} must be a data frame.")
  }
  chk::chk_superset(
    names(x),
    c("canopy_area_m2", "canopy_tide_height_m", "site", "year", "classified_area_m2"),
    x_name = x_name
  )
  nm <- column_xname(x_name, "canopy_area_m2")
  chk::chk_numeric(x$canopy_area_m2, x_name = nm)
  chk::chk_not_any_na(x$canopy_area_m2, x_name = nm)
  .chk_finite(x$canopy_area_m2, nm)
  chk::chk_gte(x$canopy_area_m2, value = 0, x_name = nm)
  nm <- column_xname(x_name, "canopy_tide_height_m")
  chk::chk_numeric(x$canopy_tide_height_m, x_name = nm)
  chk::chk_not_any_na(x$canopy_tide_height_m, x_name = nm)
  .chk_finite(x$canopy_tide_height_m, nm)
  .chk_group_columns(x, x_name)
  .chk_positive_measure(
    x$classified_area_m2,
    x_name = column_xname(x_name, "classified_area_m2")
  )
  # Every other column passed, so the canopy exceeds the classified area.
  cli::cli_abort(c(
    "{column_xname(x_name, 'canopy_area_m2')} must not exceed {.field classified_area_m2}.",
    i = "The canopy is found within the area the classification covered."
  ))
}

.chk_pool_by <- function(pool_by, data, data_name = "new_data", call = rlang::caller_env()) {
  if (.vld_pool_by(pool_by, data)) {
    return(invisible(pool_by))
  }
  chk::chk_character(pool_by, x_name = "`pool_by`")
  chk::chk_not_any_na(pool_by, x_name = "`pool_by`")
  missing <- setdiff(pool_by, names(data))
  if (length(missing)) {
    cli::cli_abort(
      "{.arg pool_by} names {cli::qty(missing)}column{?s} {.field {missing}} that {.arg {data_name}} does not have.",
      call = call
    )
  }
  bad <- pool_by[!vapply(data[pool_by], .vld_group_column, logical(1))]
  cli::cli_abort(
    c(
      "{.arg pool_by} column{?s} {.field {bad}} must be character or factor with no missing values.",
      i = "Convert a numeric code with {.fn as.character} or {.fn factor}."
    ),
    call = call
  )
}

.chk_measure_fits <- function(
  measure,
  wetdry,
  carbon,
  nitrogen,
  call = rlang::caller_env()
) {
  if (.vld_measure_fits(measure, wetdry, carbon, nitrogen)) {
    return(invisible(NULL))
  }
  if (measure %in% c("dry", "carbon", "nitrogen") && is.null(wetdry)) {
    cli::cli_abort("{.arg wetdry} is required for {measure} biomass.", call = call)
  }
  if (measure == "carbon" && is.null(carbon)) {
    cli::cli_abort("{.arg carbon} is required for carbon biomass.", call = call)
  }
  if (measure == "nitrogen" && is.null(nitrogen)) {
    cli::cli_abort("{.arg nitrogen} is required for nitrogen biomass.", call = call)
  }
  if (!is.null(wetdry)) {
    .chk_kb_fit(wetdry, "kb_fit_wetdry", call = call)
  }
  if (!is.null(carbon)) {
    .chk_kb_fit(carbon, "kb_fit_carbon", call = call)
  }
  if (!is.null(nitrogen)) {
    .chk_kb_fit(nitrogen, "kb_fit_nitrogen", call = call)
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
