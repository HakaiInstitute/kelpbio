# kelpbio internals demo: how the package is built, for a developer audience.
# Run block by block after devtools::install() (or Rscript scripts/build.R).
#
# Sections:
#   1. Model precompilation (rstan + rstantools)
#   2. S3 classes and generics
#   3. posterior rvars as the draws engine
#   4. Progress bar and Shiny
#   5. Model variants: one compiled model, data flags, priors as data
#   6. Custom priors and prior-only fits
#   7. Prediction and plotting framework
#   8. Diagnostics: PPC, residuals, LOO, prior sensitivity
#
# - Most blocks use the bundled pre-fit models (no MCMC).
# - Blocks marked "# MCMC" sample; each takes a few seconds to ~20 s.
# - Rationale: decisions/ (engine-choice, architecture, prediction-engine,
#   species-as-variant); behaviour: openspec/specs/.

library(kelpbio)
library(ggplot2)
library(dplyr)

fit <- fit_weight_sim_nereo # bundled pre-fit: Nereocystis weight allometry
set.seed(42)

# =============================================================================
# 1. MODEL PRECOMPILATION (rstan + rstantools)
# =============================================================================
# - Requirement: install a binary from R-universe and it works. No Stan
#   toolchain for users, works on shinyapps.io.
# - Stan sources in inst/stan/ are compiled into the package's shared library
#   at R CMD INSTALL; R-universe builds binaries with the models inside.
# - Rejected:
#   - cmdstanr at runtime: per-user install_cmdstan(), not on shinyapps.io.
#   - instantiate (precompiled CmdStan): CmdStan absent on R-universe build
#     servers, so no binaries.
# - rstan lags Stan releases, but nothing kelpbio needs is missing.

# the Stan sources: one file per likelihood / major variant
list.files("inst/stan")

# rstantools::rstan_config() transpiles each .stan to C++ (generated, never
# hand-edited) and writes R/stanmodels.R, which loads the compiled modules
list.files("src", pattern = "^stanExports_.*\\.(cc|h)$")
readLines("R/stanmodels.R", n = 4)

# at run time: a named list of compiled stanmodel objects
names(kelpbio:::stanmodels)
class(kelpbio:::stanmodels$weight_nereo)

# all nine models live in one shared library (MB)
round(
  file.size(list.files(
    system.file("libs", package = "kelpbio"),
    pattern = "\\.so$|\\.dll$",
    full.names = TRUE,
    recursive = TRUE
  )) /
    1e6
)

# Dev loop (scripts/build.R, also Positron tasks "kelpbio: ..."):
# - rstan_config() -> install() -> document() -> test()
# - load_all() compiles the generated C++ but does not re-transpile .stan, so
#   always rstan_config() after a .stan edit.
# - load_all() leaves -O0 debug objects in src/ that install() would reuse
#   (~20x slower sampler); build.R cleans them first.
# - --fits rebuilds pre-fits + test fixtures (a fit stores its Stan source).
readLines("scripts/build.R", n = 9)

# a fit keeps the Stan source it was sampled from
kb_stancode(fit)

# - Fitting is the only stochastic step: sample -> extract draws -> discard
#   the stanfit (R/fit_stan.R).
# - The fit holds draws, sampler diagnostics, data, and meta: small, portable,
#   rstan-version-robust; a pre-fit model is not a special case.
names(fit)
format(object.size(fit), units = "Kb")

# =============================================================================
# 2. S3 CLASSES AND GENERICS
# =============================================================================
# - S3 (not S4/S7): shallow hierarchy of list containers; generics come from
#   base/stats, generics, rstantools, posterior.
# - Three class tiers: species leaf -> model -> kb_fit.
class(fit)
class(fit_size_sim_nereo)
class(fit_cover_calibration_sim_nereo)
class(fit_wetdry_sim_macro)

# the fit object: a plain list, accessed with $
str(fit, max.level = 1, give.attr = FALSE)
names(fit$meta)

