# Mean expected weight of one site-year's plants, per draw (length D). `sizes`
# is D x n_plants. `effects` (length D) is resolved by the caller over every
# site-year at once, so a sampled new level is shared across them, and the
# plants need no site or year.
mean_plant_weight <- function(weight, sizes, effects) {
  n <- ncol(sizes)
  nchains <- posterior::nchains(weight$draws)
  plants <- tibble::tibble(.rows = n)
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
