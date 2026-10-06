test_that(".vld_ predicates recognise a weight fit", {
  expect_true(.vld_kb_fit(weight_fit))
  expect_true(.vld_kb_fit_weight(weight_fit))
  expect_false(.vld_kb_fit_weight(1))
  expect_false(.vld_kb_fit(1))
})

test_that(".vld_representative_site accepts NULL and known site levels", {
  levels <- c("a", "b", "c")
  expect_true(.vld_representative_site(NULL, levels))
  expect_true(.vld_representative_site("a", levels))
  expect_true(.vld_representative_site(c("a", "c"), levels))
  expect_false(.vld_representative_site("z", levels))
  expect_false(.vld_representative_site(c("a", "z"), levels))
  expect_false(.vld_representative_site(character(0), levels))
  expect_false(.vld_representative_site(1, levels))
})

test_that(".vld_new_data_weight_nereo requires a data frame with diameter", {
  expect_true(.vld_new_data_weight_nereo(data.frame(diameter_mm = 30)))
  expect_false(.vld_new_data_weight_nereo(data.frame(x = 1)))
  expect_false(.vld_new_data_weight_nereo(1))
  expect_false(.vld_new_data_weight_nereo(list(diameter_mm = 30)))
})

test_that(".vld_new_data_weight_macro requires a data frame with fronds", {
  expect_true(.vld_new_data_weight_macro(data.frame(fronds = 5)))
  expect_false(.vld_new_data_weight_macro(data.frame(diameter_mm = 30)))
  expect_false(.vld_new_data_weight_macro(1))
  expect_false(.vld_new_data_weight_macro(list(fronds = 5)))
})

test_that(".vld_progress accepts the three modes only", {
  expect_true(.vld_progress("bar"))
  expect_true(.vld_progress("verbose"))
  expect_true(.vld_progress("none"))
  expect_false(.vld_progress("loud"))
  expect_false(.vld_progress(c("bar", "none")))
  expect_false(.vld_progress(NA_character_))
  expect_false(.vld_progress(1))
})

test_that(".vld_progress_dir accepts NULL or an existing directory", {
  d <- withr::local_tempdir()
  expect_true(.vld_progress_dir(NULL))
  expect_true(.vld_progress_dir(d))
  expect_false(.vld_progress_dir(file.path(d, "nope")))
  expect_false(.vld_progress_dir(c(d, d)))
  expect_false(.vld_progress_dir(NA_character_))
  expect_false(.vld_progress_dir(1))
})

test_that(".vld_density accepts non-negative numbers and all-NA", {
  expect_true(.vld_density(c(0, 2.5, NA)))
  expect_true(.vld_density(NA))
  expect_false(.vld_density(c(1, -1)))
  expect_false(.vld_density("1"))
})

test_that(".vld_density_site_year allows one recorded value per site-year", {
  d <- data.frame(site = c("a", "a", "b"), year = "2020", stipes_m2 = c(3, NA, 5))
  expect_true(.vld_density_site_year(d))
  d$stipes_m2 <- c(3, 4, 5)
  expect_false(.vld_density_site_year(d))
})

test_that(".vld_positive_measure and .vld_frond_count check measured values", {
  expect_true(.vld_positive_measure(c(1.5, 30)))
  expect_false(.vld_positive_measure(c(1, 0)))
  expect_false(.vld_positive_measure(c(1, NA)))
  expect_false(.vld_positive_measure("30"))
  expect_true(.vld_frond_count(c(1, 5)))
  expect_false(.vld_frond_count(2.5))
})

test_that(".vld_kb_fit_density recognises a density fit", {
  expect_true(.vld_kb_fit_density(density_nereo_fit))
  expect_true(.vld_kb_fit_density(density_macro_fit))
  expect_false(.vld_kb_fit_density(size_nereo_fit))
  expect_false(.vld_kb_fit_density(1))
})

test_that(".vld_kb_fit_grouped recognises the models with grouping factors", {
  expect_true(.vld_kb_fit_grouped(weight_fit))
  expect_true(.vld_kb_fit_grouped(size_macro_fit))
  expect_true(.vld_kb_fit_grouped(density_nereo_fit))
  expect_false(.vld_kb_fit_grouped(wetdry_nereo_fit))
  expect_false(.vld_kb_fit_grouped(carbon_nereo_fit))
  expect_false(.vld_kb_fit_grouped(1))
})

