#' Describe a fitted model
#'
#' Render the complete fitted model in scientific notation (the default) or as a
#' report-ready methods paragraph (`prose = TRUE`). The notation uses the
#' package's own parameter names (`intercept`, `sd_site`, ...), so every symbol
#' matches a row of [tidy()], [summary()], and [coef()].
#'
#' @details
#' Priors, centring, and random effects are those of the fit; an effect not
#' fitted (such as the weight floor of a power-law fit) is omitted.
#' Priors marked `T[0, ]` are truncated at zero, and `T[0, 0.5]` at 0 and 0.5.
#'
#' @inheritParams params
#' @param prose A flag specifying whether to render a methods-section paragraph
#'   instead of the notation block.
#'
#' @returns The rendered lines, invisibly (a character vector). Called for the
#'   printed description.
#' @family fit methods
#' @export
#'
#' @examples
#' kb_model_describe(fit_weight_sim_nereo)
#' kb_model_describe(fit_weight_sim_macro, prose = TRUE)
kb_model_describe <- function(fit, ..., prose = FALSE) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
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
  floor <- .floor_on(fit)
  d0 <- signif(fit$meta$predictor_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c(
    "intercept", "site_effect[site]", "year_effect[year]",
    "site_year_effect[site, year]"
  )
  random <- list(
    list(term = "site_effect[site]", sd = "sd_site", gloss = "site effect on log(alpha)"),
    list(term = "year_effect[year]", sd = "sd_year", gloss = "year effect on log(alpha)"),
    list(
      term = "site_year_effect[site, year]",
      sd = "sd_site_year",
      gloss = "site:year effect on log(alpha)"
    )
  )
  priors <- list(
    intercept = pri$intercept,
    diameter_power = pri$diameter_power,
    weight_floor = pri$weight_floor,
    sd_residual = pri$sd_residual,
    sd_site = pri$sd_site,
    sd_year = pri$sd_year,
    sd_site_year = pri$sd_site_year
  )
  centering <- sprintf(
    "x = diameter_mm / d0,  d0 = %s  (geometric mean diameter)",
    format(d0)
  )
  if (!floor) {
    priors$weight_floor <- NULL
  }
  form_prose <- if (floor) {
    sprintf(
      paste0(
        "The expected log weight was log(mu), where mu followed a ",
        "three-parameter power function (Packard 2023) of diameter relative to the geometric mean diameter ",
        "(%s), in which weight_floor is the weight as diameter approaches zero, alpha ",
        "the weight above the floor at the reference diameter, and diameter_power the ",
        "allometric exponent."
      ),
      format(d0)
    )
  } else {
    sprintf(
      paste0(
        "The expected log weight was log(mu), where mu followed a power law ",
        "in diameter relative to the ",
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
    predictor_desc = "plant diameter (mm)",
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
      "allometric function of plant diameter. ",
      form_prose,
      " The log of alpha varied by site, by year, and by site:year.",
      " Regularising priors were placed on all parameters (see the notation ",
      "form for the prior arguments)."
    )
  )
}

#' @export
.model_spec.kb_fit_weight_macro <- function(fit) {
  f0 <- signif(fit$meta$predictor_ref, 3)
  pri <- fit$meta$priors

  mean_terms <- c(
    "intercept", "site_effect[site]", "year_effect[year]",
    "site_year_effect[site, year]"
  )
  random <- list(
    list(term = "site_effect[site]", sd = "sd_site", gloss = "site effect on log(alpha)"),
    list(term = "year_effect[year]", sd = "sd_year", gloss = "year effect on log(alpha)"),
    list(
      term = "site_year_effect[site, year]",
      sd = "sd_site_year",
      gloss = "site:year effect on log(alpha)"
    )
  )
  priors <- list(
    intercept = pri$intercept,
    fronds_slope = pri$fronds_slope,
    shape = pri$shape,
    sd_site = pri$sd_site,
    sd_year = pri$sd_year,
    sd_site_year = pri$sd_site_year
  )
  list(
    title = "Weight allometry",
    species = .species_label(fit$meta$species),
    response_desc = "wet weight (kg)",
    predictor_desc = "frond count",
    likelihood = paste0(
      "weight_kg ~ Gamma(shape, shape / mu)",
      "\n  mu = alpha * x^fronds_slope"
    ),
    mean_lhs = "log(alpha)",
    mean_terms = mean_terms,
    centering = sprintf(
      "x = fronds / f0,  f0 = %s  (geometric mean frond count)",
      format(f0)
    ),
    random = random,
    priors = priors,
    prose = sprintf(
      paste0(
        "Wet weight was modelled with a Gamma likelihood as an allometric ",
        "function of frond count. The expected weight was mu, where mu followed ",
        "a power law in frond count relative to the geometric mean frond count ",
        "(%s), in which alpha is the expected weight at the geometric mean ",
        "frond count and fronds_slope the allometric exponent. The log of alpha ",
        "varied by %s. Regularising priors were placed on all parameters (see ",
        "the notation form for the prior arguments)."
      ),
      format(f0),
      "site, by year, and by site:year"
    )
  )
}

# Random-effect structure of the size model; `intercept` is its intercept name.
.group_spec_effects <- function(fit, intercept) {
  pri <- fit$meta$priors
  list(
    mean_terms = c(
      intercept, "site_effect[site]", "year_effect[year]",
      "site_year_effect[site, year]"
    ),
    random = list(
      list(term = "site_effect[site]", sd = "sd_site", gloss = "site effect on log(mu)"),
      list(term = "year_effect[year]", sd = "sd_year", gloss = "year effect on log(mu)"),
      list(
        term = "site_year_effect[site, year]",
        sd = "sd_site_year",
        gloss = "site:year effect on log(mu)"
      )
    ),
    sds = list(
      sd_site = pri$sd_site,
      sd_year = pri$sd_year,
      sd_site_year = pri$sd_site_year
    ),
    groups = "site, year, and site:year"
  )
}

#' @export
.model_spec.kb_fit_size_nereo <- function(fit) {
  pri <- fit$meta$priors
  eff <- .group_spec_effects(fit, "intercept")
  list(
    title = "Size distribution",
    species = .species_label(fit$meta$species),
    response_desc = "plant diameter (mm)",
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
        "Plant diameter was modelled with a Weibull likelihood ",
        "parameterised by its mean, mu, with a shape common to all plants. ",
        "The log of mu varied by %s. Regularising priors were placed on all ",
        "parameters (see the notation form for the prior arguments)."
      ),
      eff$groups
    )
  )
}

