# kelpbio weight model: a walk-through for the field/lab team
# -----------------------------------------------------------------------------
# The weight model turns a sub-bulb diameter (mm) into a predicted wet weight
# (kg) for Nereocystis, with uncertainty. Once fit, you can reuse it to weigh
# plants you only measured, summarise weight-at-diameter per site or per year,
# and check how confident the model is.
#
# Run block by block.

library(kelpbio)
library(ggplot2)
library(dplyr)

# =============================================================================
# 1. The data, and checking it before you trust it
# =============================================================================

# Diameter (mm) and wet weight (kg) for harvested Nereocystis plants.
str(data_weight_hakai)

# Always check the data first. A clean dataset passes silently:
kb_check_data_weight(data_weight_hakai)

# The check catches the mistakes that actually happen when data come back from
# the field. Each errors with a clear message (run one at a time):

# A column got renamed in the spreadsheet:
bad_name <- data_weight_hakai
names(bad_name)[names(bad_name) == "diameter"] <- "diam"
kb_check_data_weight(bad_name)

# A measurement is missing:
bad_na <- data_weight_hakai
bad_na$diameter[1] <- NA_real_
kb_check_data_weight(bad_na)

# A typo turned a number into text ("1.1o" instead of "1.10"):
bad_chr <- data_weight_hakai
bad_chr$diameter <- as.character(bad_chr$diameter)
bad_chr$diameter[1] <- "1.1o"
kb_check_data_weight(bad_chr)

# =============================================================================
# 2. Fit the model
# =============================================================================

fit <- kb_fit_weight(data_weight_hakai, niters = 500L)
fit # what was fit, how much data, and whether sampling behaved

# =============================================================================
# 3. What did the model learn?
# =============================================================================

print(fit)
summary(fit)

# The allometric relationship in plain terms: the estimated weight-at-diameter
# coefficients, each with a 95% compatibility interval.
tidy(fit)
coef(fit)

# A one-line summary of fit quality:
glance(fit)

# =============================================================================
# 4. Weight-at-diameter curves (the main thing you'll plot)
# =============================================================================

# A typical site: the average plant for this dataset.
typical <- kb_predict_weight_by(fit, new_levels = "average")
kb_plot_predictions(typical, observed = data_weight_hakai) +
  ggtitle("Weight-at-diameter, typical site")

# A new, unsurveyed site: same curve, wider band, because we have not seen it.
new_site <- kb_predict_weight_by(fit, new_levels = "sample")
kb_plot_predictions(new_site, observed = data_weight_hakai) +
  ggtitle("Weight-at-diameter, a new site (wider uncertainty)")

# One curve per site, to compare sites side by side:
kb_predict_weight_by(fit, by = "site", new_levels = "average") |>
  kb_plot_predictions() +
  ggtitle("Weight-at-diameter by site")

# Per site and year. With many site-years the plot caps the number of panels
# and warns; raise max_facets or pre-filter to see more.
kb_predict_weight_by(fit, by = c("site", "year")) |>
  kb_plot_predictions() +
  ggtitle("Weight-at-diameter by site and year")

# Note: year on its own is not a knob in this model (it only acts within a
# site), so asking for curves by year alone tells you so:
kb_predict_weight_by(fit, by = "year")

# =============================================================================
# 5. Weighing plants you measured but did not harvest
# =============================================================================
# You went back, measured sub-bulb diameters, and left the plants in place.
# Feed those diameters in and get predicted weights with uncertainty.

sites <- levels(fit$data$site)

# Plain call: predicted weight for every plant in the original dataset.
predict(fit)

# New diameters at a site you have surveyed before (uses what we know there):
predict(
  fit,
  new_data = tibble(diameter = c(25, 40, 55), site = sites[1]),
  new_levels = "average"
)

# New diameters at a brand-new reef (works, just wider uncertainty):
predict(
  fit,
  new_data = tibble(diameter = c(25, 40, 55), site = "new_reef"),
  new_levels = "sample"
)

# A future year at known sites:
predict(
  fit,
  new_data = tidyr::expand_grid(
    diameter = c(25, 40, 55),
    site = sites[1:2],
    year = "2099"
  ),
  new_levels = "sample"
)

# A mix of known and new sites in one call: known sites come back with tighter
# intervals, new reefs wider. No need to split the data up.
predict(
  fit,
  new_data = tibble(
    diameter = 30,
    site = c(sites[1], sites[2], "new_reef_A", "new_reef_B")
  ),
  new_levels = "sample"
)

# =============================================================================
# 6. A new site: treat it as unknown, or borrow from reference sites
# =============================================================================
# Same measured diameters, one site the model has never seen. How should its
# site effect be handled? Three options:
#   - new_levels = "sample"   a generic new site, full between-site uncertainty
#   - new_levels = "average"  the typical site (site effects held at zero)
#   - representative_site      behave like one or more chosen, surveyed sites
# Name reference sites when you expect the new site to resemble them: it borrows
# their estimated effect (and their narrower uncertainty) rather than the full
# population spread. representative_site sets the site effect only; year still
# follows new_levels.

new_data <- tibble(diameter = c(20, 30, 40, 50, 60), site = "new_reef")
ref_sites <- sites[1:2] # two surveyed sites we expect the new reef to resemble

compare <- bind_rows(
  tibble::as_tibble(predict(fit, new_data, new_levels = "sample")) |>
    mutate(option = "new site (sample)"),
  tibble::as_tibble(predict(fit, new_data, new_levels = "average")) |>
    mutate(option = "typical site (average)"),
  tibble::as_tibble(predict(fit, new_data, representative_site = ref_sites)) |>
    mutate(option = paste0("like ", paste(ref_sites, collapse = " + ")))
)

