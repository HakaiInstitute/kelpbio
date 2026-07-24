# Build data_weight_sim_nereo, a small simulated weight dataset for fast tests and
# runnable examples. Simulated from the weight-model structure (quadratic
# log-diameter mean with site intercept, site slope, and site:year random
# effects, log-normal noise) so it passes kb_check_data_weight_nereo() and
# kb_fit_weight_nereo() converges on it. The site random effects carry genuine
# signal (each site has its own intercept and its own allometric slope) over a
# wide diameter range, so the fitted curves separate by site rather than
# collapsing to a common line. Ten sites keep the site-level SDs identifiable
# (a group-level SD is poorly determined from only a handful of groups), and the
# site:year SD is kept small so the between-site signal loads onto the site
# effect rather than being absorbed by the interaction. Kept small (10 sites x 4
# years, one missing cell) and seeded for reproducibility. Not for inference.
# Run from the package root:
#   Rscript data-raw/data_weight_sim_nereo.R

set.seed(101)

sites <- paste0("site", 1:10)
years <- as.character(2019:2022)
n_per <- 25L

grid <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
grid <- grid[!(grid$site == "site10" & grid$year == "2022"), ] # missing cell

b_weight30 <- log(0.1) # log wet weight (kg) at 30 mm
b_diameter <- 2.6 # mean allometric exponent on log(diameter / 30)
sd_site <- 0.4 # between-site intercept SD
sd_site_slope <- 0.22 # between-site allometric-slope SD
sd_site_year <- 0.1 # small: keep the between-site signal on the site effect
sd_resid <- 0.2

a_site <- stats::setNames(stats::rnorm(length(sites), 0, sd_site), sites)
a_site_slope <- stats::setNames(
  stats::rnorm(length(sites), 0, sd_site_slope),
  sites
)

rows <- lapply(seq_len(nrow(grid)), function(i) {
  s <- grid$site[i]
  y <- grid$year[i]
  a_sy <- stats::rnorm(1, 0, sd_site_year)
  log_d <- stats::rnorm(n_per, log(42), 0.35)
  diameter <- exp(log_d)
  log_w <- b_weight30 +
    (b_diameter + a_site_slope[[s]]) * (log(diameter) - log(30)) +
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

data_weight_sim_nereo <- do.call(rbind, rows)
# Pin levels to creation order (site1..site10) so they are not string-sorted to
# site1, site10, site2, ...; this order carries through to fits and predictions.
data_weight_sim_nereo$site <- factor(data_weight_sim_nereo$site, levels = sites)
data_weight_sim_nereo$year <- factor(data_weight_sim_nereo$year, levels = years)
rownames(data_weight_sim_nereo) <- NULL
data_weight_sim_nereo <- tibble::as_tibble(data_weight_sim_nereo)

usethis::use_data(data_weight_sim_nereo, overwrite = TRUE)
