# Probe the full kelpbio public API: every exported function and the main
# argument combinations. Run block by block after devtools::install().
#
# Structure: basic functionality first (fit, accessors, predictions, plots),
# then advanced functionality (priors, custom-prior/prior-only fits, control,
# progress, site:year edge cases, density, unit checks, raw posterior draws)
# further down.
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
# the sampled prediction intervals below are reproducible.
set.seed(42)

# =============================================================================
# BASIC USAGE
# =============================================================================

# --- bundled data + pre-fit model ---------------------------------------------------
str(data_weight_sim_nereo)
fit_weight_sim_nereo

# --- kb_check_data_weight_nereo() ---------------------------------------------
# diameter in mm, weight in kg; density (stipes per m^2) is an optional column,
# NA for site-years without a density survey
kb_check_data_weight_nereo(data_weight_sim_nereo)

bad <- data_weight_sim_nereo
names(bad)[names(bad) == "diameter"] <- "diam"
try(kb_check_data_weight_nereo(bad)) # missing column

bad <- data_weight_sim_nereo
bad$weight[1] <- -1
try(kb_check_data_weight_nereo(bad)) # not > 0

bad <- data_weight_sim_nereo
bad$diameter[1] <- NA_real_
try(kb_check_data_weight_nereo(bad)) # missing value

