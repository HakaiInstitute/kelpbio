# Zero-truncated negative binomial (gamma-Poisson) helpers, in the extras
# parameterisation: `lambda` is the mean of the untruncated distribution and
# `theta` the overdispersion (variance lambda + theta * lambda^2, so
# stats::dnbinom(size = 1 / theta)). `theta` must be positive. Named as extras
# functions would be, so a later move to extras is a namespace swap.

# log P(Y = 0) of the untruncated distribution.
log_p0_gamma_pois <- function(lambda, theta) {
  -log1p(lambda * theta) / theta
}

# Mean of the truncated distribution, lambda / (1 - P(Y = 0)). Written with
# functions that also work on a posterior rvar (log1p and expm1 are Math group
# generics), so .epred() can pass either an rvar or a draws matrix.
mean_gamma_pois_zt <- function(lambda, theta) {
  lambda / -expm1(-log1p(lambda * theta) / theta)
}

log_lik_gamma_pois_zt <- function(x, lambda, theta) {
  stats::dnbinom(x, mu = lambda, size = 1 / theta, log = TRUE) -
    log(-expm1(log_p0_gamma_pois(lambda, theta)))
}

# Inverse-CDF draws from the truncated distribution: a uniform on
# (P(Y = 0), 1) mapped through the untruncated quantile function. pmax() guards
# a uniform that rounds onto P(Y = 0).
ran_gamma_pois_zt <- function(n, lambda, theta) {
  lambda <- rep_len(lambda, n)
  theta <- rep_len(theta, n)
  p0 <- exp(log_p0_gamma_pois(lambda, theta))
  u <- stats::runif(n, min = p0, max = 1)
  pmax(stats::qnbinom(u, mu = lambda, size = 1 / theta), 1)
}

# Saturated log-likelihood for each count, with theta fixed. Setting the score
# to zero gives mean_gamma_pois_zt(lambda, theta) = x: the saturated lambda
# makes the truncated mean equal the count. The truncated mean increases in
# lambda and exceeds it, so the root lies in (0, x) and is found by vectorised
# bisection. At x = 1 the root is at the limit lambda -> 0, where
# P(Y = 1 | Y >= 1) -> 1, so the saturated log-likelihood is exactly 0.
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

# Deviance residual. The deviance is zero where the count equals the truncated
# mean, so the residual is signed against the truncated mean. The saturated
# log-likelihood depends only on the count and theta, so for a scalar theta (one
# draw) it is computed once per distinct count.
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
