# Simulate a small weight dataset for examples and tests.
# Nereocystis sub-bulb diameter (mm) and wet weight (kg) across several sites
# and years, with one site-year cell intentionally missing (to exercise the
# marginal prediction path). Simulated, not real survey data.

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

kb_data_weight <- do.call(rbind, rows)
kb_data_weight$site <- factor(kb_data_weight$site)
kb_data_weight$year <- factor(kb_data_weight$year)
rownames(kb_data_weight) <- NULL

usethis::use_data(kb_data_weight, overwrite = TRUE)
