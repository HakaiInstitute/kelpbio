# Per-draw factor converting wet biomass to the requested measure: 1 for wet,
# the expected dry:wet ratio for dry, and that times the expected carbon or
# nitrogen fraction and `element_scale` (1000 for grams) for carbon or nitrogen.
measure_factor <- function(measure, wetdry, carbon, nitrogen, element_scale = 1) {
  switch(
    measure,
    wet = 1,
    dry = population_draws(wetdry),
    carbon = population_draws(wetdry) * population_draws(carbon) * element_scale,
    nitrogen = population_draws(wetdry) * population_draws(nitrogen) * element_scale
  )
}

# Expected value of an intercept-only fit, one value per draw.
population_draws <- function(fit) {
  lp <- .linpred(fit, tibble::tibble(.rows = 1L), new_levels = "average")
  as.vector(posterior::draws_of(.epred(fit, lp)))
}

# Response column of a biomass verb, named for its measure and scale. Carbon and
# nitrogen per m^2 are in grams, their totals in kilograms.
derived_response <- function(measure, per_area) {
  if (per_area) {
    c(
      wet = "biomass_kg_m2",
      dry = "dry_biomass_kg_m2",
      carbon = "carbon_biomass_g_m2",
      nitrogen = "nitrogen_biomass_g_m2"
    )[[measure]]
  } else {
    c(
      wet = "biomass_kg",
      dry = "dry_biomass_kg",
      carbon = "carbon_biomass_kg",
      nitrogen = "nitrogen_biomass_kg"
    )[[measure]]
  }
}

# Per-draw sums of the row draws (D x N) within `pool_by` groups (character(0)
# sums all rows), returning the group keys, each row's group, and a D x G
# matrix. With `area` (length N, or D x N), each sum is divided by its group's
# summed area, giving the group's value per unit area. Summing draws, not
# summaries, keeps the limits of a group's total correct.
pool_draws_by <- function(grid, draws, pool_by, area = NULL) {
  keys <- tibble::as_tibble(grid)[pool_by]
  if (length(pool_by)) {
    groups <- dplyr::distinct(keys)
    # Character groups sort alphabetically ignoring case, then by case, the
    # same on every machine; factors keep their level order.
    sort_keys <- lapply(groups, function(x) {
      if (is.character(x)) list(tolower(x), x) else list(x)
    })
    ord <- do.call(order, c(unlist(sort_keys, recursive = FALSE), method = "radix"))
    groups <- groups[ord, , drop = FALSE]
    id <- match(do.call(paste, c(keys, sep = "\r")), do.call(paste, c(groups, sep = "\r")))
  } else {
    groups <- tibble::tibble(.rows = 1L)
    id <- rep(1L, nrow(grid))
  }
  # rowsum() orders by ascending id, which is the order of `groups`.
  sums <- t(rowsum(t(draws), id))
  if (!is.null(area)) {
    if (!is.matrix(area)) {
      area <- matrix(area, nrow = nrow(draws), ncol = length(area), byrow = TRUE)
    }
    sums <- sums / t(rowsum(t(area), id))
  }
  list(groups = groups, id = id, draws = sums)
}

# Total wet biomass (kg) per row, D x N: the bed biomass per m^2 (the
# calibration's mean at a fully covered unit plot at zero tide height, so the
# floor applies over the canopy only) times the tide-corrected canopy, capped at
# `classified_area_m2`. The presence probability is left out: at full cover it
# is 1 for a fit whose data identify the presence slope, and the totals should
# not depend on it where they do not (HakaiInstitute/kelpbio#66).
canopy_biomass_draws <- function(fit, grid, new_levels, representative_site) {
  bed <- grid[intersect(.group_vars(), names(grid))]
  bed$canopy_area_m2 <- 1
  bed$plot_area_m2 <- 1
  bed$canopy_tide_height_m <- 0
  density <- exp(.linpred(fit, bed, new_levels, representative_site))

  canopy <- tide_corrected_canopy(
    grid$canopy_area_m2,
    grid$canopy_tide_height_m,
    fit$draws$tide_height_slope,
    cap = grid$classified_area_m2
  )
  posterior::draws_of(density * canopy)
}
