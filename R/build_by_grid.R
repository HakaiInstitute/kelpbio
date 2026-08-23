# The prediction grid for a `_by` verb: the grouping levels named in `by` crossed
# with the fit's predictor sequence. Either side may be absent, so this covers a
# curve model (weight), a grouped-points model with no continuous predictor
# (density, mean size) and an intercept-only model (wet/dry, carbon).
build_by_grid <- function(fit, by, values = NULL) {
  predictor <- fit$meta[["predictor"]]
  preds <- if (is.null(predictor)) {
    NULL
  } else {
    predictor_grid(fit, predictor, values)
  }
  groups <- by_grid(fit, by)

  out <- if (is.null(groups)) {
    # No grouping: the predictor sequence alone, or a single population row when
    # the model has no predictor either.
    preds %||% tibble::tibble(.rows = 1L)
  } else {
    crossed <- if (is.null(preds)) groups else dplyr::cross_join(groups, preds)
    # Sort by the grouping factors then the predictor, so the row order follows
    # the fit's level order rather than the (arbitrary) row order of fit$data.
    dplyr::arrange(
      crossed,
      dplyr::pick(dplyr::all_of(c(names(groups), predictor)))
    )
  }
  # Add default offset for reporting rate (e.g. area = 1)
  add_offset_default(fit, out)
}

# The predictor sequence, spanning the observed range unless values are supplied.
predictor_grid <- function(fit, predictor, values = NULL) {
  if (is.null(values)) {
    rng <- range(fit$data[[predictor]], na.rm = TRUE)
    values <- seq(rng[1], rng[2], length.out = 30L)
  } else {
    chk::chk_numeric(values)
  }
  out <- tibble::tibble(x = values)
  names(out) <- predictor
  out
}

# The grouping levels to predict at, or NULL when `by` is empty. A single factor
# takes all its fitted levels; site and year together take only the combinations
# actually observed, since the unobserved cells carry no site:year effect.
by_grid <- function(fit, by) {
  if (length(by) == 0) {
    return(NULL)
  }
  site_levels <- fit$meta$site_levels
  year_levels <- fit$meta$year_levels
  if (setequal(by, "site")) {
    tibble::tibble(site = factor(site_levels, levels = site_levels))
  } else if (setequal(by, "year")) {
    tibble::tibble(year = factor(year_levels, levels = year_levels))
  } else {
    fit$data |>
      dplyr::distinct(.data$site, .data$year) |>
      dplyr::mutate(
        site = factor(as.character(.data$site), levels = site_levels),
        year = factor(as.character(.data$year), levels = year_levels)
      )
  }
}
