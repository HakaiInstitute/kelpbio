# Benchmark: prediction / derived-quantity engine for kelpbio.
#
# Decides which engine kelpbio should use to (i) predict from a fitted model and
# (ii) compose independently-fit sub-models into a derived per-group quantity.
# Engines compared on the SAME raw-rstan fits:
#   A      - posterior::as_draws_matrix() + hand-written vectorised R (raw matrices)
#   B      - Stan generated quantities, run on saved draws via rstan::gqs()
#   C      - mcmcderive::mcmc_derive() with a single vectorised expression
#   A-rvar - posterior::rvar arithmetic (new_expr-style, vectorised over draws);
#            same answer as A, more readable code
#   bbou   - bboutools-style mcmcr stack: newdata::xnew_data grid, mcmc_derive +
#            new_expr per-model prediction, vectorised mcmcr-array biomass
#
# Self-contained: compiles its own tiny Stan programs on tempfiles (no
# devtools::install needed). Run with: source("scripts/benchmark-prediction-methods.R")
#
# Simplifications (sufficient to exercise every capability under test):
#   - Size model is lognormal (not the analysis project's Weibull) so the
#     cross-model target has a closed-form truth to recover.
#   - Grouping is by `site` only; one random intercept per model is enough to
#     exercise typical/marginal and the draw-matched cross-model integration.
#   - Density and the other sub-models are out of scope; two models suffice.

suppressPackageStartupMessages({
  library(rstan)
  library(posterior)
  library(mcmcr)
  library(mcmcderive)
  library(newdata)
  library(dplyr)
})

rstan_options(auto_write = TRUE)
options(mc.cores = 2)
set.seed(2026)

# ------------------------------------------------------------------ #
# 1. Truth + simulation
# ------------------------------------------------------------------ #

nSite <- 5L
n_per <- 80L # enough per-site data that posteriors concentrate near truth
nObs <- nSite * n_per
log30 <- log(30)

true <- list(
  b0 = log(50),
  b1 = 2.6,
  sigmaW = 0.25,
  tauW = 0.4,
  m0 = log(30),
  sigmaS = 0.3,
  tauS = 0.4
)

# Realised random effects are drawn once and treated as the known truth, so the
# per-site closed form below is conditional on them (makes by = "site" testable).
aW_true <- rnorm(nSite, 0, true$tauW)
aS_true <- rnorm(nSite, 0, true$tauS)

site <- rep(seq_len(nSite), each = n_per)
log_d <- rnorm(nObs, true$m0 + aS_true[site], true$sigmaS) # size model
diameter <- exp(log_d)
log_d_c <- log_d - log30
log_weight <- rnorm(
  nObs,
  true$b0 + true$b1 * log_d_c + aW_true[site],
  true$sigmaW
)

# Closed-form truth: expected per-plant weight per site (integrating the size
# distribution and the residual): E[exp(.)] of a normal => + 0.5 * var terms.
truth_site <- exp(
  true$b0 +
    aW_true +
    true$b1 * ((true$m0 + aS_true) - log30) +
    0.5 * (true$b1^2 * true$sigmaS^2 + true$sigmaW^2)
)

# Prediction grid (weight-vs-diameter curve) and its typical-curve truth
# (median per-plant weight at a typical site: RE zeroed, no residual inflation).
nGrid <- 40L
# Build the prediction grid with newdata::xnew_data (the bboutools-style grid
# builder); shared by every method so curves are compared on identical points.
wdat <- data.frame(diameter = diameter, site = factor(site))
grid_df <- xnew_data(wdat, xnew_seq(diameter, length_out = nGrid))
d_grid <- grid_df$diameter
log_d_grid <- log(d_grid) - log30
truth_curve <- exp(true$b0 + true$b1 * log_d_grid)

# ------------------------------------------------------------------ #
# 2. Fit the two sub-models once (shared by all three methods)
# ------------------------------------------------------------------ #

code_weight <- "
data {
  int<lower=0> nObs;
  int<lower=1> nSite;
  array[nObs] int<lower=1, upper=nSite> site;
  vector[nObs] log_d_c;
  vector[nObs] log_weight;
}
parameters {
  real b0; real b1; real<lower=0> sigmaW; real<lower=0> tauW;
  vector[nSite] aW;
}
model {
  b0 ~ normal(0, 5); b1 ~ normal(0, 5);
  sigmaW ~ exponential(1); tauW ~ exponential(1);
  aW ~ normal(0, tauW);
  log_weight ~ normal(b0 + b1 * log_d_c + aW[site], sigmaW);
}
"

