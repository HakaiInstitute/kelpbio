# Build fit_weight_coastwide_nereo, a pre-fit Nereocystis weight model on
# coastwide harvest compilation data for the kelpbioshiny demo. Fitted with the
# default chains and draws to data-raw/real/weight_coastwide_nereo.csv (built
# by data-raw/data_hakai.R). Temporary: moves to kelpbiodata once it exists.
# Reproducibility comes from the sampler `seed`.
#
# Requires the compiled package (run `devtools::install()` first; a Stan change
# is only picked up after install). Re-run whenever the Stan model, the data, or
# the kb_fit object structure changes. Run from the package root:
#   Rscript data-raw/fit_weight_coastwide_nereo.R

devtools::load_all(quiet = TRUE)

data <- readr::read_csv(
  "data-raw/real/weight_coastwide_nereo.csv",
  show_col_types = FALSE
)

fit_weight_coastwide_nereo <- kb_fit_weight_nereo(
  data,
  cores = 4L,
  progress = "bar",
  seed = 42L
)

usethis::use_data(fit_weight_coastwide_nereo, overwrite = TRUE)