# --- kb_fit_weight_nereo() ----------------------------------------------------
# The model: log weight ~ Normal, expected weight = bFloor + alpha * x^bPower
# (Packard power function of diameter relative to its geometric mean), with year,
# site, site:year, and stipe density effects on log(alpha). The simulated data
# have density for all but three site-years, so a message reports those take
# the mean density.
fit <- kb_fit_weight_nereo(
  data_weight_sim_nereo
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

samples(fit)
prior_summary(fit)
cat(kb_stancode(fit))
dim(log_lik(fit))

# log_lik is the pointwise matrix loo expects, so model comparison / influence
# diagnostics work directly off the fit.
loo::loo(log_lik(fit))

# --- fitted / residuals / augment (observed-data diagnostics) -----------------
# fitted values are expected (mean) weight: for the lognormal model that is the
# median exp(mu) times exp(sWeight^2 / 2)
head(fitted(fit))
head(residuals(fit))
# appends fitted and residuals point estimates
augment(fit)

augment(fit) |>
  ggplot(aes(log(fitted), residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3)

# --- kb_predict_weight()  + predict() wrapper ---------------------------------
# expects user to provide new_data, gets predictions row-by-row
nd <- data.frame(diameter = c(22, 41, 38, 12))
sites <- levels(fit$data$site)

# by default, get predictions on observed data used to fit model
kb_predict_weight(fit)
# supply new data
kb_predict_weight(fit, new_data = nd)
kb_predict_weight(fit, new_data = tibble(diameter = 40))

# use generic (wrapper of kb_predict_weight)
predict(fit)

# --- kb_predict_weight_by()  --------------------------------------------------
# builds a new_data grid based on 'by' grouping (for getting group-level effect
# estimates and plotting curves by group)
# default is for 'average' site and year (RE zeroed) over diameter sequence
# spanning observed range
kb_predict_weight_by(fit)
# by default generate sequence of diameters across range
kb_predict_weight_by(fit, by = "site")
# set the diameter sequence (the predictor argument for a nereo fit)
kb_predict_weight_by(fit, by = "site", diameter = 30)
# site-year curves use each site-year's recorded density
kb_predict_weight_by(fit, by = c("site", "year"))
# typical site and year
kb_predict_weight_by(fit, diameter = c(15, 30, 45))
# both species have a year main effect, so by = "year" works for nereo too
kb_predict_weight_by(fit, by = "year", diameter = 30)

# sample from RE dist for wider uncertainty, i.e. for new, unobserved site/year
kb_predict_weight_by(fit, new_levels = "sample")
kb_predict_weight(
  fit,
  new_data = tibble(diameter = 40, site = "new_reef"),
  new_levels = "sample"
)

# gives users ability to select a representative site(s) to apply to new sites (not existing in fit dataset)
# this was requested from feedback in workshop
# these estimates are similar - but not identical because rep._site uses the site effect but draws randomly from site:year interaction
# (i.e., doesnt use the reference site's 2020 exactly, just a 'typical' year for it)
kb_predict_weight(
  kelpbio::fit_weight_sim_nereo, # the bundled simulated example fit
  new_data = tibble(
    diameter = c(40, 40),
    site = c("new_reef", sites[1]),
    year = c(2020, 2020)
  ),
  representative_site = sites[1]
)

# --- kb_plot_predictions() / autoplot() ---------------------------------------
pop <- kb_predict_weight_by(fit)
kb_plot_predictions(pop)
kb_plot_predictions(pop, observed = data_weight_sim_nereo)
autoplot(pop)

# wider uncertainty - draw from RE distributions (i.e. new, unobserved site)
pop <- kb_predict_weight_by(fit, new_levels = "sample")
kb_plot_predictions(pop)

# plot allometric curves for 'typical' year by site
# grouping from kb_predict function is stored and retrieved by plot function so is aware of how to facet
# note the default is to cap facets - user can set max_facets or pre-filter (see warning)
kb_predict_weight_by(fit) |>
  kb_plot_predictions()

# when only one predictor value per group, plot function knows to plot pointrange instead of line/ribbon
kb_predict_weight_by(fit, by = "site", diameter = 30) |>
  kb_plot_predictions() +
  coord_flip()

# predicted vs observed: kb_predict_weight() on the fit data returns the observed
# weight alongside the model estimate, so it plots directly against a 1:1 line as
# a quick fit/calibration check (log-log, since weights span two orders of magnitude)
kb_predict_weight(fit) |>
  ggplot(aes(weight, estimate)) +
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

# intercept, power (allometric exponent), floor (weight in kg at diameter -> 0),
# density, and the SDs; power and floor are truncated at zero by the model
priors <- kb_priors_weight_nereo()
priors$power <- kb_prior_normal(mean = 2, sd = 0.05)
priors$sd_site <- kb_prior_exponential(rate = 3)
priors

# custom priors
fit_custom <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = priors,
  progress = "none"
)

# a very tight prior on bPower pulls the exponent away from the default-prior
# posterior (about 3)
bind_rows(
  mutate(coef(fit), priors = "default"),
  mutate(coef(fit_custom), priors = "custom")
) |>
  filter(term == "bPower")

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
# poll kb_fit_progress() from the app to read the completed fraction (0 to 1)
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
kb_fit_progress(progress_dir) # 1 (complete)

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
    (site == "site1" & year == "2019") |
      (site == "site2" & year == "2020") |
      (site == "site3" & year == "2021") |
      (site == "site4" & year == "2022")
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
# sampled from the prior alone. No sSiteYear here:
tidy(fit_one_year)
pars(fit_one_year)
"sSiteYear" %in% posterior::variables(samples(fit_one_year)) # FALSE

# --- stipe density (optional) -------------------------------------------------
# Without a density column the density effect is omitted, silently: the model is
# the same allometry without bDensity.
no_density <- select(data_weight_sim_nereo, -density)
fit_no_density <- kb_fit_weight_nereo(no_density, chains = 2, niters = 300)
fit_no_density$meta$density_on # FALSE
tidy(fit_no_density) # no bDensity

# At prediction each row's density is resolved in order: a supplied value, the
# recorded density of a fitted site-year, otherwise the fitted mean.
kb_predict_weight(
  fit,
  new_data = tibble(
    diameter = 40,
    site = c(sites[1], sites[1], "new_reef"),
    year = "2020",
    density = c(8, NA, NA) # supplied, recorded site-year, new site (mean)
  ),
  new_levels = "average"
)
# density effect: expected weight at 40 mm across stand density
kb_predict_weight(
  fit,
  new_data = tibble(diameter = 40, density = seq(1.5, 8, by = 0.5)),
  new_levels = "average"
) |>
  kb_plot_predictions(x = "density")

# allometric curves at low, mean, and high stand density: density scales the
# size-dependent part of the weight, so the curves spread with plant size
tidyr::expand_grid(
  diameter = seq(15, 80, length.out = 40),
  density = c(1.5, 4.3, 8)
) |>
  kb_predict_weight(fit, new_data = _, new_levels = "average") |>
  ggplot(aes(
    diameter,
    estimate,
    colour = factor(density),
    fill = factor(density)
  )) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, colour = NA) +
  geom_line() +
  labs(
    x = "Sub-bulb diameter (mm)",
    y = "Wet weight (kg)",
    colour = "Stipes per m\u00b2",
    fill = "Stipes per m\u00b2"
  )

