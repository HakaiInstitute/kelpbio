# Build data_weight_sim_macro, a small simulated weight dataset for fast tests
# and runnable examples. Simulated from the Macrocystis weight-model structure
# (Gamma response with constant shape, log-linear mean in
# log-fronds, and site + year + site:year random intercepts) so it passes
# kb_check_data_weight_macro() and kb_fit_weight_macro() converges on it. The
# site random effects carry genuine signal over a wide frond-count range, so the
# fitted curves separate by site. Ten sites keep the site-level SD identifiable,
# and the site:year SD is kept small so the between-site signal loads onto the
# site effect. Kept small (10 sites x 4 years, one missing cell) and seeded for
# reproducibility. Not for inference. Run from the package root:
#   Rscript data-raw/data_weight_sim_macro.R

set.seed(202)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)
# Observations per site-year cell. Fit objects no longer store per-observation
# quantities, so this is not a size constraint; it is set for identifiability of
# the site-level SDs and for fast tests.
n_per <- 20L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cell

fronds_ref <- 5 # log-fronds centering reference (median frond count)
b_weight5 <- log(0.6) # log wet weight (kg) at 5 fronds
b_fronds <- 1.05 # allometric slope on log(fronds / 5) (near proportional)
shape <- 10 # Gamma shape (dispersion)
sd_site <- 0.4 # between-site intercept SD
sd_year <- 0.15 # between-year intercept SD
sd_site_year <- 0.1 # small: keep the between-site signal on the site effect

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)
a_year <- stats::setNames(stats::rnorm(length(years), 0, sd_year), years)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  a_sy <- stats::rnorm(1, 0, sd_site_year)
  fronds <- pmax(1L, round(exp(stats::rnorm(n_per, log(fronds_ref), 0.5))))
  log_ew <- b_weight5 +
    b_fronds * (log(fronds) - log(fronds_ref)) +
    a_site[[s]] +
    a_year[[y]] +
    a_sy
  weight <- stats::rgamma(n_per, shape = shape, rate = shape / exp(log_ew))
  data.frame(
    fronds = as.integer(fronds),
    weight = round(weight, 3),
    site = s,
    year = y
  )
})

data_weight_sim_macro <- do.call(rbind, rows)
# Pin levels to creation order (site1..site10) so they are not string-sorted;
# this order carries through to fits and predictions.
data_weight_sim_macro$site <- factor(data_weight_sim_macro$site, levels = sites)
data_weight_sim_macro$year <- factor(data_weight_sim_macro$year, levels = years)
rownames(data_weight_sim_macro) <- NULL
data_weight_sim_macro <- tibble::as_tibble(data_weight_sim_macro)

usethis::use_data(data_weight_sim_macro, overwrite = TRUE)
