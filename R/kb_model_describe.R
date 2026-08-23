#' Describe a Fitted Model
#'
#' Render the complete fitted model in scientific notation (the default) or as a
#' report-ready methods paragraph (`prose = TRUE`). The notation uses the
#' package's own parameter names (`bWeight`, `sSite`, ...), so every symbol
#' matches a row of [tidy()], [summary()], and [coef()].
#'
#' @details
#' The description reflects the fitted object: the priors shown are the fit's
#' stored priors, any predictor centering uses the reference value stored on the
#' fit, and a random effect dropped at fit time (such as `site:year` for
#' single-year data) is omitted from both the linear predictor and the
#' random-effect list. The response and predictors are named without units, since
#' the data columns are unitless.
#'
#' @param fit A `kb_fit` object.
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
  .chk_kb_fit(fit, call = rlang::current_env())
  .abort_no_method("kb_model_describe", fit, call = rlang::current_env())
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
  sy <- .site_year_on(fit)
  d0 <- signif(fit$meta$predictor_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c(
    "bWeight",
    "bYear[year]",
    "bSite[site]",
    "log(bFloor + (1 - bFloor) * x^bPower[site])"
  )
  random <- list(
    list(term = "bYear[year]", sd = "sYear", gloss = "year intercept"),
    list(term = "bSite[site]", sd = "sSite", gloss = "site intercept"),
    list(
      term = "bSitePower[site]",
      sd = "sSitePower",
      gloss = "site allometric exponent (log scale)"
    )
  )
  priors <- list(
    bWeight = pri$intercept,
    bLogPower = pri$log_power,
    bFloor = pri$floor,
    bNu = pri$nu,
    sWeight = pri$sd_residual,
    sYear = pri$sd_year,
    sSite = pri$sd_site,
    sSitePower = pri$sd_site_power
  )
  if (sy) {
    mean_terms <- c(mean_terms, "bSiteYear[site, year]")
    random <- c(
      random,
      list(list(
        term = "bSiteYear[site, year]",
        sd = "sSiteYear",
        gloss = "site:year intercept"
      ))
    )
    priors$sSiteYear <- pri$sd_site_year
  }

  list(
    title = "Weight allometry",
    species = .species_label(fit$meta$species),
    response_desc = "wet weight",
    predictor_desc = "sub-bulb diameter",
    likelihood = "log(weight) ~ Student-t(bNu, mu, sWeight)",
    mean_lhs = "mu",
    mean_terms = mean_terms,
    centering = paste0(
      sprintf(
        "x = diameter / d0,  d0 = %s  (geometric mean diameter)",
        format(d0)
      ),
      "\n  bPower[site] = exp(bLogPower + bSitePower[site])"
    ),
    random = random,
    priors = priors,
    prose = sprintf(
      paste0(
        "Wet weight was modelled on the log scale with a Student-t likelihood, ",
        "with the degrees of freedom estimated, as an allometric function of ",
        "sub-bulb diameter. Expected weight followed a three-parameter power ",
        "function (Packard 2012) of diameter relative to the geometric mean ",
        "diameter (%s), in which bFloor is the share of expected weight at that ",
        "reference diameter that does not vary with size. The allometric ",
        "exponent varied by site on the log scale, so it remained positive and ",
        "expected weight increased monotonically with diameter within every ",
        "site. %s Regularizing priors were placed on all parameters (see the ",
        "notation form for the hyperparameters)."
      ),
      format(d0),
      if (sy) {
        "The intercept varied by year, by site, and by site-year."
      } else {
        "The intercept varied by year and by site."
      }
    )
  )
}

.model_spec_macro <- function(fit) {
  sy <- .site_year_on(fit)
  f0 <- signif(fit$meta$predictor_ref, 3)
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
    random <- c(
      random,
      list(list(
        term = "bSiteYear[site, year]",
        sd = "sSiteYear",
        gloss = "site:year intercept"
      ))
    )
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
        "count, centered at the geometric mean (%s), with the intercept varying ",
        "by site, year%s. Regularizing priors were placed on all parameters ",
        "(see the notation form for the hyperparameters)."
      ),
      format(f0),
      if (sy) ", and site-year" else ""
    )
  )
}

# ---- rendering ---------------------------------------------------------------

# Left-justify to the widest element, so adjacent columns line up.
.pad_right <- function(x) {
  formatC(x, width = max(nchar(x)), flag = "-")
}

# Format a stored prior object as scientific notation for the description.
.describe_prior <- function(p) {
  if (inherits(p, "kb_prior_normal")) {
    sprintf("Normal(%s, %s)", format(p$mean), format(p$sd))
  } else if (inherits(p, "kb_prior_exponential")) {
    sprintf("Exponential(%s)", format(p$rate))
  } else if (inherits(p, "kb_prior_gamma")) {
    sprintf("Gamma(%s, %s)", format(p$shape), format(p$rate))
  } else if (inherits(p, "kb_prior_beta")) {
    sprintf("Beta(%s, %s)", format(p$shape1), format(p$shape2))
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

  # Continuation lines put the "+" under the "=" of the first line, so the
  # operands stay in one column for either mean_lhs ("mu" or "log(mu)").
  mean_lines <- c(
    paste0("  ", spec$mean_lhs, " = ", spec$mean_terms[1]),
    paste0(strrep(" ", nchar(spec$mean_lhs) + 3), "+ ", spec$mean_terms[-1])
  )
  # Pad the term and distribution columns so the glosses line up.
  re_lines <- sprintf(
    "  %s ~ %s  %s",
    .pad_right(vapply(spec$random, function(r) r$term, character(1))),
    .pad_right(vapply(
      spec$random,
      function(r) sprintf("Normal(0, %s)", r$sd),
      character(1)
    )),
    vapply(spec$random, function(r) r$gloss, character(1))
  )
  prior_lines <- vapply(
    names(spec$priors),
    function(nm) {
      sprintf("  %-14s ~ %s", nm, .describe_prior(spec$priors[[nm]]))
    },
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
