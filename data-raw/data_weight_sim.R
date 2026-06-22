# Build data_weight_sim, a small simulated weight dataset for fast tests and
# runnable examples. Simulated from the weight-model structure (quadratic
# log-diameter mean with site and site:year random effects, log-normal noise) so
# it passes kb_check_data_weight() and kb_fit_weight() converges on it. Kept
# small (6 sites x 4 years, one missing cell) and seeded for reproducibility.
# Not for inference. Run from the package root:
#   Rscript data-raw/data_weight_sim.R

set.seed(101)

sites <- paste0("site", 1:6)
years <- as.character(2019:2022)
n_per <- 25L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site6" & grid$year == "2022"), ] # missing cell

b_weight30 <- log(0.1) # log wet weight (kg) at 30 mm
b_diameter <- 2.6 # allometric exponent on log(diameter / 30)
sd_site <- 0.3
sd_site_year <- 0.2
sd_resid <- 0.25

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  a_sy <- stats::rnorm(1, 0, sd_site_year)
  log_d <- stats::rnorm(n_per, log(40), 0.3)
  diameter <- exp(log_d)
  log_w <- b_weight30 +
    b_diameter * (log(diameter) - log(30)) +
    a_site[[s]] + a_sy +
    stats::rnorm(n_per, 0, sd_resid)
  data.frame(
    diameter = round(diameter, 1),
    weight = round(exp(log_w), 3),
    site = s,
    year = y
  )
})

data_weight_sim <- do.call(rbind, rows)
data_weight_sim$site <- factor(data_weight_sim$site)
data_weight_sim$year <- factor(data_weight_sim$year)
rownames(data_weight_sim) <- NULL
data_weight_sim <- tibble::as_tibble(data_weight_sim)

usethis::use_data(data_weight_sim, overwrite = TRUE)
