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
#' random-effect list. Priors marked `T[0, ]` are truncated at zero.
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

#' @export
kb_model_describe.kb_fit_size_nereo <- function(fit, prose = FALSE) {
  chk::chk_flag(prose)
  .render_model(.model_spec_size_nereo(fit), prose)
}

#' @export
kb_model_describe.kb_fit_size_macro <- function(fit, prose = FALSE) {
  chk::chk_flag(prose)
  .render_model(.model_spec_size_macro(fit), prose)
}

#' @export
kb_model_describe.kb_fit_density_nereo <- function(fit, prose = FALSE) {
  chk::chk_flag(prose)
  .render_model(.model_spec_density_nereo(fit), prose)
}

#' @export
kb_model_describe.kb_fit_density_macro <- function(fit, prose = FALSE) {
  chk::chk_flag(prose)
  .render_model(.model_spec_density_macro(fit), prose)
}

# ---- species model specs (single source for notation and prose) -------------

.model_spec_nereo <- function(fit) {
  sy <- .site_year_on(fit)
  dens <- .density_on(fit)
  floor <- .floor_on(fit)
  d0 <- signif(fit$meta$predictor_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c("bWeight", "bYear[year]", "bSite[site]")
  random <- list(
    list(term = "bYear[year]", sd = "sYear", gloss = "year effect on log(alpha)"),
    list(term = "bSite[site]", sd = "sSite", gloss = "site effect on log(alpha)")
  )
  priors <- list(
    bWeight = pri$intercept,
    bPower = pri$power,
    bFloor = pri$floor,
    sWeight = pri$sd_residual,
    sYear = pri$sd_year,
    sSite = pri$sd_site
  )
  centering <- sprintf(
    "x = diameter_mm / d0,  d0 = %s  (geometric mean diameter)",
    format(d0)
  )
  density_prose <- ""
  if (dens) {
    m <- format(signif(fit$meta$density_mean, 3))
    s <- format(signif(fit$meta$density_sd, 3))
    mean_terms <- append(mean_terms, "bDensity * density", after = 1L)
    priors <- append(priors, list(bDensity = pri$density), after = 3L)
    centering <- paste0(
      centering,
      sprintf(
        "\n  density = (stipe density - %s) / %s  (standardised site-year density)",
        m,
        s
      )
    )
    density_prose <- sprintf(
      paste0(
        " The log of alpha also varied linearly with site-year stipe density, ",
        "standardised by its mean (%s) and standard deviation (%s)."
      ),
      m,
      s
    )
  }
  if (sy) {
    mean_terms <- c(mean_terms, "bSiteYear[site, year]")
    random <- c(
      random,
      list(list(
        term = "bSiteYear[site, year]",
        sd = "sSiteYear",
        gloss = "site:year effect on log(alpha)"
      ))
    )
    priors$sSiteYear <- pri$sd_site_year
  }

  if (!floor) {
    priors$bFloor <- NULL
  }
  form_prose <- if (floor) {
    sprintf(
      paste0(
        "Expected weight followed a three-parameter power function (Packard ",
        "2023) of diameter relative to the geometric mean diameter ",
        "(%s), in which bFloor is the weight as diameter approaches zero, alpha ",
        "the weight above the floor at the reference diameter, and bPower the ",
        "allometric exponent."
      ),
      format(d0)
    )
  } else {
    sprintf(
      paste0(
        "Expected weight followed a power law in diameter relative to the ",
        "geometric mean diameter (%s), in which alpha is the weight at the ",
        "reference diameter and bPower the allometric exponent."
      ),
      format(d0)
    )
  }

  list(
    title = "Weight allometry",
    species = .species_label(fit$meta$species),
    response_desc = "wet weight (kg)",
    predictor_desc = "sub-bulb diameter (mm)",
    likelihood = paste0(
      "log(weight_kg) ~ Normal(log(mu), sWeight)",
      if (floor) "\n  mu = bFloor + alpha * x^bPower" else "\n  mu = alpha * x^bPower"
    ),
    mean_lhs = "log(alpha)",
    mean_terms = mean_terms,
    centering = centering,
    random = random,
    priors = priors,
    truncated = c("bPower", if (floor) "bFloor"),
    prose = paste0(
      "Wet weight was modelled on the log scale with a Normal likelihood as an ",
      "allometric function of sub-bulb diameter. ",
      form_prose,
      " ",
      if (sy) {
        "The log of alpha varied by year, by site, and by site-year."
      } else {
        "The log of alpha varied by year and by site."
      },
      density_prose,
      " Regularizing priors were placed on all parameters (see the notation ",
      "form for the hyperparameters)."
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
    bShape = pri$shape,
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
    likelihood = "weight_kg ~ Gamma(bShape, bShape / mu)",
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

# The size and density models share their random-effect structure, so the terms,
# random effects, and SD priors are assembled once; `intercept` is the species'
# intercept name.
.group_spec_effects <- function(fit, intercept) {
  sy <- .site_year_on(fit)
  pri <- fit$meta$priors
  mean_terms <- c(intercept, "bSite[site]", "bYear[year]")
  random <- list(
    list(term = "bSite[site]", sd = "sSite", gloss = "site effect on log(mu)"),
    list(term = "bYear[year]", sd = "sYear", gloss = "year effect on log(mu)")
  )
  sds <- list(sSite = pri$sd_site, sYear = pri$sd_year)
  if (sy) {
    mean_terms <- c(mean_terms, "bSiteYear[site, year]")
    random <- c(
      random,
      list(list(
        term = "bSiteYear[site, year]",
        sd = "sSiteYear",
        gloss = "site:year effect on log(mu)"
      ))
    )
    sds$sSiteYear <- pri$sd_site_year
  }
  list(
    mean_terms = mean_terms,
    random = random,
    sds = sds,
    groups = if (sy) "site, year, and site-year" else "site and year"
  )
}

.model_spec_size_nereo <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "bDiameter")
  list(
    title = "Size distribution",
    species = .species_label(fit$meta$species),
    response_desc = "maximum sub-bulb diameter (mm)",
    likelihood = paste0(
      "diameter_mm ~ Weibull(bShape, mu / gamma(1 + 1 / bShape))"
    ),
    mean_lhs = "log(mu)",
    mean_terms = eff$mean_terms,
    random = eff$random,
    priors = c(
      list(bDiameter = pri$intercept, bShape = pri$shape),
      eff$sds
    ),
    prose = sprintf(
      paste0(
        "Maximum sub-bulb diameter was modelled with a Weibull likelihood ",
        "parameterised by its mean, mu, with a shape common to all plants. ",
        "The log of mu varied by %s. Regularizing priors were placed on all ",
        "parameters (see the notation form for the hyperparameters)."
      ),
      eff$groups
    )
  )
}

.model_spec_size_macro <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "bFronds")
  list(
    title = "Size distribution",
    species = .species_label(fit$meta$species),
    response_desc = "fronds reaching 1 m above the holdfast",
    likelihood = paste0(
      "fronds ~ NegBinomial(mu, 1 / bDispersion) T[1, ]",
      "\n  E[fronds] = mu / (1 - P(fronds = 0))"
    ),
    mean_lhs = "log(mu)",
    mean_terms = eff$mean_terms,
    random = eff$random,
    priors = c(
      list(bFronds = pri$intercept, bDispersion = pri$dispersion),
      eff$sds
    ),
    prose = sprintf(
      paste0(
        "The number of fronds reaching 1 m above the holdfast was modelled with ",
        "a zero-truncated negative binomial likelihood, with an overdispersion ",
        "common to all plants. The log of the untruncated mean, mu, varied by ",
        "%s. Regularizing priors were placed on all parameters (see the ",
        "notation form for the hyperparameters)."
      ),
      eff$groups
    )
  )
}

