# Mean expected weight of one site-year's plants, per draw (length D). `sizes`
# is D x n_plants; each plant is a grid row whose size is an rvar, so the weight
# model's own mean is evaluated at every drawn size. The plants share their
# site-year, so they share its effects, including a sampled new level's.
mean_plant_weight <- function(weight, row, sizes, new_levels, representative_site) {
  n <- ncol(sizes)
  plants <- tibble::tibble(
    site = rep(row$site, n),
    year = rep(row$year, n),
    stipes_m2 = rep(row[["stipes_m2"]], n)
  )
  plants[[weight$meta$predictor]] <- posterior::rvar(
    sizes,
    nchains = posterior::nchains(weight$draws)
  )
  expected <- .epred(
    weight,
    .linpred(weight, plants, new_levels, representative_site)
  )
  rowMeans(posterior::draws_of(expected))
}
