# Probe the full kelpbio public API: every exported function and the main
# argument combinations. Run block by block after devtools::install().
#
# Structure: basic functionality first (fit, accessors, predictions, plots),
# then advanced functionality (priors, custom-prior/prior-only fits, control,
# progress, site:year edge cases, raw posterior draws) further down, then the
# Macrocystis weight model, the size, wet/dry, and carbon models, survey biomass
# and mean weight, the cover calibration, and biomass over canopy.
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
# Column names carry their unit: diameter_mm and weight_kg
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
# or above 200, weight_kg above 100). The data still pass.
cm <- mutate(data_weight_sim_nereo, diameter_mm = diameter_mm / 10)
kb_check_data_weight_nereo(cm)
grams <- mutate(data_weight_sim_macro, weight_kg = weight_kg * 1000)
kb_check_data_weight_macro(grams)

# --- kb_fit_weight_nereo() ----------------------------------------------------
# The model: log weight ~ Normal, with year, site, and site:year effects on
# log(alpha). form sets expected weight as a function of x = diameter_mm / d0:
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

# --- fit accessors: broom + posterior + diagnostics ---------------------------
print(fit)
tidy(fit)
tidy(fit, include_random_effects = TRUE)
tidy(fit, conf_level = 0.8, sig_fig = 4)
coef(fit)
glance(fit)
kb_converged(fit)
summary(fit)

# full model in scientific notation, or as a methods paragraph (prose = TRUE);
# units and truncated priors (T[0, ]) are shown
kb_model_describe(fit)
kb_model_describe(fit, prose = TRUE)

nobs(fit)
# posterior's draw counts and names, re-exported
niterations(fit)
nchains(fit)
ndraws(fit)
nvariables(fit)
variables(fit)
# per-parameter Rhat and effective sample sizes
posterior::summarise_draws(fit)

kb_samples(fit)
# posterior's conversions and summaries accept the fit, as for brms or cmdstanr
posterior::as_draws_df(fit)
prior_summary(fit)
# prior sensitivity (needs priorsense); each term is also the kb_priors_*()
# entry to edit, and priorsense's own plots accept the fit
kb_sensitivity(fit)
kb_sensitivity(fit, prior_threshold = 0.05)
priorsense::powerscale_plot_dens(fit)
cat(kb_stancode(fit))
dim(log_lik(fit))

# leave-one-out cross-validation straight from the fit (loo is re-exported)
loo(fit)

# compare the two functional forms: elpd_diff is relative to the better form,
# with se_diff its standard error
loo_compare(list(packard_floor = loo(fit), power = loo(fit_power)))

# influential or poorly predicted plants: worth checking for recording errors
influence <- kb_influence(fit)
influence[influence$influential, ]
influence |> arrange(elpd_loo) |> head()

# posterior predictive checks (bayesplot): replicated data against the observed
# weights, and the same for deviance residuals
pp_check(fit)
pp_check(fit, "residual", ndraws = 20)

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
# site or year levels by name: every site in 2021, or one site across years;
# a level the fit has not seen is predicted as a new level
kb_new_data(fit, by = "site", diameter_mm = 30, year = 2021)
kb_new_data(fit, site = sites[1], year = 2019:2022, diameter_mm = 30)
kb_new_data(fit, site = "new_reef", diameter_mm = 30)

# predict at the grid: curves for the typical site and year, and by site
kb_predict_weight(fit, kb_new_data(fit))
kb_predict_weight(fit, kb_new_data(fit, by = "site"))
# by site and year: the site:year effect of each fitted site-year
kb_predict_weight(
  fit,
  kb_new_data(fit, by = c("site", "year"), diameter_mm = 30)
)
# both species have a year main effect, so by = "year" works for nereo too
kb_predict_weight(fit, kb_new_data(fit, by = "year", diameter_mm = 30))

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
kb_predict_weight(
  fit,
  tibble(diameter_mm = 40, site = sites[1]),
  new_levels = "sample"
)

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

# log axes: "y" or "xy" (the default is "none"); the axis titles say log scale
kb_plot_predictions(pop, log_axis = "xy")
kb_predict_weight(fit, kb_new_data(fit, by = "site")) |>
  kb_plot_predictions(log_axis = "y")

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
# at diameter -> 0), and the SDs; diameter_power and weight_floor
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
# Weight and size models always fit the site:year effect (there is no
# site_year_on argument). When the data cannot separate it from the site or year
# effect, the fit warns, naming that effect; estimates at the surveyed
# site-years are unaffected, but the site and year effects then lean on the
# sd_site_year prior (check with kb_sensitivity()). The cover calibration has
# site and year effects only. Three designs a reviewer should see, using
# subsets of the bundled example data:

