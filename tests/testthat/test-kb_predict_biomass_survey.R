survey_nereo <- function() {
  subset(data_survey_sim_nereo, as.integer(site) <= 4)
}

test_that("tallied surveys give one row each, plants times mean weight per m2", {
  withr::local_seed(1)
  survey <- survey_nereo()
  p <- kb_predict_biomass_survey(weight_nereo_fit, size_nereo_fit, survey, progress = "none")
  expect_s3_class(p, "kb_predictions")
  expect_equal(nrow(p), nrow(survey))
  expect_identical(p$year, date_year(survey$date))
  expect_true(all(c("weight_support", "size_support", "biomass_kg_m2") %in% names(p)))
  expect_identical(attr(p, "kb_response"), "biomass_kg_m2")

  withr::local_seed(1)
  groups <- tibble::tibble(site = as.character(survey$site), year = date_year(survey$date))
  first <- !duplicated(paste(groups$site, groups$year))
  mean_weight <- mean_weight_draws(
    weight_nereo_fit, size_nereo_fit, groups[first, ],
    new_levels = "sample", representative_site = NULL,
    n_plants = 100L, progress = "none", progress_dir = NULL
  )
  i <- match(paste(groups$site, groups$year), paste(groups$site, groups$year)[first])
  expected <- sweep(mean_weight[, i, drop = FALSE], 2, survey$plants / survey$survey_area_m2, "*")
  expect_equal(posterior::draws_of(p$biomass_kg_m2), expected, ignore_attr = TRUE)
})

test_that("a tallied survey with no plants has zero biomass", {
  p <- kb_predict_biomass_survey(
    weight_nereo_fit, size_nereo_fit, data_survey_sim_nereo,
    new_levels = "average", progress = "none"
  )
  zero <- data_survey_sim_nereo$plants == 0
  expect_true(any(zero))
  expect_true(all(posterior::draws_of(p$biomass_kg_m2)[, zero] == 0))
})

test_that("census surveys sum each plant's expected weight, half for a partial plant", {
  survey <- tibble::tibble(
    site = "seal_ledge", plot_id = c("1", "2"), date = as.Date("2019-08-11"),
    survey_area_m2 = c(100, 50)
  )
  plants <- tibble::tibble(
    site = "seal_ledge", plot_id = "1", date = as.Date("2019-08-11"),
    fronds = c(4, 10), partial = c(FALSE, TRUE)
  )
  expect_snapshot(
    p <- kb_predict_biomass_survey(
      weight_macro_fit, plants, survey,
      per_area = FALSE, new_levels = "average"
    )
  )
  expected <- posterior_epred(
    weight_macro_fit,
    data.frame(site = "seal_ledge", year = "2019", fronds = c(4, 10)),
    new_levels = "average"
  )
  expect_equal(
    posterior::draws_of(p$biomass_kg)[, 1],
    expected[, 1] + 0.5 * expected[, 2],
    ignore_attr = TRUE
  )
  expect_true(all(posterior::draws_of(p$biomass_kg)[, 2] == 0))
  expect_false("size_support" %in% names(p))
})

test_that("per_area divides by the area searched", {
  withr::local_seed(1)
  per_m2 <- kb_predict_biomass_survey(
    weight_macro_fit, data_plants_sim_macro, data_survey_sim_macro,
    progress = "none"
  )
  withr::local_seed(1)
  total <- kb_predict_biomass_survey(
    weight_macro_fit, data_plants_sim_macro, data_survey_sim_macro,
    per_area = FALSE, progress = "none"
  )
  expect_equal(
    posterior::draws_of(total$biomass_kg),
    sweep(posterior::draws_of(per_m2$biomass_kg_m2), 2, data_survey_sim_macro$survey_area_m2, "*"),
    ignore_attr = TRUE
  )
})

test_that("sum_by pools surveys as total kg over total area", {
  withr::local_seed(1)
  rows <- kb_predict_biomass_survey(
    weight_macro_fit, data_plants_sim_macro, data_survey_sim_macro,
    per_area = FALSE, progress = "none"
  )
  withr::local_seed(1)
  pooled <- kb_predict_biomass_survey(
    weight_macro_fit, data_plants_sim_macro, data_survey_sim_macro,
    sum_by = c("site", "year"), progress = "none"
  )
  expect_named(pooled, c("site", "year", "biomass_kg_m2", "estimate", "lower", "upper"))
  key <- paste(rows$site, rows$year)
  k <- key[1]
  draws <- posterior::draws_of(rows$biomass_kg)[, key == k, drop = FALSE]
  area <- sum(data_survey_sim_macro$survey_area_m2[key == k])
  expect_equal(
    posterior::draws_of(pooled$biomass_kg_m2)[, paste(pooled$site, pooled$year) == k],
    rowSums(draws) / area,
    ignore_attr = TRUE
  )
})

test_that("invalid and mismatched inputs error", {
  expect_snapshot(
    kb_predict_biomass_survey(
      weight_macro_fit, data_plants_sim_macro, data_survey_sim_macro, n_plants = 10
    ),
    error = TRUE
  )
  expect_snapshot(
    kb_predict_biomass_survey(weight_nereo_fit, data_plants_sim_macro, data_survey_sim_macro),
    error = TRUE
  )
  expect_error(
    kb_predict_biomass_survey(weight_nereo_fit, size_nereo_fit, data_survey_sim_macro),
    "plants"
  )
  expect_error(
    kb_predict_biomass_survey(
      weight_macro_fit, data_plants_sim_macro, data_survey_sim_macro, measure = "dry"
    ),
    "wetdry"
  )
  expect_error(
    kb_predict_biomass_survey(
      weight_nereo_fit, size_nereo_fit, data_survey_sim_nereo, sum_by = "zone"
    ),
    "zone"
  )
})