# all registered S3 methods, from the installed NAMESPACE, with the package
# that owns each generic (re-exported generics such as tidy() resolve to theirs)
ns_lines <- readLines(system.file("NAMESPACE", package = "kelpbio"))
s3 <- regmatches(ns_lines, regexec("^S3method\\(([^,]+),([^)]+)\\)", ns_lines))
generic_owner <- function(generic) {
  if (grepl("::", generic)) {
    return(sub("::.*", "", generic))
  }
  f <- get(generic, envir = asNamespace("kelpbio"))
  environmentName(environment(f))
}
methods_tbl <- tibble(
  generic = vapply(s3, `[`, "", 2),
  class = vapply(s3, `[`, "", 3)
) |>
  filter(!is.na(generic)) |>
  mutate(
    package = vapply(generic, generic_owner, ""),
    generic = sub(".*::", "", generic),
    tier = case_when(
      class == "default" ~ "default",
      class == "kb_fit" ~ "kb_fit",
      grepl("_(nereo|macro)$", class) ~ "species",
      grepl("^kb_fit_", class) ~ "model",
      TRUE ~ "other"
    )
  )

# public generics by the package that owns them (kelpbio's own exports, such as
# kb_samples() and the kb_predict_* verbs, are plain functions, not generics)
methods_tbl |>
  filter(!startsWith(generic, ".")) |>
  summarise(generics = toString(unique(generic)), .by = package) |>
  print(width = Inf)

# - Never add default methods to other packages' generics.
# - Re-exported so users need not attach generics/rstantools/posterior.
# One call per generic, grouped by owning package:
nd <- kb_new_data(fit, by = "site", diameter_mm = 40)

# base
print(fit)
summary(fit)

# stats
coef(fit)
head(fitted(fit))
head(residuals(fit))
nobs(fit)
predict(fit, nd)

# generics (tidymodels/broom)
tidy(fit)
glance(fit)
head(augment(fit))

# posterior (stan-dev): draw counts and names (re-exported), and per-parameter
# Rhat and effective sample sizes through as_draws()
nchains(fit)
niterations(fit)
ndraws(fit)
nvariables(fit)
variables(fit)
posterior::summarise_draws(fit)

# kelpbio's convergence verdict (no Stan-ecosystem equivalent)
kb_converged(fit)

# rstantools (stan-dev): draws x rows matrices
posterior_epred(fit, nd) |> dim()
# rstantools fixes `transform` as posterior_linpred()'s second argument
posterior_linpred(fit, new_data = nd) |> dim()
posterior_predict(fit, nd) |> dim()
log_lik(fit) |> dim()
prior_summary(fit)

# posterior (stan-dev): as_draws() (re-exported), so posterior's conversions
# and summaries take a fit
as_draws(fit)
posterior::as_draws_df(fit)
posterior::summarise_draws(fit)

# priorsense (stan-dev, optional, so not re-exported): create_priorsense_data(),
# so its functions take a fit; kb_sensitivity(fit) is the kelpbio verb
priorsense::powerscale_sensitivity(fit)

# ggplot2: autoplot() on predictions, not fits
autoplot(kb_predict_weight(fit, nd))

# Tiering rule: a method lives at the highest tier where its body is invariant.
# - Public bodies at kb_fit (one augment(), one tidy(), one log_lik(), ...).
# - They delegate what varies to internal generics (leading dot), registered
#   at the model or species tier.
methods_tbl |>
  filter(startsWith(generic, "."), tier != "default") |>
  count(generic, tier) |>
  tidyr::pivot_wider(names_from = tier, values_from = n, values_fill = 0)

# e.g. .epred: log link at the model tier, nereo overrides for the lognormal
# mean (exp(mu + sd^2 / 2))
kelpbio:::.epred.kb_fit_weight
kelpbio:::.epred.kb_fit_weight_nereo

# .obs_family: each model states its observation distribution once; log_lik,
# residuals, posterior_predict, and priorsense all read it
kelpbio:::.obs_family.kb_fit_weight_nereo

# Fail loudly:
# - Every internal generic's .default aborts, so a new sub-model without its
#   methods errors instead of returning a plausible wrong number.
# - tests/testthat/test-abort.R discovers the internal generics from the
#   namespace and pins this.
fake <- fit
class(fake) <- c("kb_fit_kelp_nereo", "kb_fit_kelp", "kb_fit")
tidy(fake) # model-agnostic: reads draws + meta, so works
try(fitted(fake)) # needs .linpred/.epred: aborts naming the class

