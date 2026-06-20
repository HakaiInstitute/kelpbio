# Build data_weight_hakai from the Hakai Nereocystis allometry survey data.
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

data_weight_hakai <- data_submax[c("diameter", "weight", "site", "year")]
data_weight_hakai$site <- droplevels(factor(data_weight_hakai$site))
data_weight_hakai$year <- droplevels(factor(data_weight_hakai$year))
data_weight_hakai <- tibble::as_tibble(data_weight_hakai)

usethis::use_data(data_weight_hakai, overwrite = TRUE)
