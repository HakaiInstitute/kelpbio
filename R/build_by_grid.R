# The grid behind kb_new_data(): `by` levels crossed with the predictor
# sequence; either side may be absent.
build_by_grid <- function(fit, by, values = NULL) {
  predictor <- fit$meta[["predictor"]]
  preds <- if (is.null(predictor)) {
    NULL
  } else {
    predictor_grid(fit, predictor, values)
  }
  groups <- by_grid(fit, by)

  if (is.null(groups)) {
    preds %||% tibble::tibble(.rows = 1L)
  } else {
    crossed <- if (is.null(preds)) groups else dplyr::cross_join(groups, preds)
    # Follow the fit's level order, not the row order of fit$data.
    dplyr::arrange(
      crossed,
      dplyr::pick(dplyr::all_of(c(names(groups), predictor)))
    )
  }
}

# Supplied values are range-checked later, when the grid is predicted at.
predictor_grid <- function(fit, predictor, values = NULL) {
  if (is.null(values)) {
    observed <- fit$data[[predictor]]
    rng <- fit$meta$predictor_range %||% range(observed, na.rm = TRUE)
    values <- seq(rng[1], rng[2], length.out = 30L)
    if (identical(predictor, "fronds")) {
      values <- unique(round(values))
    }
  }
  out <- tibble::tibble(x = values)
  names(out) <- predictor
  out
}

# Site and year together take only observed combinations, since an unobserved
# cell has no estimated site:year effect.
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
