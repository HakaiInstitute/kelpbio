# Simulation study: calibrating the site:year random-effect SD prior, and
# deciding whether a structural drop is needed in addition to the prior.
#
# Background (team discussion): kelpbio fits one fixed hierarchical structure to
# arbitrary, often sparse, datasets. A weakly-supported site:year interaction is
# regularized by a prior on its SD, held tighter than the marginals. A term that
# the design cannot identify can also be dropped structurally. Because the model
# is pre-compiled, dropping is encoded as a 0/1 multiplier passed in the data
# (site_year_on) that zeroes the term, not as a prior change.
#
# Two questions:
#   A. What exponential rate calibrates the site:year SD prior?
#   B. Across data richness and true effect size, does the structural drop
#      (site_year_on = FALSE) beat the tight prior? The decisive metric is
#      held-out prediction for NEW site-years (marginal over the interaction),
#      since that is where a spuriously non-zero SD injects variance.
#
# Run: devtools::install() first (Stan must be compiled), then Rscript this file.
# Defaults to a fast smoke test; set SIM_FULL=1 for the full grid.

library(kelpbio)
library(ggplot2)
library(dplyr)

# =============================================================================
# Config
# =============================================================================

out_dir <- "scripts/sim-output"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

base_seed <- 20260623L

QUICK <- !identical(Sys.getenv("SIM_FULL"), "1")

# sigmas_b includes 0.5 (large interaction, well above the tight prior's mean SD
# of 0.2) to test whether, under full aliasing, the tight prior under-disperses
# new-site-year predictions because the data cannot pull the unidentified split.
cfg <- if (QUICK) {
  list(chains = 2L, niters = 300L, cores = 2L,
       reps_a = 3L, rates_a = c(1, 5), sigmas_a = c(0, 0.35),
       reps_b = 2L, sigmas_b = c(0, 0.5))
} else {
  list(chains = 2L, niters = 500L, cores = max(1L, parallel::detectCores() - 1L),
       reps_a = 30L, rates_a = c(1, 2, 5, 10, 25), sigmas_a = c(0, 0.15, 0.35),
       reps_b = 20L, sigmas_b = c(0, 0.15, 0.25, 0.5))
}

# Experiment B arms: loose/equal prior, tight prior, and the structural drop.
arms_b <- data.frame(
  arm = c("loose (equal)", "tight", "drop (flag)"),
  rate = c(1, 5, 1),
  site_year_on = c(TRUE, TRUE, FALSE),
  stringsAsFactors = FALSE
)
arm_levels <- arms_b$arm

# True data-generating parameters (scales from data-raw/data_weight_sim_nereo.R).
true_base <- list(
  b_weight = log(0.1),
  b_diameter = 2.6,
  b_diameter2 = 0,
  sd_site = 0.3,
  sd_site_diameter = 0.1,
  sd_resid = 0.25,
  diameter_ref = 40
)

designs <- list(
  rich    = list(n_sites = 8L, n_years = 5L, plants = 20L, aliased = FALSE),
  sparse  = list(n_sites = 5L, n_years = 3L, plants = 4L,  aliased = FALSE),
  aliased = list(n_sites = 6L, n_years = 6L, plants = 15L, aliased = TRUE)
)
n_test <- 10L          # held-out plants per observed site-year
n_new_years <- 2L      # held-out new years (observed sites) for marginal scoring
n_test_newyear <- 8L   # held-out plants per new site-year

# =============================================================================
# Generative model (matches inst/stan/weight_nereo.stan)
# =============================================================================

build_cells <- function(design) {
  sites <- paste0("site", seq_len(design$n_sites))
  years <- paste0("yr", seq_len(design$n_years))
  if (design$aliased) {
    cells <- data.frame(site = sites, year = years[seq_along(sites)],
                        stringsAsFactors = FALSE)
  } else {
    cells <- expand.grid(site = sites, year = years, stringsAsFactors = FALSE)
  }
  cells$n <- design$plants
  cells
}

rule_diagnostics <- function(cells) {
  per_site_years <- tapply(cells$year, cells$site, function(x) length(unique(x)))
  list(
    n_sites_multiyear = sum(per_site_years > 1),
    n_cells = nrow(cells),
    rule_fires = sum(per_site_years > 1) == 0
  )
}

