# Probe the full kelpbio public API: every exported function and the main
# argument combinations. Run block by block after devtools::install().
#
# Structure: basic functionality first (fit, accessors, predictions, plots),
# then advanced functionality (priors, custom-prior/prior-only fits, control,
# progress, site:year edge cases, fits without density, raw posterior draws)
# further down, then the Macrocystis weight model, the size, density, wet/dry,
# and carbon models, and the biomass compositions (plot, cover, site).
#
# Orientation: pair this with decisions/architecture.md (the design overview);
# the behavioural contract lives in openspec/specs/, and the rendered pkgdown
# site (docs/) has the reference + Get Started vignette. The fitting blocks run
# MCMC, so expect them to take a little time.

library(kelpbio)
library(ggplot2)
library(dplyr)
library(bayesplot)

# new_levels = "sample" draws fresh random effects on each call; set a seed so
# the sampled prediction intervals below are reproducible. The default,
# "average", needs no seed.
set.seed(42)

# =============================================================================
# BASIC USAGE
# =============================================================================

# --- bundled data + pre-fit model ---------------------------------------------------
str(data_weight_sim_nereo)
fit_weight_sim_nereo

# --- kb_check_data_weight_nereo() ---------------------------------------------
# Column names carry their unit: diameter_mm, weight_kg, and the optional stipe
# density stipes_m2 (stipes per m^2), one value per site-year (NA where a
# site-year has no density survey)
kb_check_data_weight_nereo(data_weight_sim_nereo)

bad <- data_weight_sim_nereo
names(bad)[names(bad) == "diameter_mm"] <- "diam"
try(kb_check_data_weight_nereo(bad)) # missing column

# unsuffixed names (diameter, weight) are missing columns: the unit is part of
# the name
bad <- rename(data_weight_sim_nereo, diameter = diameter_mm, weight = weight_kg)
try(kb_check_data_weight_nereo(bad))

bad <- data_weight_sim_nereo
bad$weight_kg[1] <- -1
try(kb_check_data_weight_nereo(bad)) # not > 0

bad <- data_weight_sim_nereo
bad$diameter_mm[1] <- NA_real_
try(kb_check_data_weight_nereo(bad)) # missing value

# unit checks: data in the wrong unit fit without error but give wrong results,
# so the data checks warn when a median is implausible (diameter_mm below 10
# or above 200, weight_kg above 100, stipes_m2 above 100). The data
# still pass.
cm <- mutate(data_weight_sim_nereo, diameter_mm = diameter_mm / 10)
kb_check_data_weight_nereo(cm)
grams <- mutate(data_weight_sim_macro, weight_kg = weight_kg * 1000)
kb_check_data_weight_macro(grams)

# --- kb_fit_weight_nereo() ----------------------------------------------------
# The model: log weight ~ Normal, with year, site, site:year, and stipe density
# effects on log(alpha). The simulated data have density recorded for every
# site-year. form sets expected weight as a function of x = diameter_mm / d0:
#   "packard_floor" (default): weight_floor + alpha * x^diameter_power, a power law plus a
#     weight floor, so the log-log curve bends (recommended)
#   "power": alpha * x^diameter_power, a straight line on log-log axes (no weight_floor)
fit <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  form = "packard_floor"
)
fit_power <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  form = "power"
)
# print key model info (see other generics including summary() below)
fit

# --- fit accessors: broom + universals + diagnostics --------------------------
print(fit)
tidy(fit)
tidy(fit, include_random_effects = TRUE)
tidy(fit, conf_level = 0.8, sig_fig = 4)
coef(fit)
glance(fit)
converged(fit)
summary(fit)

# full model in scientific notation, or as a methods paragraph (prose = TRUE);
# units, truncated priors (T[0, ]), and the density standardisation are shown
kb_model_describe(fit)
kb_model_describe(fit, prose = TRUE)

nobs(fit)
niters(fit)
nchains(fit)
npars(fit)
nterms(fit)
pars(fit)
# bayesplot (and posterior) export their own rhat() generic, which masks the
# kelpbio/universals one once attached; namespace it, or read rhat/ESS off
# glance(fit) / summary(fit), which never collide.
kelpbio::rhat(fit)
esr(fit)
estimates(fit)

kb_samples(fit)
# posterior's conversions and summaries accept the fit, as for brms or cmdstanr
posterior::as_draws_df(fit)
posterior::summarise_draws(fit)
prior_summary(fit)
# prior sensitivity (needs priorsense); each term is also the kb_priors_*()
# entry to edit, and priorsense's own plots accept the fit
kb_sensitivity(fit)
kb_sensitivity(fit, prior_threshold = 0.05)
priorsense::powerscale_plot_dens(fit)
cat(kb_stancode(fit))
dim(log_lik(fit))

# log_lik is the pointwise matrix loo expects, so model comparison / influence
# diagnostics work directly off the fit.
loo::loo(log_lik(fit))