code_size <- "
data {
  int<lower=0> nObs;
  int<lower=1> nSite;
  array[nObs] int<lower=1, upper=nSite> site;
  vector[nObs] log_d;
}
parameters {
  real m0; real<lower=0> sigmaS; real<lower=0> tauS;
  vector[nSite] aS;
}
model {
  m0 ~ normal(0, 5);
  sigmaS ~ exponential(1); tauS ~ exponential(1);
  aS ~ normal(0, tauS);
  log_d ~ normal(m0 + aS[site], sigmaS);
}
"

message("Compiling and fitting the two sub-models ...")
modW <- stan_model(model_code = code_weight)
modS <- stan_model(model_code = code_size)

chains <- 2L
iter <- 3000L
warmup <- 1000L # 4000 pooled draws each (ample ESS for stable medians/tails)

fitW <- sampling(
  modW,
  refresh = 0,
  seed = 11,
  chains = chains,
  iter = iter,
  warmup = warmup,
  data = list(
    nObs = nObs,
    nSite = nSite,
    site = site,
    log_d_c = log_d_c,
    log_weight = log_weight
  )
)
fitS <- sampling(
  modS,
  refresh = 0,
  seed = 12,
  chains = chains,
  iter = iter,
  warmup = warmup,
  data = list(nObs = nObs, nSite = nSite, site = site, log_d = log_d)
)

max_rhat <- max(
  summary(fitW)$summary[, "Rhat"],
  summary(fitS)$summary[, "Rhat"],
  na.rm = TRUE
)
if (max_rhat > 1.1) {
  warning("max Rhat = ", round(max_rhat, 3), " (> 1.1)")
}

# ------------------------------------------------------------------ #
# 3. Shared draws (the fairness control: every method reads these fits)
# ------------------------------------------------------------------ #

# A: posterior draws_matrix
dwA <- posterior::as_draws_matrix(fitW)
dsA <- posterior::as_draws_matrix(fitS)
ndraws <- nrow(dwA)
col <- function(d, nm) as.numeric(d[, nm])
# Coerce to a plain base matrix: posterior's draws_matrix does not drop dims on
# `[, s]`, which would make per-site columns [ndraws x 1] arrays (non-conformable).
mcol <- function(d, pat) {
  m <- as.matrix(d[, grep(pat, colnames(d))])
  matrix(as.numeric(m), nrow(m), ncol(m))
}
A <- list(
  b0 = col(dwA, "b0"),
  b1 = col(dwA, "b1"),
  sigmaW = col(dwA, "sigmaW"),
  tauW = col(dwA, "tauW"),
  aW = mcol(dwA, "^aW\\["), # ndraws x nSite
  m0 = col(dsA, "m0"),
  sigmaS = col(dsA, "sigmaS"),
  tauS = col(dsA, "tauS"),
  aS = mcol(dsA, "^aS\\[")
)

# B: plain matrices, lp__ dropped, column-bound (rows are draw-matched)
drop_lp <- function(m) m[, colnames(m) != "lp__", drop = FALSE]
WmatB <- drop_lp(as.matrix(fitW))
SmatB <- drop_lp(as.matrix(fitS))
drawsB <- cbind(WmatB, SmatB)

# C: stanfit -> mcmcr (no as.mcmcr.stanfit; go via coda), drop lp__, bind.
t_convertC <- system.time({
  mrW <- as.mcmcr(rstan::As.mcmc.list(fitW))
  mrS <- as.mcmcr(rstan::As.mcmc.list(fitS))
  mrW <- subset(mrW, pars = setdiff(pars(mrW), "lp__"))
  mrS <- subset(mrS, pars = setdiff(pars(mrS), "lp__"))
  mr <- mcmcr::bind_parameters(mrW, mrS)
})[["elapsed"]]

stopifnot(nrow(drawsB) == ndraws, niters(mrW) * nchains(mrW) == ndraws)

# A-rvar: posterior rvars (new_expr-style engine; the one kelpbio will ship).
t_convertArv <- system.time({
  rvW <- posterior::as_draws_rvars(fitW)
  rvS <- posterior::as_draws_rvars(fitS)
})[["elapsed"]]

# ------------------------------------------------------------------ #
# 4. Compile method B's GQ-only programs (one-time structural cost)
# ------------------------------------------------------------------ #

gq_pred_code <- "
data { int<lower=0> nGrid; vector[nGrid] log_d_grid; }
parameters { real b0; real b1; real<lower=0> tauW; }
generated quantities {
  vector[nGrid] weight_typical;
  vector[nGrid] weight_marginal;
  for (g in 1:nGrid) {
    weight_typical[g]  = exp(b0 + b1 * log_d_grid[g]);
    weight_marginal[g] = exp(b0 + normal_rng(0, tauW) + b1 * log_d_grid[g]);
  }
}
"

