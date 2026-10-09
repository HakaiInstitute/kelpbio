# The fit shared by the proportion models (wet/dry, carbon), identical across
# species; the exported wrappers supply the species' data check, default priors,
# and Stan data assembler (decisions/species-as-variant.md).
fit_beta_model <- function(
  data,
  priors,
  model,
  species,
  response,
  check_data,
  defaults,
  assemble,
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

  # The species' own check, so its errors name the function users know.
  .with_call(check_data(data, x_name = "`data`"), call)
  .chk_fit_rows(data, prior_only, call = call)
  priors <- resolve_priors(priors, defaults, call = call)
  stan_data <- assemble(data, priors, prior_only = prior_only)

  parameters <- fit_parameters(priors)
  core <- fit_stan(
    stanmodels[[model]],
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = model,
    ...,
    call = call
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = model,
    species = species,
    # A proportion within one sample, so there is no survey effort.
    offset = NULL,
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(response = response)
  )
}
