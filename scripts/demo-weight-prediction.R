# Demo / test-drive: kelpbio weight model prediction API
# -----------------------------------------------------------------------------
# Purpose: exercise the full prediction surface end to end so we can judge
#   (1) coverage  - is all the functionality we need present?
#   (2) ergonomics - are the argument choices intuitive?
#   (3) output     - do the results look sensible?
#
# Run interactively, block by block. A Stan-free package load is enough since no
# .stan changed:  devtools::load_all()   (or library(kelpbio) after install).
#
# Two prediction verbs, independent arguments:
#   kb_predict_weight(fit, new_data)     -> predict weight for rows you supply
#                                           (per-row: known levels conditioned,
#                                            new levels sampled). predict() wraps it.
#   kb_predict_weight_by(fit, by)        -> allometric curve(s) over a diameter
#                                           sequence, for visualisation.
# augment(fit) is the diagnostics verb (fitted/residuals on the training data).

library(kelpbio)
library(ggplot2)
library(dplyr)
library(bayesplot)

# =============================================================================
# USE CASE A - Fit to data, inspect, visualise the allometric curves
# =============================================================================

# A0. The data ---------------------------------------------------------------
# Real Hakai Nereocystis sub-bulb diameter (mm) and wet weight (kg).
str(kb_data_weight)
kb_check_data_weight(kb_data_weight) # passes: validate before fitting

# kb_check_data_weight() errors clearly on bad input (run these one at a time):
#  - wrong column name
bad_name <- kb_data_weight
names(bad_name)[names(bad_name) == "diameter"] <- "diam"
kb_check_data_weight(bad_name)
#  - missing value in diameter
bad_na <- kb_data_weight
bad_na$diameter[1] <- NA_real_
kb_check_data_weight(bad_na)
#  - non-numeric (character) value in diameter
bad_chr <- kb_data_weight
bad_chr$diameter <- as.character(bad_chr$diameter)
bad_chr$diameter[1] <- "1.1o"
kb_check_data_weight(bad_chr)

# A1. Fit ---------------------------------------------------------------------
fit <- kb_fit_weight(kb_data_weight, chains = 4, niters = 500, quiet = FALSE)
fit # print: model, data, sampler summary (no URL popup; progress streams)

# A2. Inspect the fit via the generics ---------------------------------------
converged(fit)
glance(fit)
tidy(fit, include_random_effects = FALSE)
coef(fit)
prior_summary(fit)
draws <- samples(fit) # posterior::draws_rvars for bespoke work
posterior::summarise_draws(draws) |> head()

# A2b. Custom priors and prior predictive check ------------------------------
# Defaults: a named list of structured prior objects. The prior FAMILY is fixed
# (population terms Normal, SDs Exponential); only the hyperparameters change.
kb_priors_weight()

# Override a couple of entries; unmodified entries keep their defaults. Here we
# deliberately impose a tight, biased prior on the allometric slope (bDiameter)
# so its posterior is pulled well away from the data estimate (~2.6) - enough to
# show the prior visibly moving the result.
priors <- kb_priors_weight()
priors$sd_site <- kb_prior_exponential(rate = 3) # tighter between-site spread
priors$diameter <- kb_prior_normal(mean = 1.5, sd = 0.05) # strong, off-target slope
priors

# Prior predictive check: fit from the priors only (likelihood off), then judge
# whether the priors imply a plausible weight-at-diameter relationship by
# overlaying the observed data on the prior-implied curve.
prior_fit <- kb_fit_weight(
  kb_data_weight,
  priors = priors, prior_only = TRUE,
  chains = 2, niters = 500, quiet = TRUE
)
prior_summary(prior_fit) # confirms the priors actually used
kb_predict_weight_by(prior_fit, new_levels = "sample") |>
  kb_plot_predictions(observed = kb_data_weight) +
  ggtitle("A2b. Prior predictive curve vs observed data")

# Prior predictive distribution of weight (from the prior-only yrep) against the
# observed weights: do the priors generate data in a sensible range before
# fitting? (Prior predictive draws can be widely dispersed; log the x axis.)
prior_yrep <- posterior_predict(prior_fit)
ppc_dens_overlay(
  y = prior_fit$data$weight,
  yrep = prior_yrep[1:50, , drop = FALSE]
) +
  scale_x_log10() +
  ggtitle("A2b. Prior predictive check (prior yrep vs observed weight)")

# Refit with the custom priors (likelihood on) and compare coefficients to the
# default-prior fit. The tight, off-target prior pulls bDiameter away from its
# default-prior posterior; the other terms barely move.
fit_custom <- kb_fit_weight(
  kb_data_weight,
  priors = priors, chains = 4, niters = 500, quiet = TRUE
)

coef_compare <- bind_rows(
  mutate(coef(fit, include_random_effects = FALSE), priors = "default"),
  mutate(coef(fit_custom, include_random_effects = FALSE), priors = "custom")
)
# the slope is the term expected to move:
filter(coef_compare, term == "bDiameter")

