#' Parameter Descriptions for Package
#'
#' Default parameter descriptions which may be overridden in individual
#' functions.
#'
#' A flag is a non-missing logical scalar.
#'
#' A string is a non-missing character scalar.
#'
#' @section Sampling:
#' Chains run in parallel by default, one core per chain, capped at the cores
#' available. `cores` sets the number of cores; when it is `NULL`,
#' `getOption("mc.cores")` is used if set. Set `cores = 1` (or
#' `options(mc.cores = 1)`) where cores are shared or limited, or inside another
#' parallel process.
#'
#' The sampler runs with `adapt_delta = 0.95` by default, which reduces
#' divergences at the cost of slightly longer runtime. Override it, or set any
#' other sampler control, by passing a `control` list through `...`, for example
#' `control = list(adapt_delta = 0.99)`; only the entries supplied are changed.
#' See the `control` argument of [rstan::stan()] for the full set of entries.
#'
#' By default, each of 4 chains runs 1000 warmup iterations and then saves 1000
#' draws with no thinning, giving 4000 draws in total. These match the defaults
#' of [rstan::stan()] and Stan's general recommendations.
#'
#' Check convergence with [kb_converged()], [glance()], or [summary()].
#'
#' @section Model:
#' [kb_model_describe()] prints the fitted model, with its priors, in notation
#' or as a written description. The
#' [Methods article](https://hakaiinstitute.github.io/kelpbio/articles/methods.html)
#' describes each model and its assumptions.
#'
#' @section Priors:
#' Each entry is named after the parameter it sets, which [kb_model_describe()]
#' prints with the model. A list passed to `priors` replaces the entries it
#' names; the others keep their defaults. The prior family of each entry is
#' fixed; only its arguments can be changed.
#'
#' @section Site and year interaction:
#' The site:year effect lets a site depart from the year-to-year pattern shared
#' by all sites. It is separable from the site and year effects only when a site
#' has data in more than one year and a year has more than one site; otherwise
#' the fit warns. Estimates for the site-years in the data are then unaffected,
#' but other predictions depend on the `sd_site_year` prior (see
#' [kb_sensitivity()]).
#'
#' @inheritParams rlang::args_dots_empty
#' @param fit A `kb_fit` object.
#' @param object A `kb_fit` object.
#' @param x A `kb_fit` object.
#' @param x_name A string naming the data for error messages.
#' @param prior_only A flag specifying whether to sample from the priors only,
#'   for prior predictive checks.
#' @param chains A whole number of MCMC chains.
#' @param niters A whole number of saved post-warmup draws per chain (minimum
#'   2; number of warmup draws defaults to match).
#' @param nthin A whole number of the thinning interval.
#' @param cores A whole number of cores used to sample chains in parallel, or
#'   `NULL` to use `getOption("mc.cores")` if set or `chains` if not. Capped at
#'   the number of available cores.
#' @param seed A whole number passed to [rstan::sampling()] to make the fit
#'   reproducible, or `NULL` (the default, which uses a random seed). A
#'   preceding `set.seed()` also makes the fit reproducible.
#' @param progress A string, one of `"bar"` (the default, a console progress
#'   bar), `"verbose"` (rstan's per-iteration output and diagnostic warnings), or
#'   `"none"` (silent).
#' @param progress_dir A string giving an existing directory in which to record
#'   progress for [kb_progress()], or `NULL` (the default) to record none.
#' @param conf_level A number greater than 0 and less than 1 giving the
#'   compatibility-interval level.
#' @param estimate A function that reduces a numeric vector of posterior draws to
#'   a single estimate, such as `median` or `mean`.
#' @param sig_fig A whole number of significant figures for summary output.
#' @param include_random_effects A flag specifying whether to include the
#'   group-level random-effect terms in the output.
#' @param rhat A number giving the maximum acceptable Rhat.
#' @param ess A number giving the minimum acceptable bulk and tail effective
#'   sample size per chain.
#' @param max_perc_divergent A number giving the maximum acceptable percentage of
#'   saved draws that ended in a divergent transition.
#' @param by A character vector of grouping factors giving the rows of the
#'   grid. One of:
#'   - `NULL`: no grouping columns (the typical site and year).
#'   - `"site"`: one row per fitted site.
#'   - `"year"`: one row per fitted year.
#'   - `c("site", "year")`: one row per site-year.
#' @param new_levels A string giving how uncertainty is estimated for a site or
#'   year not in the data used to fit the model, or when `new_data` has no
#'   `site` or `year` column. Sites and years in the model fit always use their
#'   own estimates. One of:
#'   - `"average"` (the default): the typical site or year. The site and year
#'     effects are set to 0, their mean, so the interval does not include
#'     among-site or among-year variation. Use it to describe an average site or
#'     year.
#'   - `"sample"`: a new effect for each new site or year, drawn from the
#'     estimated variation among sites or among years (the random-effect
#'     standard deviation). The point estimate is equivalent, but the interval
#'     is wider since it also includes that variation. Use it to get realistic
#'     uncertainty about a particular site or year that the model has no
#'     information on. The interval varies slightly between calls; use
#'     `set.seed()` to reproduce it.
#' @param representative_site A character vector of sites in the fit whose
#'   effects a new site adopts (averaged when several are named), or `NULL` (the
#'   default) to follow `new_levels`.
#' @keywords internal
#' @aliases parameters arguments args
#' @usage NULL
# nocov start
params <- function(...) NULL
# nocov end

