# Build the simulated Macrocystis datasets: data_weight_sim_macro,
# data_in_situ_sim_macro, data_size_census_sim_macro, and data_canopy_sim_macro, for
# fast tests and runnable examples. Not for inference.
#
# All four come from one set of true site-year values, so they agree: survey
# biomass from the weight fit and the counted plants lands near the true
# biomass the drone cover is simulated from. Means, slopes, shapes, and
# dispersions are near the analysis-project production fits, and random-effect
# SDs near the Hakai Institute fits, so that every model converges at the
# default sampler settings. Nine sites over six years, with abundance declining
# at every site to 2024 and recovering in 2025, most at one small site and one
# large bed. The data sources cover different site-years, as in the field:
# surveys and drone cover at most, and weight harvests at six sites. Site names
# are invented and match no Hakai Institute survey site.
#
# Every counted plant has its fronds at 1 m recorded, drawn from the
# site-year's frond distribution; about one in twelve is a partial (edge)
# plant. Each site-year's four transects are summed to one survey; at a few
# site-years the transects are split between two plots, or between two visits
# to one plot, and one transect with no plants is its own survey.
#
# Run from the package root:
#   Rscript data-raw/data_sim_macro.R

# The seed is one whose drone covers spread widely, with none at the limits.
set.seed(20)

# 1. Sites, years, and which data source covers each site-year ---------------

sites <- c(
  "seal_ledge", "mussel_point", "cormorant_rock", "anemone_bay", "limpet_head",
  "shearwater_islet", "driftwood_cove", "abalone_reef", "nudibranch_bay"
)
years <- as.character(2020:2025)

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
i_site <- match(grid$site, sites)
i_year <- match(grid$year, years)
key <- paste(grid$site, grid$year)

# Six sites are surveyed every year, one misses a year, and two miss two years.
gaps <- list(`4` = 2022, `5` = c(2021, 2024), `8` = c(2020, 2023))
missing <- unlist(lapply(names(gaps), function(s) paste(sites[as.integer(s)], gaps[[s]])))
grid$surveyed <- !key %in% missing
grid$size <- grid$surveyed &
  !key %in% c("seal_ledge 2022", "limpet_head 2021", "abalone_reef 2022", "anemone_bay 2020")
# Three sites are never harvested.
grid$weight <- grid$surveyed & !grid$site %in% c("limpet_head", "shearwater_islet", "nudibranch_bay")
grid$drone <- grid$surveyed

# Abundance trend on the log scale, shared by plant density and canopy area: a
# decline at every site, steeper at some, and a recovery in the last year that
# takes one small site (seal_ledge) and one large bed (driftwood_cove) above
# their first-year abundance.
trend_slope <- -0.3 * c(1, 0.8, 0.9, 1.2, 1.1, 0.7, 1, 0.8, 1.3)
trend_recovery <- c(1.8, 0.5, 0.3, 0.6, 0.3, 0.4, 1.7, 0.6, 0.5)
grid$trend <- trend_slope[i_site] * (i_year - (length(years) + 1) / 2) +
  ifelse(i_year == length(years), trend_recovery[i_site], 0)

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
grid$e_weight <- effects(0.1, 0.3, 0.15)

# Size: zero-truncated negative binomial frond count at 1 m.
b_fronds_size <- 1.73 # log mean frond count before truncation
dispersion_size <- 0.63 # variance mu + dispersion * mu^2
grid$e_size <- effects(0.25, 0.08, 0.08)

# Counts: negative binomial plant count on a transect of area_m2. The intercept
# is near the production estimate (log 0.31).
b_plants <- log(0.35) # log plants per m^2
dispersion_density <- 0.11
grid$e_density <- effects(0.3, 0, 0.1) + grid$trend

# Cover: biomass floor plus a canopy term in tide-corrected cover.
b_canopy <- 8 # kg per m^2 of canopy, within the production interval
b_floor <- 0.42 # kg/m^2 at zero cover
b_tide <- 0.23 # share of the zero-tide canopy lost per m of tide
# Small group SDs, so the calibration and the totals it gives are estimated
# with moderate uncertainty.
grid$e_cover <- effects(0.1, 0.05, 0)

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

# Drawn but not saved (there is no Macrocystis size model), so the draws after
# it match earlier versions.
data_size_sim_macro <- do.call(rbind, lapply(cells("size"), function(i) {
  n <- 20L
  fronds <- rztnb(n, exp(b_fronds_size + grid$e_size[i]), dispersion_size)
  data.frame(fronds = as.integer(fronds), site = grid$site[i], year = grid$year[i])
}))