# Generate plants for a set of cells, given the random effects.
gen_plants <- function(cells_df, a_sy_vec, a_site, b_site_d, true) {
  rows <- lapply(seq_len(nrow(cells_df)), function(i) {
    s <- cells_df$site[i]
    y <- cells_df$year[i]
    n <- cells_df$n[i]
    log_d <- stats::rnorm(n, log(40), 0.3)
    diameter <- exp(log_d)
    ld <- log(diameter) - log(true$diameter_ref)
    asy <- a_sy_vec[[paste(s, y, sep = ":")]]
    log_w <- true$b_weight + a_site[[s]] +
      (true$b_diameter + b_site_d[[s]]) * ld +
      true$b_diameter2 * ld^2 +
      asy +
      stats::rt(n, df = 4) * true$sd_resid
    data.frame(diameter = diameter, weight = exp(log_w),
               site = s, year = y, stringsAsFactors = FALSE)
  })
  df <- do.call(rbind, rows)
  df$site <- factor(df$site)
  df$year <- factor(df$year)
  tibble::as_tibble(df)
}

# Draw REs once; generate training plants, held-out plants in the observed
# site-years, and held-out plants in fresh site-years (observed sites).
simulate_weight_data <- function(cells, true, seed) {
  set.seed(seed)
  sites <- unique(cells$site)
  a_site <- stats::setNames(stats::rnorm(length(sites), 0, true$sd_site), sites)
  b_site_d <- stats::setNames(
    stats::rnorm(length(sites), 0, true$sd_site_diameter), sites
  )
  a_sy <- stats::setNames(
    stats::rnorm(nrow(cells), 0, true$sd_site_year),
    paste(cells$site, cells$year, sep = ":")
  )

  train <- gen_plants(cells, a_sy, a_site, b_site_d, true)
  test_cells <- cells
  test_cells$n <- n_test
  test <- gen_plants(test_cells, a_sy, a_site, b_site_d, true)

  # fresh site-years at the observed sites
  existing_years <- unique(cells$year)
  new_years <- paste0("newyr", seq_len(n_new_years))
  new_cells <- expand.grid(site = sites, year = new_years,
                           stringsAsFactors = FALSE)
  new_cells$n <- n_test_newyear
  a_sy_new <- stats::setNames(
    stats::rnorm(nrow(new_cells), 0, true$sd_site_year),
    paste(new_cells$site, new_cells$year, sep = ":")
  )
  test_newyear <- gen_plants(new_cells, a_sy_new, a_site, b_site_d, true)

  list(train = train, test = test, test_newyear = test_newyear)
}

# =============================================================================
# Fit one arm (single fixed model; prior rate and structural flag are the knobs)
# =============================================================================

fit_one <- function(train, rate, site_year_on, cfg, seed) {
  priors <- kb_priors_weight_nereo()
  priors$sd_site_year <- kb_prior_exponential(rate = rate)
  kb_fit_weight_nereo(
    train,
    priors = priors,
    site_year_on = site_year_on,
    chains = cfg$chains,
    niters = cfg$niters,
    cores = 1L,
    quiet = TRUE,
    seed = seed
  )
}

# =============================================================================
# Metrics from the stored draws
# =============================================================================

.lme <- function(x) {
  m <- max(x)
  m + log(mean(exp(x - m)))
}
.draws_of <- function(rv) posterior::draws_of(rv)