# --- unit checks --------------------------------------------------------------
# Data in the wrong unit fit without error but give wrong results, so the data
# checks warn when a median is implausible (diameter below 10 or above 200 mm,
# weight above 100 kg, density above 100 stipes per m^2). The data still pass.
cm <- mutate(data_weight_sim_nereo, diameter = diameter / 10)
kb_check_data_weight_nereo(cm)
grams <- mutate(data_weight_sim_macro, weight = weight * 1000)
kb_check_data_weight_macro(grams)

# At prediction (for example from a pre-fit model), values far outside the fitted
# range warn: here diameters given in cm to a fit made in mm
kb_predict_weight(fit, new_data = tibble(diameter = c(2.5, 4)))

# new_data predictor values are validated
try(kb_predict_weight(fit, new_data = tibble(diameter = -5)))
try(kb_predict_weight(fit, new_data = tibble(diameter = NA_real_)))

# --- raw posterior draws (rstantools generics) --------------------------------
# users may want more low-level access to the draws to do their own diagnostics/derived quants
# posterior_epred() is expected (mean) weight; posterior_linpred(transform =
# TRUE) is exp() of the linear predictor, the median. They differ by
# exp(sWeight^2 / 2) for nereo:
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
  fit$data$weight,
  posterior_predict(fit)[1:50, , drop = FALSE]
) +
  scale_x_log10()

# compare this to prior predictive simulation (from prior-only model)
ppc_dens_overlay(
  fit_prior$data$weight,
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
  new_data = tibble(diameter = 40, site = "new_reef"),
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
kb_priors_weight_macro() # intercept, fronds, shape, sd_site/year/site_year

# --- fit ----------------------------------------------------------------------
fit_m <- kb_fit_weight_macro(
  data_weight_sim_macro,
  chains = 4,
  niters = 500,
  nthin = 2
)
fit_m # slim header; kb_model_describe(fit_m) shows the Gamma model + structure

# same accessors as nereo; the term list is macro's (bFronds, shape)

tidy(fit_m)
glance(fit_m)
summary(fit_m)

# --- predictions --------------------------------------------------------------
# new_data uses the `fronds` predictor (not diameter); fronds must be whole numbers
kb_predict_weight(fit_m, new_data = tibble(fronds = c(2, 5, 10, 15)))
try(kb_predict_weight(fit_m, new_data = tibble(fronds = 2.5)))

# one estimate per year at 10 fronds
kb_predict_weight_by(fit_m, by = "year", fronds = 10) |>
  kb_plot_predictions() +
  coord_flip()

kb_predict_weight_by(fit_m, by = "site") |>
  kb_plot_predictions(observed = data_weight_sim_macro)

augment(fit_m) |>
  ggplot(aes(log(fitted), residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3)

# posterior_predict draws strictly positive Gamma replicates
pp_m <- posterior_predict(fit_m, new_data = tibble(fronds = c(2, 5, 10)))
range(pp_m) # all > 0

# residuals are Gamma deviance residuals
head(residuals(fit_m))
