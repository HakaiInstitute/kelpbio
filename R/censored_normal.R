# Normal censored below at zero, extras-style: a recorded 0 stands for any
# value at or below zero. `sd` is given per observation.

log_lik_censored_normal <- function(x, mean, sd) {
  ifelse(
    x == 0,
    stats::pnorm(0, mean, sd, log.p = TRUE),
    stats::dnorm(x, mean, sd, log = TRUE)
  )
}

# Deviance residual with `sd` held at its fitted value: the standardised
# residual for x > 0, and for a censored zero, whose saturated likelihood is 1,
# minus the root of minus twice its log probability.
res_censored_normal <- function(x, mean, sd) {
  ifelse(
    x == 0,
    -sqrt(-2 * stats::pnorm(0, mean, sd, log.p = TRUE)),
    (x - mean) / sd
  )
}

ran_censored_normal <- function(n, mean, sd) {
  pmax(0, stats::rnorm(n, mean, sd))
}
