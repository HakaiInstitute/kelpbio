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