# Pointwise held-out log predictive density.
#   marginal = FALSE: condition on the fitted site:year effect (observed cells).
#   marginal = TRUE : integrate over the site:year distribution (new cells), so
#                     a fresh effect is drawn per posterior draw.
elpd_holdout <- function(fit, test, site_year_on, marginal) {
  d <- fit$draws
  bW <- as.numeric(.draws_of(d$bWeight))
  bD <- as.numeric(.draws_of(d$bDiameter))
  bD2 <- as.numeric(.draws_of(d$bDiameter2))
  sW <- as.numeric(.draws_of(d$sWeight))
  sy <- as.numeric(.draws_of(d$sSiteYear))
  bSite <- .draws_of(d$bSite)
  bSiteD <- .draws_of(d$bSiteDiameter)
  bSY <- if (!marginal) .draws_of(d$bSiteYear) else NULL
  ndraws <- length(bW)

  dref <- fit$meta$diameter_ref
  s_idx <- match(as.character(test$site), fit$meta$site_levels)
  y_idx <- if (!marginal) match(as.character(test$year), fit$meta$year_levels) else NULL
  ld <- log(test$diameter) - log(dref)
  lw <- log(test$weight)

  set.seed(7L) # reproducible marginal draws
  lpd <- vapply(seq_len(nrow(test)), function(j) {
    s <- s_idx[j]
    mu <- bW + bSite[, s] + (bD + bSiteD[, s]) * ld[j] + bD2 * ld[j]^2
    if (site_year_on) {
      if (marginal) {
        mu <- mu + stats::rnorm(ndraws, 0, sy)
      } else {
        mu <- mu + bSY[, s, y_idx[j]]
      }
    }
    ll <- stats::dt((lw[j] - mu) / sW, df = 4, log = TRUE) - log(sW)
    .lme(ll)
  }, numeric(1))
  sum(lpd)
}

extract_metrics <- function(fit, true, sim, site_year_on) {
  d <- fit$draws
  sy <- as.numeric(.draws_of(d$sSiteYear))
  ss <- as.numeric(.draws_of(d$sSite))

  # When the term is dropped its SD is structurally 0 (the stored sSiteYear is
  # inert prior noise), so report the effective values.
  if (site_year_on) {
    eff_sy_med <- stats::median(sy)
    q_sy <- stats::quantile(sy, c(0.025, 0.975), names = FALSE)
    covers <- q_sy[1] <= true$sd_site_year && true$sd_site_year <= q_sy[2]
    total_med <- stats::median(sqrt(ss^2 + sy^2))
  } else {
    eff_sy_med <- 0
    covers <- NA
    total_med <- stats::median(ss)
  }

  diag <- fit$diagnostics$summary
  tibble::tibble(
    sd_site_year_med = eff_sy_med,
    sd_site_year_covers = covers,
    sd_site_med = stats::median(ss),
    sd_total_med = total_med,
    elpd = elpd_holdout(fit, sim$test, site_year_on, marginal = FALSE),
    elpd_newyear = elpd_holdout(fit, sim$test_newyear, site_year_on, marginal = TRUE),
    ndivergent = fit$diagnostics$ndivergent,
    max_rhat = max(diag$rhat, na.rm = TRUE),
    min_ess = min(diag$ess_bulk, na.rm = TRUE)
  )
}

# =============================================================================
# Build the run grid
# =============================================================================

grid_a <- expand.grid(
  experiment = "A", design = "sparse",
  true_sd_site_year = cfg$sigmas_a, rate = cfg$rates_a,
  rep = seq_len(cfg$reps_a), stringsAsFactors = FALSE
)
grid_a$site_year_on <- TRUE
grid_a$arm <- ifelse(grid_a$rate <= 1, "loose (equal)", "tight")

grid_b <- expand.grid(
  experiment = "B", design = names(designs),
  true_sd_site_year = cfg$sigmas_b, arm = arms_b$arm,
  rep = seq_len(cfg$reps_b), stringsAsFactors = FALSE
)
grid_b <- dplyr::left_join(grid_b, arms_b, by = "arm")

grid <- dplyr::bind_rows(grid_a, grid_b)
grid$row <- seq_len(nrow(grid))
message(sprintf("Total fits: %d (QUICK = %s)", nrow(grid), QUICK))

# =============================================================================
# Run one grid row
# =============================================================================

run_row <- function(r) {
  design <- designs[[r$design]]
  cells <- build_cells(design)
  rd <- rule_diagnostics(cells)
  true <- c(true_base, list(sd_site_year = r$true_sd_site_year))

  seed_data <- base_seed + r$row
  seed_fit <- base_seed + 100000L + r$row

  res <- tryCatch({
    sim <- simulate_weight_data(cells, true, seed_data)
    fit <- fit_one(sim$train, r$rate, r$site_year_on, cfg, seed_fit)
    cbind(extract_metrics(fit, true, sim, r$site_year_on), error = NA_character_)
  }, error = function(e) {
    tibble::tibble(
      sd_site_year_med = NA_real_, sd_site_year_covers = NA,
      sd_site_med = NA_real_, sd_total_med = NA_real_, elpd = NA_real_,
      elpd_newyear = NA_real_, ndivergent = NA_integer_, max_rhat = NA_real_,
      min_ess = NA_real_, error = conditionMessage(e)
    )
  })

  cbind(
    tibble::tibble(
      experiment = r$experiment, design = r$design,
      true_sd_site_year = r$true_sd_site_year, rate = r$rate,
      site_year_on = r$site_year_on, arm = r$arm, rep = r$rep,
      n_sites_multiyear = rd$n_sites_multiyear, n_cells = rd$n_cells,
      rule_fires = rd$rule_fires
    ),
    res
  )
}

