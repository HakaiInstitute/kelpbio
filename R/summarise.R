# Summarise a subset of a fit's draws into a tidy tibble: one row per scalar
# term (e.g. bSite[1]), with estimate / std.error / conf.low / conf.high
# computed over draws via posterior. Internal.
summarise_draws_terms <- function(draws, variables, conf_level = 0.95) {
  a <- (1 - conf_level) / 2
  sub <- posterior::subset_draws(draws, variable = variables)
  out <- posterior::summarise_draws(
    sub,
    estimate = stats::median,
    std.error = stats::sd,
    conf.low = function(x) unname(posterior::quantile2(x, a)),
    conf.high = function(x) unname(posterior::quantile2(x, 1 - a))
  )
  names(out)[names(out) == "variable"] <- "term"
  tibble::as_tibble(out)
}
