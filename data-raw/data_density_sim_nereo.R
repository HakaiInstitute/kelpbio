# Build data_density_sim_nereo, a small simulated density dataset for fast tests
# and runnable examples. Simulated from the density-model structure (a
# zero-inflated negative binomial on the number of stipes per transect, with the
# transect area as an offset and site, year, and site:year effects on log
# density) so it passes kb_check_data_density_nereo() and kb_fit_density_nereo()
# converges on it. The sites and years match the other simulated datasets, with 4
# transects per site-year, transect areas typical of Hakai Institute surveys, and
# one missing cell. About a fifth of transects hold no stipes. Not for inference.
# Run from the package root:
#   Rscript data-raw/data_density_sim_nereo.R

set.seed(404)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)
n_per <- 4L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cell

b_stipes <- log(0.8) # log stipes per m^2 on transects holding stipes
zi <- 0.2 # probability a transect holds no stipes
dispersion <- 0.5 # variance mu + dispersion * mu^2
sd_site <- 0.6
sd_year <- 0.3
sd_site_year <- 0.3

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)
a_year <- stats::setNames(stats::rnorm(length(years), 0, sd_year), years)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  log_density <- b_stipes + a_site[[s]] + a_year[[y]] +
    stats::rnorm(1, 0, sd_site_year)
  area_m2 <- sample(c(20, 40, 40, 60, 100), n_per, replace = TRUE)
  mu <- area_m2 * exp(log_density)
  stipes <- stats::rnbinom(n_per, mu = mu, size = 1 / dispersion)
  stipes[stats::runif(n_per) < zi] <- 0L
  data.frame(stipes = as.integer(stipes), area_m2 = area_m2, site = s, year = y)
})

data_density_sim_nereo <- do.call(rbind, rows)
# Pin levels to creation order (site1..site10) rather than string order.
data_density_sim_nereo$site <- factor(data_density_sim_nereo$site, levels = sites)
data_density_sim_nereo$year <- factor(data_density_sim_nereo$year, levels = years)
rownames(data_density_sim_nereo) <- NULL
data_density_sim_nereo <- tibble::as_tibble(data_density_sim_nereo)

usethis::use_data(data_density_sim_nereo, overwrite = TRUE)