# entry checks name the class the verb needs
try(kb_model_describe(1))
try(kb_predict_size(fit))

# Meta versus dispatch (decisions/architecture.md):
# - A fact computable at fit time, or consumed identically by every model, is
#   a value in meta (predictor, terms, structural flags).
# - Only differing arithmetic or control flow becomes a generic.
fit$meta[c("predictor", "response", "form", "site_year_on")]
fit_cover_calibration_sim_nereo$meta$site_year_on # no site:year term

# =============================================================================
# 3. POSTERIOR RVARS AS THE DRAWS ENGINE
# =============================================================================
# - as_draws(fit) is a posterior draws_rvars: one rvar per estimated parameter,
#   each a distribution stored as its draws. Arithmetic and summaries read like
#   the model and keep the draws paired across parameters.
d <- as_draws(fit)
d$diameter_power # rvar<iterations, chains>

# --- convergence diagnostics -------------------------------------------------
kb_converged(fit) # Rhat < 1.01, bulk and tail ESS >= 100 per chain
glance(fit) # the worst parameter's Rhat and ESS
posterior::summarise_draws(fit) # per parameter: rhat, ess_bulk, ess_tail
# precision of the 95% limits themselves (tail ESS uses the 5% and 95% points)
posterior::ess_quantile(d$sd_site, probs = c(0.025, 0.975))
posterior::mcse_quantile(d$sd_site, probs = c(0.025, 0.975))
# trace and rank plots (rank plots: Vehtari et al. 2021)
bayesplot::mcmc_trace(d, pars = c("diameter_power", "sd_site"))
bayesplot::mcmc_rank_overlay(d, pars = c("diameter_power", "sd_site"))

# --- summaries and derived quantities ----------------------------------------
tidy(fit, include_random_effects = TRUE)
# any function of the parameters, per draw, then summarised: the weight above
# the floor at the reference diameter (kg)
alpha <- exp(d$intercept)
median(alpha)
posterior::quantile2(alpha, c(0.025, 0.975))
# a custom summary table
posterior::summarise_draws(
  fit,
  median,
  ~ posterior::quantile2(.x, c(0.025, 0.975)),
  "rhat"
)

# --- probability statements --------------------------------------------------
posterior::Pr(d$diameter_power > 2) # weight rises faster than diameter squared
posterior::Pr(d$sd_year > d$sd_site) # more variation among years than sites
posterior::Pr(d$site_effect > 0) # each site above the typical site

# --- plots -------------------------------------------------------------------
bayesplot::mcmc_areas(d, pars = c("sd_site", "sd_year", "sd_site_year"))
bayesplot::mcmc_intervals(d, regex_pars = "^site_effect")
# rvar columns plot directly with ggdist
site_effects <- tibble::tibble(
  site = names(d$site_effect),
  effect = d$site_effect
)
ggplot(site_effects, aes(y = site, xdist = effect)) +
  ggdist::stat_halfeye()
# a prediction's full posterior: the draws x rows matrix as an rvar column
pred <- nd
pred$weight <- posterior::rvar(posterior_epred(fit, nd))
ggplot(pred, aes(y = site, xdist = weight)) +
  ggdist::stat_halfeye() +
  labs(x = "Expected weight of a 40 mm plant (kg)")

# posterior predictive checks, residuals, LOO, and prior sensitivity: section 8

# --- the model equation in R -------------------------------------------------
# - Each model's mean is written once in R, as rvar arithmetic, in its
#   .linpred() method (R/linpred.R), mirroring the Stan model block.
# - Scalar rvar x numeric vector over grid rows -> rvar over rows: the
#   draws-by-rows broadcasting is automatic.
nd <- tibble(diameter_mm = c(20, 40, 60))
log_x <- log(nd$diameter_mm) - log(fit$meta$predictor_ref)
mu <- log(d$weight_floor + exp(d$intercept + d$diameter_power * log_x))
expected <- exp(mu + d$sd_residual^2 / 2) # lognormal mean
expected