# compare the two functional forms: elpd_diff is relative to the better form,
# with se_diff its standard error
loo::loo_compare(
  list(
    packard_floor = loo::loo(log_lik(fit)),
    power = loo::loo(log_lik(fit_power))
  )
)

# --- fitted / residuals / augment (observed-data diagnostics) -----------------
# fitted values are expected (mean) weight: for the lognormal model that is the
# median exp(mu) times exp(sd_residual^2 / 2)
head(fitted(fit))
head(residuals(fit))
# appends fitted and residuals point estimates
augment(fit)

augment(fit) |>
  ggplot(aes(log(fitted), residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3)

# --- kb_predict_weight()  + predict() wrapper ---------------------------------
# every prediction verb predicts the expected response at the rows of new_data
nd <- data.frame(diameter_mm = c(22, 41, 38, 12))
sites <- levels(fit$data$site)

# by default, get predictions on observed data used to fit model
kb_predict_weight(fit)
# supply new data
kb_predict_weight(fit, new_data = nd)
kb_predict_weight(fit, new_data = tibble(diameter_mm = 40))

# use generic (wrapper of kb_predict_weight)
predict(fit)

# stipe density: each row's density is resolved in order: a supplied value, the
# recorded density of a fitted site-year, otherwise the fitted mean.
kb_predict_weight(
  fit,
  new_data = tibble(
    diameter_mm = 40,
    site = c(sites[1], sites[1], "new_reef"),
    year = "2020",
    stipes_m2 = c(8, NA, NA) # supplied, recorded site-year, new site (mean)
  )
)
# density effect: expected weight at 40 mm across stand density
kb_predict_weight(
  fit,
  new_data = tibble(diameter_mm = 40, stipes_m2 = seq(1.5, 8, by = 0.5))
) |>
  kb_plot_predictions(x = "stipes_m2")

# unit checks at prediction (for example from a pre-fit model): values far
# outside the fitted range warn, here diameters given in cm to a fit made in mm
kb_predict_weight(fit, new_data = tibble(diameter_mm = c(2.5, 4)))

# new_data predictor values are validated
try(kb_predict_weight(fit, new_data = tibble(diameter_mm = -5)))
try(kb_predict_weight(fit, new_data = tibble(diameter_mm = NA_real_)))

# --- kb_new_data(): rows by group ---------------------------------------------
# builds new_data by grouping (for group-level estimates and curves by group);
# the factors not named in `by` are absent, so they take the typical level
kb_new_data(fit)
# one row per site, crossed with a diameter sequence spanning the observed range
kb_new_data(fit, by = "site")
# set the diameter_mm values (the predictor argument for a nereo fit)
kb_new_data(fit, by = "site", diameter_mm = 30)
# by site and year gives only the site-years in the fitted data
kb_new_data(fit, by = c("site", "year"), diameter_mm = 30)
# the wrong species' predictor errors with the fix
try(kb_new_data(fit, fronds = 5))

# predict at the grid: curves for the typical site and year, and by site
kb_predict_weight(fit, kb_new_data(fit))
kb_predict_weight(fit, kb_new_data(fit, by = "site"))
# site-year curves use each site-year's recorded density
kb_predict_weight(fit, kb_new_data(fit, by = c("site", "year"), diameter_mm = 30))
# both species have a year main effect, so by = "year" works for nereo too
kb_predict_weight(fit, kb_new_data(fit, by = "year", diameter_mm = 30))

# the grid is an ordinary data frame: build your own, e.g. allometric curves at
# low, mean, and high stand density (stipes per m^2) for a typical site and
# year; density scales the size-dependent part of the weight, so the curves
# spread with plant size
tidyr::expand_grid(
  diameter_mm = seq(15, 80, length.out = 40),
  stipes_m2 = signif(c(1.5, fit$meta$density_mean, 8), 2)
) |>
  kb_predict_weight(fit, new_data = _) |>
  ggplot(aes(
    diameter_mm,
    estimate,
    colour = factor(stipes_m2),
    fill = factor(stipes_m2)
  )) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, colour = NA) +
  geom_line() +
  labs(
    x = "Sub-bulb diameter (mm)",
    y = "Wet weight (kg)",
    colour = "Stipes per m²",
    fill = "Stipes per m²"
  )

# --- new_levels: "average" (default) versus "sample" --------------------------
# A site, year, or site-year the fit never saw (or a grouping column that is
# absent) has no estimated effect. new_levels decides what stands in for it:
# - "average" (the default): the effect is zero, the typical site. The interval
#   is for the typical site, and the same on every call.
# - "sample": a new effect is drawn from the fitted between-site distribution,
#   so the interval includes how much sites differ. Use it for a prediction at a
#   particular unsurveyed site. It changes between calls unless a seed is set.
new_reef <- tibble(diameter_mm = c(20, 40, 60), site = "new_reef")
kb_predict_weight(fit, new_reef)
kb_predict_weight(fit, new_reef, new_levels = "sample")
# a fitted site is conditioned on its own effect under either setting
kb_predict_weight(fit, tibble(diameter_mm = 40, site = sites[1]))
kb_predict_weight(fit, tibble(diameter_mm = 40, site = sites[1]), new_levels = "sample")

