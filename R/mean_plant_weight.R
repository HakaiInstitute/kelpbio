# Mean expected weight of one site-year's plants, per draw (length D). `sizes`
# is D x n_plants. `effects` (length D) is resolved by the caller over every
# site-year at once, so a sampled new level is shared across them.
mean_plant_weight <- function(weight, row, sizes, effects) {
  n <- ncol(sizes)
  nchains <- posterior::nchains(weight$draws)
  plants <- tibble::tibble(
    site = rep(row$site, n),
    year = rep(row$year, n),
    stipes_m2 = rep(row[["stipes_m2"]], n)
  )
  plants[[weight$meta$predictor]] <- posterior::rvar(sizes, nchains = nchains)
  plant_effects <- posterior::rvar(
    matrix(effects, nrow = length(effects), ncol = n),
    nchains = nchains
  )
  expected <- .epred(
    weight,
    .linpred(weight, plants, new_levels = "average", effects = plant_effects)
  )
  rowMeans(posterior::draws_of(expected))
}
