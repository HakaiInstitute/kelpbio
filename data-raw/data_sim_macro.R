# Build the simulated Macrocystis site-based datasets: data_weight_sim_macro,
# data_size_sim_macro, data_density_sim_macro, data_cover_biomass_sim_macro, and
# data_plot_biomass_sim_macro, for fast tests and runnable examples. Not for
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
#   Rscript data-raw/data_sim_macro.R

set.seed(202)

# 1. Sites, years, and which data source covers each site-year ---------------

sites <- c(
  "seal_ledge", "mussel_point", "cormorant_rock", "anemone_bay", "limpet_head",
  "shearwater_islet", "driftwood_cove", "abalone_reef", "nudibranch_bay",
  "murrelet_pass"
)
years <- as.character(2019:2022)

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
i_site <- match(grid$site, sites)
i_year <- match(grid$year, years)
key <- paste(grid$site, grid$year)

grid$density <- !key %in% c("murrelet_pass 2022", "nudibranch_bay 2019")
grid$size <- grid$density &
  !key %in% c("seal_ledge 2021", "limpet_head 2019", "abalone_reef 2022", "anemone_bay 2020")
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

# Weight: Gamma with constant shape, log mean linear in log fronds.
fronds_ref <- 5
b_weight5 <- 1.67 # log wet weight (kg) at 5 fronds
b_fronds_weight <- 1.11
shape_weight <- 4.7
grid$e_weight <- effects(0.3, 0.29, 0.15)

# Size: zero-truncated negative binomial frond count at 1 m.
b_fronds_size <- 1.73 # log mean frond count before truncation
dispersion_size <- 0.63 # variance mu + dispersion * mu^2
grid$e_size <- effects(0.28, 0.27, 0.23)

# Density: negative binomial plant count on a transect of area_m2. The intercept
# is above the production estimate (log 0.31) so the composed plot biomass spans
# the production range despite the moderated SDs.
b_plants <- log(0.45) # log plants per m^2
dispersion_density <- 0.11
grid$e_density <- effects(0.5, 0.2, 0.4)

# Cover: biomass floor plus a canopy term in tide-corrected cover.
b_canopy <- 8 # kg per m^2 of canopy, within the production interval
b_floor <- 0.42 # kg/m^2 at zero cover
b_tide <- 0.23 # fractional canopy increase per m of tide
b_scaling <- 1.16 # multiplier on the in situ log SDs
grid$e_cover <- effects(0.2, 0.2, 0)

# True plot biomass (wet kg/m^2): expected plants per m^2 times the mean expected
# plant weight over the frond-count distribution.
fronds_max <- 200
dztnb <- function(f, mu, dispersion) {
  stats::dnbinom(f, mu = mu, size = 1 / dispersion) /
    (1 - stats::dnbinom(0, mu = mu, size = 1 / dispersion))
}
expected_weight <- function(fronds, e) {
  exp(b_weight5 + b_fronds_weight * (log(fronds) - log(fronds_ref)) + e)
}
grid$plot_biomass <- vapply(seq_len(nrow(grid)), function(i) {
  f <- seq_len(fronds_max)
  p <- dztnb(f, exp(b_fronds_size + grid$e_size[i]), dispersion_size)
  plants_m2 <- exp(b_plants + grid$e_density[i])
  plants_m2 * sum(p * expected_weight(f, grid$e_weight[i])) / sum(p)
}, numeric(1))

# 3. Observations --------------------------------------------------------------

rztnb <- function(n, mu, dispersion) {
  p0 <- stats::dnbinom(0, mu = mu, size = 1 / dispersion)
  u <- stats::runif(n, min = p0, max = 1)
  pmax(stats::qnbinom(u, mu = mu, size = 1 / dispersion), 1)
}

cells <- function(source) which(grid[[source]])

# Harvested plants are a sample of the site-year's plants, so their frond counts
# come from its size distribution.
data_weight_sim_macro <- do.call(rbind, lapply(cells("weight"), function(i) {
  n <- 20L
  fronds <- rztnb(n, exp(b_fronds_size + grid$e_size[i]), dispersion_size)
  mu <- expected_weight(fronds, grid$e_weight[i])
  data.frame(
    fronds = as.integer(fronds),
    weight_kg = round(stats::rgamma(n, shape_weight, shape_weight / mu), 3),
    site = grid$site[i],
    year = grid$year[i]
  )
}))

