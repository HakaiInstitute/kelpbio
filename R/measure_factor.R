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