gq_bio_code <- "
data { int<lower=1> nSite; int<lower=1> nPlants; real log30; }
parameters {
  real b0; real b1; real<lower=0> sigmaW; vector[nSite] aW;
  real m0; real<lower=0> sigmaS; vector[nSite] aS;
}
generated quantities {
  vector[nSite] biomass;
  for (s in 1:nSite) {
    vector[nPlants] w;
    for (k in 1:nPlants) {
      real logd = normal_rng(m0 + aS[s], sigmaS);
      w[k] = exp(b0 + aW[s] + b1 * (logd - log30) + normal_rng(0, sigmaW));
    }
    biomass[s] = mean(w);
  }
}
"

t_compileB <- system.time({
  gq_pred <- stan_model(model_code = gq_pred_code)
  gq_bio <- stan_model(model_code = gq_bio_code)
})[["elapsed"]]

# ------------------------------------------------------------------ #
# 5. Methods. Each predict_* returns typical/marginal [ndraws x nGrid];
#    each biomass_* returns [ndraws x nSite]. nPlants matched across methods.
# ------------------------------------------------------------------ #

nPlants <- 2000L

# Adding a length-ndraws vector to an [ndraws x k] matrix recycles column-major,
# i.e. adds element i to row i across all columns - exactly the per-draw broadcast.

# ---- Method A: posterior + hand-R ----
predict_A <- function() {
  lp <- A$b0 + outer(A$b1, log_d_grid) # ndraws x nGrid
  list(typical = exp(lp), marginal = exp(lp + rnorm(ndraws, 0, A$tauW)))
}
biomass_A <- function() {
  out <- matrix(NA_real_, ndraws, nSite)
  for (s in seq_len(nSite)) {
    logd <- matrix(
      rnorm(ndraws * nPlants, A$m0 + A$aS[, s], A$sigmaS),
      ndraws,
      nPlants
    )
    eps <- matrix(rnorm(ndraws * nPlants, 0, A$sigmaW), ndraws, nPlants)
    logw <- A$b0 + A$aW[, s] + A$b1 * (logd - log30) + eps
    out[, s] <- rowMeans(exp(logw))
  }
  out
}
# Bonus: A exploiting the closed form (per draw), reported separately.
biomass_A_analytic <- function() {
  exp(
    A$b0 +
      A$aW +
      A$b1 * ((A$m0 + A$aS) - log30) +
      0.5 * (A$b1^2 * A$sigmaS^2 + A$sigmaW^2)
  ) # ndraws x nSite
}

# ---- Method B: Stan generated quantities via gqs ----
predict_B <- function() {
  out <- gqs(
    gq_pred,
    draws = WmatB,
    data = list(nGrid = nGrid, log_d_grid = log_d_grid)
  )
  m <- as.matrix(out)
  list(
    typical = m[, grep("^weight_typical\\[", colnames(m))],
    marginal = m[, grep("^weight_marginal\\[", colnames(m))]
  )
}
biomass_B <- function() {
  out <- gqs(
    gq_bio,
    draws = drawsB,
    data = list(nSite = nSite, nPlants = nPlants, log30 = log30)
  )
  m <- as.matrix(out)
  m[, grep("^biomass\\[", colnames(m))]
}

# ---- Method C: pure mcmcderive, one vectorised expr each ----
mcmcr_mat <- function(x) as.matrix(coda::as.mcmc.list(x))

expr_pred <- "
  typical  <- exp(b0 + b1 * log_d_grid)
  marginal <- exp(b0 + b1 * log_d_grid + rnorm(length(log_d_grid), 0, tauW))
"
predict_C <- function() {
  out <- mcmc_derive(
    mrW,
    expr_pred,
    monitor = "typical|marginal",
    values = list(log_d_grid = log_d_grid),
    silent = TRUE
  )
  m <- mcmcr_mat(out)
  list(
    typical = m[, grep("^typical\\[", colnames(m))],
    marginal = m[, grep("^marginal\\[", colnames(m))]
  )
}

expr_bio <- "
  logd <- rnorm(nPlants * nSite, m0 + aS[site_long], sigmaS)
  w    <- exp(b0 + aW[site_long] + b1 * (logd - log30) + rnorm(nPlants * nSite, 0, sigmaW))
  biomass <- as.vector(tapply(w, site_long, mean))