transects <- do.call(rbind, lapply(cells("surveyed"), function(i) {
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

# 4. Counted plants and in situ surveys -------------------------------------------

# A survey is a plot visit: its transects' areas summed and their plants listed.
transects$transect <- stats::ave(seq_len(nrow(transects)), transects$site, transects$year, FUN = seq_along)
transects$plot_id <- "1"
transects$visit <- 1L
two_plots <- c("seal_ledge 2020", "limpet_head 2022", "driftwood_cove 2021")
two_visits <- "anemone_bay 2023"
tkey <- paste(transects$site, transects$year)
transects$plot_id[tkey %in% two_plots & transects$transect > 2] <- "2"
transects$visit[tkey %in% two_visits & transects$transect > 2] <- 2L
# One transect becomes an empty survey of its own plot.
empty <- which(!tkey %in% c(two_plots, two_visits))[5]
transects$plants[empty] <- 0L
transects$plot_id[empty] <- "3"

survey_id <- paste(transects$site, transects$year, transects$plot_id, transects$visit)
first <- !duplicated(survey_id)
survey <- transects[first, c("site", "year", "plot_id", "visit")]
survey$survey_area_m2 <- as.vector(tapply(transects$area_m2, survey_id, sum)[survey_id[first]])
survey$survey_id <- paste(
  survey$site,
  survey$year,
  stats::ave(seq_len(nrow(survey)), survey$site, survey$year, FUN = seq_along),
  sep = "-"
)

i_grid <- match(paste(transects$site, transects$year), key)
plants <- do.call(rbind, lapply(which(transects$plants > 0), function(t) {
  n <- transects$plants[t]
  i <- i_grid[t]
  data.frame(
    survey = survey_id[t],
    fronds = as.integer(rztnb(n, exp(b_fronds_size + grid$e_size[i]), dispersion_size)),
    partial = stats::runif(n) < 1 / 12
  )
}))
plants$survey_id <- survey$survey_id[match(plants$survey, survey_id[first])]

# Drone cover on the surveys of drone site-years: the cover model solved for the
# true plot biomass, with plot-to-plot variation, kept between 0.02 and 0.95.
i_survey <- match(paste(survey$site, survey$year), key)
# The empty survey's plot has no canopy imagery, so no survey with drone cover is
# empty and the calibration has no presence part.
drone <- grid$drone[i_survey] & survey$plot_id != "3"
n <- nrow(survey)
plot_area_m2 <- round(stats::runif(n, 180, 280), 1)
canopy_tide_height_m <- sample(seq(0, 1.6, by = 0.05), n, replace = TRUE)
cover <- (grid$plot_biomass[i_survey] - b_floor) /
  (b_canopy * exp(grid$e_cover[i_survey])) * exp(stats::rnorm(n, 0, 0.1))
clipped <- cover < 0.02 | cover > 0.95
cover <- pmin(pmax(cover, 0.02), 0.95)
canopy_area_m2 <- round(cover * plot_area_m2 * (1 - b_tide * canopy_tide_height_m), 2)
survey$plot_area_m2 <- ifelse(drone, plot_area_m2, NA_real_)
survey$canopy_area_m2 <- ifelse(drone, canopy_area_m2, NA_real_)
survey$canopy_tide_height_m <- ifelse(drone, canopy_tide_height_m, NA_real_)
survey$survey_area_m2 <- pmin(survey$survey_area_m2, ifelse(drone, plot_area_m2, Inf))

data_in_situ_sim_macro <- survey[c(
  "survey_id", "site", "year", "survey_area_m2",
  "plot_area_m2", "canopy_area_m2", "canopy_tide_height_m"
)]
data_size_census_sim_macro <- plants[c("survey_id", "fronds", "partial")]

# 5. Mapped canopy for totals ----------------------------------------------------

canopy <- grid[grid$drone, c("site", "year")]
m <- nrow(canopy)
# Each site's bed at zero tide follows the abundance trend; the mapped canopy is
# what remains visible at the tide height of the imagery.
bed_area_m2 <- stats::runif(length(sites), 2500, 8000)
# Two large beds hold far more kelp than the rest: their bed areas are set so
# that the total averages 150,000 to 250,000 kg over the years.
kg_m2_bed <- vapply(c(2, 7), function(s) {
  k <- which(grid$drone & i_site == s)
  mean((b_floor + b_canopy * exp(grid$e_cover[k])) * exp(grid$trend[k]))
}, numeric(1))
bed_area_m2[c(2, 7)] <- stats::runif(2, 150000, 250000) / (kg_m2_bed * (1 - b_tide * 0.8))
canopy$canopy_tide_height_m <- sample(seq(0, 1.6, by = 0.05), m, replace = TRUE)
canopy$canopy_area_m2 <- round(
  bed_area_m2[match(canopy$site, sites)] *
    exp(grid$trend[grid$drone] + stats::rnorm(m, 0, 0.1)) *
    (1 - b_tide * canopy$canopy_tide_height_m)
)
canopy$classified_area_m2 <- round(canopy$canopy_area_m2 * stats::runif(m, 1.5, 3))
canopy$region <- factor(
  ifelse(match(canopy$site, sites) <= 4, "north", "south"),
  levels = c("north", "south")
)
data_canopy_sim_macro <- canopy[c(
  "site", "year", "canopy_area_m2", "canopy_tide_height_m", "classified_area_m2", "region"
)]

# 6. Save ----------------------------------------------------------------------

# Levels in creation order, not string order; this order carries through to fits
# and predictions.
as_sim <- function(data) {
  if ("site" %in% names(data)) {
    data$site <- factor(data$site, levels = sites)
  }
  if ("year" %in% names(data)) {
    data$year <- factor(data$year, levels = years)
  }
  rownames(data) <- NULL
  tibble::as_tibble(data)
}
data_weight_sim_macro <- as_sim(data_weight_sim_macro)
data_in_situ_sim_macro <- as_sim(data_in_situ_sim_macro)
data_size_census_sim_macro <- as_sim(data_size_census_sim_macro)
data_canopy_sim_macro <- as_sim(data_canopy_sim_macro)

message(
  "True plot biomass (kg/m2) at surveyed site-years, quantiles 0, 0.25, 0.5, 0.75, 1: ",
  paste(signif(stats::quantile(grid$plot_biomass[grid$surveyed]), 2), collapse = ", ")
)
message(
  "Surveys: ", n, "; with drone cover: ", sum(drone),
  "; clipped cover: ", sum(clipped & drone), "; counted plants: ", nrow(plants)
)

usethis::use_data(data_weight_sim_macro, overwrite = TRUE)
usethis::use_data(data_in_situ_sim_macro, overwrite = TRUE)
usethis::use_data(data_size_census_sim_macro, overwrite = TRUE)
usethis::use_data(data_canopy_sim_macro, overwrite = TRUE)
