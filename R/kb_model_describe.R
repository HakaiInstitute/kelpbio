#' Describe a Fitted Model
#'
#' Render the complete fitted model in scientific notation (the default) or as a
#' report-ready methods paragraph (`prose = TRUE`). The notation uses the
#' package's own parameter names (`intercept`, `sd_site`, ...), so every symbol
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
  .abort_no_method(fit, call = rlang::current_env())
}

#' @rdname kb_model_describe
#' @export
kb_model_describe.kb_fit <- function(fit, prose = FALSE) {
  chk::chk_flag(prose)
  .render_model(.model_spec(fit), prose)
}

# ---- model specs -------------------------------------------------------------

# The fields .render_model() lays out, one method per model.
.model_spec <- function(fit) {
  UseMethod(".model_spec")
}

#' @export
.model_spec.default <- function(fit) {
  .abort_no_method(fit, call = NULL)
}

#' @export
.model_spec.kb_fit_weight_nereo <- function(fit) {
  sy <- .site_year_on(fit)
  dens <- .density_on(fit)
  floor <- .floor_on(fit)
  d0 <- signif(fit$meta$predictor_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c("intercept", "year_effect[year]", "site_effect[site]")
  random <- list(
    list(term = "year_effect[year]", sd = "sd_year", gloss = "year effect on log(alpha)"),
    list(term = "site_effect[site]", sd = "sd_site", gloss = "site effect on log(alpha)")
  )
  priors <- list(
    intercept = pri$intercept,
    diameter_power = pri$diameter_power,
    weight_floor = pri$weight_floor,
    sd_residual = pri$sd_residual,
    sd_year = pri$sd_year,
    sd_site = pri$sd_site
  )
  centering <- sprintf(
    "x = diameter_mm / d0,  d0 = %s  (geometric mean diameter)",
    format(d0)
  )
  density_prose <- ""
  if (dens) {
    m <- format(signif(fit$meta$density_mean, 3))
    s <- format(signif(fit$meta$density_sd, 3))
    mean_terms <- append(mean_terms, "density_slope * density", after = 1L)
    priors <- append(priors, list(density_slope = pri$density_slope), after = 3L)
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
    mean_terms <- c(mean_terms, "site_year_effect[site, year]")
    random <- c(
      random,
      list(list(
        term = "site_year_effect[site, year]",
        sd = "sd_site_year",
        gloss = "site:year effect on log(alpha)"
      ))
    )
    priors$sd_site_year <- pri$sd_site_year
  }

  if (!floor) {
    priors$weight_floor <- NULL
  }
  form_prose <- if (floor) {
    sprintf(
      paste0(
        "Expected weight followed a three-parameter power function (Packard ",
        "2023) of diameter relative to the geometric mean diameter ",
        "(%s), in which weight_floor is the weight as diameter approaches zero, alpha ",
        "the weight above the floor at the reference diameter, and diameter_power the ",
        "allometric exponent."
      ),
      format(d0)
    )
  } else {
    sprintf(
      paste0(
        "Expected weight followed a power law in diameter relative to the ",
        "geometric mean diameter (%s), in which alpha is the weight at the ",
        "reference diameter and diameter_power the allometric exponent."
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
      "log(weight_kg) ~ Normal(log(mu), sd_residual)",
      if (floor) "\n  mu = weight_floor + alpha * x^diameter_power" else "\n  mu = alpha * x^diameter_power"
    ),
    mean_lhs = "log(alpha)",
    mean_terms = mean_terms,
    centering = centering,
    random = random,
    priors = priors,
    truncated = c("diameter_power", if (floor) "weight_floor"),
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

#' @export
.model_spec.kb_fit_weight_macro <- function(fit) {
  sy <- .site_year_on(fit)
  f0 <- signif(fit$meta$predictor_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c("intercept", "fronds_slope * x", "site_effect[site]", "year_effect[year]")
  random <- list(
    list(term = "site_effect[site]", sd = "sd_site", gloss = "site intercept"),
    list(term = "year_effect[year]", sd = "sd_year", gloss = "year intercept")
  )
  priors <- list(
    intercept = pri$intercept,
    fronds_slope = pri$fronds_slope,
    shape = pri$shape,
    sd_site = pri$sd_site,
    sd_year = pri$sd_year
  )
  if (sy) {
    mean_terms <- c(mean_terms, "site_year_effect[site, year]")
    random <- c(
      random,
      list(list(
        term = "site_year_effect[site, year]",
        sd = "sd_site_year",
        gloss = "site:year intercept"
      ))
    )
    priors$sd_site_year <- pri$sd_site_year
  }

  list(
    title = "Weight allometry",
    species = .species_label(fit$meta$species),
    response_desc = "wet weight",
    predictor_desc = "frond count",
    likelihood = "weight_kg ~ Gamma(shape, shape / mu)",
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

# Random-effect structure shared by size and density; `intercept` is the
# species' intercept name.
.group_spec_effects <- function(fit, intercept) {
  sy <- .site_year_on(fit)
  pri <- fit$meta$priors
  mean_terms <- c(intercept, "site_effect[site]", "year_effect[year]")
  random <- list(
    list(term = "site_effect[site]", sd = "sd_site", gloss = "site effect on log(mu)"),
    list(term = "year_effect[year]", sd = "sd_year", gloss = "year effect on log(mu)")
  )
  sds <- list(sd_site = pri$sd_site, sd_year = pri$sd_year)
  if (sy) {
    mean_terms <- c(mean_terms, "site_year_effect[site, year]")
    random <- c(
      random,
      list(list(
        term = "site_year_effect[site, year]",
        sd = "sd_site_year",
        gloss = "site:year effect on log(mu)"
      ))
    )
    sds$sd_site_year <- pri$sd_site_year
  }
  list(
    mean_terms = mean_terms,
    random = random,
    sds = sds,
    groups = if (sy) "site, year, and site-year" else "site and year"
  )
}

#' @export
.model_spec.kb_fit_size_nereo <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "intercept")
  list(
    title = "Size distribution",
    species = .species_label(fit$meta$species),
    response_desc = "maximum sub-bulb diameter (mm)",
    likelihood = paste0(
      "diameter_mm ~ Weibull(shape, mu / gamma(1 + 1 / shape))"
    ),
    mean_lhs = "log(mu)",
    mean_terms = eff$mean_terms,
    random = eff$random,
    priors = c(
      list(intercept = pri$intercept, shape = pri$shape),
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

#' @export
.model_spec.kb_fit_size_macro <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "intercept")
  list(
    title = "Size distribution",
    species = .species_label(fit$meta$species),
    response_desc = "fronds reaching 1 m above the holdfast",
    likelihood = paste0(
      "fronds ~ NegBinomial(mu, 1 / dispersion) T[1, ]",
      "\n  E[fronds] = mu / (1 - P(fronds = 0))"
    ),
    mean_lhs = "log(mu)",
    mean_terms = eff$mean_terms,
    random = eff$random,
    priors = c(
      list(intercept = pri$intercept, dispersion = pri$dispersion),
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
#' @export
.model_spec.kb_fit_density_nereo <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "intercept")
  list(
    title = "Density",
    species = .species_label(fit$meta$species),
    response_desc = "stipes counted on a transect of area_m2 (m\u00b2)",
    likelihood = paste0(
      "stipes ~ ZeroInflatedNegBinomial(mu, 1 / dispersion, zi)",
      "\n  zi = inv_logit(logit_zero_inflation)",
      "\n  E[stipes] = (1 - zi) * mu"
    ),
    mean_lhs = "log(mu)",
    mean_terms = c("log(area_m2)", eff$mean_terms),
    random = eff$random,
    priors = c(
      list(
        intercept = pri$intercept,
        logit_zero_inflation = pri$logit_zero_inflation,
        dispersion = pri$dispersion
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

#' @export
.model_spec.kb_fit_density_macro <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "intercept")
  list(
    title = "Density",
    species = .species_label(fit$meta$species),
    response_desc = "plants counted on a transect of area_m2 (m\u00b2)",
    likelihood = "plants ~ NegBinomial(mu, 1 / dispersion)",
    mean_lhs = "log(mu)",
    mean_terms = c("log(area_m2)", eff$mean_terms),
    random = eff$random,
    priors = c(
      list(intercept = pri$intercept, dispersion = pri$dispersion),
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

# Wet/dry and carbon share one Beta model; only the response differs.
#' @export
.model_spec.kb_fit_wetdry <- function(fit) {
  .model_spec_beta(
    fit,
    title = "Wet/dry ratio",
    response = "dry_wet_ratio",
    response_desc = "dry_mass_g / wet_mass_g, the dry:wet mass ratio of a sample",
    subject = "The dry:wet mass ratio of each sample"
  )
}

#' @export
.model_spec.kb_fit_carbon <- function(fit) {
  .model_spec_beta(
    fit,
    title = "Carbon fraction",
    response = "carbon_fraction",
    response_desc = paste0(
      "carbon_fraction = carbon_mass_ug / 1000 / sample_mass_mg, the fraction ",
      "of a dry sample's mass that is carbon"
    ),
    subject = "The carbon fraction of each dried sample"
  )
}

.model_spec_beta <- function(fit, title, response, response_desc, subject) {
  pri <- fit$meta$priors
  list(
    title = title,
    species = .species_label(fit$meta$species),
    response_desc = response_desc,
    likelihood = paste0(
      response,
      " ~ Beta(mu * precision, (1 - mu) * precision)"
    ),
    mean_lhs = "logit(mu)",
    mean_terms = "intercept",
    random = list(),
    priors = list(intercept = pri$intercept, precision = pri$precision),
    prose = paste0(
      subject,
      " was modelled with a Beta likelihood parameterised by its mean, mu, ",
      "and precision, both common to all samples. Samples were pooled over the ",
      "months, sites, and tissues they came from. Regularizing priors were ",
      "placed on all parameters (see the notation form for the ",
      "hyperparameters)."
    )
  )
}

# One model for both species; the species differ only in their default priors.
#' @export
.model_spec.kb_fit_cover_biomass <- function(fit) {
  pri <- fit$meta$priors
  z <- format(signif(stats::qnorm(1 - (1 - fit$meta$conf_level) / 2), 3))
  list(
    title = "Cover biomass",
    species = .species_label(fit$meta$species),
    response_desc = paste0(
      "estimate, the in situ wet biomass of a plot (kg/m\u00b2), ",
      "with compatibility limits lower and upper"
    ),
    likelihood = "log(estimate) ~ Normal(log(mu), error_scaling * sd)",
    mean_lhs = "mu",
    mean_terms = c("biomass_floor", "cover_slope * exp(year_effect[year] + site_effect[site]) * cover"),
    centering = paste0(
      "cover = min(1, canopy_area_m2 * (1 + tide_height_slope * tide_height_m) / plot_area_m2)\n",
      "  sd = (log(upper) - log(lower)) / (2 * ",
      z,
      ")  (log-scale SD of the in situ estimate)"
    ),
    random = list(
      list(term = "year_effect[year]", sd = "sd_year", gloss = "year effect on log(cover_slope)"),
      list(term = "site_effect[site]", sd = "sd_site", gloss = "site effect on log(cover_slope)")
    ),
    priors = list(
      cover_slope = pri$cover_slope,
      biomass_floor = pri$biomass_floor,
      tide_height_slope = pri$tide_height_slope,
      error_scaling = pri$error_scaling,
      sd_year = pri$sd_year,
      sd_site = pri$sd_site
    ),
    truncated = c("biomass_floor", "tide_height_slope", "error_scaling"),
    prose = paste0(
      "The in situ wet biomass of each surveyed plot was modelled as a biomass ",
      "floor, common to all sites and years, plus a term proportional to the ",
      "plot's tide-corrected canopy cover, whose slope varied by site and year. ",
      "Canopy area was increased by a fixed fraction per metre of tide height, ",
      "and cover was capped at 1. The log of each in situ estimate was modelled ",
      "with a normal likelihood whose standard deviation was the log-scale ",
      "standard deviation of that estimate multiplied by a scaling parameter. ",
      "Regularizing priors were placed on all parameters, with an informative ",
      "prior on the tide correction (see the notation form for the ",
      "hyperparameters)."
    )
  )
}

# ---- rendering ---------------------------------------------------------------

# Left-justify to the widest element, so adjacent columns line up.
.pad_right <- function(x) {
  formatC(x, width = max(nchar(x)), flag = "-")
}

# resolve_priors() guarantees one of the three kb_prior classes.
.describe_prior <- function(p) {
  if (inherits(p, "kb_prior_normal")) {
    sprintf("Normal(%s, %s)", format(p$mean), format(p$sd))
  } else if (inherits(p, "kb_prior_exponential")) {
    sprintf("Exponential(%s)", format(p$rate))
  } else if (inherits(p, "kb_prior_lognormal")) {
    sprintf("LogNormal(%s, %s)", format(p$meanlog), format(p$sdlog))
  }
}

# Prints notation or a methods paragraph; returns the lines invisibly.
.render_model <- function(spec, prose) {
  if (prose) {
    lines <- strwrap(spec$prose, width = 76)
    cli::cat_line(lines)
    return(invisible(lines))
  }

  # Align continuation "+" under the "=" for either mean_lhs.
  mean_lines <- c(
    paste0("  ", spec$mean_lhs, " = ", spec$mean_terms[1]),
    if (length(spec$mean_terms) > 1L) {
      paste0(strrep(" ", nchar(spec$mean_lhs) + 3), "+ ", spec$mean_terms[-1])
    }
  )
  width <- max(14L, nchar(names(spec$priors)))
  prior_lines <- vapply(
    names(spec$priors),
    function(nm) {
      trunc <- if (nm %in% spec$truncated) " T[0, ]" else ""
      sprintf(
        "  %-*s ~ %s%s",
        width,
        nm,
        .describe_prior(spec$priors[[nm]]),
        trunc
      )
    },
    character(1)
  )

  # Size has no predictor.
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

  # Wet/dry has no random effects.
  random_block <- if (length(spec$random)) {
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
    c("", "Random effects", re_lines)
  }

  lines <- c(
    paste0(spec$title, " - ", spec$species),
    paste0("Response: ", spec$response_desc, predictor),
    "",
    "Likelihood",
    paste0("  ", spec$likelihood),
    mean_lines,
    centering,
    random_block,
    "",
    "Priors",
    prior_lines
  )
  cli::cat_line(lines)
  invisible(lines)
}