# (a) Single year of data: site:year cannot be separated from site, so the fit
# warns naming the site effect (the warning shows whatever `progress` is).
one_year <- data_weight_sim_nereo |>
  filter(format(date, "%Y") == "2019") |>
  droplevels()
fit_one_year <- kb_fit_weight_nereo(one_year, chains = 2, niters = 300)
fit_one_year$meta$site_year_on # TRUE (fitted, with a warning)
"sd_site_year" %in% variables(fit_one_year) # TRUE

# (b) Aliased design: each site sampled in one year and each year at one site,
# so the warning names both the site and the year effects.
aliased <- data_weight_sim_nereo |>
  mutate(year = format(date, "%Y")) |>
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

# (c) One site over several years: the warning names the year effect.
one_site <- data_weight_sim_nereo |>
  filter(site == "otter_cove") |>
  droplevels()
fit_one_site <- kb_fit_weight_nereo(one_site, chains = 2, niters = 300, progress = "none")

# how much the site and year effects depend on the sd_site_year prior
kb_sensitivity(fit_one_year)

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
# SIZE DISTRIBUTION MODEL
# =============================================================================
# Size is one row per measured Nereocystis plant: maximum sub-bulb diameter (mm),
# Weibull. The log mean size varies by site, year, and site:year. There is no
# predictor, so predictions are one expected size per row or group.
# Macrocystis has no size model: every counted plant's fronds are recorded.

str(data_size_sim_nereo)
kb_check_data_size_nereo(data_size_sim_nereo)
kb_priors_size_nereo() # intercept, shape, sd_site/year/site_year

fit_s <- kb_fit_size_nereo(data_size_sim_nereo)
fit_s
tidy(fit_s)
summary(fit_s)
kb_model_describe(fit_s)

# expected size by group (the mean of the distribution)
kb_predict_size(fit_s, kb_new_data(fit_s))
kb_predict_size(fit_s, kb_new_data(fit_s, by = "site")) |>
  kb_plot_predictions() +
  coord_flip()

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