ggplot(coef_compare, aes(estimate, term, colour = priors)) +
  geom_pointrange(
    aes(xmin = lower, xmax = upper),
    position = position_dodge(width = 0.5)
  ) +
  ggtitle("A2b. Coefficients: default vs custom (tight, off-target) priors")

# A3. Residual diagnostics (augment = diagnostics verb) -----------------------
aug <- augment(fit) # fitted/residual at observed rows, conditioned on their REs
ggplot(aug, aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3) +
  labs(title = "A3. Residuals vs fitted")

# Posterior-predictive check from stored yrep (bayesplot-ready):
yrep <- posterior_predict(fit) # D x N, conditioned on observed groups
ppc_dens_overlay(y = fit$data$weight, yrep = yrep[1:50, , drop = FALSE]) +
  ggtitle("A3. Posterior predictive check (yrep)")

# A4. Raw posterior draws, if you need them (bayesplot / loo / bespoke work) ---
# The rstantools generics return the SAME predictions as kb_predict_weight(),
# just as a raw draws-by-rows matrix instead of a summary data frame.
nd <- data.frame(diameter = c(20, 40, 60))
dim(posterior_epred(fit, newdata = nd)) # draws x rows matrix
kb_predict_weight(fit, new_data = nd) # the same draws, summarised

# A5. Population curve --------------------------------------------------------
pop_avg <- kb_predict_weight_by(fit, new_levels = "average") # typical site
pop_smp <- kb_predict_weight_by(fit, new_levels = "sample") # a new, unsampled site
print(pop_smp)
kb_plot_predictions(pop_avg, observed = kb_data_weight) +
  ggtitle("A5. Typical-site weight-at-diameter")
kb_plot_predictions(pop_smp, observed = kb_data_weight) +
  ggtitle("A5. New-site weight-at-diameter (wider band)")

# A6. Group-level curves ------------------------------------------------------
# One curve per site (site conditioned; omitted site:year averaged out):
kb_predict_weight_by(fit, by = "site", new_levels = "average") |>
  kb_plot_predictions() +
  ggtitle("A6. Per-site weight-at-diameter")

# Per site-year: many panels with real data -> facet cap kicks in (warns,
# shows the first max_facets). Raise max_facets or pre-filter to see more.
kb_predict_weight_by(fit, by = c("site", "year")) |>
  kb_plot_predictions() +
  ggtitle("A6. Per-site-year (facet-capped)")

# A7. Guard rail - year has no main effect (enters only via site:year):
try(kb_predict_weight_by(fit, by = "year"))


# =============================================================================
# USE CASE B - Predict weight for newly measured diameters (no harvest)
# =============================================================================
# Hakai returns, measures sub-bulb diameters, does NOT harvest. Reuse the fit to
# turn diameters into predicted weights. (In production this is a shipped pre-fit
# object; here we reuse `fit`.)
sites <- levels(fit$data$site)

# B0. Bare call = observed data, conditioned (base R predict() convention):
predict(fit) # one row per observed individual + estimate/lower/upper

# B1. New diameters at an EXISTING site (conditioned on that site) ------------
newdata_existing <- tibble(diameter = c(25, 40, 55), site = sites[1])
predict(fit, new_data = newdata_existing, new_levels = "average")

# B2. New diameters at a BRAND-NEW site - works, no error (sampled, wider) ----
newdata_new_site <- tibble(diameter = c(25, 40, 55), site = "new_reef")
predict(fit, new_data = newdata_new_site, new_levels = "sample")

# B3. A NEW YEAR at existing sites (site conditioned, new site:year sampled) --
newdata_new_year <- tidyr::expand_grid(
  diameter = c(25, 40, 55), site = sites[1:2], year = "2099"
)
predict(fit, new_data = newdata_new_year, new_levels = "sample")

# B4. A MIX of existing and new sites - resolved per row, ONE call, no bind ---
newdata_mix <- tibble(
  diameter = 30,
  site = c(sites[1], sites[2], "new_reef_A", "new_reef_B")
)
predict(fit, new_data = newdata_mix, new_levels = "sample")
# ^ known sites conditioned (narrower), new reefs sampled (wider) - all at once.

# B5. A predicted curve for a new site a field team could read off ------------
kb_predict_weight_by(fit, new_levels = "sample") |>
  kb_plot_predictions() +
  ggtitle("B5. Predicted weight-at-diameter, new site (95% CI)")

# -----------------------------------------------------------------------------
# REVIEW CHECKLIST
#  [ ] Coverage: any prediction you wanted that no verb above produces?
#  [ ] Ergonomics: kb_predict_weight (your data) vs kb_predict_weight_by (curves)
#      - clear which to reach for? new_levels sample-vs-average obvious?
#  [ ] Output: estimate/lower/upper ordered, positive? Do bands widen as
#      expected (typical site < new site; known row < new-site row)?
#  [ ] The mix (B4): one call, no bind - does it read right?
# -----------------------------------------------------------------------------
