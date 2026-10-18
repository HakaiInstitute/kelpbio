# Per-draw factor converting wet biomass to the requested measure: 1 for wet,
# the expected dry:wet ratio for dry, and that times the expected carbon
# fraction and `carbon_scale` (1000 for grams of carbon) for carbon.
measure_factor <- function(measure, wetdry, carbon, carbon_scale = 1) {
  switch(
    measure,
    wet = 1,
    dry = population_draws(wetdry),
    carbon = population_draws(wetdry) * population_draws(carbon) * carbon_scale
  )
}