# Wet/dry, carbon, and nitrogen share one Beta model; only the response differs.
#' @export
.model_spec.kb_fit_wetdry <- function(fit) {
  .model_spec_beta(
    fit,
    title = "Wet/dry ratio",
    response = "dry_wet_ratio",
    response_desc = "dry_mass_g / wet_mass_g, the dry:wet ratio of a sample",
    subject = "The dry:wet ratio of each sample"
  )
}

#' @export
.model_spec.kb_fit_carbon <- function(fit) {
  .model_spec_beta(
    fit,
    title = "Carbon fraction",
    response = "carbon_fraction",
    response_desc = paste0(
      "carbon_fraction, the carbon mass divided by the sample mass (carbon_mass_ug ",
      "converted to mg, divided by sample_mass_mg)"
    ),
    subject = "The carbon fraction of each dried sample"
  )
}

#' @export
.model_spec.kb_fit_nitrogen <- function(fit) {
  .model_spec_beta(
    fit,
    title = "Nitrogen fraction",
    response = "nitrogen_fraction",
    response_desc = paste0(
      "nitrogen_fraction, the nitrogen mass divided by the sample mass (nitrogen_mass_ug ",
      "converted to mg, divided by sample_mass_mg)"
    ),
    subject = "The nitrogen fraction of each dried sample"
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
      "months, sites, and tissues they came from. Regularising priors were ",
      "placed on all parameters (see the notation form for the ",
      "prior arguments)."
    )
  )
}