# identical, draw for draw, to the package's prediction
all.equal(
  unname(posterior::draws_of(expected)),
  unname(posterior_epred(fit, nd))
)
median(expected)
kb_predict_weight(fit, nd)

# --- the footgun rvars remove ------------------------------------------------
# - With raw D x N matrices, adding a per-row vector recycles down columns
#   (across draws), silently, unless you remember sweep().
# - Per-row values (such as log areas) are added while still an rvar over rows.
draws_mat <- matrix(
  posterior::draws_of(d$intercept),
  nrow = posterior::ndraws(d$intercept),
  ncol = 3
)
log_area <- log(c(1, 10, 100))
colMeans(draws_mat + log_area) # wrong: recycled over draws
colMeans(sweep(draws_mat, 2, log_area, "+")) # right, by hand
mean(d$intercept + log_area) # right, by construction

# --- versus the mcmcr / mcmcderive idiom (bboutools) -------------------------
# - bboutools: samples as mcmcr; predictions via mcmc_derive() with a string
#   expression evaluated per draw.
# - The string is not R code: no R CMD check, no debugger, no tests of its own.
# - Per-draw evaluation scales with draws; the full benchmark
#   (scripts/benchmark-prediction-methods.R) found ~130x slower at realistic
#   grid sizes, too slow for the Shiny app.
# - Also rejected: Stan generated quantities (recompile per query, rigid for
#   composing separately fitted models).
arr <- posterior::subset_draws(
  posterior::as_draws_array(fit),
  variable = c("intercept", "diameter_power", "weight_floor", "sd_residual")
)
mcmc <- mcmcr::as.mcmcr(coda::as.mcmc.list(lapply(
  seq_len(dim(arr)[2]),
  function(chain) coda::mcmc(unclass(arr)[, chain, ])
)))
grid_x <- log(seq(10, 90, length.out = 500)) - log(fit$meta$predictor_ref)
system.time(
  by_mcmcderive <- mcmcderive::mcmc_derive(
    mcmc,
    "prediction <- exp(log(weight_floor + exp(intercept + diameter_power * log_x)) +
    sd_residual^2 / 2)",
    values = list(log_x = grid_x),
    silent = TRUE
  )
)
system.time(
  by_rvar <- exp(
    log(d$weight_floor + exp(d$intercept + d$diameter_power * grid_x)) +
      d$sd_residual^2 / 2
  )
)
all.equal(apply(by_mcmcderive$prediction, 3, median), unname(median(by_rvar)))

# --- caveats -----------------------------------------------------------------
# - Some base functions do not dispatch on rvar (plogis() errors), so model
#   code uses arithmetic: 1 / (1 + exp(-x)).
try(plogis(d$intercept))
1 / (1 + exp(-d$intercept))
# - Indexing-heavy internals (random-effect resolution, biomass integration)
#   drop to draws_of() matrices and re-wrap as rvar; same numbers.
# - Only production rvar paths are used; rfun()/rdo()/for_each_draw() avoided.

# --- composition happens on draws, never on intervals ------------------------
# - Survey biomass multiplies plants by mean plant weight over the size
#   distribution, per draw; canopy totals sum per draw, so a regional total's
#   limits are correct.
drone <- tibble(
  site = c("otter_cove", "gull_rock", "cedar_bay"),
  year = "2020",
  canopy_area_m2 = c(1100, 4800, 2600),
  tide_height_m = c(0.7, 0.5, 1.2),
  region = c("north", "south", "south")
)
kb_predict_biomass_canopy(
  fit_cover_calibration_sim_nereo,
  drone,
  new_levels = "average"
)
kb_predict_biomass_canopy(
  fit_cover_calibration_sim_nereo,
  drone,
  new_levels = "average",
  pool_by = "region"
)

# =============================================================================
# 4. PROGRESS BAR AND SHINY
# =============================================================================
# - rstan's console output is noisy and its HTML viewer breaks in some GUIs.
# - progress = "bar" (default):
#   - rstan::sampling() runs in a callr::r_bg() child process, writing each
#     chain's draws to sample_file CSVs in a progress directory, plus a
#     manifest (chains, warmup, niters, nthin).
#   - The parent counts CSV rows against the manifest and drives a cli bar.
#   - The child re-fetches the compiled model by name: a C++ pointer cannot
#     cross processes.
#   - The seed is drawn in the parent, so set.seed() still reproduces.
# - "verbose": rstan's raw output (debugging). "none": silent.
# - progress never changes the draws.

