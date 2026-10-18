# The fit shared by the cover calibration models, identical across species but
# for the data check and default priors (decisions/species-as-variant.md).
fit_cover_calibration_model <- function(
  data,
  priors,
  species,
  check_data,
  defaults,
  ...,
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
  progress <- rlang::arg_match(
    progress,
    c("bar", "verbose", "none"),
    error_call = call
  )
  .chk_fit_inputs(
    data,
    check_data,
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
  data <- survey_calibration_rows(data, progress = progress)
  if (!nrow(data) && !prior_only) {
    cli::cli_abort(
      c(
        "No survey in {.arg data} has drone cover.",
        i = "A survey has drone cover when {.field plot_area_m2}, {.field canopy_area_m2}, and {.field tide_height_m} are given."
      ),
      call = call
    )
  }
  priors <- resolve_priors(priors, defaults, call = call)
  stan_data <- assemble_cover_calibration_data(
    data,
    priors,
    prior_only = prior_only
  )

  parameters <- fit_parameters(priors, c("site_effect", "year_effect"))
  core <- fit_stan(
    stanmodels$cover_calibration,
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "cover_calibration",
    ...,
    call = call
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "cover_calibration",
    species = species,
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      # Most site-years hold one plot, so a site:year effect would be
      # confounded with the residual.
      site_year_on = FALSE,
      response = "biomass_kg_m2",
      # Curves run over tide-corrected cover, a proportion of the plot, which
      # the data do not hold as a column (it depends on the fitted tide_height_slope).
      predictor = "cover",
      predictor_range = c(0, 1)
    )
  )
}

# The rows with drone cover, with each survey's biomass draws reduced to their
# mean (`biomass_kg_m2`) and SD (`biomass_sd_kg_m2`), so the fit stores no
# draws per observation. Silent when progress = "none".
survey_calibration_rows <- function(data, progress = "bar") {
  data <- tibble::as_tibble(data)
  covered <- !is.na(data$canopy_area_m2)
  n <- sum(!covered)
  if (n > 0L && !identical(progress, "none")) {
    cli::cli_inform(c(
      i = "{n} survey{?s} without drone cover {cli::qty(n)}{?is/are} not fitted."
    ))
  }
  data <- data[covered, , drop = FALSE]
  draws <- posterior::draws_of(data$biomass_kg_m2)
  dim(draws) <- c(nrow(draws), nrow(data))
  data$biomass_kg_m2 <- colMeans(draws)
  data$biomass_sd_kg_m2 <- apply(draws, 2L, stats::sd)
  # The survey verb's summary columns would be read as the calibration's own
  # predictions, and its attributes describe that prediction, not these data.
  data <- data[setdiff(names(data), c("estimate", "lower", "upper"))]
  tibble::as_tibble(as.data.frame(data))
}