# the same contrast on a grid: the typical-site curve versus a new-site curve
bind_rows(
  average = kb_predict_weight(fit, kb_new_data(fit)),
  sample = kb_predict_weight(fit, kb_new_data(fit), new_levels = "sample"),
  .id = "new_levels"
) |>
  ggplot(aes(diameter_mm, estimate, colour = new_levels, fill = new_levels)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, colour = NA) +
  geom_line() +
  labs(x = "Sub-bulb diameter (mm)", y = "Wet weight (kg)")

# side by side with kb_plot_predictions()
patchwork_available <- requireNamespace("patchwork", quietly = TRUE)
p_average <- kb_predict_weight(fit, kb_new_data(fit)) |>
  kb_plot_predictions() +
  ggtitle('new_levels = "average"')
p_sample <- kb_predict_weight(fit, kb_new_data(fit), new_levels = "sample") |>
  kb_plot_predictions() +
  ggtitle('new_levels = "sample"')
if (patchwork_available) {
  patchwork::wrap_plots(p_average, p_sample) &
    coord_cartesian(ylim = c(0, max(layer_data(p_sample)$ymax)))
} else {
  print(p_average)
  print(p_sample)
}

# gives users ability to select a representative site(s) to apply to new sites (not existing in fit dataset)
# this was requested from feedback in workshop
# these estimates are similar - but not identical because rep._site uses the site effect but draws randomly from site:year interaction
# (i.e., doesnt use the reference site's 2020 exactly, just a 'typical' year for it)
kb_predict_weight(
  kelpbio::fit_weight_sim_nereo, # the bundled simulated example fit
  new_data = tibble(
    diameter_mm = c(40, 40),
    site = c("new_reef", sites[1]),
    year = c(2020, 2020)
  ),
  new_levels = "sample",
  representative_site = sites[1]
)

# --- kb_plot_predictions() / autoplot() ---------------------------------------
# predictions at a kb_new_data() grid over several diameters are drawn as curves
pop <- kb_predict_weight(fit, kb_new_data(fit))
kb_plot_predictions(pop)
# raw data are not drawn: the curve holds the other effects at typical values,
# so the points are not a like-for-like comparison (see the 1:1 plot below).
# Add them as a layer if wanted:
kb_plot_predictions(pop) +
  geom_point(
    aes(diameter_mm, weight_kg),
    data = data_weight_sim_nereo,
    alpha = 0.3
  )
autoplot(pop)

# plot allometric curves for 'typical' year by site
# grouping from the prediction is stored and retrieved by plot function so is aware of how to facet
# note the default is to cap facets - user can set max_facets or pre-filter (see warning)
kb_predict_weight(fit, kb_new_data(fit, by = "site")) |>
  kb_plot_predictions()

# when only one predictor value per group, plot function knows to plot pointrange instead of line/ribbon
kb_predict_weight(fit, kb_new_data(fit, by = "site", diameter_mm = 30)) |>
  kb_plot_predictions() +
  coord_flip()

# predicted vs observed: kb_predict_weight() on the fit data returns the observed
# weight alongside the model estimate, so it plots directly against a 1:1 line as
# a quick fit/calibration check (log-log, since weights span two orders of magnitude)
kb_predict_weight(fit) |>
  ggplot(aes(weight_kg, estimate)) +
  geom_abline(slope = 1, intercept = 0, linetype = 2) +
  geom_point(alpha = 0.3) +
  scale_x_log10() +
  scale_y_log10() +
  labs(x = "Observed weight", y = "Predicted weight")

# =============================================================================
# ADVANCED USAGE
# =============================================================================

# --- priors -------------------------------------------------------------------
kb_priors_weight_nereo()
kb_prior_normal(mean = 0, sd = 2)
kb_prior_exponential(rate = 1)
# priors are classed
class(kb_prior_exponential(rate = 1))

# intercept, diameter_power (allometric exponent), weight_floor (weight in kg
# at diameter -> 0), density_slope, and the SDs; diameter_power and weight_floor
# are truncated at zero by the model
priors <- kb_priors_weight_nereo()
priors$diameter_power <- kb_prior_normal(mean = 2, sd = 0.05)
priors$sd_site <- kb_prior_exponential(rate = 3)
priors

# custom priors
fit_custom <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = priors,
  progress = "none"
)

# a very tight prior on diameter_power pulls the exponent away from the default-prior
# posterior (about 3.2)
bind_rows(
  mutate(coef(fit), priors = "default"),
  mutate(coef(fit_custom), priors = "custom")
) |>
  filter(term == "diameter_power")

# --- prior_only (prior predictive) --------------------------------------------
# prior_only ignores observed weights; supplied data informs RE dimensions,
# centering reference, and prior-predictive checks
fit_prior <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  prior_only = TRUE,
  chains = 2,
  niters = 500,
  progress = "none"
)
prior_summary(fit_prior)