# draws of individual plant sizes
ppc_dens_overlay(fit_s$data$diameter_mm, posterior_predict(fit_s)[1:50, ])
augment(fit_s) |>
  ggplot(aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_jitter(width = 0.2, alpha = 0.3)


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
# MEAN WEIGHT AND SURVEY BIOMASS
# =============================================================================
# A plant is one individual (sporophyte), identified by its holdfast. A survey
# is one in situ count of a plot on a date: site, plot_id, date, and the surveyed
# area (survey_area_m2). Plant sizes come from a size fit when plants were
# tallied (Nereocystis: `plants` on the survey row), or from a table of every
# counted plant (Macrocystis: data_plants_sim_macro, with partial plants as
# half). A survey paired with a drone flight also carries plot_area_m2,
# canopy_area_m2, and tide_height_m.

str(data_survey_sim_nereo)
kb_check_data_survey(data_survey_sim_nereo)
kb_check_data_survey(data_survey_sim_macro, data_plants_sim_macro)
kb_check_data_plants_macro(data_plants_sim_macro)
# a date as text, or a tally next to a plant table: errors
try(kb_check_data_survey(mutate(
  data_survey_sim_nereo,
  date = as.character(date)
)))
try(kb_check_data_survey(data_survey_sim_nereo, data_plants_sim_macro))

# mean plant weight of each site-year from the weight and size fits; new
# site-years are sampled by default (every row is a particular site-year)
set.seed(1)
kb_predict_mean_weight(fit_weight_sim_nereo, fit_size_sim_nereo)
kb_predict_mean_weight(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  kb_new_data(fit_size_sim_nereo, by = "site"),
  new_levels = "average"
) |>
  kb_plot_predictions()

# survey biomass per m2 of the surveyed area, one row per survey, with its draws
set.seed(1)
biomass_n <- kb_predict_biomass_survey(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  data_survey_sim_nereo
)
biomass_n
biomass_m <- kb_predict_biomass_survey(
  fit_weight_sim_macro,
  data_plants_sim_macro,
  data_survey_sim_macro
)
# pooled by site-year (total kg over total area), or kg in the surveyed area
kb_predict_biomass_survey(
  fit_weight_sim_macro,
  data_plants_sim_macro,
  data_survey_sim_macro,
  pool_by = c("site", "year")
) |>
  kb_plot_predictions()
kb_predict_biomass_survey(
  fit_weight_sim_macro,
  data_plants_sim_macro,
  data_survey_sim_macro,
  per_area = FALSE
)
# carbon per m2 (g C/m2)
kb_predict_biomass_survey(
  fit_weight_sim_macro,
  data_plants_sim_macro,
  data_survey_sim_macro,
  fit_wetdry_sim_macro,
  fit_carbon_sim_macro,
  measure = "carbon"
)
# fits of different species: an error
try(kb_predict_biomass_survey(
  fit_weight_sim_nereo,
  data_plants_sim_macro,
  data_survey_sim_macro
))

# =============================================================================
# COVER CALIBRATION MODELS
# =============================================================================
# The calibration takes survey biomass from kb_predict_biomass_survey() with
# its defaults. Each survey with drone cover is one observation; the others are
# left out with a message. Biomass is a floor plus a term proportional to
# tide-corrected cover, Normal censored at zero, with an SD combining a
# constant, a part proportional to the mean, and each survey's weight SD.

kb_check_data_cover_calibration_nereo(biomass_n)
# summed or dry biomass has no biomass_kg_m2 column of draws: an error
try(kb_check_data_cover_calibration_nereo(select(biomass_n, -biomass_kg_m2)))

# cover_slope, biomass_floor, tide_height_slope, sd_residual, cv_residual,
# sd_site, sd_year
kb_priors_cover_calibration_nereo()
kb_priors_cover_calibration_macro() # macro differs in the floor and tide priors

fit_cv <- kb_fit_cover_calibration_nereo(biomass_n)
fit_cv
kb_model_describe(fit_cv)
tidy(fit_cv)
augment(fit_cv) # surveys with their mean and SD biomass, fitted, residual
pp_check(fit_cv)
kb_predict_cover_calibration(
  fit_cv,
  data.frame(
    canopy_area_m2 = c(0, 50, 150),
    plot_area_m2 = 200,
    tide_height_m = 0.5
  )
)
# curves over tide-corrected cover (0 to 1 by default) by site: each grid row is
# a unit plot at zero tide height
kb_predict_cover_calibration(fit_cv, kb_new_data(fit_cv, by = "site")) |>
  kb_plot_predictions()
fit_cvm <- kb_fit_cover_calibration_macro(biomass_m)

# =============================================================================
# BIOMASS OVER CANOPY
# =============================================================================
# kb_predict_biomass_canopy() turns a cover calibration fit and mapped canopy
# into total biomass: the expected biomass per m2 of bed (floor included) times
# each row's tide-corrected canopy area, in kg (wet, dry) or kg C. The rows need
# site, year, canopy_area_m2, tide_height_m, and classified_area_m2, which caps
# the corrected canopy. Unseen sites and years are sampled by default.

set.seed(1)
kb_predict_biomass_canopy(fit_cv, data_canopy_sim_nereo)
kb_predict_biomass_canopy(fit_cv, data_canopy_sim_nereo) |>
  kb_plot_predictions()
# totals summed on the draws: by region, by year, and over all rows
kb_predict_biomass_canopy(fit_cv, data_canopy_sim_nereo, pool_by = "region")
kb_predict_biomass_canopy(fit_cv, data_canopy_sim_nereo, pool_by = "year")
kb_predict_biomass_canopy(fit_cv, data_canopy_sim_nereo, pool_by = character(0))
# carbon stock (kg C) by year, from the wet/dry and carbon fits; the fits must
# have the same number of draws, so this uses the bundled calibration pre-fit
# (fit_cv has the default 4000 draws, the bundled pre-fits 1500)
kb_predict_biomass_canopy(
  fit_cover_calibration_sim_nereo,
  data_canopy_sim_nereo,
  fit_wetdry_sim_nereo,
  fit_carbon_sim_nereo,
  measure = "carbon",
  pool_by = "year"
)
# two rows of one site-year in a group warn; a canopy larger than its site errors
kb_predict_biomass_canopy(
  fit_cv,
  bind_rows(data_canopy_sim_nereo, data_canopy_sim_nereo[1, ]),
  pool_by = "region"
)
try(kb_predict_biomass_canopy(
  fit_cv,
  mutate(data_canopy_sim_nereo, classified_area_m2 = 10)
))