# Compare the predicted weights (with 95% intervals) across the three options.
# The reference-site curve tracks the chosen sites and is tighter than the
# generic "sample" new site.
ggplot(compare, aes(diameter, estimate, colour = option, fill = option)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, colour = NA) +
  geom_line(linewidth = 1) +
  scale_x_continuous("Sub-bulb diameter (mm)") +
  scale_y_continuous("Predicted wet weight (kg)") +
  labs(
    colour = NULL, fill = NULL,
    title = "New-site weight: treat as unknown vs. borrow from reference sites"
  )

# =============================================================================
# 7. Refit with new sites: do they borrow strength from the full dataset?
# =============================================================================
# Section 6 borrowed a reference site's effect without refitting. The other
# option is to add the new sites' data to the model and refit. This shows what
# partial pooling buys you: estimates for a handful of new sites are shaky on
# their own, but sharpen when fit alongside the full coastwide dataset.

# Simulate a small survey at three brand-new reefs in a future year (2099),
# with measured diameters AND weights (so the model can be fit, not just used to
# predict). Each reef sits a little above or below the coastwide relationship.
set.seed(2099)
new_reefs <- c("reef_X", "reef_Y", "reef_Z")
sim_reef <- function(site, offset) {
  n <- 20
  diameter <- round(runif(n, 15, 70), 1)
  log_weight <- log(0.10) + 2.6 * (log(diameter) - log(40)) +
    offset + rnorm(n, 0, 0.25)
  tibble(
    diameter = diameter, weight = round(exp(log_weight), 3),
    site = site, year = "2099"
  )
}
new_survey <- bind_rows(
  sim_reef("reef_X", -0.3),
  sim_reef("reef_Y", 0.0),
  sim_reef("reef_Z", 0.4)
)
kb_check_data_weight(new_survey)

# Fit A: the three new reefs ALONE (little data, no coastwide context).
fit_alone <- kb_fit_weight(new_survey, niters = 500L, quiet = TRUE)

# Fit B: the new reefs APPENDED to the full Hakai dataset, refit together. The
# coastwide allometry is now pinned down by all the data, and the new reefs
# borrow strength from it. (A full refit; takes as long as the section-2 fit.)
combined <- bind_rows(data_weight_hakai, new_survey)
fit_combined <- kb_fit_weight(combined, niters = 500L, quiet = TRUE)

# Per-reef weight-at-diameter curves (conditioned on site and the 2099 year)
# under each fit. Compare the same three reefs alone vs. within the full dataset.
curves <- bind_rows(
  tibble::as_tibble(kb_predict_weight_by(fit_alone, by = c("site", "year"))) |>
    mutate(fit = "new reefs alone"),
  tibble::as_tibble(kb_predict_weight_by(fit_combined, by = c("site", "year"))) |>
    filter(site %in% new_reefs) |>
    mutate(fit = "appended to Hakai data")
)

ggplot(curves, aes(diameter, estimate, colour = fit, fill = fit)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, colour = NA) +
  geom_line(linewidth = 1) +
  facet_wrap(~site) +
  scale_x_continuous("Sub-bulb diameter (mm)") +
  scale_y_continuous("Predicted wet weight (kg)") +
  labs(
    colour = NULL, fill = NULL,
    title = "New reefs: fit alone vs. appended to the full dataset",
    subtitle = "Pooling with more data tightens the bands and stabilises the curve"
  )

# =============================================================================
# 8. Does the model fit the data? (a quick sanity check)
# =============================================================================

# Residuals should scatter evenly around zero with no pattern:
aug <- augment(fit)
ggplot(aug, aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3) +
  ggtitle("Residuals vs fitted")

# Simulated weights from the model should look like the real weights:
yrep <- posterior_predict(fit)
bayesplot::ppc_dens_overlay(
  y = fit$data$weight,
  yrep = yrep[1:50, , drop = FALSE]
) +
  ggtitle("Model-simulated weights vs observed")

# =============================================================================
# 9. Advanced: priors and raw posterior access
# =============================================================================
# Skip this unless you want to steer the model's assumptions or do bespoke
# posterior work.

# 7a. Priors -----------------------------------------------------------------
# The defaults encode weak, sensible assumptions. You can see them:
kb_priors_weight()

# To override, change individual entries; the rest keep their defaults. Here we
# impose a deliberately strong, off-target prior on the allometric slope:
priors <- kb_priors_weight()
priors$sd_site <- kb_prior_exponential(rate = 3)
priors$diameter <- kb_prior_normal(mean = 1.5, sd = 0.05)
priors

# Prior predictive check: fit from the priors alone (no data) and see whether
# the assumed curve is even plausible against the observed plants.
prior_fit <- kb_fit_weight(
  data_weight_hakai,
  priors = priors,
  prior_only = TRUE,
  quiet = TRUE
)
kb_predict_weight_by(prior_fit, new_levels = "sample") |>
  kb_plot_predictions(observed = data_weight_hakai) +
  ggtitle("Prior-implied curve vs observed data")

# Refit with the data and compare: the strong prior pulls the slope away from
# what the data alone would say, while the other terms barely move.
fit_custom <- kb_fit_weight(data_weight_hakai, priors = priors, quiet = TRUE)
bind_rows(
  mutate(coef(fit), priors = "default"),
  mutate(coef(fit_custom), priors = "custom")
) |>
  filter(term == "bDiameter")

# 7b. Raw posterior draws ----------------------------------------------------
# Standard rstantools generics work and return the same predictions as the
# kb_* verbs, as a draws-by-rows matrix for loo/bayesplot/bespoke analysis.
prior_summary(fit)
nd <- data.frame(diameter = c(20, 40, 60))
dim(posterior_epred(fit, newdata = nd))
samples(fit) |> posterior::summarise_draws() |> head()
