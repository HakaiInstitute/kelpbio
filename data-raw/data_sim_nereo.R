# Build the simulated Nereocystis datasets: data_weight_sim_nereo,
# data_size_sample_sim_nereo, data_survey_sim_nereo, and data_canopy_sim_nereo, for
# fast tests and runnable examples. Not for inference.
#
# All four come from one set of true site-year values, so they agree: survey
# biomass from fits to the weight and size data lands near the true biomass the
# drone cover is simulated from. Means, slopes, shapes, and dispersions are near
# the analysis-project production fits; random-effect SDs are held moderate so
# the small pre-fits converge and site differences show in examples. The data
# sources cover different site-years, as in the field: surveys at most, size at
# most of those, weight harvests at about half (three sites never harvested),
# and drone cover at about two-thirds. Site names are invented and match no
# Hakai Institute survey site.
#
# Each site-year's four transects are summed to one in situ survey; at a few
# site-years the transects are split between two plots, or between two visits
# to one plot, and one transect with no plants is its own survey. The
# draws up to the size data are unchanged from earlier versions, so the weight
# and size data, and their pre-fits, are too.
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

grid$surveyed <- !key %in% c("raven_reef 2022", "tidepool_bluff 2019")
grid$size <- grid$surveyed &
  !key %in% c("gull_rock 2020", "urchin_shoal 2022", "fog_islet 2021", "cedar_bay 2019")
# Seven sites harvested, each in three of the four years.
grid$weight <- grid$surveyed & i_site <= 7 & i_year != (i_site %% 4) + 1
grid$drone <- grid$surveyed & (i_site + i_year) %% 3 != 0

# 2. True values ---------------------------------------------------------------

effects <- function(sd_site, sd_year, sd_site_year) {
  a_site <- stats::rnorm(length(sites), 0, sd_site)
  a_year <- stats::rnorm(length(years), 0, sd_year)
  a_site_year <- stats::rnorm(nrow(grid), 0, sd_site_year)
  a_site[i_site] + a_year[i_year] + a_site_year
}

# Weight: lognormal around a power function of diameter with a floor.
b_weight30 <- log(0.91) # log weight above the floor (kg) at 30 mm
b_power <- 3.02
b_floor <- 0.115 # kg
sd_weight <- 0.46 # residual SD of log weight
# Site differences dominate site:year noise, so the site SD is identifiable
# from the seven harvested sites.
grid$e_weight <- effects(0.5, 0.17, 0.1)

# Size: Weibull sub-bulb diameter with mean exp(log mean).
b_diameter <- log(23) # log mean diameter (mm)
shape_size <- 2.7
grid$e_size <- effects(0.2, 0.15, 0.12)

# Counts: zero-inflated negative binomial plant count on a transect of area_m2.
# The intercept is above the production estimate (log 0.18) so the composed plot
# biomass spans the production range despite the moderated SDs.
b_plants <- log(1.5) # log plants per m^2 on occupied transects
zero_inflation <- 0.05 # probability a transect is unoccupied (a structural zero)
dispersion_density <- 0.45 # variance mu + dispersion * mu^2
grid$e_density <- effects(0.6, 0.4, 0.5)

# Cover: biomass floor plus a canopy term in tide-corrected cover.
b_canopy <- 8 # kg per m^2 of canopy
b_cover_floor <- 0.093 # kg/m^2 at zero cover
b_tide <- 0.28 # share of the zero-tide canopy lost per m of tide
grid$e_cover <- effects(0.2, 0.2, 0)

# 3. Transect counts ------------------------------------------------------------

transects <- do.call(rbind, lapply(which(grid$surveyed), function(i) {
  n <- 4L
  area_m2 <- sample(c(20, 40, 40, 60, 100), n, replace = TRUE)
  mu <- area_m2 * exp(b_plants + grid$e_density[i])
  plants <- stats::rnbinom(n, mu = mu, size = 1 / dispersion_density)
  plants[stats::runif(n) < zero_inflation] <- 0L
  data.frame(plants = as.integer(plants), area_m2 = area_m2, site = grid$site[i], year = grid$year[i])
}))

n_weight <- 20L

expected_weight <- function(diameter, i) {
  b_floor + exp(b_weight30 + grid$e_weight[i]) * (diameter / 30)^b_power
}
size_scale <- function(i) exp(b_diameter + grid$e_size[i]) / gamma(1 + 1 / shape_size)

# True plot biomass (wet kg/m^2) at surveyed site-years: expected plants
# per m^2 times the mean expected plant weight over the diameter distribution,
# using the lognormal mean.
quantiles <- (seq_len(1000) - 0.5) / 1000
grid$plot_biomass <- NA_real_
for (i in which(grid$surveyed)) {
  diameter <- stats::qweibull(quantiles, shape_size, size_scale(i))
  plants_m2 <- (1 - zero_inflation) * exp(b_plants + grid$e_density[i])
  grid$plot_biomass[i] <- plants_m2 *
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
    year = grid$year[i]
  )
}))

data_size_sample_sim_nereo <- do.call(rbind, lapply(which(grid$size), function(i) {
  diameter <- stats::rweibull(20L, shape_size, size_scale(i))
  data.frame(diameter_mm = round(diameter, 1), site = grid$site[i], year = grid$year[i])
}))