# --- control (technical rstan sampling args) ----------------------------------
# pass more technical rstan sampling args through control
# see control argument in ?rstan::stan for options - control is passed via ...
# through to underlying sample arg
fit_ctrl <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  chains = 1,
  niters = 200,
  progress = "none",
  control = list(adapt_delta = 0.99, max_treedepth = 12)
)

# --- progress reporting -------------------------------------------------------
# progress controls fit-time console output only (it never changes the draws).
# rstan's own per-iteration output is verbose and confusing for a non-technical
# audience, so the default is a clean progress bar.
#   "bar"     - a tidy console progress bar (default)
#   "verbose" - rstan's raw per-iteration output and HMC diagnostics (debugging)
#   "none"    - silent (scripts, batch runs)
fit_bar <- kb_fit_weight_nereo(data_weight_sim_nereo, chains = 2, niters = 300)
fit_verbose <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  chains = 2,
  niters = 300,
  progress = "verbose"
)
fit_none <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  chains = 2,
  niters = 300,
  progress = "none"
)

# The same progress signal drives a Shiny app: point the fit at a directory with
# progress_dir, run it in a background process (e.g. shiny::ExtendedTask), and
# poll kb_progress() from the app to read the completed fraction (0 to 1)
# while the fit runs. Here the fit is synchronous, so progress reads 1 once done.
progress_dir <- tempfile()
dir.create(progress_dir)
fit_polled <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  chains = 2,
  niters = 300,
  progress = "none",
  progress_dir = progress_dir
)
kb_progress(progress_dir) # 1 (complete)

# --- site:year effect edge cases ----------------------------------------------
# The site:year effect is determined automatically from the data (there is no
# site_year_on argument). Two edge cases a reviewer should see, using subsets of
# the bundled example data:

# (a) Single year of data: the site:year effect is confounded with the site
# effect, so it is omitted. An informational notice prints (unless progress = "none").
one_year <- data_weight_sim_nereo |>
  filter(year == "2019") |>
  droplevels()
fit_one_year <- kb_fit_weight_nereo(one_year, chains = 2, niters = 300)
fit_one_year$meta$site_year_on # FALSE (effect omitted)

# (b) Aliased design: several years, but each site sampled in only one year, so
# site and site:year cannot be separated. The effect is retained and a warning is
# issued (shown regardless of progress).
aliased <- data_weight_sim_nereo |>
  filter(
    (site == "otter_cove" & year == "2019") |
      (site == "gull_rock" & year == "2020") |
      (site == "cedar_bay" & year == "2021") |
      (site == "heron_reef" & year == "2022")
  ) |>
  droplevels()
fit_aliased <- kb_fit_weight_nereo(
  aliased,
  chains = 2,
  niters = 300,
  progress = "none"
)
fit_aliased$meta$site_year_on # TRUE (retained despite non-identifiability)

# An omitted effect is left out of every summary and of the draws: its draws were
# sampled from the prior alone. No sd_site_year here:
tidy(fit_one_year)
pars(fit_one_year)
"sd_site_year" %in% posterior::variables(kb_samples(fit_one_year)) # FALSE

# --- functional form ---------------------------------------------------------
# fit_power (fitted above with form = "power") has no weight_floor; its straight
# log-log line pivots to fit the small plants, so it sits below the
# packard_floor curve for the smallest and largest plants and above it between
tidy(fit_power)
kb_model_describe(fit_power)
bind_rows(
  mutate(
    kb_predict_weight(fit, kb_new_data(fit)),
    form = "packard_floor"
  ),
  mutate(
    kb_predict_weight(fit_power, kb_new_data(fit_power)),
    form = "power"
  )
) |>
  ggplot(aes(diameter_mm, estimate, colour = form, fill = form)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, colour = NA) +
  geom_line() +
  scale_x_log10() +
  scale_y_log10()

# --- fits without density ----------------------------------------------------
# Without a density column the density effect is omitted, silently: the model is
# the same allometry without density_slope.
no_density <- select(data_weight_sim_nereo, -stipes_m2)
fit_no_density <- kb_fit_weight_nereo(no_density, chains = 2, niters = 300)
fit_no_density$meta$density_on # FALSE
tidy(fit_no_density) # no density_slope

# --- raw posterior draws (rstantools generics) --------------------------------
# users may want more low-level access to the draws to do their own diagnostics/derived quants
# posterior_epred() is expected (mean) weight; posterior_linpred(transform =
# TRUE) is exp() of the linear predictor, the median. They differ by
# exp(sd_residual^2 / 2) for nereo:
median(posterior_epred(fit, new_data = nd)[, 1])
median(posterior_linpred(fit, transform = TRUE, new_data = nd)[, 1])
class(posterior_epred(fit))
dim(posterior_epred(fit))
dim(posterior_epred(fit, new_data = nd))
dim(posterior_linpred(fit))
dim(posterior_linpred(fit, transform = TRUE))
dim(posterior_predict(fit))
dim(posterior_predict(fit, new_data = nd))