# MCMC: the console bar
fit_bar <- kb_fit_weight_nereo(data_weight_sim_nereo, chains = 2, niters = 300)

# kb_progress() reads the same directory from any process. Here the fit runs
# in a background process and this session polls it:
progress_dir <- "kb_progress_"
dir.create(progress_dir)
bg <- callr::r_bg(
  function(data, dir) {
    kelpbio::kb_fit_weight_nereo(
      data,
      chains = 2,
      niters = 1000,
      progress = "none",
      progress_dir = dir
    )
  },
  args = list(data = data_weight_sim_nereo, dir = progress_dir)
)
while (bg$is_alive()) {
  cat(sprintf("%3.0f%%\n", 100 * kb_progress(progress_dir)))
  Sys.sleep(1)
}
kb_progress(progress_dir) # 1
list.files(progress_dir) # manifest + per-chain CSVs; kelpbio never deletes it
fit_bg <- bg$get_result()

# survey biomass writes the same kind of record
biomass_dir <- tempfile("kb_progress_")
dir.create(biomass_dir)
pb <- kb_predict_biomass_survey(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  data_survey_sim_nereo,
  progress = "none",
  progress_dir = biomass_dir
)
kb_progress(biomass_dir)

# Shiny (kelpbioshiny), not run here:
# - The fit runs on a mirai daemon through shiny::ExtendedTask, so the app
#   stays responsive and a fit can be cancelled.
# - An observer with invalidateLater() polls kb_progress(dir) into a
#   progress bar.
#
#   task <- ExtendedTask$new(function(fn, args) mirai::mirai(do.call(fn, args), ...))
#   task$invoke(kb_fit_weight_nereo, list(data, progress = "none", progress_dir = dir))
#   observe({
#     invalidateLater(500)
#     progress(100 * kb_progress(dir))
#   })

# =============================================================================
# 5. MODEL VARIANTS: ONE COMPILED MODEL, DATA FLAGS, PRIORS AS DATA
# =============================================================================
# - Compiled models cannot change per call, so run-time flexibility is data:
#   - prior hyperparameters in the Stan data block;
#   - 0/1 structural flags (floor_on, prior_only).
# - Flags are set by the fitting layer from the data or a model-choice
#   argument (form), never exposed as flag arguments.
# - A separate .stan only for a different likelihood or major variant.

# the flags in the Stan source
stan_lines <- strsplit(kb_stancode(fit), "\n")[[1]]
grep("_on|prior_only", stan_lines, value = TRUE)

# Species is a variant, not a species = argument:
# - The species differ structurally (nereo weight: lognormal on a power
#   function of diameter with a floor; macro: Gamma on log fronds).
# - A species argument would silently change required columns, priors, and
#   output: so one kb_fit_<model>_<species>() per species, its own priors,
#   data check, and .stan.
# - Where species are structurally identical (wet/dry, carbon), one .stan is
#   shared: compare the stanmodels names with the fit functions.
names(kelpbio:::stanmodels)
grep("^kb_fit_", getNamespaceExports("kelpbio"), value = TRUE) |> sort()

# The site:year effect is always fitted; a pure helper reports which effects
# the data cannot separate from it (the fit then warns), testable without MCMC:
weight_data <- kelpbio:::with_year(data_weight_sim_nereo) # year from date
one_year <- filter(weight_data, year == "2019") |> droplevels()
kelpbio:::site_year_aliasing(weight_data) # none
kelpbio:::site_year_aliasing(one_year) # "year"

# the Stan data list a fit would send: data, flags, and prior fields
priors <- kb_priors_weight_nereo()
stan_data <- kelpbio:::assemble_weight_nereo_data(
  one_year,
  priors,
  diameter_ref = 30,
  prior_only = FALSE,
  floor_on = TRUE
)
str(stan_data[c("n_obs", "n_site", "n_year", "floor_on")])
str(stan_data[startsWith(names(stan_data), "prior_")])

