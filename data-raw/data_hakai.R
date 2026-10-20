# Build the real datasets behind the Hakai Institute and coastwide pre-fit
# models (data-raw/fit_*_hakai_*.R, data-raw/fit_weight_coastwide_nereo.R),
# reshaped to the columns the kelpbio fit functions take, and written to
# data-raw/real/ so the pre-fits rebuild without the analysis project.
#
# The source is the cleaned modelling data of the hakai-kelp-biomass-25 analysis
# project, as fitted there:
#
# - Hakai Nereocystis weight: maximum sub-bulb diameter harvests after the
#   outlier screen (`data_submax`), restricted to day of year > 140 as in
#   analyse-weight-nereo.R.
# - Coastwide Nereocystis weight: the coastwide harvest compilation on the
#   maximum sub-bulb convention (paper/output/data/allometry/data.rds); site is
#   already qualified by programme ("pontier:Second").
# - Hakai Macrocystis weight: plant-level harvests after the outlier screen.
# - Hakai Nereocystis size sample: every maximum sub-bulb diameter record.
# - Hakai wet/dry and carbon: every tissue sample, all months and tissues
#   pooled. Wet and dry masses are recorded in mg and converted to g; carbon
#   samples are already in mg (sample) and µg (carbon).
#
# Temporary: these move to kelpbiodata, with the pre-fits, once it exists.
#
# Run from the package root after re-running the analysis project's manipulate
# scripts:
#   Rscript data-raw/data_hakai.R

analysis <- "~/Analyses/poissonconsulting/hakai-kelp-biomass-25"

read_analysis <- function(...) {
  readRDS(file.path(analysis, ...))
}

write_real <- function(data, name) {
  dir.create("data-raw/real", showWarnings = FALSE)
  readr::write_csv(data, file.path("data-raw/real", paste0(name, ".csv")))
}

weight_hakai_nereo <- read_analysis(
  "output/data/nereo/weight/data_submax.rds"
) |>
  dplyr::filter(doy > 140) |>
  dplyr::transmute(
    diameter_mm = diameter,
    weight_kg = weight,
    site = as.character(site),
    year = as.integer(format(date, "%Y"))
  )

weight_coastwide_nereo <- read_analysis(
  "paper/output/data/allometry/data.rds"
) |>
  dplyr::transmute(
    diameter_mm = diameter,
    weight_kg = weight,
    site = as.character(site),
    year = as.integer(format(date, "%Y")),
    study = as.character(study),
    region = as.character(macroregion)
  )

weight_hakai_macro <- read_analysis("output/data/macro/weight/data.rds") |>
  dplyr::transmute(
    fronds = fronds_1m,
    weight_kg = plant_weight,
    site = as.character(site),
    year = as.integer(format(date, "%Y"))
  )

size_sample_hakai_nereo <- read_analysis("output/data/nereo/size/data.rds") |>
  dplyr::transmute(
    diameter_mm = sbulb_max,
    site = as.character(site),
    year = as.integer(format(date, "%Y"))
  )

reshape_wetdry <- function(data) {
  dplyr::transmute(
    data,
    wet_mass_g = wet_mass / 1000,
    dry_mass_g = dry_mass / 1000,
    site = as.character(site),
    year = as.integer(format(date, "%Y")),
    tissue = as.character(stipe_blade)
  )
}

wetdry_hakai_nereo <- read_analysis("output/data/nereo/wetdry/data.rds") |>
  reshape_wetdry()

wetdry_hakai_macro <- read_analysis("output/data/macro/wetdry/data.rds") |>
  reshape_wetdry()

reshape_carbon <- function(data) {
  dplyr::transmute(
    data,
    sample_mass_mg = weight,
    carbon_mass_ug = carbon,
    site = as.character(site),
    year = as.integer(format(date, "%Y"))
  )
}

carbon_hakai_nereo <- read_analysis("output/data/nereo/carbon/data.rds") |>
  reshape_carbon()

carbon_hakai_macro <- read_analysis("output/data/macro/carbon/data.rds") |>
  reshape_carbon()

write_real(weight_hakai_nereo, "weight_hakai_nereo")
write_real(weight_coastwide_nereo, "weight_coastwide_nereo")
write_real(weight_hakai_macro, "weight_hakai_macro")
write_real(size_sample_hakai_nereo, "size_sample_hakai_nereo")
write_real(wetdry_hakai_nereo, "wetdry_hakai_nereo")
write_real(wetdry_hakai_macro, "wetdry_hakai_macro")
write_real(carbon_hakai_nereo, "carbon_hakai_nereo")
write_real(carbon_hakai_macro, "carbon_hakai_macro")
