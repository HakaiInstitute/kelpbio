# Build data_density_sim_macro, a small simulated density dataset for fast tests
# and runnable examples. Simulated from the density-model structure (a negative
# binomial on the number of plants per transect, with the transect area as an
# offset and site, year, and site:year effects on log density) so it passes
# kb_check_data_density_macro() and kb_fit_density_macro() converges on it. The
# sites and years match the other simulated datasets, with 4 transects per
# site-year, transect areas typical of Hakai Institute surveys, and one missing
# cell. Not for inference. Run from the package root:
#   Rscript data-raw/data_density_sim_macro.R

set.seed(505)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)
n_per <- 4L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cell

b_plants <- log(0.3) # log plants per m^2
dispersion <- 0.3 # variance mu + dispersion * mu^2
sd_site <- 0.5
sd_year <- 0.2
sd_site_year <- 0.2

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)
a_year <- stats::setNames(stats::rnorm(length(years), 0, sd_year), years)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  log_density <- b_plants + a_site[[s]] + a_year[[y]] +
    stats::rnorm(1, 0, sd_site_year)
  area_m2 <- sample(c(40, 40, 40, 60, 120), n_per, replace = TRUE)
  mu <- area_m2 * exp(log_density)
  plants <- stats::rnbinom(n_per, mu = mu, size = 1 / dispersion)
  data.frame(plants = as.integer(plants), area_m2 = area_m2, site = s, year = y)
})

data_density_sim_macro <- do.call(rbind, rows)
# Pin levels to creation order (site1..site10) rather than string order.
data_density_sim_macro$site <- factor(data_density_sim_macro$site, levels = sites)
data_density_sim_macro$year <- factor(data_density_sim_macro$year, levels = years)
rownames(data_density_sim_macro) <- NULL
data_density_sim_macro <- tibble::as_tibble(data_density_sim_macro)

usethis::use_data(data_density_sim_macro, overwrite = TRUE)