ppc_dens_overlay(
  fit$data$weight_kg,
  posterior_predict(fit)[1:50, , drop = FALSE]
) +
  scale_x_log10()

# compare this to prior predictive simulation (from prior-only model)
ppc_dens_overlay(
  fit_prior$data$weight_kg,
  posterior_predict(fit_prior)[1:50, , drop = FALSE]
) +
  scale_x_log10() # prior predictive

# --- advanced prediction arguments --------------------------------------------
# tinker with how estimates summarised
kb_predict_weight(
  fit,
  new_data = nd,
  conf_level = 0.8,
  estimate = mean,
  sig_fig = 4
)
# fails if rep._site not in existing fit site levels
try(kb_predict_weight(
  fit,
  new_data = tibble(diameter_mm = 40, site = "new_reef"),
  representative_site = "nope"
))

# =============================================================================
# SECOND SPECIES: MACROCYSTIS (Gamma on frond count)
# =============================================================================
# Macrocystis has its own fit function, priors, and data check because the model
# differs structurally from nereo: the predictor is a frond COUNT (`fronds`) and
# the response is Gamma with a constant shape (`shape`). The fit object is the
# same class, so every accessor, generic, and prediction/plot function above
# works unchanged.

# --- bundled data + pre-fit model ---------------------------------------------
str(data_weight_sim_macro)
fit_weight_sim_macro

# --- data check (requires a `fronds` column, whole numbers > 0) ---------------
kb_check_data_weight_macro(data_weight_sim_macro)

bad <- data_weight_sim_macro
bad$fronds[1] <- 5.5
try(kb_check_data_weight_macro(bad)) # not a whole number

# --- priors (macro-specific parameter set) ------------------------------------
kb_priors_weight_macro() # intercept, fronds_slope, shape, sd_site/year/site_year

# --- fit ----------------------------------------------------------------------
fit_m <- kb_fit_weight_macro(
  data_weight_sim_macro,
  chains = 4,
  niters = 500,
  nthin = 2
)
fit_m # slim header; kb_model_describe(fit_m) shows the Gamma model + structure

# same accessors as nereo; the term list is macro's (fronds_slope, shape)

tidy(fit_m)
glance(fit_m)
summary(fit_m)

# --- predictions --------------------------------------------------------------
# new_data uses the `fronds` predictor (not diameter_mm); fronds must be whole numbers
kb_predict_weight(fit_m, new_data = tibble(fronds = c(2, 5, 10, 15)))
try(kb_predict_weight(fit_m, new_data = tibble(fronds = 2.5)))

# one estimate per year at 10 fronds
kb_predict_weight(fit_m, kb_new_data(fit_m, by = "year", fronds = 10)) |>
  kb_plot_predictions() +
  coord_flip()

# the default frond sequence takes whole numbers over the observed range
kb_predict_weight(fit_m, kb_new_data(fit_m, by = "site")) |>
  kb_plot_predictions()