# The area offset leads the mean so the notation reads as area times density.
.model_spec_density_nereo <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "bStipes")
  list(
    title = "Density",
    species = .species_label(fit$meta$species),
    response_desc = "stipes counted on a transect of area_m2 (m\u00b2)",
    likelihood = paste0(
      "stipes ~ ZeroInflatedNegBinomial(mu, 1 / bDispersion, zi)",
      "\n  zi = inv_logit(bZeroInflation)",
      "\n  E[stipes] = (1 - zi) * mu"
    ),
    mean_lhs = "log(mu)",
    mean_terms = c("log(area_m2)", eff$mean_terms),
    random = eff$random,
    priors = c(
      list(
        bStipes = pri$intercept,
        bZeroInflation = pri$zero_inflation,
        bDispersion = pri$dispersion
      ),
      eff$sds
    ),
    prose = sprintf(
      paste0(
        "The number of stipes on a transect was modelled with a zero-inflated ",
        "negative binomial likelihood, with the transect area as an offset. The ",
        "zero-inflation probability, zi, and the overdispersion were common to ",
        "all transects. The log stipe density on transects holding stipes ",
        "varied by %s. Regularizing priors were placed on all parameters (see ",
        "the notation form for the hyperparameters)."
      ),
      eff$groups
    )
  )
}

.model_spec_density_macro <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "bPlants")
  list(
    title = "Density",
    species = .species_label(fit$meta$species),
    response_desc = "plants counted on a transect of area_m2 (m\u00b2)",
    likelihood = "plants ~ NegBinomial(mu, 1 / bDispersion)",
    mean_lhs = "log(mu)",
    mean_terms = c("log(area_m2)", eff$mean_terms),
    random = eff$random,
    priors = c(
      list(bPlants = pri$intercept, bDispersion = pri$dispersion),
      eff$sds
    ),
    prose = sprintf(
      paste0(
        "The number of plants on a transect was modelled with a negative ",
        "binomial likelihood, with the transect area as an offset and an ",
        "overdispersion common to all transects. The log plant density varied ",
        "by %s. Regularizing priors were placed on all parameters (see the ",
        "notation form for the hyperparameters)."
      ),
      eff$groups
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
      trunc <- if (nm %in% spec$truncated) " T[0, ]" else ""
      sprintf("  %-14s ~ %s%s", nm, .describe_prior(spec$priors[[nm]]), trunc)
    },
    character(1)
  )

  # A model without a predictor (size) has no predictor or centering line.
  predictor <- if (is.null(spec$predictor_desc)) {
    ""
  } else {
    paste0("; predictor: ", spec$predictor_desc)
  }
  centering <- if (is.null(spec$centering)) {
    NULL
  } else {
    paste0("  ", spec$centering)
  }

  lines <- c(
    paste0(spec$title, " - ", spec$species),
    paste0("Response: ", spec$response_desc, predictor),
    "",
    "Likelihood",
    paste0("  ", spec$likelihood),
    mean_lines,
    centering,
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
