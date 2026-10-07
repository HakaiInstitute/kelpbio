# The Stan data fields for a resolved prior list: one field per hyperparameter,
# named `prior_<entry>_<argument>` after the entry and the prior constructor's
# argument (prior_intercept_mean, prior_sd_site_rate, prior_cover_slope_sdlog).
# Each Stan program declares the fields for its own entries.
prior_data <- function(priors) {
  fields <- purrr::imap(priors, function(prior, entry) {
    hyper <- unclass(prior)
    rlang::set_names(hyper, paste0("prior_", entry, "_", names(hyper)))
  })
  purrr::list_flatten(unname(fields))
}
