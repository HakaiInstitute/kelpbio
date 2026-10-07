# One Stan data field per hyperparameter, `prior_<entry>_<argument>` (e.g.
# prior_sd_site_rate).
prior_data <- function(priors) {
  fields <- purrr::imap(priors, function(prior, entry) {
    hyper <- unclass(prior)
    rlang::set_names(hyper, paste0("prior_", entry, "_", names(hyper)))
  })
  purrr::list_flatten(unname(fields))
}