# =============================================================================
# Execute in chunks, writing incrementally
# =============================================================================

raw_rds <- file.path(out_dir, "results-raw.rds")
raw_csv <- file.path(out_dir, "results-raw.csv")

rows <- split(grid, seq_len(nrow(grid)))
chunk_size <- cfg$cores * 4L
chunks <- split(rows, ceiling(seq_along(rows) / chunk_size))

results <- list()
for (ci in seq_along(chunks)) {
  message(sprintf("Chunk %d/%d ...", ci, length(chunks)))
  out <- parallel::mclapply(chunks[[ci]], run_row, mc.cores = cfg$cores)
  results <- c(results, out)
  done <- dplyr::bind_rows(results)
  saveRDS(done, raw_rds)
  utils::write.csv(done, raw_csv, row.names = FALSE)
}
results <- dplyr::bind_rows(results)
message(sprintf("Completed %d fits; %d errored.",
                nrow(results), sum(!is.na(results$error))))

# =============================================================================
# Summary tables
# =============================================================================

summary_a <- results |>
  dplyr::filter(experiment == "A") |>
  dplyr::group_by(true_sd_site_year, rate) |>
  dplyr::summarise(
    n = dplyr::n(),
    bias_sd_site_year = mean(sd_site_year_med - true_sd_site_year, na.rm = TRUE),
    rmse_sd_site_year = sqrt(mean((sd_site_year_med - true_sd_site_year)^2, na.rm = TRUE)),
    coverage_95 = mean(sd_site_year_covers, na.rm = TRUE),
    bias_sd_site = mean(sd_site_med - 0.3, na.rm = TRUE),
    mean_elpd = mean(elpd, na.rm = TRUE),
    mean_divergent = mean(ndivergent, na.rm = TRUE),
    .groups = "drop"
  )
utils::write.csv(summary_a, file.path(out_dir, "summary-calibration.csv"),
                 row.names = FALSE)

true_total <- function(sd_sy) sqrt(0.3^2 + sd_sy^2)
summary_b <- results |>
  dplyr::filter(experiment == "B") |>
  dplyr::group_by(design, true_sd_site_year, arm, rule_fires) |>
  dplyr::summarise(
    n = dplyr::n(),
    med_sd_site_year = stats::median(sd_site_year_med, na.rm = TRUE),
    med_sd_site = stats::median(sd_site_med, na.rm = TRUE),
    med_sd_total = stats::median(sd_total_med, na.rm = TRUE),
    true_total = true_total(dplyr::first(true_sd_site_year)),
    mean_elpd_obs = mean(elpd, na.rm = TRUE),
    mean_elpd_newyear = mean(elpd_newyear, na.rm = TRUE),
    mean_divergent = mean(ndivergent, na.rm = TRUE),
    .groups = "drop"
  )
utils::write.csv(summary_b, file.path(out_dir, "summary-identifiability.csv"),
                 row.names = FALSE)

# =============================================================================
# Plots
# =============================================================================

res_a <- dplyr::filter(results, experiment == "A", is.na(error))
res_b <- dplyr::filter(results, experiment == "B", is.na(error))
res_b$arm <- factor(res_b$arm, levels = arm_levels)
res_b$design <- factor(res_b$design, levels = c("rich", "sparse", "aliased"))

sigma_facet <- function() {
  facet_wrap(~true_sd_site_year, labeller = labeller(
    true_sd_site_year = function(x) paste0("true sigma[s:y] = ", x)
  ))
}
grid_facet <- function() {
  facet_grid(true_sd_site_year ~ design, labeller = labeller(
    true_sd_site_year = function(x) paste0("sigma[s:y] = ", x)
  ))
}

