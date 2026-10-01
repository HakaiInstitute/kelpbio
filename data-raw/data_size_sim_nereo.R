# Build data_size_sim_nereo, a small simulated size dataset for fast tests and
# runnable examples. Simulated from the size-model structure (a Weibull on
# maximum sub-bulb diameter, parameterised by its mean, with site, year, and
# site:year effects on the log mean and a common shape) so it passes
# kb_check_data_size_nereo() and kb_fit_size_nereo() converges on it. Ten sites
# keep the site-level SD identifiable. The sites and years match
# data_weight_sim_nereo, with 15 plants per site-year (a typical transect size
# sample) and one missing cell. Not for inference. Run from the package root:
#   Rscript data-raw/data_size_sim_nereo.R

set.seed(202)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)
n_per <- 15L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cell

b_diameter <- log(35) # log mean diameter (mm)
shape <- 3.5
sd_site <- 0.25
sd_year <- 0.1
sd_site_year <- 0.1

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)
a_year <- stats::setNames(stats::rnorm(length(years), 0, sd_year), years)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  mu <- exp(b_diameter + a_site[[s]] + a_year[[y]] + stats::rnorm(1, 0, sd_site_year))
  diameter <- stats::rweibull(n_per, shape = shape, scale = mu / gamma(1 + 1 / shape))
  data.frame(diameter = round(diameter, 1), site = s, year = y)
})

data_size_sim_nereo <- do.call(rbind, rows)
# Pin levels to creation order (site1..site10) rather than string order.
data_size_sim_nereo$site <- factor(data_size_sim_nereo$site, levels = sites)
data_size_sim_nereo$year <- factor(data_size_sim_nereo$year, levels = years)
rownames(data_size_sim_nereo) <- NULL
data_size_sim_nereo <- tibble::as_tibble(data_size_sim_nereo)

usethis::use_data(data_size_sim_nereo, overwrite = TRUE)
