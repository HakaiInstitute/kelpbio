# Zero-truncated gamma-Poisson helpers, extras-style: `lambda` is the
# untruncated mean and `theta > 0` the overdispersion (size = 1 / theta).

# log P(Y = 0) of the untruncated distribution.
log_p0_gamma_pois <- function(lambda, theta) {
  -log1p(lambda * theta) / theta
}

# Truncated mean, lambda / (1 - P(Y = 0)). Uses only Math group generics so it
# works on the rvar that .epred() passes.
mean_gamma_pois_zt <- function(lambda, theta) {
  lambda / -expm1(-log1p(lambda * theta) / theta)
}

log_lik_gamma_pois_zt <- function(x, lambda, theta) {
  stats::dnbinom(x, mu = lambda, size = 1 / theta, log = TRUE) -
    log(-expm1(log_p0_gamma_pois(lambda, theta)))
}

# Inverse-CDF draws: a uniform on (P(Y = 0), 1) through the untruncated
# quantile function. pmax() guards a uniform that rounds onto P(Y = 0).
ran_gamma_pois_zt <- function(n, lambda, theta) {
  lambda <- rep_len(lambda, n)
  theta <- rep_len(theta, n)
  p0 <- exp(log_p0_gamma_pois(lambda, theta))
  u <- stats::runif(n, min = p0, max = 1)
  pmax(stats::qnbinom(u, mu = lambda, size = 1 / theta), 1)
}

# Saturated log-likelihood with theta fixed: the saturated lambda makes the
# truncated mean equal x. That mean increases in lambda and exceeds it, so the
# root lies in (0, x) and is found by bisection. At x = 1 the root is the limit
# lambda -> 0, where P(Y = 1 | Y >= 1) -> 1, so the value is exactly 0.
log_lik_sat_gamma_pois_zt <- function(x, theta, iter = 60L) {
  lo <- rep(0, length(x))
  hi <- as.numeric(x)
  for (i in seq_len(iter)) {
    mid <- (lo + hi) / 2
    below <- mean_gamma_pois_zt(mid, theta) < x
    lo[below] <- mid[below]
    hi[!below] <- mid[!below]
  }
  out <- log_lik_gamma_pois_zt(x, (lo + hi) / 2, theta)
  out[x == 1] <- 0
  out
}

# Signed against the truncated mean, where the deviance is zero. The saturated
# log-likelihood depends only on x and theta, so a scalar theta computes it
# once per distinct count.
res_gamma_pois_zt <- function(x, lambda, theta) {
  if (length(theta) == 1L) {
    ux <- unique(x)
    ll_sat <- log_lik_sat_gamma_pois_zt(ux, theta)[match(x, ux)]
  } else {
    ll_sat <- log_lik_sat_gamma_pois_zt(x, theta)
  }
  dev <- 2 * (ll_sat - log_lik_gamma_pois_zt(x, lambda, theta))
  sign(x - mean_gamma_pois_zt(lambda, theta)) * sqrt(pmax(dev, 0))
}
