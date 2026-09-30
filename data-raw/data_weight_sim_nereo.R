# Build data_weight_sim_nereo, a small simulated weight dataset for fast tests and
# runnable examples. Simulated from the weight-model structure (Packard power
# function with a common floor, year, site, and site:year effects on log(alpha),
# lognormal noise) so it passes kb_check_data_weight_nereo() and
# kb_fit_weight_nereo() converges on it. The site effects carry genuine signal
# over a wide diameter range, so the fitted curves separate by site. Ten sites
# keep the site-level SD identifiable (a group-level SD is poorly determined from
# only a handful of groups), and the site:year SD is kept small so the
# between-site signal loads onto the site effect rather than being absorbed by
# the interaction. Parameter values are near the analysis-project estimates.
# Kept small (10 sites x 4 years, one missing cell) and seeded for
# reproducibility. Not for inference. Run from the package root:
#   Rscript data-raw/data_weight_sim_nereo.R

set.seed(101)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)
# Observations per site-year cell. Fit objects no longer store per-observation
# quantities, so this is not a size constraint; it is set for identifiability of
# the site-level SDs and for fast tests.
n_per <- 20L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cell

b_alpha30 <- log(1) # log weight above the floor (kg) at 30 mm
b_power <- 3 # allometric exponent
b_floor <- 0.12 # weight floor (kg)
sd_year <- 0.15
sd_site <- 0.4 # between-site SD
sd_site_year <- 0.1 # small: keep the between-site signal on the site effect
sd_resid <- 0.25

a_year <- stats::setNames(stats::rnorm(length(years), 0, sd_year), years)
a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  a_sy <- stats::rnorm(1, 0, sd_site_year)
  diameter <- exp(stats::rnorm(n_per, log(35), 0.28))
  alpha <- exp(b_alpha30 + a_year[[y]] + a_site[[s]] + a_sy)
  e_weight <- b_floor + alpha * (diameter / 30)^b_power
  log_w <- log(e_weight) + stats::rnorm(n_per, 0, sd_resid)
  data.frame(
    diameter = round(diameter, 1),
    weight = round(exp(log_w), 3),
    site = s,
    year = y
  )
})

data_weight_sim_nereo <- do.call(rbind, rows)
# Pin levels to creation order (site1..site10) so they are not string-sorted to
# site1, site10, site2, ...; this order carries through to fits and predictions.
data_weight_sim_nereo$site <- factor(data_weight_sim_nereo$site, levels = sites)
data_weight_sim_nereo$year <- factor(data_weight_sim_nereo$year, levels = years)
rownames(data_weight_sim_nereo) <- NULL
data_weight_sim_nereo <- tibble::as_tibble(data_weight_sim_nereo)

usethis::use_data(data_weight_sim_nereo, overwrite = TRUE)
