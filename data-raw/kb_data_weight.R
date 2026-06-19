# Build kb_data_weight from the Hakai Nereocystis allometry survey data.
#
# Source: the prepared weight dataset from the analysis project
# (hakai-kelp-biomass-25), `data_submax`, which already carries the analysis
# cleaning (Hakai-only, max sub-bulb measurements, completeness, outlier
# removal). No day-of-year filter is applied here. Columns are already
# snake_case (diameter mm, weight kg, site, year).
#
# This script reads a machine-local path in the analysis project and is run by
# the package maintainer, not by users.

src <- "~/Analyses/poissonconsulting/hakai-kelp-biomass-25/output/data/nereo/weight/data_submax.rds"
data_submax <- readRDS(path.expand(src))

kb_data_weight <- data_submax[c("diameter", "weight", "site", "year")]
kb_data_weight$site <- droplevels(factor(kb_data_weight$site))
kb_data_weight$year <- droplevels(factor(kb_data_weight$year))
kb_data_weight <- tibble::as_tibble(kb_data_weight)

usethis::use_data(kb_data_weight, overwrite = TRUE)