data_size_sim_macro <- do.call(rbind, lapply(cells("size"), function(i) {
  n <- 20L
  fronds <- rztnb(n, exp(b_fronds_size + grid$e_size[i]), dispersion_size)
  data.frame(fronds = as.integer(fronds), site = grid$site[i], year = grid$year[i])
}))

data_density_sim_macro <- do.call(rbind, lapply(cells("density"), function(i) {
  n <- 4L
  area_m2 <- sample(c(40, 40, 40, 60, 120), n, replace = TRUE)
  mu <- area_m2 * exp(b_plants + grid$e_density[i])
  data.frame(
    plants = as.integer(stats::rnbinom(n, mu = mu, size = 1 / dispersion_density)),
    area_m2 = area_m2,
    site = grid$site[i],
    year = grid$year[i]
  )
}))

# 4. Drone surveys and in situ plot biomass ------------------------------------

# Each surveyed site-year's tide-corrected cover is the cover model solved for its
# true plot biomass. Macrocystis surveys have no zero-canopy plots, so cover is
# kept between 0.02 and 0.95.
drone <- grid[cells("drone"), ]
n <- nrow(drone)
plot_area_m2 <- round(stats::runif(n, 180, 280), 1)
tide_height_m <- sample(seq(0, 1.6, by = 0.05), n, replace = TRUE)
cover <- (drone$plot_biomass - b_floor) / (b_canopy * exp(drone$e_cover))
clipped <- cover < 0.02 | cover > 0.95
cover <- pmin(pmax(cover, 0.02), 0.95)
canopy_area_m2 <- round(cover * plot_area_m2 / (1 + b_tide * tide_height_m), 2)

# The in situ estimate and its 95% compatibility limits, lognormal around the
# true plot biomass; the limits understate the error by the factor b_scaling.
sd_log <- stats::runif(n, 0.18, 0.5)
log_estimate <- log(drone$plot_biomass) + stats::rnorm(n, 0, b_scaling * sd_log)
z <- stats::qnorm(0.975)

data_cover_biomass_sim_macro <- data.frame(
  site = drone$site,
  year = drone$year,
  canopy_area_m2 = canopy_area_m2,
  plot_area_m2 = plot_area_m2,
  tide_height_m = tide_height_m
)

data_plot_biomass_sim_macro <- data.frame(
  site = drone$site,
  year = drone$year,
  estimate = signif(exp(log_estimate), 3),
  lower = signif(exp(log_estimate - z * sd_log), 3),
  upper = signif(exp(log_estimate + z * sd_log), 3)
)

# 5. Save ----------------------------------------------------------------------

# Levels in creation order, not string order; this order carries through to fits
# and predictions.
as_sim <- function(data) {
  data$site <- factor(data$site, levels = sites)
  data$year <- factor(data$year, levels = years)
  rownames(data) <- NULL
  tibble::as_tibble(data)
}
data_weight_sim_macro <- as_sim(data_weight_sim_macro)
data_size_sim_macro <- as_sim(data_size_sim_macro)
data_density_sim_macro <- as_sim(data_density_sim_macro)
data_cover_biomass_sim_macro <- as_sim(data_cover_biomass_sim_macro)
data_plot_biomass_sim_macro <- as_sim(data_plot_biomass_sim_macro)

message(
  "True plot biomass (kg/m2) at density-surveyed site-years, quantiles 0, 0.25, 0.5, 0.75, 1: ",
  paste(signif(stats::quantile(grid$plot_biomass[grid$density]), 2), collapse = ", ")
)
message("Drone surveys with clipped cover: ", sum(clipped), " of ", n)

usethis::use_data(data_weight_sim_macro, overwrite = TRUE)
usethis::use_data(data_size_sim_macro, overwrite = TRUE)
usethis::use_data(data_density_sim_macro, overwrite = TRUE)
usethis::use_data(data_cover_biomass_sim_macro, overwrite = TRUE)
usethis::use_data(data_plot_biomass_sim_macro, overwrite = TRUE)
