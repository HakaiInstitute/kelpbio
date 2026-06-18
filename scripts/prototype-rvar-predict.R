# Prototype: rvar-based prediction engine for kelpbio (Method A).
#
# Goal: the code that CHANGES PER MODEL is a tiny new_expr-style block; all the
# by/uncertainty/summarise machinery is written once and shared. Built on
# posterior::rvar, so the per-model math reads as scalar arithmetic (the draw
# dimension is hidden) yet stays vectorised over draws (no speed sacrifice).
#
# Run: source("scripts/prototype-rvar-predict.R")

suppressPackageStartupMessages({
  library(posterior)
  library(dplyr)
})

# ================================================================== #
# SHARED ENGINE  (written once; never changes when a model is added)
# ================================================================== #

# Resolve one random-effect contribution under the by/uncertainty rule.
#   mode "observed" -> the estimated per-level effect, indexed to each row
#   mode "marginal" -> a fresh draw from Normal(0, sd) per row (a new level)
#   mode "typical"  -> zero (population-average)
kb_re <- function(mode, n, sd = NULL, effect = NULL, idx = NULL) {
  switch(mode,
    typical  = 0,
    observed = effect[idx],
    marginal = posterior::rvar_rng(rnorm, n, mean = 0, sd = sd)
  )
}

# Build the named list of RE contributions for a model, given its RE spec and
# the requested `by` / `uncertainty`. A factor named in `by` is held at its
# observed level; an omitted factor is drawn (marginal) or zeroed (typical).
kb_resolve_re <- function(rv, new_data, by, uncertainty, re_spec) {
  n <- nrow(new_data)
  out <- list()
  for (nm in names(re_spec)) {
    sp <- re_spec[[nm]]
    observed <- all(sp$group %in% by)
    if (observed) {
      idx <- as.integer(new_data[[sp$group]]) # single-factor; 2D for site:year
      out[[nm]] <- kb_re("observed", n, effect = rv[[sp$effect]], idx = idx)
    } else {
      out[[nm]] <- kb_re(uncertainty, n, sd = rv[[sp$sd]])
    }
  }
  out
}

# Summarise a length-n prediction rvar into kb_predictions columns.
kb_summarise <- function(x, conf_level = 0.95, estimate = median, sig_fig = 3) {
  d <- posterior::draws_of(x) # [ndraws x n]
  a <- (1 - conf_level) / 2
  tibble(
    estimate = signif(apply(d, 2, estimate), sig_fig),
    lower    = signif(apply(d, 2, quantile, a), sig_fig),
    upper    = signif(apply(d, 2, quantile, 1 - a), sig_fig)
  )
}

# The generic predictor: wire new_data + resolved REs through a model's expr.
kb_predict <- function(rv, new_data, expr_fun, re_spec,
                       by = NULL, uncertainty = "marginal",
                       conf_level = 0.95, estimate = median, sig_fig = 3) {
  re <- kb_resolve_re(rv, new_data, by, uncertainty, re_spec)
  pred <- expr_fun(rv, new_data, re) # an rvar of length nrow(new_data)
  bind_cols(new_data, kb_summarise(pred, conf_level, estimate, sig_fig))
}

# ================================================================== #
# PER-MODEL CODE  (the ONLY part that changes per model -- new_expr style)
# ================================================================== #

# Weight model: quadratic log-diameter mean with site intercept, site slope,
# and site:year random effects. This is the whole per-model surface.
re_spec_weight <- list(
  site          = list(sd = "sSite",         effect = "bSite",         group = "site"),
  site_diameter = list(sd = "sSiteDiameter", effect = "bSiteDiameter", group = "site"),
  site_year     = list(sd = "sSiteYear",     effect = "bSiteYear",     group = c("site", "year"))
)

predict_expr_weight <- function(d, nd, re) {
  log_d <- log(nd$diameter) - log(30)
  exp(
    d$bWeight30 +
      d$bDiameter * log_d +
      d$bDiameter2 * log_d^2 +
      re$site +
      re$site_diameter * log_d +
      re$site_year
  )
}

