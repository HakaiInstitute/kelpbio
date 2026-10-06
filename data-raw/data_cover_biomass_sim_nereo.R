# Build data_cover_biomass_sim_nereo and data_plot_biomass_sim_nereo, small simulated
# cover datasets for fast tests and runnable examples: the drone surveys, and the
# in situ wet biomass of each surveyed site-year with its 95% compatibility
# limits, standing in for a biomass prediction. Simulated from the cover biomass model
# structure (a biomass floor plus a canopy term proportional to tide-corrected
# cover, with site and year effects on the canopy term, and a lognormal in situ
# estimate whose log SD is scaled by bScaling) with parameters near the
# analysis-project production fit, so they pass kb_check_data_cover_biomass_nereo() and
# kb_fit_cover_biomass_nereo() converges on them. The sites and years match the other
# simulated datasets, with one drone survey per site-year, with about one survey in six at zero canopy,
# plots, tide heights, and in situ precisions typical of the Hakai Institute
# surveys, and two missing cells. Not for inference. Run from the package root:
#   Rscript data-raw/data_cover_biomass_sim_nereo.R

set.seed(606)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cells
grid <- grid[!(grid$site == "site9" & grid$year == "2019"), ]
n <- nrow(grid)

b_canopy <- 8 # kg per m^2 of canopy
b_floor <- 0.09 # kg/m^2 at zero cover
b_tide <- 0.276 # fractional canopy increase per m of tide
b_scaling <- 1.2 # multiplier on the in situ log SDs
sd_site <- 0.3
sd_year <- 0.4

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)
a_year <- stats::setNames(stats::rnorm(length(years), 0, sd_year), years)

plot_area_m2 <- round(stats::runif(n, 180, 280), 1)
# Raw cover is right-skewed, and about one survey in six has no delineated
# canopy, as in the Hakai Institute Nereocystis surveys.
raw_cover <- stats::rbeta(n, 0.8, 3)
raw_cover[stats::runif(n) < 1 / 6] <- 0
canopy_area_m2 <- round(raw_cover * plot_area_m2, 2)
tide_height_m <- sample(seq(0, 1.6, by = 0.05), n, replace = TRUE)

cover <- pmin(plot_area_m2, canopy_area_m2 * (1 + b_tide * tide_height_m)) / plot_area_m2
mu <- b_floor + b_canopy * exp(a_site[grid$site] + a_year[grid$year]) * cover

# The in situ estimate and its 95% compatibility limits, lognormal around mu.
sd_log <- stats::runif(n, 0.3, 0.8)
log_estimate <- log(mu) + stats::rnorm(n, 0, b_scaling * sd_log)
z <- stats::qnorm(0.975)

# Pin levels to creation order (site1..site10) rather than string order.
site <- factor(grid$site, levels = sites)
year <- factor(grid$year, levels = years)

data_cover_biomass_sim_nereo <- tibble::tibble(
  site = site,
  year = year,
  canopy_area_m2 = canopy_area_m2,
  plot_area_m2 = plot_area_m2,
  tide_height_m = tide_height_m
)

data_plot_biomass_sim_nereo <- tibble::tibble(
  site = site,
  year = year,
  estimate = signif(exp(log_estimate), 3),
  lower = signif(exp(log_estimate - z * sd_log), 3),
  upper = signif(exp(log_estimate + z * sd_log), 3)
)

usethis::use_data(data_cover_biomass_sim_nereo, overwrite = TRUE)
usethis::use_data(data_plot_biomass_sim_nereo, overwrite = TRUE)
