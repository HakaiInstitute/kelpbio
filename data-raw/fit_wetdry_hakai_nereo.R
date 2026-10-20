# Build fit_wetdry_hakai_nereo, a pre-fit Nereocystis wet/dry model on Hakai
# Institute data for the kelpbioshiny demo. Fitted with the default chains and
# draws to data-raw/real/wetdry_hakai_nereo.csv (built by
# data-raw/data_hakai.R). Temporary: moves to kelpbiodata once it exists.
# Reproducibility comes from the sampler `seed`.
#
# Requires the compiled package (run `devtools::install()` first; a Stan change
# is only picked up after install). Re-run whenever the Stan model, the data, or
# the kb_fit object structure changes. Run from the package root:
#   Rscript data-raw/fit_wetdry_hakai_nereo.R

devtools::load_all(quiet = TRUE)

data <- readr::read_csv(
  "data-raw/real/wetdry_hakai_nereo.csv",
  show_col_types = FALSE
)

fit_wetdry_hakai_nereo <- kb_fit_wetdry_nereo(
  data,
  cores = 4L,
  progress = "bar",
  seed = 42L
)

usethis::use_data(fit_wetdry_hakai_nereo, overwrite = TRUE)
