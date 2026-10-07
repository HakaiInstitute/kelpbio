# Build the simulated Nereocystis site-based datasets: data_weight_sim_nereo,
# data_size_sim_nereo, data_density_sim_nereo, data_cover_biomass_sim_nereo, and
# data_plot_biomass_sim_nereo, for fast tests and runnable examples. Not for
# inference.
#
# All five come from one set of true site-year values, so they agree: plot
# biomass composed from fits to the weight, size, and density data lands near
# the in situ plot biomass the cover data are calibrated against. Means, slopes,
# shapes, and dispersions are near the analysis-project production fits;
# random-effect SDs are held moderate so the small pre-fits converge and site
# differences show in examples. The data sources cover different site-years, as
# in the field: density at most, size at most of those, weight harvests at about
# half (three sites never harvested), and drone surveys at about two-thirds.
# Site names are invented and match no Hakai Institute survey site.
#
# Run from the package root:
#   Rscript data-raw/data_sim_nereo.R

set.seed(101)

# 1. Sites, years, and which data source covers each site-year ---------------

sites <- c(
  "otter_cove", "gull_rock", "cedar_bay", "heron_reef", "urchin_shoal",
  "sculpin_head", "eagle_spit", "fog_islet", "tidepool_bluff", "raven_reef"
)
years <- as.character(2019:2022)

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
i_site <- match(grid$site, sites)
i_year <- match(grid$year, years)
key <- paste(grid$site, grid$year)

grid$density <- !key %in% c("raven_reef 2022", "tidepool_bluff 2019")
grid$size <- grid$density &
  !key %in% c("gull_rock 2020", "urchin_shoal 2022", "fog_islet 2021", "cedar_bay 2019")
# Seven sites harvested, each in three of the four years.
grid$weight <- grid$density & i_site <= 7 & i_year != (i_site %% 4) + 1
grid$drone <- grid$density & (i_site + i_year) %% 3 != 0

# 2. True values ---------------------------------------------------------------

effects <- function(sd_site, sd_year, sd_site_year) {
  a_site <- stats::rnorm(length(sites), 0, sd_site)
  a_year <- stats::rnorm(length(years), 0, sd_year)
  a_site_year <- stats::rnorm(nrow(grid), 0, sd_site_year)
  a_site[i_site] + a_year[i_year] + a_site_year
}

# Weight: lognormal around a power function of diameter with a floor, with a
# stipe density effect on the weight above the floor.
b_weight30 <- log(0.91) # log weight above the floor (kg) at 30 mm
b_power <- 3.02
b_floor <- 0.115 # kg
b_density <- -0.159 # per SD of stipe density
sd_weight <- 0.46 # residual SD of log weight
grid$e_weight <- effects(0.3, 0.17, 0.2)

# Size: Weibull sub-bulb diameter with mean exp(log mean).
b_diameter <- log(23) # log mean diameter (mm)
shape_size <- 2.7
grid$e_size <- effects(0.2, 0.15, 0.12)

# Density: zero-inflated negative binomial stipe count on a transect of area_m2.
# The intercept is above the production estimate (log 0.18) so the composed plot
# biomass spans the production range despite the moderated SDs.
b_stipes <- log(1.5) # log stipes per m^2 on transects holding stipes
zero_inflation <- 0.05 # probability a transect holds no stipes
dispersion_density <- 0.45 # variance mu + dispersion * mu^2
grid$e_density <- effects(0.6, 0.4, 0.5)

# Cover: biomass floor plus a canopy term in tide-corrected cover.
b_canopy <- 8 # kg per m^2 of canopy
b_cover_floor <- 0.093 # kg/m^2 at zero cover
b_tide <- 0.28 # fractional canopy increase per m of tide
b_scaling <- 1.21 # multiplier on the in situ log SDs
grid$e_cover <- effects(0.2, 0.2, 0)

# 3. Density observations, which also give each site-year's observed stipe
# density: the weight model's density covariate, as plot biomass reads it ----

data_density_sim_nereo <- do.call(rbind, lapply(which(grid$density), function(i) {
  n <- 4L
  area_m2 <- sample(c(20, 40, 40, 60, 100), n, replace = TRUE)
  mu <- area_m2 * exp(b_stipes + grid$e_density[i])
  stipes <- stats::rnbinom(n, mu = mu, size = 1 / dispersion_density)
  stipes[stats::runif(n) < zero_inflation] <- 0L
  data.frame(stipes = as.integer(stipes), area_m2 = area_m2, site = grid$site[i], year = grid$year[i])
}))

totals <- stats::aggregate(
  cbind(stipes, area_m2) ~ site + year,
  data = data_density_sim_nereo,
  FUN = sum
)
grid$stipes_m2 <- round(
  (totals$stipes / totals$area_m2)[match(key, paste(totals$site, totals$year))],
  2
)

# The density covariate is standardised over the harvested plants, as the weight
# fit does; every harvested site-year has the same number of plants.
n_weight <- 20L
harvest_density <- rep(grid$stipes_m2[grid$weight], each = n_weight)
density_mean <- mean(harvest_density)
density_sd <- stats::sd(harvest_density)

