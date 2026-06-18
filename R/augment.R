#' Augment Weight Data with Fitted Values
#'
#' Return the input data augmented with fitted values and residuals, evaluated
#' at each observed row using that row's estimated random effects (site
#' intercept, site slope, and site:year). Full precision; for residual
#' diagnostics and posterior predictive checks.
#'
#' @inheritParams params
#' @param x A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return The input data with added columns `.fitted`, `.resid`, `.lower`,
#'   `.upper`.
#' @exportS3Method generics::augment
augment.kb_fit_weight <- function(x, conf_level = 0.95, ...) {
  rlang::check_dots_empty()
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)

  data <- x$data
  d <- x$draws
  b0 <- as.vector(posterior::draws_of(d$bWeight30))
  b1 <- as.vector(posterior::draws_of(d$bDiameter))
  b2 <- as.vector(posterior::draws_of(d$bDiameter2))
  a_site <- posterior::draws_of(d$bSite) # [ndraws x nSite]
  a_slope <- posterior::draws_of(d$bSiteDiameter) # [ndraws x nSite]
  a_sy <- posterior::draws_of(d$bSiteYear) # [ndraws x nSite x nYear]

  si <- as.integer(factor(data$site, levels = x$meta$site_levels))
  yi <- as.integer(factor(data$year, levels = x$meta$year_levels))
  log_dc <- log(data$diameter) - log(x$meta$diameter_ref)

  a <- (1 - conf_level) / 2
  n <- nrow(data)
  fitted <- lower <- upper <- numeric(n)
  for (i in seq_len(n)) {
    lp <- b0 + a_site[, si[i]] +
      (b1 + a_slope[, si[i]]) * log_dc[i] +
      b2 * log_dc[i]^2 +
      a_sy[, si[i], yi[i]]
    w <- exp(lp)
    fitted[i] <- stats::median(w)
    lower[i] <- stats::quantile(w, a, names = FALSE)
    upper[i] <- stats::quantile(w, 1 - a, names = FALSE)
  }

  dplyr::mutate(
    tibble::as_tibble(data),
    .fitted = fitted,
    .resid = data$weight - fitted,
    .lower = lower,
    .upper = upper
  )
}
