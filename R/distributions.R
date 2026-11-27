# Beta deviance residual (shape1/shape2 of stats::dbeta(), extras-style).
#
# With phi = alpha + beta fixed, the saturated mean m solves
#   digamma(m * phi) - digamma((1 - m) * phi) = log(x) - log(1 - x),
# whose left side increases in m, so it is found by bisection on (0, 1). m is
# not exactly x, so taking m = x (as the analysis project's res_beta() does) can
# give a negative deviance. The deviance is zero at
# x0 = plogis(digamma(alpha) - digamma(beta)), so the sign is x - x0, not x - mu.
res_beta <- function(x, alpha, beta) {
  phi <- alpha + beta
  target <- log(x) - log1p(-x)
  lo <- rep_len(0, length(x))
  hi <- rep_len(1, length(x))
  phi <- rep_len(phi, length(x))
  for (i in seq_len(60L)) {
    m <- (lo + hi) / 2
    above <- digamma(m * phi) - digamma((1 - m) * phi) > target
    hi[above] <- m[above]
    lo[!above] <- m[!above]
  }
  m <- (lo + hi) / 2
  ll_sat <- stats::dbeta(x, m * phi, (1 - m) * phi, log = TRUE)
  ll_fit <- stats::dbeta(x, alpha, beta, log = TRUE)
  x0 <- stats::plogis(digamma(alpha) - digamma(beta))
  sign(x - x0) * sqrt(pmax(2 * (ll_sat - ll_fit), 0))
}

ran_beta <- function(n, alpha, beta) {
  stats::rbeta(n, shape1 = alpha, shape2 = beta)
}

# Gamma with a presence hurdle (shape/rate of stats::dgamma(), extras-style): a
# value is 0 with probability 1 - plogis(logit_p), and otherwise Gamma. The
# Bernoulli terms are taken on the log-odds scale, as in
# inst/stan/cover_calibration.stan: extras::log_lik_bern() takes a probability,
# which rounds to 1 past log odds of about 37 and makes log(1 - p) infinite. A
# zero is passed to the Gamma as 1 to keep its terms finite; they are then
# dropped.

log_lik_hurdle_gamma <- function(x, logit_p, shape, rate) {
  present <- x > 0
  ifelse(
    present,
    stats::plogis(logit_p, log.p = TRUE) +
      extras::log_lik_gamma(x + !present, shape, rate),
    stats::plogis(logit_p, lower.tail = FALSE, log.p = TRUE)
  )
}

# The root of the summed Bernoulli and Gamma deviances, signed by the
# difference from the expected value. The saturated Bernoulli log-likelihood
# is 0, so its deviance is -2 times the log probability of the outcome.
res_hurdle_gamma <- function(x, logit_p, shape, rate) {
  present <- x > 0
  dev_bern <- -2 * ifelse(
    present,
    stats::plogis(logit_p, log.p = TRUE),
    stats::plogis(logit_p, lower.tail = FALSE, log.p = TRUE)
  )
  dev <- dev_bern + ifelse(present, extras::dev_gamma(x + !present, shape, rate), 0)
  sign(x - stats::plogis(logit_p) * shape / rate) * sqrt(pmax(dev, 0))
}

ran_hurdle_gamma <- function(n, logit_p, shape, rate) {
  extras::ran_bern(n, stats::plogis(logit_p)) * extras::ran_gamma(n, shape, rate)
}

# Weibull helpers (shape/scale of stats::dweibull(), extras-style).

weibull_scale <- function(mu, shape) {
  mu / gamma(1 + 1 / shape)
}

log_lik_weibull <- function(x, shape, scale) {
  stats::dweibull(x, shape = shape, scale = scale, log = TRUE)
}

# With shape fixed the saturated scale is x, so the deviance is
# 2 * (t^shape - 1 - shape * log(t)) with t = x / scale. It is zero at
# x = scale, not at the mean (below the scale for shape > 1), so the sign is
# x - scale; signing by x - mean would flip observations between the two.
res_weibull <- function(x, shape, scale) {
  t <- x / scale
  dev <- 2 * (t^shape - 1 - shape * log(t))
  sign(x - scale) * sqrt(pmax(dev, 0))
}

ran_weibull <- function(n, shape, scale) {
  stats::rweibull(n, shape = shape, scale = scale)
}