augment(fit_m) |>
  ggplot(aes(log(fitted), residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3)

# posterior_predict draws strictly positive Gamma replicates
pp_m <- posterior_predict(fit_m, new_data = tibble(fronds = c(2, 5, 10)))
range(pp_m) # all > 0

# residuals are Gamma deviance residuals
head(residuals(fit_m))

# =============================================================================
# SIZE DISTRIBUTION MODELS
# =============================================================================
# Size is one row per plant: maximum sub-bulb diameter (mm) for nereo (Weibull),
# fronds reaching 1 m above the holdfast for macro (zero-truncated negative
# binomial). The log mean size varies by site, year, and site:year. There is no
# predictor, so predictions are one expected size per row or group.

str(data_size_sim_nereo)
kb_check_data_size_nereo(data_size_sim_nereo)
kb_check_data_size_macro(data_size_sim_macro)
try(kb_check_data_size_macro(mutate(data_size_sim_macro, fronds = 0))) # >= 1

kb_priors_size_nereo() # intercept, shape, sd_site/year/site_year
kb_priors_size_macro() # intercept, dispersion, sd_site/year/site_year

fit_s <- kb_fit_size_nereo(data_size_sim_nereo)
fit_s
tidy(fit_s)
summary(fit_s)
kb_model_describe(fit_s)

fit_sm <- kb_fit_size_macro(data_size_sim_macro)
kb_model_describe(fit_sm)

# expected size by group (the mean of the distribution); for macro, the
# expected frond count of a plant with at least one frond at 1 m
kb_predict_size(fit_s, kb_new_data(fit_s))
kb_predict_size(fit_s, kb_new_data(fit_s, by = "site")) |>
  kb_plot_predictions() +
  coord_flip()
kb_predict_size(fit_sm, kb_new_data(fit_sm, by = "year")) |>
  kb_plot_predictions()

# rows of site/year (no predictor column); a new site is the typical site by
# default, and "sample" adds the variation between sites
kb_predict_size(fit_s, new_data = tibble(site = c("otter_cove", "new_reef")))
kb_predict_size(
  fit_s,
  new_data = tibble(site = c("otter_cove", "new_reef")),
  new_levels = "sample"
)
kb_predict_size(
  fit_s,
  new_data = tibble(site = "new_reef"),
  representative_site = "otter_cove"
)

# macro: posterior_epred is the truncated mean; linpred(transform = TRUE) is the
# untruncated mean, which is lower
nd <- tibble(site = "otter_cove")
median(posterior_epred(fit_sm, new_data = nd))
median(posterior_linpred(fit_sm, transform = TRUE, new_data = nd))

# draws of individual plant sizes (whole numbers >= 1 for macro)
ppc_dens_overlay(fit_s$data$diameter_mm, posterior_predict(fit_s)[1:50, ])
head(residuals(fit_sm))
augment(fit_s) |>
  ggplot(aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_jitter(width = 0.2, alpha = 0.3)

# =============================================================================
# DENSITY MODELS
# =============================================================================
# Density is one row per transect: the count of stipes (nereo, zero-inflated
# negative binomial) or plants (macro, negative binomial) on a transect of
# area_m2. The expected count is area times density, so area_m2 is an offset.
# Log density varies by site, year, and site:year. Sum bin-level counts (and
# their areas) to one row per transect before fitting.

str(data_density_sim_nereo)
kb_check_data_density_nereo(data_density_sim_nereo)
kb_check_data_density_macro(data_density_sim_macro)
try(kb_check_data_density_nereo(mutate(data_density_sim_nereo, area_m2 = 0)))
# area in cm^2 warns
kb_check_data_density_nereo(mutate(
  data_density_sim_nereo,
  area_m2 = area_m2 * 1e4
))

kb_priors_density_nereo() # intercept, logit_zero_inflation, dispersion, sd_*
kb_priors_density_macro() # intercept, dispersion, sd_*

fit_d <- kb_fit_density_nereo(data_density_sim_nereo)
fit_d
tidy(fit_d) # intercept: log stipes per m^2; logit_zero_inflation: logit P(no stipes)
kb_model_describe(fit_d)

fit_dm <- kb_fit_density_macro(data_density_sim_macro)
kb_model_describe(fit_dm)

# density is always per m^2 (zero inflation included for nereo), at the
# observed transects, by group, or at your own rows
kb_predict_density(fit_d)
kb_predict_density(fit_d, kb_new_data(fit_d))
kb_predict_density(fit_d, kb_new_data(fit_d, by = "site")) |>
  kb_plot_predictions() +
  coord_flip()
kb_predict_density(fit_dm, kb_new_data(fit_dm, by = c("site", "year"))) |>
  kb_plot_predictions()
kb_predict_density(fit_d, new_data = tibble(site = c("otter_cove", "new_reef")))

# an area_m2 column does not change the estimate: it stays per m^2
kb_predict_density(fit_d, new_data = tibble(site = "otter_cove", area_m2 = c(20, 40)))
# the expected count on a 40 m^2 transect, and its limits, are the density x 40
kb_predict_density(fit_d, new_data = tibble(site = "otter_cove")) |>
  mutate(across(c(estimate, lower, upper), \(x) x * 40))

# transect counts: the draw generics read area_m2 (1 m^2 when absent)
transects <- tibble(site = "otter_cove", area_m2 = c(20, 40))
apply(posterior_epred(fit_d, new_data = transects), 2, median) # expected counts
pp_counts <- posterior_predict(fit_d, new_data = transects) # simulated counts
apply(pp_counts, 2, quantile, probs = c(0.025, 0.5, 0.975))

# nereo: posterior_epred includes the zero-inflation probability;
# linpred(transform = TRUE) is the mean on a transect holding stipes, so higher
nd <- tibble(site = "otter_cove")
median(posterior_epred(fit_d, new_data = nd))
median(posterior_linpred(fit_d, transform = TRUE, new_data = nd))
median(posterior_linpred(fit_d, new_data = nd))

# draws of transect counts (whole numbers >= 0)
ppc_bars(fit_d$data$stipes, posterior_predict(fit_d)[1:50, ])
augment(fit_dm) |>
  ggplot(aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3)

# =============================================================================
# WET/DRY MODELS
# =============================================================================
# Wet/dry is one row per tissue sample: wet_mass_g and dry_mass_g. The dry:wet
# ratio is Beta with one mean and precision for all samples (no random effects;
# samples pooled over months, sites, and tissues). For a season-specific ratio,
# fit to that season's samples only.

str(data_wetdry_sim_nereo)
kb_check_data_wetdry_nereo(data_wetdry_sim_nereo)
try(kb_check_data_wetdry_nereo(mutate(
  data_wetdry_sim_nereo,
  dry_mass_g = wet_mass_g
)))
# one implausible sample (ratio 0.7): a warning, and the sample is kept
odd <- data_wetdry_sim_nereo
odd$dry_mass_g[1] <- 0.7 * odd$wet_mass_g[1]
kb_check_data_wetdry_nereo(odd)
# masses in mg warn
kb_check_data_wetdry_macro(mutate(
  data_wetdry_sim_macro,
  across(everything(), ~ .x * 1000)
))

kb_priors_wetdry_nereo() # intercept (logit ratio), precision

fit_w <- kb_fit_wetdry_nereo(data_wetdry_sim_nereo)
fit_w
tidy(fit_w) # intercept: logit mean ratio; precision: Beta precision
kb_model_describe(fit_w)

# the expected dry:wet ratio, one estimate
kb_predict_wetdry(fit_w)
kb_predict_wetdry(kb_fit_wetdry_macro(data_wetdry_sim_macro))

# draws of individual sample ratios
ppc_dens_overlay(
  fit_w$data$dry_mass_g / fit_w$data$wet_mass_g,
  posterior_predict(fit_w)[1:50, ]
)

# =============================================================================
# CARBON MODELS
# =============================================================================
# Carbon is one row per dried tissue sample, as the isotope lab reports it:
# sample_mass_mg and carbon_mass_ug. The response is the carbon fraction,
# carbon_mass_ug / 1000 / sample_mass_mg: Beta with one mean and precision for
# all samples, pooled over months; fit to a season's samples for a
# season-specific fraction. Fractions outside 0.10 to 0.50 warn but are kept.

str(data_carbon_sim_nereo)
kb_check_data_carbon_nereo(data_carbon_sim_nereo)
# one implausible sample (fraction 0.60): a warning, and the sample is kept
odd <- data_carbon_sim_nereo
odd$carbon_mass_ug[1] <- 0.6 * odd$sample_mass_mg[1] * 1000
kb_check_data_carbon_nereo(odd)
# carbon in mg rather than ug: every fraction falls far below 0.10, so all warn
kb_check_data_carbon_nereo(mutate(
  data_carbon_sim_nereo,
  carbon_mass_ug = carbon_mass_ug / 1000
))
# sample mass in g rather than mg: carbon exceeds the sample mass, an error
try(kb_check_data_carbon_nereo(mutate(
  data_carbon_sim_nereo,
  sample_mass_mg = sample_mass_mg / 1000
)))

kb_priors_carbon_nereo() # intercept (logit fraction), precision

fit_c <- kb_fit_carbon_nereo(data_carbon_sim_nereo)
fit_c
kb_model_describe(fit_c)
kb_predict_carbon(fit_c)
kb_predict_carbon(kb_fit_carbon_macro(data_carbon_sim_macro))

# =============================================================================
# PLOT BIOMASS
# =============================================================================
# kb_predict_plot_biomass() combines a weight, a size, and a density fit of one
# species into the expected biomass per m2 of each site-year surveyed for
# density: density x mean plant weight over the size distribution, per draw.
# measure = "dry" adds a wet/dry fit, "carbon" a carbon fit too (g C/m2).
# weight_support / size_support say what data each fit has for the site-year:
# "site-year", "site, year" (both, not together), "site", "year", or "none".

# site-years the weight or size fit never saw draw their effects ("sample", the
# default, unlike the prediction verbs: every row is a particular site-year), so
# set a seed; "average" gives them the typical site and year instead
set.seed(1)
kb_predict_plot_biomass(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  fit_density_sim_nereo
)
kb_predict_plot_biomass(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  fit_density_sim_nereo,
  new_levels = "average"
)
kb_predict_plot_biomass(
  fit_weight_sim_macro,
  fit_size_sim_macro,
  fit_density_sim_macro,
  fit_wetdry_sim_macro,
  fit_carbon_sim_macro,
  measure = "carbon"
) |>
  kb_plot_predictions()
# fits of different species, or different draw counts: an error
try(kb_predict_plot_biomass(
  fit_weight_sim_nereo,
  fit_size_sim_macro,
  fit_density_sim_nereo
))

# =============================================================================
# COVER BIOMASS MODELS
# =============================================================================
# Cover takes two data frames. `data` is one row per drone survey:
# canopy_area_m2 within plot_area_m2, the survey tide_height_m, site, and year.
# `biomass` is the in situ wet biomass of each site-year (kg/m^2) as
# estimate/lower/upper, such as kb_predict_plot_biomass() output; the fit pairs them
# by site and year, and surveys with no biomass are dropped with a message.
# Biomass is a floor plus a term proportional to tide-corrected cover; each
# survey is weighted by the precision of its in situ estimate.

str(data_cover_biomass_sim_nereo)
str(data_plot_biomass_sim_nereo)
kb_check_data_cover_biomass_nereo(data_cover_biomass_sim_nereo, data_plot_biomass_sim_nereo)
# canopy larger than its plot: an error
try(kb_check_data_cover_biomass_nereo(mutate(
  data_cover_biomass_sim_nereo,
  canopy_area_m2 = plot_area_m2 + 1
)))
# limits that do not bracket the estimate: an error
try(kb_check_data_cover_biomass_nereo(
  data_cover_biomass_sim_nereo,
  mutate(data_plot_biomass_sim_nereo, lower = estimate * 2)
))
# two biomass rows for one site-year: an error
try(kb_check_data_cover_biomass_nereo(
  data_cover_biomass_sim_nereo,
  rbind(data_plot_biomass_sim_nereo, data_plot_biomass_sim_nereo[1, ])
))
# tide in cm: a warning
kb_check_data_cover_biomass_nereo(mutate(
  data_cover_biomass_sim_nereo,
  tide_height_m = tide_height_m * 100
))

# cover_slope, biomass_floor, tide_height_slope, error_scaling, sd_site, sd_year
kb_priors_cover_biomass_nereo()
kb_priors_cover_biomass_macro() # macro differs in the floor and tide priors

fit_cv <- kb_fit_cover_biomass_nereo(data_cover_biomass_sim_nereo, data_plot_biomass_sim_nereo)
fit_cv
kb_model_describe(fit_cv)
tidy(fit_cv)
augment(fit_cv) # surveys with the paired in situ biomass, fitted, residual
kb_predict_cover_biomass(
  fit_cv,
  data.frame(
    canopy_area_m2 = c(0, 50, 150),
    plot_area_m2 = 200,
    tide_height_m = 0.5
  )
)
# curves over tide-corrected cover (0 to 1 by default) by site: each grid row is
# a unit plot at zero tide height
kb_new_data(fit_cv, by = "site", cover = c(0, 0.5, 1))
kb_predict_cover_biomass(fit_cv, kb_new_data(fit_cv, by = "site")) |>
  kb_plot_predictions()
# a new site: the typical site by default, "sample" adds between-site variation
new_survey <- data.frame(
  site = "new_reef",
  canopy_area_m2 = 80,
  plot_area_m2 = 200,
  tide_height_m = 0.5
)
kb_predict_cover_biomass(fit_cv, new_survey)
kb_predict_cover_biomass(fit_cv, new_survey, new_levels = "sample")
# surveys without in situ biomass are dropped with a message
kb_fit_cover_biomass_nereo(data_cover_biomass_sim_nereo, data_plot_biomass_sim_nereo[-(1:3), ])
# in situ limits at 90% rather than 95%
kb_fit_cover_biomass_macro(
  data_cover_biomass_sim_macro,
  data_plot_biomass_sim_macro,
  conf_level = 0.9
)

# end to end: in situ biomass from the weight, size, and density fits, then the
# cover fit on it (surveys of site-years without plot biomass are dropped)
set.seed(1)
plot_biomass <- kb_predict_plot_biomass(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  fit_density_sim_nereo
)
fit_cv_e2e <- kb_fit_cover_biomass_nereo(data_cover_biomass_sim_nereo, plot_biomass)
kb_predict_cover_biomass(fit_cv_e2e, kb_new_data(fit_cv_e2e)) |>
  kb_plot_predictions()

# =============================================================================
# SITE BIOMASS
# =============================================================================
# kb_predict_site_biomass() turns a cover biomass fit and drone surveys of whole
# sites into total biomass: the expected biomass per m2 of bed (floor included)
# times each survey's tide-corrected canopy area, in kg (wet, dry) or kg C. The
# surveys need site, year, canopy_area_m2, and tide_height_m; site_area_m2 (the
# area within the site boundary) is optional and caps the corrected canopy.
# Unseen sites and years are sampled by default, so set a seed.

drone <- tibble(
  site = c("otter_cove", "otter_cove", "gull_rock", "cedar_bay", "new_reef"),
  year = c("2019", "2020", "2020", "2020", "2020"),
  canopy_area_m2 = c(1500, 1100, 4800, 2600, 900),
  tide_height_m = c(1.7, 0.7, 0.5, 1.2, 0.9),
  site_area_m2 = 5e4,
  region = c("north", "north", "south", "south", "south")
)
set.seed(1)
# one total per survey; cover_support says what the cover fit has for it
kb_predict_site_biomass(fit_cv, drone)
kb_predict_site_biomass(fit_cv, drone) |>
  kb_plot_predictions()
# a new site at its typical value instead of sampled
kb_predict_site_biomass(fit_cv, drone, new_levels = "average")
# totals summed on the draws: by region, by year, and over all surveys
kb_predict_site_biomass(fit_cv, drone, sum_by = "region")
kb_predict_site_biomass(fit_cv, drone, sum_by = "year")
kb_predict_site_biomass(fit_cv, drone, sum_by = character(0))
# carbon stock (kg C) by year, from the wet/dry and carbon fits
kb_predict_site_biomass(
  fit_cv,
  drone,
  fit_wetdry_sim_nereo,
  fit_carbon_sim_nereo,
  measure = "carbon",
  sum_by = "year"
)
# a numeric grouping column, or two surveys of one site-year in a group
try(kb_predict_site_biomass(fit_cv, mutate(drone, zone = 1), sum_by = "zone"))
kb_predict_site_biomass(fit_cv, bind_rows(drone, drone[1, ]), sum_by = "region")
# a canopy larger than its site: an error
try(kb_predict_site_biomass(fit_cv, mutate(drone, site_area_m2 = 1000)))
