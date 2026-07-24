# Build the small SIMULATED weight dataset used to build the test fixture and to
# drive the fit/check tests. Kept small and controlled (6 sites x 4 years, one
# missing cell) and independent of the bundled datasets, so tests
# stay fast and stable. NOT run during testing.
#
# Run from the package root:  Rscript tests/testthat/fixtures/make-sim-data.R

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
    a_site[[s]] +
    a_sy +
    stats::rnorm(n_per, 0, sd_resid)
  data.frame(
    diameter = round(diameter, 1),
    weight = round(exp(log_w), 3),
    site = s,
    year = y
  )
})

sim_weight <- do.call(rbind, rows)
sim_weight$site <- factor(sim_weight$site)
sim_weight$year <- factor(sim_weight$year)
rownames(sim_weight) <- NULL

saveRDS(sim_weight, "tests/testthat/fixtures/sim_weight.rds")
message("Wrote tests/testthat/fixtures/sim_weight.rds")
