# Demo / test-drive: kelpbio weight model prediction + uncertainty API
# -----------------------------------------------------------------------------
# Purpose: exercise the full prediction surface end to end so we can judge
#   (1) coverage  - is all the functionality we need present?
#   (2) ergonomics - are the argument choices intuitive?
#   (3) output     - do the results look sensible?
#
# Run interactively, block by block (the fits are fast; no cmdstan needed).
# A Stan-free package load is enough since no .stan changed:
#   devtools::load_all()   # or library(kelpbio) after devtools::install()
#
# Two real-world use cases:
#   A. Hakai fits a weight model to their own harvest data, inspects it, and
#      predicts / visualises at the population and group level and at the
#      observation level, under different forms of uncertainty.
#   B. Hakai reuses an existing (coastwide) weight model fit and predicts weight
#      for newly collected diameters - at existing sites, brand-new sites, a new
#      year at existing sites, and a mix - without harvesting (no new weights).
# -----------------------------------------------------------------------------

library(kelpbio)
library(ggplot2)
library(dplyr)

# =============================================================================
# USE CASE A - Fit to your own data, inspect, predict, visualise
# =============================================================================

# A0. The data ---------------------------------------------------------------
# Simulated Nereocystis sub-bulb diameter (mm) and wet weight (kg) across 6
# sites and 4 years (one site-year cell is intentionally absent).
str(kb_data_weight)
kb_check_data_weight(kb_data_weight)   # validate before fitting

# A1. Fit ---------------------------------------------------------------------
# Small/fast settings for a test-drive; bump for real use.
fit <- kb_fit_weight(
  kb_data_weight,
  chains = 2, niters = 500, quiet = TRUE
)
fit                       # print method: model, data, sampler summary

# A2. Inspect the fit via the generics ---------------------------------------
converged(fit)            # did it converge? (report-mode rhat/esr thresholds)
glance(fit)               # one-row model-level summary + diagnostics
tidy(fit)                 # tidy parameter estimates (term/estimate/lower/upper)
coef(fit)                 # fixed-effect coefficients
prior_summary(fit)        # the resolved priors actually used
pars(fit); nterms(fit); npars(fit); nobs(fit)   # universals accessors

# Raw posterior access for bespoke work / the broader ecosystem:
draws <- samples(fit)     # posterior::draws_rvars
posterior::summarise_draws(draws) |> head()

# A3. Residual diagnostics at the observed points -----------------------------
# augment() conditions on each row's own site & year (its estimated REs).
aug <- augment(fit)
head(aug)
ggplot(aug, aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.4) +
  labs(title = "A3. Residuals vs fitted (conditioned on observed site-year)")

# Posterior-predictive check using the stored yrep (bayesplot-ready):
if (requireNamespace("bayesplot", quietly = TRUE)) {
  yrep <- posterior_predict(fit)           # D x N, conditioned on observed groups
  bayesplot::ppc_dens_overlay(
    y = fit$data$weight,
    yrep = yrep[1:50, , drop = FALSE]
  ) + ggplot2::ggtitle("A3. Posterior predictive check (yrep)")
}

# A4. The three uncertainty axes, made explicit -------------------------------
# Axis 1 - the QUANTITY (which generic):
#   posterior_linpred : log-scale mean (no link, no obs noise)
#   posterior_epred   : expected weight = exp(linpred) (link, no obs noise)
#   posterior_predict : expected weight + Student-t observation noise
# Axis 2 - the GROUP REGIME (by + new_levels):
#   by         -> which grouping factors get their own curve (conditioned on)
#   new_levels -> what to do with factors NOT named in `by`:
#                   "sample"  = a new, unsampled group (Normal(0, sd) draw)
#                   "average" = the typical group (random effects held at 0)
# Axis 3 - PARAMETER uncertainty is always on (it is the posterior).
grid <- data.frame(diameter = seq(20, 80, by = 20))

dim(posterior_linpred(fit, newdata = grid))             # D x N, log scale
dim(posterior_epred(fit, newdata = grid))               # D x N, response scale
dim(posterior_predict(fit, newdata = grid))             # D x N, + obs noise

# new_levels widens epred at the population level (between-site variation in):
ep_avg <- posterior_epred(fit, newdata = grid, new_levels = "average")
ep_smp <- posterior_epred(fit, newdata = grid, new_levels = "sample")
rbind(
  average = apply(ep_avg, 2, sd),
  sample  = apply(ep_smp, 2, sd)
)   # sample SDs should be >= average SDs

# A5. Population-level prediction curve ---------------------------------------
# Typical (average) site - narrow: only parameter uncertainty.
pop_avg <- kb_predict_weight(fit, new_levels = "average")
# A new, unsampled site-year - wide: adds between-group variation.
pop_smp <- kb_predict_weight(fit, new_levels = "sample")
print(pop_avg)
kb_plot_predictions(pop_avg, observed = kb_data_weight) +
  ggtitle("A5. Population-average weight-at-diameter")
kb_plot_predictions(pop_smp, observed = kb_data_weight) +
  ggtitle("A5. New-site-year weight-at-diameter (wider)")

# A6. Group-level prediction curves -------------------------------------------
# One curve per site (conditioned on each site's estimated REs); the omitted
# site:year effect is averaged out.
by_site <- kb_predict_weight(fit, by = "site", new_levels = "average")
autoplot(by_site, observed = kb_data_weight) +
  ggtitle("A6. Per-site weight-at-diameter")

