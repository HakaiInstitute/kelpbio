# Build data_size_sim_macro, a small simulated size dataset for fast tests and
# runnable examples. Simulated from the size-model structure (a zero-truncated
# negative binomial on the number of fronds reaching 1 m above the holdfast, with
# site, year, and site:year effects on the log mean before truncation) so it
# passes kb_check_data_size_macro() and kb_fit_size_macro() converges on it. The
# sites and years match data_weight_sim_macro, with 20 plants per site-year and
# one missing cell. Zero-truncated draws use the inverse CDF on (P(0), 1). Not for
# inference. Run from the package root:
#   Rscript data-raw/data_size_sim_macro.R

set.seed(303)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)
n_per <- 20L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cell

b_fronds <- log(6) # log mean frond count before truncation
dispersion <- 0.8 # variance mu + dispersion * mu^2
sd_site <- 0.5
sd_year <- 0.2
sd_site_year <- 0.15

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)
a_year <- stats::setNames(stats::rnorm(length(years), 0, sd_year), years)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  mu <- exp(b_fronds + a_site[[s]] + a_year[[y]] + stats::rnorm(1, 0, sd_site_year))
  p0 <- stats::dnbinom(0, mu = mu, size = 1 / dispersion)
  u <- stats::runif(n_per, min = p0, max = 1)
  fronds <- pmax(stats::qnbinom(u, mu = mu, size = 1 / dispersion), 1)
  data.frame(fronds = as.integer(fronds), site = s, year = y)
})

data_size_sim_macro <- do.call(rbind, rows)
# Pin levels to creation order (site1..site10) rather than string order.
data_size_sim_macro$site <- factor(data_size_sim_macro$site, levels = sites)
data_size_sim_macro$year <- factor(data_size_sim_macro$year, levels = years)
rownames(data_size_sim_macro) <- NULL
data_size_sim_macro <- tibble::as_tibble(data_size_sim_macro)

usethis::use_data(data_size_sim_macro, overwrite = TRUE)