"
biomass_C <- function() {
  out <- mcmc_derive(
    mr,
    expr_bio,
    monitor = "^biomass$",
    silent = TRUE,
    values = list(
      nPlants = nPlants,
      nSite = nSite,
      log30 = log30,
      site_long = rep(seq_len(nSite), each = nPlants)
    )
  )
  m <- mcmcr_mat(out)
  m[, grep("^biomass\\[", colnames(m))]
}

# ---- Method A-rvar: posterior rvars, new_expr-style + vectorised over draws ----
# Same engine as A, but the per-model math is scalar-looking rvar arithmetic
# (the draw dimension is hidden). This is the form kelpbio will ship.
predict_Arvar <- function() {
  lp <- rvW$b0 + rvW$b1 * log_d_grid # rvar over the grid
  list(
    typical = posterior::draws_of(exp(lp)),
    marginal = posterior::draws_of(exp(
      lp + rvar_rng(rnorm, nGrid, 0, rvW$tauW)
    ))
  )
}
biomass_Arvar <- function() {
  cols <- lapply(seq_len(nSite), function(s) {
    logd <- rvar_rng(rnorm, nPlants, rvS$m0 + rvS$aS[s], rvS$sigmaS) - log30
    w <- exp(
      rvW$b0 +
        rvW$aW[s] +
        rvW$b1 * logd +
        rvar_rng(rnorm, nPlants, 0, rvW$sigmaW)
    )
    rvar_mean(w)
  })
  posterior::draws_of(do.call(c, cols)) # [ndraws x nSite]
}

# ---- Method bbou: bboutools-style mcmcr stack ----
# Mirrors how bboutools is built: per-model prediction via mcmc_derive + a
# new_expr string (the bb_predict_* idiom -- identical to Method C here), but the
# heavy biomass composite via VECTORISED mcmcr-array arithmetic (the bboutools
# `lambda <- sur / (1 - rec)` idiom), NOT mcmc_derive. Grid built with
# newdata::xnew_data (see section 1). This keeps the familiar new_expr surface
# for cheap predictions while keeping array-arithmetic speed on the hot path.
predict_bbou <- predict_C # bboutools predicts per-model with mcmc_derive + new_expr
biomass_bbou <- function() {
  M <- mcmcr_mat(mr) # mcmcr draws -> [ndraws x params] (chains collapsed)
  b0 <- M[, "b0"]
  b1 <- M[, "b1"]
  sW <- M[, "sigmaW"]
  m0 <- M[, "m0"]
  sS <- M[, "sigmaS"]
  aW <- M[, grep("^aW\\[", colnames(M))]
  aS <- M[, grep("^aS\\[", colnames(M))]
  out <- matrix(0, ndraws, nSite)
  for (s in seq_len(nSite)) {
    logd <- matrix(rnorm(ndraws * nPlants, m0 + aS[, s], sS), ndraws, nPlants)
    eps <- matrix(rnorm(ndraws * nPlants, 0, sW), ndraws, nPlants)
    out[, s] <- rowMeans(exp(b0 + aW[, s] + b1 * (logd - log30) + eps))
  }
  out
}

# ------------------------------------------------------------------ #
# 6. Summarise + run each method once for validity
# ------------------------------------------------------------------ #

summ <- function(mat) {
  tibble(
    estimate = apply(mat, 2, median),
    lower = apply(mat, 2, quantile, 0.025),
    upper = apply(mat, 2, quantile, 0.975)
  )
}

pA <- predict_A()
bA <- biomass_A()
bAan <- biomass_A_analytic()
pB <- predict_B()
bB <- biomass_B()
pC <- predict_C()
bC <- biomass_C()
pArv <- predict_Arvar()
bArv <- biomass_Arvar()
pBb <- predict_bbou()
bBb <- biomass_bbou()

bio <- list(
  A = bA,
  B = bB,
  C = bC,
  `A-rvar` = bArv,
  bbou = bBb,
  `A (analytic)` = bAan
)
typ <- list(
  A = pA$typical,
  B = pB$typical,
  C = pC$typical,
  `A-rvar` = pArv$typical,
  bbou = pBb$typical
)
mar <- list(
  A = pA$marginal,
  B = pB$marginal,
  C = pC$marginal,
  `A-rvar` = pArv$marginal,
  bbou = pBb$marginal
)

# ------------------------------------------------------------------ #
# 7. Assertions.
#    HARD gates test ENGINE EQUIVALENCE (the benchmark's purpose): the three
#    engines, reading the same draws, must produce the same answer. Recovery of
#    the known truth is fit-quality dependent (RE shrinkage, finite data), so it
#    is checked by interval COVERAGE (robust) and reported, not hard-failed on a
#    median tolerance.
# ------------------------------------------------------------------ #