# - An omitted effect is still sampled (from its prior) but is not an
#   estimate: dropped from draws, summaries, convergence, and prediction.
# - Model choice: form = "power" sets floor_on = 0 (a straight log-log line).
fit$meta$terms

# MCMC: a structural variant from the same compiled model
fit_power <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  form = "power",
  chains = 2,
  niters = 500,
  progress = "none"
)
tidy(fit_power) # no weight_floor
loo::loo_compare(list(
  packard_floor = loo::loo(log_lik(fit)),
  power = loo::loo(log_lik(fit_power))
))

# =============================================================================
# 6. CUSTOM PRIORS AND PRIOR-ONLY FITS
# =============================================================================
# - Priors are classed objects, not a flat named vector as in bboutools
#   (c(b0_mu = 3, b0_sd = 10)):
#   - the family is visible and parameterisation unambiguous (sd, not
#     precision or variance);
#   - the family is fixed by the compiled model, so a family swap errors;
#   - values are validated at the call, not deep in the sampler;
#   - names are user concepts (sd_site), not model symbols (sAnnual).
# - Kept from bboutools: one priors argument, a defaults getter, partial
#   override.
priors <- kb_priors_weight_nereo()
priors
class(priors$sd_site)
kelpbio:::prior_data(priors)[1:4] # each object -> prior_<entry>_<argument>

priors$diameter_power <- kb_prior_normal(mean = 2, sd = 0.05)
priors$sd_site <- kb_prior_exponential(rate = 3)

# all of these error before any sampling
try(kb_prior_normal(0, sd = -1))
try(kb_prior_exponential(rate = 0))
try(kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = list(diameter_power = kb_prior_exponential(1))
))
try(kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = list(power = kb_prior_normal(2, 1))
))

# MCMC: custom priors; the tight prior pulls the exponent from ~3.2 to ~2
fit_custom <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = priors,
  chains = 2,
  niters = 500,
  progress = "none"
)
bind_rows(default = tidy(fit), custom = tidy(fit_custom), .id = "priors") |>
  filter(term == "diameter_power")

# the priors used travel with the fit (data-passed values never appear in the
# Stan source), so the description always matches what was fitted
prior_summary(fit_custom)
kb_model_describe(fit_custom)

# MCMC: prior-only
# - prior_only = TRUE switches off the likelihood in Stan; the data still set
#   the group dimensions and predictor reference.
# - Prior predictive checks calibrate the SD priors that carry the most weight.
fit_prior <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  prior_only = TRUE,
  chains = 2,
  niters = 500,
  progress = "none"
)
fit_prior
bayesplot::ppc_dens_overlay(
  log(fit_prior$data$weight_kg),
  log(posterior_predict(fit_prior)[1:50, ])
) +
  labs(x = "log weight (kg), prior predictive")

# =============================================================================
# 7. PREDICTION AND PLOTTING FRAMEWORK
# =============================================================================
# Pipeline, identical for every model:
#   rows (new_data, or kb_new_data(fit, by)) -> .linpred(): link-scale rvar
#   over rows -> .epred(): response scale -> summarise draws ->
#   kb_predictions (tibble + column-role attributes) -> kb_plot_predictions()
#
# - One verb per model, model-named: kb_predict_weight(), kb_predict_size(),
#   ... A generic kb_predict() was built and reverted: with a pre-fit model in
#   a reviewed script, the call site should name the model.
# - The grid is an ordinary data frame: kb_new_data() builds one by group,
#   or users bring their own rows.
# - The draw generics (posterior_epred etc.) share the same engine and return
#   draws x rows matrices for bayesplot/loo.
kb_new_data(fit, by = "site", diameter_mm = c(20, 40, 60))
kb_predict_weight(
  fit,
  kb_new_data(fit, by = "site", diameter_mm = c(20, 40, 60))
)

# Groups resolve per row, per factor:
# - A fitted level is conditioned on its estimated effect.
# - A new level, or an absent column, follows new_levels: "average" sets it
#   to zero (the typical group); "sample" draws Normal(0, sd).
# - So fitted and new sites mix in one call; representative_site lends a
#   fitted site's effect to a new one.
mixed <- tibble(diameter_mm = 40, site = c("otter_cove", "new_reef"))
kb_predict_weight(fit, mixed)
kb_predict_weight(fit, mixed, new_levels = "sample")
kb_predict_weight(fit, mixed, representative_site = "gull_rock")

