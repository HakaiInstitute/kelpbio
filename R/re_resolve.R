# Random-effect resolvers. They assume independent, mean-zero Gaussian effects
# on the link scale, so "average" is zero: the median group, not the mean.

re_draw <- function(n, sd_rvar) {
  posterior::rvar_rng(stats::rnorm, n, mean = 0, sd = sd_rvar)
}

# One draw per distinct key, so rows naming the same new level share it. An NA
# key (grouping column absent) is no particular level, so each row draws its own.
re_draw_shared <- function(keys, sd_rvar) {
  named <- !is.na(keys)
  group <- match(keys, unique(keys[named]))
  group[!named] <- max(0L, group, na.rm = TRUE) + seq_len(sum(!named))
  draws <- posterior::draws_of(re_draw(max(group), sd_rvar))
  draws[, group, drop = FALSE]
}

re_labels <- function(idx) {
  attr(idx, "labels", exact = TRUE) %||% rep(NA_character_, length(idx))
}

# Unknown rows borrow the per-draw mean of the representative sites if given,
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
  }
  posterior::rvar(out)
}

# An unobserved cell of a fitted site and year has no likelihood term, so its
# draws are prior noise and it is treated as a new level.
# `borrow` gives, per row, the site indices whose cells in that row's year an
# unknown row takes the per-draw mean of (the representative sites observed in
# that year); a row with none follows new_levels.
resolve_re2 <- function(param, i, j, observed, new_levels, sd_rvar, borrow = NULL) {
  known <- !is.na(i) & !is.na(j) & observed
  borrowed <- !known & lengths(borrow %||% vector("list", length(i))) > 0L
  ndraws <- posterior::ndraws(param)
  out <- matrix(0, nrow = ndraws, ncol = length(i))
  if (any(known | borrowed)) {
    param_draws <- posterior::draws_of(param)
    n_site <- dim(param_draws)[2]
    cells <- matrix(param_draws, nrow = ndraws)
    out[, known] <- cells[, i[known] + (j[known] - 1L) * n_site]
    for (r in which(borrowed)) {
      out[, r] <- rowMeans(cells[, borrow[[r]] + (j[r] - 1L) * n_site, drop = FALSE])
    }
  }
  fresh <- !known & !borrowed
  if (any(fresh) && new_levels == "sample") {
    site <- re_labels(i)[fresh]
    year <- re_labels(j)[fresh]
    keys <- ifelse(is.na(site) | is.na(year), NA_character_, site_year_key(site, year))
    out[, fresh] <- re_draw_shared(keys, sd_rvar)
  }
  posterior::rvar(out)
}

rvar_index1 <- function(rv, idx) {
  posterior::rvar(posterior::draws_of(rv)[, idx, drop = FALSE])
}

# Row indices into the fit's levels per grouping factor, plus `rep`. NA marks a
# new level or an omitted factor.
.grid_indices <- function(fit, grid, representative_site = NULL) {
  n <- nrow(grid)
  # Labels let rows naming the same new level share one sampled effect.
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
  # idx$rep <- NULL would drop the element.
  c(idx, list(rep = rep_idx))
}