med_bio <- sapply(bio, function(m) apply(m, 2, median)) # nSite x method
med_typ <- sapply(typ, function(m) apply(m, 2, median)) # nGrid x method

# -- HARD: the engines agree with each other --
# biomass and marginal carry independent RNG -> agree within MC tolerance;
# typical is deterministic (exp of the linear predictor) -> agree near-exactly.
engines <- c("A", "B", "C", "A-rvar", "bbou")
for (a in engines) {
  for (b in engines) {
    if (a < b) {
      stopifnot(all(abs(med_bio[, a] - med_bio[, b]) / truth_site < 0.05))
      stopifnot(all(abs(med_typ[, a] - med_typ[, b]) / truth_curve < 0.01))
      d_mar <- abs(apply(mar[[a]], 2, median) - apply(mar[[b]], 2, median))
      stopifnot(all(d_mar / truth_curve < 0.10))
    }
  }
}

# -- HARD: marginal interval strictly wider than typical at every grid point --
for (nm in names(typ)) {
  wt <- summ(typ[[nm]])
  wm <- summ(mar[[nm]])
  stopifnot(all((wm$upper - wm$lower) > (wt$upper - wt$lower)))
}

# -- HARD: determinism of the R-side Monte-Carlo (Method A) --
set.seed(99)
m1 <- apply(biomass_A(), 2, median)
set.seed(99)
m2 <- apply(biomass_A(), 2, median)
stopifnot(identical(m1, m2))

# -- REPORTED: recovery of the known truth via 95% CI coverage --
cover_bio <- sapply(bio, function(m) {
  s <- summ(m)
  mean(truth_site >= s$lower & truth_site <= s$upper)
})
cover_typ <- sapply(typ, function(m) {
  s <- summ(m)
  mean(truth_curve >= s$lower & truth_curve <= s$upper)
})

message("Engine-equivalence assertions passed.")

# ------------------------------------------------------------------ #
# 8. Timing (base R; compute isolated from the shared fit)
# ------------------------------------------------------------------ #

time_median <- function(fun, reps = 11L) {
  fun() # untimed warm-up
  t <- numeric(reps)
  for (i in seq_len(reps)) {
    t[i] <- system.time(fun())[["elapsed"]]
  }
  stats::median(t)
}

timing <- tibble(
  method = rep(c("A", "B", "C", "A-rvar", "bbou"), each = 2),
  phase = rep(c("predict", "biomass"), times = 5),
  seconds = c(
    time_median(predict_A),
    time_median(biomass_A),
    time_median(predict_B),
    time_median(biomass_B),
    time_median(predict_C),
    time_median(biomass_C),
    time_median(predict_Arvar),
    time_median(biomass_Arvar),
    time_median(predict_bbou),
    time_median(biomass_bbou)
  )
)

# One-time structural costs (NOT steady-state compute): in production B's GQ
# model is precompiled into the package binary; C's conversion is per-fit.
structural <- tibble(
  method = c("B (GQ compile)", "C (mcmcr convert)", "A-rvar (rvar convert)"),
  phase = "setup (one-time)",
  seconds = c(t_compileB, t_convertC, t_convertArv)
)

# ------------------------------------------------------------------ #
# 9. Reporting (printed tables)
# ------------------------------------------------------------------ #

recovery <- bind_rows(
  bind_rows(lapply(names(bio), function(nm) {
    summ(bio[[nm]]) |>
      mutate(method = nm, quantity = "biomass (per site)", truth = truth_site)
  })),
  bind_rows(lapply(names(typ), function(nm) {
    summ(typ[[nm]]) |>
      mutate(method = nm, quantity = "typical curve", truth = truth_curve)
  }))
) |>
  mutate(in_CI = truth >= lower & truth <= upper)

cat("\n--- Runtime (median wall-clock, seconds) ---\n")
print(timing)
cat("\n--- One-time structural costs (seconds) ---\n")
print(structural)
cat("\n--- Recovery (per-site biomass) ---\n")
print(
  recovery |>
    filter(quantity == "biomass (per site)") |>
    mutate(across(c(estimate, lower, upper, truth), ~ signif(.x, 3)))
)
cat("\n--- Recovery: truth in 95% CI (coverage by engine) ---\n")
print(tibble(
  method = names(cover_bio),
  biomass_coverage = unname(cover_bio),
  typical_curve_coverage = unname(cover_typ[match(
    names(cover_bio),
    names(cover_typ)
  )])
))

message("Benchmark complete.")