test_that(".vld_new_data_density requires a data frame with any area positive", {
  expect_true(.vld_new_data_density(data.frame(area_m2 = c(20, 40))))
  expect_true(.vld_new_data_density(data.frame(site = "a")))
  expect_false(.vld_new_data_density(data.frame(area_m2 = 0)))
  expect_false(.vld_new_data_density(data.frame(area_m2 = NA_real_)))
  expect_false(.vld_new_data_density(list(area_m2 = 20)))
})

test_that(".vld_kb_fit_wetdry recognises a wet/dry fit", {
  expect_true(.vld_kb_fit_wetdry(wetdry_nereo_fit))
  expect_false(.vld_kb_fit_wetdry(density_nereo_fit))
  expect_false(.vld_kb_fit_wetdry(1))
})

test_that(".vld_kb_fit_carbon recognises a carbon fit", {
  expect_true(.vld_kb_fit_carbon(carbon_nereo_fit))
  expect_false(.vld_kb_fit_carbon(wetdry_nereo_fit))
})

test_that(".vld_same_species and .vld_same_ndraws compare fits", {
  expect_true(.vld_same_species(list(weight_fit, size_nereo_fit)))
  expect_false(.vld_same_species(list(weight_fit, size_macro_fit)))
  expect_true(.vld_same_ndraws(list(weight_fit, size_nereo_fit)))
  expect_false(.vld_same_ndraws(list(weight_fit, fit_size_sim_nereo)))
})


test_that(".vld_kb_fit_cover_biomass recognises a cover biomass fit", {
  expect_true(.vld_kb_fit_cover_biomass(cover_biomass_nereo_fit))
  expect_false(.vld_kb_fit_cover_biomass(carbon_nereo_fit))
})

test_that(".vld_cover_survey accepts zero canopy within the plot", {
  good <- data.frame(canopy_area_m2 = c(0, 40), plot_area_m2 = 200, tide_height_m = -0.3)
  expect_true(.vld_cover_survey(good))
  expect_false(.vld_cover_survey(transform(good, canopy_area_m2 = 300)))
  expect_false(.vld_cover_survey(transform(good, plot_area_m2 = 0)))
  expect_false(.vld_cover_survey(transform(good, tide_height_m = NA)))
  expect_false(.vld_cover_survey(good[c("canopy_area_m2", "plot_area_m2")]))
})

test_that(".vld_biomass_limits and .vld_biomass_estimate need bracketing limits", {
  good <- data.frame(estimate = 2, lower = 1, upper = 4)
  expect_true(.vld_biomass_limits(good))
  expect_true(.vld_biomass_estimate(good))
  expect_false(.vld_biomass_limits(transform(good, upper = 1)))
  expect_false(.vld_biomass_estimate(transform(good, estimate = 5)))
  expect_false(.vld_biomass_estimate(transform(good, estimate = 0.5)))
  expect_false(.vld_biomass_limits(good["estimate"]))
})

test_that(".vld_plot_biomass needs one valid row per site-year", {
  good <- data.frame(
    site = c("a", "b"),
    year = "2020",
    estimate = 2,
    lower = 1,
    upper = 4
  )
  expect_true(.vld_plot_biomass(good))
  expect_false(.vld_plot_biomass(rbind(good, good[1, ])))
  expect_false(.vld_plot_biomass(transform(good, year = 2020)))
  expect_false(.vld_plot_biomass(good[c("site", "estimate", "lower", "upper")]))
  expect_false(.vld_plot_biomass(transform(good, lower = 3)))
})

test_that(".vld_site_surveys needs canopy, tide, site, and year, and a large enough site", {
  good <- data.frame(site = "a", year = "2020", canopy_area_m2 = 100, tide_height_m = 0.5)
  expect_true(.vld_site_surveys(good))
  expect_true(.vld_site_surveys(transform(good, site_area_m2 = 1e4)))
  expect_false(.vld_site_surveys(transform(good, site_area_m2 = 50)))
  expect_false(.vld_site_surveys(transform(good, canopy_area_m2 = -1)))
  expect_false(.vld_site_surveys(transform(good, site = NA)))
  expect_false(.vld_site_surveys(good[c("site", "year", "canopy_area_m2")]))
  expect_false(.vld_site_surveys(list(good)))
})

test_that(".vld_sum_by accepts NULL or grouping columns of the data", {
  data <- data.frame(region = "north", zone = 1, site = NA_character_)
  expect_true(.vld_sum_by(NULL, data))
  expect_true(.vld_sum_by(character(0), data))
  expect_true(.vld_sum_by("region", data))
  expect_false(.vld_sum_by("zone", data))
  expect_false(.vld_sum_by("site", data))
  expect_false(.vld_sum_by("missing", data))
})
