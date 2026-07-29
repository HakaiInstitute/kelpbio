#' Describe a Fitted Model
#'
#' Render the complete fitted model in scientific notation (the default) or as a
#' report-ready methods paragraph (`prose = TRUE`). The notation uses the
#' package's own parameter names (`bWeight`, `bDiameter`, `sSite`, ...), so every
#' symbol matches a row of [tidy()], [summary()], and [coef()].
#'
#' @details
#' The description reflects the fitted object: the priors shown are the fit's
#' stored priors, the centering reference is the fit's stored geometric-mean
#' reference, and a `site:year` effect dropped at fit time (single-year data) is
#' omitted from both the linear predictor and the random-effect list. The
#' response and predictor are named without units, since the data columns are
#' unitless and the model is scale-invariant (centered in log space).
#'
#' @param fit A `kb_fit_weight` object.
#' @param prose A flag specifying whether to render a methods-section paragraph
#'   instead of the notation block.
#'
#' @return The rendered lines, invisibly (a character vector). Called for the
#'   printed description.
#' @family model
#' @export
#'
#' @examples
#' kb_model_describe(fit_weight_sim_nereo)
#' kb_model_describe(fit_weight_sim_macro, prose = TRUE)
kb_model_describe <- function(fit, prose = FALSE) {
  UseMethod("kb_model_describe")
}

#' @export
kb_model_describe.default <- function(fit, prose = FALSE) {
  cli::cli_abort(
    "{.fun kb_model_describe} is not defined for {.cls {class(fit)[1]}}."
  )
}

#' @export
kb_model_describe.kb_fit_weight_nereo <- function(fit, prose = FALSE) {
  chk::chk_flag(prose)
  .render_model(.model_spec_nereo(fit), prose)
}

#' @export
kb_model_describe.kb_fit_weight_macro <- function(fit, prose = FALSE) {
  chk::chk_flag(prose)
  .render_model(.model_spec_macro(fit), prose)
}

# ---- species model specs (single source for notation and prose) -------------