# 1. Calibration (Experiment A)
p1 <- ggplot(res_a, aes(factor(rate), sd_site_year_med)) +
  geom_boxplot(outlier.size = 0.6) +
  geom_hline(aes(yintercept = true_sd_site_year), linetype = "dashed",
             colour = "firebrick") +
  sigma_facet() +
  labs(title = "Recovery of the site:year SD vs prior rate (Exp A)",
       subtitle = "Dashed = truth. All arms include the term (flag on).",
       x = "site:year SD exponential prior rate",
       y = "posterior median site:year SD (one point per rep)")

# 2. Marginal distortion (Experiment A)
p2 <- ggplot(res_a, aes(factor(rate), sd_site_med)) +
  geom_boxplot(outlier.size = 0.6) +
  geom_hline(yintercept = 0.3, linetype = "dashed", colour = "firebrick") +
  sigma_facet() +
  labs(title = "Site SD vs prior rate (Exp A)",
       subtitle = "Dashed = true site SD (0.3).",
       x = "site:year SD exponential prior rate", y = "posterior median site SD")

# 3. Predictive accuracy, observed cells (Experiment A)
res_a_elpd <- res_a |>
  dplyr::group_by(true_sd_site_year, rep) |>
  dplyr::mutate(delta_elpd = elpd - max(elpd, na.rm = TRUE)) |>
  dplyr::ungroup()
p3 <- ggplot(res_a_elpd, aes(factor(rate), delta_elpd)) +
  geom_boxplot(outlier.size = 0.6) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  sigma_facet() +
  labs(title = "Held-out accuracy (observed cells) vs prior rate (Exp A)",
       subtitle = "elpd relative to the best rate per rep (0 = best).",
       x = "site:year SD exponential prior rate", y = "elpd minus per-rep best")

# 4. Total intercept SD recovery across the gradient (Experiment B)
true_lines <- res_b |>
  dplyr::distinct(design, true_sd_site_year) |>
  dplyr::mutate(true_total = true_total(true_sd_site_year))
p4 <- ggplot(res_b, aes(arm, sd_total_med)) +
  geom_boxplot(outlier.size = 0.5) +
  geom_hline(data = true_lines, aes(yintercept = true_total),
             linetype = "dashed", colour = "firebrick") +
  grid_facet() +
  labs(title = "Total intercept SD recovery (Exp B)",
       subtitle = "Dashed = true total intercept SD. Drop = structural flag off.",
       x = "prior arm", y = "posterior median total intercept SD") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

# 5. DECISION plot: new-site-year predictive accuracy (Experiment B)
res_b_newyear <- res_b |>
  dplyr::group_by(design, true_sd_site_year, rep) |>
  dplyr::mutate(delta_elpd_newyear = elpd_newyear - max(elpd_newyear, na.rm = TRUE)) |>
  dplyr::ungroup()
p5 <- ggplot(res_b_newyear, aes(arm, delta_elpd_newyear)) +
  geom_boxplot(outlier.size = 0.5) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  grid_facet() +
  labs(title = "New-site-year predictive accuracy (Exp B): the decision plot",
       subtitle = "Marginal elpd for fresh site-years, relative to best arm per rep (0 = best).",
       x = "prior arm", y = "new-site-year elpd minus per-rep best") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

# 6. Sampler health (Experiment B)
p6 <- ggplot(res_b, aes(arm, ndivergent)) +
  geom_boxplot(outlier.size = 0.5) +
  facet_wrap(~design) +
  labs(title = "Divergences across the gradient (Exp B)",
       x = "prior arm", y = "divergent transitions per fit") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

plots <- list(calibration = p1, marginal_distortion = p2, predictive = p3,
              identifiability = p4, decision_newyear = p5, sampler_health = p6)

for (nm in names(plots)) {
  ggsave(file.path(out_dir, paste0("plot-", nm, ".png")), plots[[nm]],
         width = 9, height = 6, dpi = 150)
}
grDevices::pdf(file.path(out_dir, "plots-all.pdf"), width = 9, height = 6)
for (p in plots) print(p)
grDevices::dev.off()

message("Done. Outputs in ", out_dir)