# 5. In situ surveys --------------------------------------------------------------

# A survey is a plot visit: its transects' plants and areas summed.
transects$transect <- stats::ave(seq_len(nrow(transects)), transects$site, transects$year, FUN = seq_along)
transects$plot_id <- "1"
transects$visit <- 1L
two_plots <- c("otter_cove 2020", "heron_reef 2021", "eagle_spit 2019")
two_visits <- "cedar_bay 2021"
tkey <- paste(transects$site, transects$year)
transects$plot_id[tkey %in% two_plots & transects$transect > 2] <- "2"
transects$visit[tkey %in% two_visits & transects$transect > 2] <- 2L
# One transect with no plants becomes a survey of its own plot, an empty survey.
empty <- which(transects$plants == 0 & !tkey %in% c(two_plots, two_visits))[1]
transects$plot_id[empty] <- "3"

survey_id <- paste(transects$site, transects$year, transects$plot_id, transects$visit)
first <- !duplicated(survey_id)
survey <- transects[first, c("site", "year", "plot_id", "visit")]
survey$plants <- as.vector(tapply(transects$plants, survey_id, sum)[survey_id[first]])
survey$survey_area_m2 <- as.vector(tapply(transects$area_m2, survey_id, sum)[survey_id[first]])
survey$survey_id <- paste(
  survey$site,
  survey$year,
  stats::ave(seq_len(nrow(survey)), survey$site, survey$year, FUN = seq_along),
  sep = "-"
)

# Drone cover on the surveys of drone site-years: the cover model solved for the
# true plot biomass, with plot-to-plot variation. Cover below zero is set to
# zero and capped at 0.95; the empty survey's plot has no delineated canopy.
i_grid <- match(paste(survey$site, survey$year), key)
drone <- grid$drone[i_grid]
n <- nrow(survey)
plot_area_m2 <- round(stats::runif(n, 180, 280), 1)
tide_height_m <- sample(seq(0, 1.6, by = 0.05), n, replace = TRUE)
cover <- (grid$plot_biomass[i_grid] - b_cover_floor) /
  (b_canopy * exp(grid$e_cover[i_grid])) * exp(stats::rnorm(n, 0, 0.1))
clipped <- cover > 0.95
cover <- pmin(pmax(cover, 0), 0.95)
cover[survey$plot_id == "3"] <- 0
canopy_area_m2 <- round(cover * plot_area_m2 * (1 - b_tide * tide_height_m), 2)
survey$plot_area_m2 <- ifelse(drone, plot_area_m2, NA_real_)
survey$canopy_area_m2 <- ifelse(drone, canopy_area_m2, NA_real_)
survey$tide_height_m <- ifelse(drone, tide_height_m, NA_real_)
survey$survey_area_m2 <- pmin(survey$survey_area_m2, ifelse(drone, plot_area_m2, Inf))

data_survey_sim_nereo <- survey[c(
  "survey_id", "site", "year", "survey_area_m2", "plants",
  "plot_area_m2", "canopy_area_m2", "tide_height_m"
)]

# 6. Mapped canopy for totals ----------------------------------------------------

canopy <- grid[grid$drone, c("site", "year")]
m <- nrow(canopy)
canopy$canopy_area_m2 <- round(stats::runif(m, 500, 12000))
canopy$tide_height_m <- sample(seq(0, 1.6, by = 0.05), m, replace = TRUE)
canopy$classified_area_m2 <- round(canopy$canopy_area_m2 * stats::runif(m, 1.5, 3))
canopy$region <- factor(
  ifelse(match(canopy$site, sites) <= 5, "north", "south"),
  levels = c("north", "south")
)
data_canopy_sim_nereo <- canopy

# 7. Save ----------------------------------------------------------------------

# Levels in creation order, not string order; this order carries through to fits
# and predictions.
as_sim <- function(data) {
  data$site <- factor(data$site, levels = sites)
  if ("year" %in% names(data)) {
    data$year <- factor(data$year, levels = years)
  }
  rownames(data) <- NULL
  tibble::as_tibble(data)
}
data_weight_sim_nereo <- as_sim(data_weight_sim_nereo)
data_size_sample_sim_nereo <- as_sim(data_size_sample_sim_nereo)
data_survey_sim_nereo <- as_sim(data_survey_sim_nereo)
data_canopy_sim_nereo <- as_sim(data_canopy_sim_nereo)

message(
  "True plot biomass (kg/m2) at surveyed site-years, quantiles 0, 0.25, 0.5, 0.75, 1: ",
  paste(signif(stats::quantile(grid$plot_biomass, na.rm = TRUE), 2), collapse = ", ")
)
message(
  "Surveys: ", n, "; with drone cover: ", sum(drone),
  "; capped cover: ", sum(clipped & drone), "; no plants: ", sum(survey$plants == 0)
)

usethis::use_data(data_weight_sim_nereo, overwrite = TRUE)
usethis::use_data(data_size_sample_sim_nereo, overwrite = TRUE)
usethis::use_data(data_survey_sim_nereo, overwrite = TRUE)
usethis::use_data(data_canopy_sim_nereo, overwrite = TRUE)
