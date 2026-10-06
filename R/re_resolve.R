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

# Draws (D x length(keys)) for the unknown rows of one effect, one draw per
# distinct key, so rows naming the same new level share its effect: a new site
# is one site, whichever rows name it. An NA key (the grouping column is absent)
# is no particular level, so each such row draws its own.
re_draw_shared <- function(keys, sd_rvar) {
  named <- !is.na(keys)
  group <- match(keys, unique(keys[named]))
  group[!named] <- max(0L, group, na.rm = TRUE) + seq_len(sum(!named))
  draws <- posterior::draws_of(re_draw(max(group), sd_rvar))
  draws[, group, drop = FALSE]
}

# The level labels of an index from .grid_indices(), NA where the grid omits the
# grouping column; all NA for an index without labels.
re_labels <- function(idx) {
  attr(idx, "labels", exact = TRUE) %||% rep(NA_character_, length(idx))
}

# One-factor random effect per row: known rows take their estimated effect; unknown
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
      out[, !known] <- re_draw_shared(re_labels(idx)[!known], sd_rvar)
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
    # A cell is a level only when both its site and year are named.
    site <- re_labels(i)[!known]
    year <- re_labels(j)[!known]
    keys <- ifelse(is.na(site) | is.na(year), NA_character_, site_year_key(site, year))
    out[, !known] <- re_draw_shared(keys, sd_rvar)
  }
  posterior::rvar(out)
}

rvar_index1 <- function(rv, idx) {
  posterior::rvar(posterior::draws_of(rv)[, idx, drop = FALSE])
}

# Row indices into the fit's factor levels, one integer vector per grouping
# factor plus the representative-site index. NA marks a row the fit cannot
# condition on, either a level it never saw or a factor the grid omits entirely,
# which is exactly what resolve_re1()/resolve_re2() key on. Every .linpred method
# opens with this, so the level matching is defined once rather than per model.
.grid_indices <- function(fit, grid, representative_site = NULL) {
  n <- nrow(grid)
  # Each index carries its level labels, so rows naming the same new level can
  # share one sampled effect (see re_draw_shared()).
  idx <- lapply(.group_vars(), function(nm) {
    labels <- if (nm %in% names(grid)) {
      as.character(grid[[nm]])
    } else {
      rep(NA_character_, n)
    }
    structure(match(labels, .fit_levels(fit, nm)), labels = labels)
  })
  names(idx) <- .group_vars()
  rep_idx <- if (is.null(representative_site)) {
    NULL
  } else {
    match(representative_site, fit$meta$site_levels)
  }
  # c(), not idx$rep <-, which would drop the name when rep_idx is NULL.
  c(idx, list(rep = rep_idx))
}