# One model for both species; the species differ only in their default priors.
# The presence part is described only where the data held an empty survey.
#' @export
.model_spec.kb_fit_cover_calibration <- function(fit) {
  pri <- fit$meta$priors
  presence <- .presence_on(fit)
  gamma <- paste0(
    "Gamma(shape, shape / mu)",
    "\n  shape = 1 / (cv_residual^2 + weight_cv^2),  weight_cv = biomass_sd_kg_m2 / biomass_kg_m2"
  )
  likelihood <- if (presence) {
    paste0(
      "biomass_kg_m2 = 0 with probability 1 - p, else ~ ", gamma,
      "\n  logit(p) = presence_intercept + presence_cover_slope * 100 * cover"
    )
  } else {
    paste0("biomass_kg_m2 ~ ", gamma)
  }
  priors <- list(
    cover_slope = pri$cover_slope,
    biomass_floor = pri$biomass_floor,
    tide_height_slope = pri$tide_height_slope,
    cv_residual = pri$cv_residual,
    presence_intercept = pri$presence_intercept,
    presence_cover_slope = pri$presence_cover_slope,
    sd_year = pri$sd_year,
    sd_site = pri$sd_site
  )
  if (!presence) {
    priors$presence_intercept <- NULL
    priors$presence_cover_slope <- NULL
  }
  presence_prose <- if (presence) {
    paste0(
      "Surveys with no plants counted entered through a presence part: the ",
      "log odds that a survey held plants were linear in its percent cover, ",
      "and biomass was Gamma only where plants were present. "
    )
  } else {
    ""
  }
  list(
    title = "Cover calibration",
    species = .species_label(fit$meta$species),
    response_desc = paste0(
      "biomass_kg_m2, the mean wet biomass of an in situ survey (kg/m\u00b2), ",
      "with SD biomass_sd_kg_m2 from plant weight"
    ),
    likelihood = likelihood,
    mean_lhs = "mu",
    mean_terms = c("biomass_floor", "cover_slope * exp(year_effect[year] + site_effect[site]) * cover"),
    centering = paste0(
      "cover = min(1, canopy_area_m2 / (1 - tide_height_slope * canopy_tide_height_m) / plot_area_m2), ",
      "and 1 where canopy_area_m2 > 0 and canopy_tide_height_m >= 1 / tide_height_slope"
    ),
    random = list(
      list(term = "year_effect[year]", sd = "sd_year", gloss = "year effect on log(cover_slope)"),
      list(term = "site_effect[site]", sd = "sd_site", gloss = "site effect on log(cover_slope)")
    ),
    priors = priors,
    truncated = "biomass_floor",
    bounded = c(tide_height_slope = paste0(" T[0, ", TIDE_SLOPE_UPPER, "]")),
    prose = paste0(
      "The mean wet biomass of each in situ survey was modelled as a biomass ",
      "floor, common to all sites and years, plus a term proportional to the ",
      "tide-corrected canopy cover of the survey's plot, whose slope varied by ",
      "site and year. Canopy area was divided by one minus an estimated share ",
      "per metre of tide height, and cover was capped at 1; plots with canopy ",
      "at or above the tide height where that share reaches 1 were fully ",
      "covered. The likelihood was Gamma, with a coefficient of variation ",
      "combining a residual part and the survey's coefficient of variation ",
      "from plant weight. ",
      presence_prose,
      "Regularising priors were placed on all parameters, with an informative ",
      "prior on the tide correction (see the notation form for the prior ",
      "arguments)."
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
      trunc <- if (nm %in% names(spec$bounded)) {
        spec$bounded[[nm]]
      } else if (nm %in% spec$truncated) {
        " T[0, ]"
      } else {
        ""
      }
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
