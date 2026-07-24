# kelpbio weight model demo

library(kelpbio)
library(ggplot2)
library(dplyr)

# =============================================================================
# 1. data and check data
# =============================================================================

# Simulated diameter and wet weight for harvested Nereocystis plants (the bundled
# example dataset; the real survey data lives in the companion data package).
str(data_weight_sim_nereo)

# check data fits model expectation
kb_check_data_weight_nereo(data_weight_sim_nereo)

# common catches:

# wrong column name
bad_name <- data_weight_sim_nereo
names(bad_name)[names(bad_name) == "diameter"] <- "diam"
kb_check_data_weight_nereo(bad_name)

# missing diameter
bad_na <- data_weight_sim_nereo
bad_na$diameter[1] <- NA_real_
kb_check_data_weight_nereo(bad_na)

# A typo turned a number into text ("1.1o" instead of "1.10"):
bad_chr <- data_weight_sim_nereo
bad_chr$diameter <- as.character(bad_chr$diameter)
bad_chr$diameter[1] <- "1.1o"
kb_check_data_weight_nereo(bad_chr)

# =============================================================================
# 2. Fit the model
# =============================================================================

?kb_fit_weight_nereo
fit <- kb_fit_weight_nereo(data_weight_sim_nereo, niters = 500L)
fit

# =============================================================================
# 3. common generics
# =============================================================================

print(fit)
summary(fit)

# parameter estimates
tidy(fit)
coef(fit, include_random_effects = TRUE)

# A one-line summary of fit quality:
glance(fit)

# get fitted and residuals
augment(fit)

# =============================================================================
# 4. Prediction Scenario 1 - predictions over grid - understand allometric relationships for different groups
# =============================================================================

# new_levels: if "average" then gets predictions for typical ('average') site/site:year (narrower uncertainty)
#             if "sample" then shows prediction for new, unobserved site/site:year (wider uncertainty)

# A typical site: the average plant for this dataset.
typical <- kb_predict_weight_by(fit, new_levels = "average")
kb_plot_predictions(typical, observed = data_weight_sim_nereo) +
  ggtitle("Weight-at-diameter, typical site")

# A new, unsurveyed site: same curve, wider band
new_site <- kb_predict_weight_by(fit, new_levels = "sample")
kb_plot_predictions(new_site, observed = data_weight_sim_nereo) +
  ggtitle("Weight-at-diameter, a new site (wider uncertainty)")

# One curve per site
kb_predict_weight_by(fit, by = "site", new_levels = "average") |>
  kb_plot_predictions() +
  ggtitle("Weight-at-diameter by site")

# Per site and year. With many site-years the plot caps the number of panels
# and warns; raise max_facets or pre-filter to see more.
kb_predict_weight_by(fit, by = c("site", "year")) |>
  kb_plot_predictions() +
  ggtitle("Weight-at-diameter by site and year")

# Pointrange estimates at a reference diameter. Holding diameter at one value
# turns the curve into grouped points: sites land on the x-axis, no facet.
kb_predict_weight_by(fit, by = "site", predictor = 30, new_levels = "average") |>
  kb_plot_predictions() +
  ggtitle("Weight at 30 mm diameter by site")

# Note: year on its own won't work since intercept/slope doesnt vary by year alone (only site:year):
# question: arguably for most general-prupose model intercept could also vary by year RE?
kb_predict_weight_by(fit, by = "year")

# =============================================================================
# 5. Prediction scenario 2 - Predict weight on new diameters
# =============================================================================

sites <- levels(fit$data$site)

# Plain call: predicted weight for every plant in the original dataset.
kb_predict_weight(fit)

# New diameters at a site you have surveyed before (uses what we know there):
kb_predict_weight(
  fit,
  new_data = tibble(diameter = c(25, 40, 55), site = sites[1])
)

# New diameters at a brand-new site (works, just wider uncertainty):
kb_predict_weight(
  fit,
  new_data = tibble(diameter = c(25, 40, 55), site = "new_reef"),
  new_levels = "sample"
)

# A future year at known sites:
kb_predict_weight(
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
kb_predict_weight(
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
# choose one more more representative sites for new, unobserved site

new_data <- tibble(diameter = c(20, 30, 40, 50, 60), site = "new_reef")
ref_sites <- sites[1:2] # two surveyed sites we expect the new reef to resemble

kb_predict_weight(fit, new_data, representative_site = ref_sites)

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
    colour = NULL,
    fill = NULL,
    title = "New-site weight: treat as unknown vs. borrow from reference sites"
  ) +
  facet_wrap(~option)

# =============================================================================
# 8. Advanced things
# =============================================================================

# Residuals check
aug <- augment(fit)
ggplot(aug, aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3) +
  ggtitle("Residuals vs fitted")

# priors and raw posterior access
kb_priors_weight_nereo()

# To override, change individual entries; the rest keep their defaults. Here we
# impose a deliberately strong, off-target prior on the allometric slope:
priors <- kb_priors_weight_nereo()
priors$sd_site <- kb_prior_exponential(rate = 3)
priors$diameter <- kb_prior_normal(mean = 1.5, sd = 0.05)
priors

# Prior predictive check: fit from the priors alone (no data) and see whether
# the assumed curve is even plausible against the observed plants.
prior_fit <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = priors,
  prior_only = TRUE,
  progress = "none"
)
kb_predict_weight_by(prior_fit, new_levels = "sample") |>
  kb_plot_predictions(observed = data_weight_sim_nereo) +
  ggtitle("Prior-implied curve vs observed data")

# Refit with the data and compare: the strong prior pulls the slope away from
# what the data alone would say, while the other terms barely move.
fit_custom <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = priors,
  progress = "none"
)
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
dim(posterior_epred(fit, new_data = nd))
class(posterior_epred(fit, new_data = nd))
samples(fit) |>
  posterior::summarise_draws() |>
  head()