# - What a prediction reports is fixed by its rows, not an argument: the cover
#   calibration reads canopy, plot area, and tide from each row.
plots <- tibble(
  site = "otter_cove",
  canopy_area_m2 = c(0, 100, 200),
  plot_area_m2 = 200,
  tide_height_m = 0.5
)
kb_predict_cover_calibration(fit_cover_calibration_sim_nereo, plots)

# --- the plot configures itself from attributes ------------------------------
pred_site <- kb_predict_weight(fit, kb_new_data(fit, by = "site"))
attributes(pred_site)[c(
  "kb_predictor",
  "kb_group_vars",
  "kb_response",
  "kb_curve",
  "kb_conf_level"
)]

# rules (R/kb_plot_predictions.R):
# - x: the predictor if it varies, else the last grouping variable (or x =).
# - facets: the remaining grouping variables, never x; max_facets caps them.
# - geometry: line + ribbon only for a generated curve (kb_curve) over a
#   varying predictor; otherwise pointrange.
# - kb_curve is stored because scattered user rows and a generated grid can
#   look alike; only a grid should be joined by a line.
# - plots take predictions, never fits; the result is a ggplot to extend.
kb_plot_predictions(pred_site) # curve per site, faceted
kb_predict_weight(fit, kb_new_data(fit, by = "site", diameter_mm = 30)) |>
  kb_plot_predictions() # one value per site: pointrange
kb_predict_size(
  fit_size_sim_nereo,
  kb_new_data(fit_size_sim_nereo, by = c("site", "year"))
) |>
  kb_plot_predictions() # no predictor: year on x, site faceted
kb_predict_weight(fit, data_weight_sim_nereo[1:20, ]) |>
  kb_plot_predictions() # supplied rows: points, not a line
autoplot(pred_site) +
  geom_point(
    aes(diameter_mm, weight_kg),
    data = data_weight_sim_nereo,
    alpha = 0.2
  )

# =============================================================================
# 8. DIAGNOSTICS: PPC, RESIDUALS, LOO, PRIOR SENSITIVITY
# =============================================================================
# - Sampler diagnostics are computed at fit time (the stanfit is discarded).
# - kb_converged(): Rhat < 1.01, bulk and tail ESS >= 100 per chain
#   (Vehtari et al. 2021), divergences <= 0.2%.
# - Treedepth and E-BFMI are reported by summary(), not in the verdict.
kb_converged(fit)
glance(fit)
summary(fit)

# --- posterior predictive checks ---------------------------------------------
# posterior_predict() draws replicates from .obs_family(): any bayesplot ppc
bayesplot::ppc_dens_overlay(
  log(fit$data$weight_kg),
  log(posterior_predict(fit)[1:50, ])
) +
  labs(x = "log weight (kg)")
bayesplot::ppc_stat(
  fit_size_sim_nereo$data$diameter_mm,
  posterior_predict(fit_size_sim_nereo),
  stat = "sd"
)

# --- residuals ---------------------------------------------------------------
# deviance residuals under each model's likelihood; augment() binds them
augment(fit) |>
  ggplot(aes(log(fitted), residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3)

# --- LOO ---------------------------------------------------------------------
# log_lik() is computed in R from stored draws: no log_lik in generated
# quantities, nothing per observation stored in the fit
dim(log_lik(fit))
loo::loo(log_lik(fit))

# --- prior sensitivity (priorsense power-scaling) ----------------------------
# - create_priorsense_data.kb_fit() supplies draws, log prior (from the stored
#   prior objects), and log likelihood; priorsense's functions then accept
#   the fit directly.
# - kb_sensitivity(): one row per prior entry, flagged with Poisson
#   thresholds (prior CJS < 0.1: weak prior; likelihood CJS >= 0.05: data
#   informative).
kb_sensitivity(fit)
priorsense::powerscale_sensitivity(fit)
priorsense::powerscale_plot_dens(fit, variable = c("diameter_power", "sd_site"))
