# The parameters a fit samples and the terms it estimates. `off` parameters are
# still sampled (from their priors) but are not estimates.
fit_parameters <- function(priors, effects = character(0), off = character(0)) {
  list(
    sampled = c(names(priors), effects),
    fixed = setdiff(names(priors), off),
    random = setdiff(effects, off)
  )
}

# The per-level group effects of the site:year models, and those switched off
# when the data omit the site:year effect.
GROUP_EFFECTS <- c("site_effect", "year_effect", "site_year_effect")
site_year_off <- function(site_year_on) {
  if (site_year_on) character(0) else c("sd_site_year", "site_year_effect")
}