#' Parameter Descriptions for the Derived Verbs
#'
#' Parameter descriptions shared by [kb_predict_mean_weight()],
#' [kb_predict_biomass_in_situ()], and [kb_predict_biomass_canopy()].
#'
#' @param weight A `kb_fit_weight` object.
#' @param wetdry A `kb_fit_wetdry` object, required for dry, carbon, and
#'   nitrogen biomass, or `NULL`. All fits must be of the same species and have
#'   the same number of draws.
#' @param carbon A `kb_fit_carbon` object, required for carbon biomass, or
#'   `NULL`.
#' @param nitrogen A `kb_fit_nitrogen` object, required for nitrogen biomass,
#'   or `NULL`.
#' @param measure A string, one of `"wet"`, `"dry"`, `"carbon"`, or
#'   `"nitrogen"`, giving the type of biomass to predict.
#' @param n_plants A whole number of sizes averaged per draw to compute the
#'   mean plant weight; larger values are more precise and slower to compute.
#' @param progress A string, one of `"bar"` (the default, a console progress
#'   bar) or `"none"` (silent).
#' @param new_levels A string giving how uncertainty is shown for a site or
#'   year not in the fit. Sites and years in the fit always use their own
#'   estimates. One of:
#'   - `"sample"` (the default): a new effect for each new site or year, drawn
#'     from the estimated variation among sites or among years (the
#'     random-effect standard deviation). The point estimate is equivalent, but
#'     the interval is wider since it also includes that variation. Use it to
#'     get realistic uncertainty about a particular site or year that the model
#'     has no information on. The interval varies slightly between calls; use
#'     `set.seed()` to reproduce it.
#'   - `"average"`: the typical site or year. The site and year effects are set
#'     to 0, their mean, so the interval does not include among-site or
#'     among-year variation. Use it to describe an average site or year.
#' @param pool_by A character vector naming character or factor columns to
#'   group the rows by, such as `c("site", "year")`, `character(0)` to pool all
#'   rows, or `NULL` (the default) for one row per input row. On
#'   each draw, the biomass of a group is the sum of its rows' biomass (kg).
#'   For another summary, such as an unweighted mean of rows, summarise the
#'   draws column, for example with [posterior::rvar_mean()].
#' @keywords internal
#' @usage NULL
# nocov start
derived_params <- function(...) NULL
# nocov end

#' Parameter Descriptions for the Two-Fit Derived Verbs
#'
#' Parameter descriptions shared by [kb_predict_mean_weight()] and
#' [kb_predict_biomass_in_situ()].
#'
#' @param representative_site A character vector of sites whose effects a new
#'   site takes in every fit (averaged when several are named), a list naming
#'   the sites per fit, such as `list(weight = "site_a")`, where a fit left out
#'   follows `new_levels`, or `NULL` (the default) to follow `new_levels`.
#' @keywords internal
#' @usage NULL
# nocov start
two_fit_params <- function(...) NULL
# nocov end