.model_spec_nereo <- function(fit) {
  sy <- isTRUE(fit$meta$site_year_on)
  d0 <- signif(fit$meta$diameter_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c(
    "bWeight",
    "bSite[site]",
    "(bDiameter + bSiteDiameter[site]) * x",
    "bDiameter2 * x^2"
  )
  random <- list(
    list(term = "bSite[site]", sd = "sSite", gloss = "site intercept"),
    list(
      term = "bSiteDiameter[site]",
      sd = "sSiteDiameter",
      gloss = "site slope on log-diameter"
    )
  )
  priors <- list(
    bWeight = pri$intercept,
    bDiameter = pri$diameter,
    bDiameter2 = pri$diameter2,
    sWeight = pri$sd_residual,
    sSite = pri$sd_site,
    sSiteDiameter = pri$sd_site_diameter
  )
  if (sy) {
    mean_terms <- c(mean_terms, "bSiteYear[site, year]")
    random <- c(random, list(list(
      term = "bSiteYear[site, year]",
      sd = "sSiteYear",
      gloss = "site:year intercept"
    )))
    priors$sSiteYear <- pri$sd_site_year
  }

  list(
    title = "Weight allometry",
    species = .species_label(fit$meta$species),
    response_desc = "wet weight",
    predictor_desc = "sub-bulb diameter",
    likelihood = "log(weight) ~ Student-t(4, mu, sWeight)",
    mean_lhs = "mu",
    mean_terms = mean_terms,
    centering = sprintf(
      "x = log(diameter) - log(d0),  d0 = %s  (geometric mean diameter)",
      format(d0)
    ),
    random = random,
    priors = priors,
    prose = sprintf(
      paste0(
        "Wet weight was modelled on the log scale with a Student-t likelihood ",
        "(4 degrees of freedom) as an allometric function of sub-bulb diameter. ",
        "Expected log weight was a quadratic function of log diameter, centred ",
        "at the geometric mean diameter (%s), with the intercept and the ",
        "log-diameter slope varying by site%s. Regularizing priors were placed ",
        "on all parameters (see the notation form for the hyperparameters)."
      ),
      format(d0),
      if (sy) " and the intercept additionally varying by site-year" else ""
    )
  )
}

.model_spec_macro <- function(fit) {
  sy <- isTRUE(fit$meta$site_year_on)
  f0 <- signif(fit$meta$fronds_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c("bWeight", "bFronds * x", "bSite[site]", "bYear[year]")
  random <- list(
    list(term = "bSite[site]", sd = "sSite", gloss = "site intercept"),
    list(term = "bYear[year]", sd = "sYear", gloss = "year intercept")
  )
  priors <- list(
    bWeight = pri$intercept,
    bFronds = pri$fronds,
    shape = pri$shape,
    sSite = pri$sd_site,
    sYear = pri$sd_year
  )
  if (sy) {
    mean_terms <- c(mean_terms, "bSiteYear[site, year]")
    random <- c(random, list(list(
      term = "bSiteYear[site, year]",
      sd = "sSiteYear",
      gloss = "site:year intercept"
    )))
    priors$sSiteYear <- pri$sd_site_year
  }

  list(
    title = "Weight allometry",
    species = .species_label(fit$meta$species),
    response_desc = "wet weight",
    predictor_desc = "frond count",
    likelihood = "weight ~ Gamma(shape, shape / mu)",
    mean_lhs = "log(mu)",
    mean_terms = mean_terms,
    centering = sprintf(
      "x = log(fronds) - log(f0),  f0 = %s  (geometric mean frond count)",
      format(f0)
    ),
    random = random,
    priors = priors,
    prose = sprintf(
      paste0(
        "Wet weight was modelled with a Gamma likelihood as an allometric ",
        "function of frond count. Expected weight was log-linear in log frond ",
        "count, centred at the geometric mean (%s), with the intercept varying ",
        "by site, year%s. Regularizing priors were placed on all parameters ",
        "(see the notation form for the hyperparameters)."
      ),
      format(f0),
      if (sy) ", and site-year" else ""
    )
  )
}

# ---- rendering ---------------------------------------------------------------

# Format a stored prior object as scientific notation for the description.
.describe_prior <- function(p) {
  if (inherits(p, "kb_prior_normal")) {
    sprintf("Normal(%s, %s)", format(p$mean), format(p$sd))
  } else if (inherits(p, "kb_prior_exponential")) {
    sprintf("Exponential(%s)", format(p$rate))
  } else {
    format(p)
  }
}

# Render a model spec as notation (prose = FALSE) or a methods paragraph
# (prose = TRUE); print to stdout and return the lines invisibly.
.render_model <- function(spec, prose) {
  if (prose) {
    lines <- strwrap(spec$prose, width = 76)
    cli::cat_line(lines)
    return(invisible(lines))
  }

  mean_lines <- c(
    paste0("  ", spec$mean_lhs, " = ", spec$mean_terms[1]),
    paste0("     + ", spec$mean_terms[-1])
  )
  re_lines <- vapply(
    spec$random,
    function(r) {
      sprintf("  %s ~ Normal(0, %s)    %s", r$term, r$sd, r$gloss)
    },
    character(1)
  )
  prior_lines <- vapply(
    names(spec$priors),
    function(nm) sprintf("  %-14s ~ %s", nm, .describe_prior(spec$priors[[nm]])),
    character(1)
  )

  lines <- c(
    paste0(spec$title, " - ", spec$species),
    paste0(
      "Response: ",
      spec$response_desc,
      "; predictor: ",
      spec$predictor_desc
    ),
    "",
    "Likelihood",
    paste0("  ", spec$likelihood),
    mean_lines,
    paste0("  ", spec$centering),
    "",
    "Random effects",
    re_lines,
    "",
    "Priors",
    prior_lines
  )
  cli::cat_line(lines)
  invisible(lines)
}
