# The parameters a fit estimates, from its priors: every parameter but the
# per-level `effects` has a prior entry of its own name
# (decisions/parameter-naming.md), in the model's order. `off` names the
# parameters the data or the model form switched off; they are sampled but not
# stored.
fit_parameters <- function(priors, effects = character(0), off = character(0)) {
  list(
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