expected_weight <- function(diameter, i) {
  density_std <- (grid$stipes_m2[i] - density_mean) / density_sd
  b_floor + exp(b_weight30 + b_density * density_std + grid$e_weight[i]) *
    (diameter / 30)^b_power
}
size_scale <- function(i) exp(b_diameter + grid$e_size[i]) / gamma(1 + 1 / shape_size)

# True plot biomass (wet kg/m^2) at density-surveyed site-years: expected stipes
# per m^2 times the mean expected plant weight over the diameter distribution,
# using the lognormal mean.
quantiles <- (seq_len(1000) - 0.5) / 1000
grid$plot_biomass <- NA_real_
for (i in which(grid$density)) {
  diameter <- stats::qweibull(quantiles, shape_size, size_scale(i))
  stipes_m2 <- (1 - zero_inflation) * exp(b_stipes + grid$e_density[i])
  grid$plot_biomass[i] <- stipes_m2 *
    mean(expected_weight(diameter, i)) * exp(sd_weight^2 / 2)
}

# 4. Weight and size observations ----------------------------------------------

# Harvested plants are a sample of the site-year's plants, so their diameters come
# from its size distribution.
data_weight_sim_nereo <- do.call(rbind, lapply(which(grid$weight), function(i) {
  diameter <- stats::rweibull(n_weight, shape_size, size_scale(i))
  log_weight <- log(expected_weight(diameter, i)) + stats::rnorm(n_weight, 0, sd_weight)
  data.frame(
    diameter_mm = round(diameter, 1),
    weight_kg = round(exp(log_weight), 3),
    site = grid$site[i],
    year = grid$year[i],
    stipes_m2 = grid$stipes_m2[i]
  )
}))

data_size_sim_nereo <- do.call(rbind, lapply(which(grid$size), function(i) {
  diameter <- stats::rweibull(20L, shape_size, size_scale(i))
  data.frame(diameter_mm = round(diameter, 1), site = grid$site[i], year = grid$year[i])
}))

# 5. Drone surveys and in situ plot biomass ------------------------------------

# Each surveyed site-year's tide-corrected cover is the cover model solved for its
# true plot biomass. Nereocystis surveys include plots with no delineated canopy,
# so cover below zero is set to zero; it is capped at 0.95.
drone <- grid[grid$drone, ]
n <- nrow(drone)
plot_area_m2 <- round(stats::runif(n, 180, 280), 1)
tide_height_m <- sample(seq(0, 1.6, by = 0.05), n, replace = TRUE)
cover <- (drone$plot_biomass - b_cover_floor) / (b_canopy * exp(drone$e_cover))
clipped <- cover > 0.95
cover <- pmin(pmax(cover, 0), 0.95)
canopy_area_m2 <- round(cover * plot_area_m2 / (1 + b_tide * tide_height_m), 2)

# The in situ estimate and its 95% compatibility limits, lognormal around the
# true plot biomass; the limits understate the error by the factor b_scaling.
sd_log <- stats::runif(n, 0.3, 0.8)
log_estimate <- log(drone$plot_biomass) + stats::rnorm(n, 0, b_scaling * sd_log)
z <- stats::qnorm(0.975)

data_cover_biomass_sim_nereo <- data.frame(
  site = drone$site,
  year = drone$year,
  canopy_area_m2 = canopy_area_m2,
  plot_area_m2 = plot_area_m2,
  tide_height_m = tide_height_m
)

data_plot_biomass_sim_nereo <- data.frame(
  site = drone$site,
  year = drone$year,
  estimate = signif(exp(log_estimate), 3),
  lower = signif(exp(log_estimate - z * sd_log), 3),
  upper = signif(exp(log_estimate + z * sd_log), 3)
)

# 6. Save ----------------------------------------------------------------------

# Levels in creation order, not string order; this order carries through to fits
# and predictions.
as_sim <- function(data) {
  data$site <- factor(data$site, levels = sites)
  data$year <- factor(data$year, levels = years)
  rownames(data) <- NULL
  tibble::as_tibble(data)
}
data_weight_sim_nereo <- as_sim(data_weight_sim_nereo)
data_size_sim_nereo <- as_sim(data_size_sim_nereo)
data_density_sim_nereo <- as_sim(data_density_sim_nereo)
data_cover_biomass_sim_nereo <- as_sim(data_cover_biomass_sim_nereo)
data_plot_biomass_sim_nereo <- as_sim(data_plot_biomass_sim_nereo)

message(
  "True plot biomass (kg/m2) at density-surveyed site-years, quantiles 0, 0.25, 0.5, 0.75, 1: ",
  paste(signif(stats::quantile(grid$plot_biomass, na.rm = TRUE), 2), collapse = ", ")
)
message(
  "Drone surveys with capped cover: ", sum(clipped), " of ", n,
  "; with no canopy: ", sum(canopy_area_m2 == 0)
)

usethis::use_data(data_weight_sim_nereo, overwrite = TRUE)
usethis::use_data(data_size_sim_nereo, overwrite = TRUE)
usethis::use_data(data_density_sim_nereo, overwrite = TRUE)
usethis::use_data(data_cover_biomass_sim_nereo, overwrite = TRUE)
usethis::use_data(data_plot_biomass_sim_nereo, overwrite = TRUE)
