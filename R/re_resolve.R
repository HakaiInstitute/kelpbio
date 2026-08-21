# Random-effect resolvers, shared by every model's .linpred. They assume the
# effects are independent, mean-zero, Gaussian and additive on the link scale, so
# "average" means zero -- the median group, not the mean. A model with correlated
# or non-Gaussian effects needs its own.

# Draw fresh random effects for n new/unknown levels from their estimated
# distribution N(0, sd_rvar). Only the "sample" mode reaches here; the "average"
# mode leaves those rows at zero in the caller (no draw needed).
re_draw <- function(n, sd_rvar) {
  posterior::rvar_rng(stats::rnorm, n, mean = 0, sd = sd_rvar)
}

# Site intercept/slope per row: known rows take their estimated effect; unknown
# rows borrow the per-draw mean of the representative sites (rep_idx) if given,
# else follow new_levels.
resolve_re1 <- function(param, idx, new_levels, sd_rvar, rep_idx = NULL) {
  known <- !is.na(idx)
  if (all(known)) {
    return(rvar_index1(param, idx))
  }
  n <- length(idx)
  param_draws <- posterior::draws_of(param)
  ndraws <- nrow(param_draws)
  out <- matrix(0, nrow = ndraws, ncol = n)
  if (any(known)) {
    out[, known] <- param_draws[, idx[known], drop = FALSE]
  }
  if (!all(known)) {
    if (!is.null(rep_idx)) {
      out[, !known] <- rowMeans(param_draws[, rep_idx, drop = FALSE])
    } else if (new_levels == "sample") {
      out[, !known] <- posterior::draws_of(re_draw(sum(!known), sd_rvar))
    }
    # new_levels == "average" leaves unknown columns at zero.
  }
  posterior::rvar(out)
}

# site:year: conditioned only where both site and year are known, else new_levels.
resolve_re2 <- function(param, i, j, new_levels, sd_rvar) {
  known <- !is.na(i) & !is.na(j)
  n <- length(i)
  ndraws <- posterior::ndraws(param)
  out <- matrix(0, nrow = ndraws, ncol = n)
  if (any(known)) {
    param_draws <- posterior::draws_of(param)
    kk <- which(known)
    out[, kk] <- vapply(
      kk,
      function(r) param_draws[, i[r], j[r]],
      numeric(ndraws)
    )
  }
  if (!all(known) && new_levels == "sample") {
    out[, !known] <- posterior::draws_of(re_draw(sum(!known), sd_rvar))
  }
  posterior::rvar(out)
}

rvar_index1 <- function(rv, idx) {
  posterior::rvar(posterior::draws_of(rv)[, idx, drop = FALSE])
}