# Size model (lognormal diameter): site intercept only, for the demo.
re_spec_size <- list(
  site = list(sd = "sSizeSite", effect = "bSizeSite", group = "site")
)
predict_expr_size <- function(d, nd, re) {
  exp(d$m0 + re$site) # expected diameter at a site (median scale)
}

# ================================================================== #
# DEMO  (synthetic draws; no MCMC needed -- proves ergonomics + speed)
# ================================================================== #

set.seed(1)
ndraws <- 4000L
nSite <- 5L
rdraw <- function(mu, s, n = 1) posterior::rvar(matrix(rnorm(ndraws * n, mu, s), ndraws, n))

rv <- list(
  bWeight30 = rdraw(log(50), 0.1),
  bDiameter = rdraw(2.6, 0.05),
  bDiameter2 = rdraw(0, 0.05),
  sSite = rdraw(0.4, 0.05), bSite = rdraw(0, 0.4, nSite),
  sSiteDiameter = rdraw(0.3, 0.05), bSiteDiameter = rdraw(0, 0.3, nSite),
  sSiteYear = rdraw(0.3, 0.05), bSiteYear = rdraw(0, 0.3, nSite),
  # size model
  m0 = rdraw(log(30), 0.05),
  sSizeSite = rdraw(0.3, 0.05), bSizeSite = rdraw(0, 0.3, nSite)
)

grid <- tibble(diameter = seq(10, 120, length.out = 40))
grid_site <- tidyr::crossing(diameter = seq(10, 120, length.out = 40), site = factor(1:nSite))

cat("--- population curve, typical vs marginal (by = NULL) ---\n")
typ <- kb_predict(rv, grid, predict_expr_weight, re_spec_weight, by = NULL, uncertainty = "typical")
mar <- kb_predict(rv, grid, predict_expr_weight, re_spec_weight, by = NULL, uncertainty = "marginal")
print(head(bind_rows(typ |> mutate(u = "typical"), mar |> mutate(u = "marginal")), 3))
cat(sprintf("marginal band wider than typical at all grid pts: %s\n",
            all((mar$upper - mar$lower) >= (typ$upper - typ$lower))))

cat("\n--- per-site curves (by = 'site') ---\n")
bysite <- kb_predict(rv, grid_site, predict_expr_weight, re_spec_weight,
                     by = "site", uncertainty = "marginal")
print(head(bysite, 3))

# Cross-model composition: rvar multiplication auto-matches draws.
cat("\n--- biomass per site = E_size[ weight(diameter) ], via rvar ---\n")
biomass_site <- function(rv, site, nPlants = 2000) {
  # draw nPlants diameters from the size model for this site, push through the
  # weight allometry, average -- all rvar, vectorised over draws.
  log_d <- posterior::rvar_rng(rnorm, nPlants,
    mean = rv$m0 + rv$bSizeSite[site], sd = rv$sSizeSite) - log(30)
  w <- exp(rv$bWeight30 + rv$bSite[site] +
             (rv$bDiameter + rv$bSiteDiameter[site]) * log_d +
             rv$bDiameter2 * log_d^2)
  posterior::rvar_mean(w)
}
bio <- do.call(c, lapply(seq_len(nSite), function(s) biomass_site(rv, s)))
print(tibble(site = 1:nSite,
             estimate = signif(median(bio), 3),
             lower = signif(posterior::quantile2(bio, 0.025), 3),
             upper = signif(posterior::quantile2(bio, 0.975), 3)))

# Timing: confirm the engine keeps Method A speed.
tm <- function(f, reps = 7) { f(); t <- numeric(reps); for (i in 1:reps) t[i] <- system.time(f())[["elapsed"]]; median(t) }
cat(sprintf("\ntiming: predict(by=NULL) = %.4f s   predict(by=site) = %.4f s   biomass(5 sites) = %.3f s\n",
            tm(function() kb_predict(rv, grid, predict_expr_weight, re_spec_weight, uncertainty = "marginal")),
            tm(function() kb_predict(rv, grid_site, predict_expr_weight, re_spec_weight, by = "site")),
            tm(function() do.call(c, lapply(seq_len(nSite), function(s) biomass_site(rv, s))), reps = 3)))