# One curve per observed site-by-year cell (every factor conditioned on):
by_site_year <- kb_predict_weight(fit, by = c("site", "year"))
autoplot(by_site_year) +
  ggtitle("A6. Per-site-year weight-at-diameter")

# A7. Guard rails - do the errors read well? ----------------------------------
# year has no main effect (enters only via site:year):
try(kb_predict_weight(fit, by = "year"))
# nothing left to sample when every factor is conditioned on:
try(kb_predict_weight(fit, by = c("site", "year"), new_levels = "sample"))


# =============================================================================
# USE CASE B - Reuse an existing model, predict weight for NEW diameter data
# =============================================================================
# Hakai returns next year, measures sub-bulb diameters, but does NOT harvest
# (no new weights). They reuse the existing weight model to turn diameters into
# predicted weights. In production this would be a shipped pre-fit object
# (e.g. kb_default_weight); here we reuse `fit` from Use Case A as that model.
coastwide <- fit
existing_sites <- coastwide$meta$site_levels   # site1..site6
existing_years <- coastwide$meta$year_levels   # 2019..2022

# B1. New diameters at EXISTING sites -----------------------------------------
# Conditioning is inferred from the columns present in newdata (brms-style):
# a known `site` column conditions on that site's estimated random effects.
# NOTE: with supplied new_data, `by` is not needed - the columns drive
# conditioning. `by` only matters for the auto-generated grid (use case A).
newdata_existing <- data.frame(
  diameter = c(25, 40, 55),
  site = "site2"
)
# Point + interval per row, conditioned on site2 (site:year averaged out):
predict(coastwide, new_data = newdata_existing, new_levels = "average")
# Raw draws for downstream propagation (e.g. into a biomass calc):
pe <- posterior_epred(coastwide, newdata = newdata_existing, new_levels = "average")
str(pe)   # D x 3

# B2. New diameters at a BRAND-NEW site ---------------------------------------
# No matching level -> the prediction must integrate over the population of
# sites. Either omit the site column, or use new_levels = "sample".
newdata_new_site <- data.frame(diameter = c(25, 40, 55))
# A new, unsampled site -> wider interval (between-site variation included):
predict(coastwide, new_data = newdata_new_site, new_levels = "sample")

# B3. A NEW YEAR at EXISTING sites --------------------------------------------
# Hakai measures diameters in a year the model never saw (e.g. 2023), at sites
# it knows. The site intercept/slope are conditioned on; the site:year effect is
# new, so it is sampled. Supply `site` (known) but leave `year` to new_levels.
newdata_new_year <- expand.grid(
  diameter = c(25, 40, 55),
  site = c("site1", "site3"),
  stringsAsFactors = FALSE
)
# site (known) is conditioned on; year is absent so the new site:year is sampled:
predict(coastwide, new_data = newdata_new_year, new_levels = "sample")

# B4. A MIX - some existing sites, some new -----------------------------------
# Rows with a known site condition on it; the genuinely new site is handled by
# new_levels. Mark new sites by leaving them out of the model's known levels.
newdata_mix <- data.frame(
  diameter = c(30, 30, 30, 30),
  site     = c("site1", "site4", "new_reef_A", "new_reef_B")
)
# A present-but-unknown level should error clearly (it is not silently "new"):
try(posterior_epred(coastwide, newdata = newdata_mix, new_levels = "sample"))
# Intended pattern for a mix: predict known sites conditioned, unknown sites
# from the population, then bind. Known:
known <- dplyr::filter(newdata_mix, site %in% existing_sites)
new   <- dplyr::filter(newdata_mix, !site %in% existing_sites)
pred_known <- predict(coastwide, new_data = known, new_levels = "average")
pred_new   <- predict(coastwide, new_data = dplyr::select(new, diameter),
                      new_levels = "sample")
dplyr::bind_rows(
  dplyr::mutate(as_tibble(pred_known), site = known$site),
  dplyr::mutate(as_tibble(pred_new),   site = new$site)
)
# ^ NOTE FOR REVIEW: this hand-binding is the friction point in use case B.
#   Question for the API: should a single call accept a mix of known and new
#   levels and resolve each row (condition where known, sample where new)?

# B5. Visualise predicted weights over a diameter sequence for new data -------
# A smooth predicted curve a field team could read off:
curve_new_site <- kb_predict_weight(coastwide, new_levels = "sample")   # new site
kb_plot_predictions(curve_new_site) +
  ggtitle("B5. Predicted weight-at-diameter for a new site (95% CI)")

# -----------------------------------------------------------------------------
# REVIEW CHECKLIST while running the above
#  [ ] Coverage: any prediction you wanted that no function above produces?
#  [ ] Ergonomics: did `by` vs `new_levels` read naturally? Was "sample" vs
#      "average" obvious without reading the help? Did newdata-column-driven
#      conditioning (B1-B4) match your mental model?
#  [ ] Output: are estimate/lower/upper sensible, ordered, positive? Do the
#      intervals widen in the expected order (average < per-site < new site)?
#  [ ] The mix case (B4): is hand-binding acceptable, or do we want one call?
# -----------------------------------------------------------------------------
