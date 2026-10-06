test_that("kb_new_data gives one row per fitted level of by", {
  site <- kb_new_data(size_nereo_fit, by = "site")
  expect_named(site, "site")
  expect_identical(levels(site$site), size_nereo_fit$meta$site_levels)
  expect_equal(nrow(site), length(size_nereo_fit$meta$site_levels))

  year <- kb_new_data(density_macro_fit, by = "year")
  expect_named(year, "year")
  expect_equal(nrow(year), length(density_macro_fit$meta$year_levels))

  sy <- kb_new_data(size_macro_fit, by = c("site", "year"))
  expect_equal(nrow(sy), length(size_macro_fit$meta$site_year_levels))

  pop <- kb_new_data(density_nereo_fit)
  expect_equal(nrow(pop), 1L)
  expect_length(names(pop), 0L)
})

test_that("kb_new_data holds no area column for a density fit", {
  expect_false("area_m2" %in% names(kb_new_data(density_nereo_fit, by = "site")))
})

test_that("a weight grid spans the observed predictor range by default", {
  grid <- kb_new_data(weight_fit)
  expect_named(grid, "diameter_mm")
  expect_equal(nrow(grid), 30L)
  expect_equal(range(grid$diameter_mm), range(weight_fit$data$diameter_mm))
})

test_that("a default frond sequence takes whole numbers", {
  grid <- kb_new_data(weight_macro_fit)
  expect_true(all(grid$fronds == round(grid$fronds)))
  expect_equal(range(grid$fronds), range(weight_macro_fit$data$fronds))
  expect_s3_class(kb_predict_weight(weight_macro_fit, grid), "kb_predictions")
})

test_that("a supplied predictor sequence is used for either species", {
  expect_equal(
    kb_new_data(weight_fit, diameter_mm = c(25, 50, 75))$diameter_mm,
    c(25, 50, 75)
  )
  expect_equal(kb_new_data(weight_macro_fit, fronds = c(2, 5, 10))$fronds, c(2, 5, 10))
})

test_that("a single predictor value gives one row per group", {
  grid <- kb_new_data(weight_fit, by = "site", diameter_mm = 50)
  expect_named(grid, c("site", "diameter_mm"))
  expect_equal(nrow(grid), length(weight_fit$meta$site_levels))
  expect_true(all(grid$diameter_mm == 50))
})

test_that("weight grids are marked as curves and others are not", {
  expect_true(attr(kb_new_data(weight_fit), "kb_curve"))
  expect_false(attr(kb_new_data(size_nereo_fit, by = "site"), "kb_curve"))
})

test_that("kb_new_data rejects a bad by, predictor, or model", {
  expect_error(kb_new_data(size_nereo_fit, by = "month"), "Invalid")
  expect_error(kb_new_data(weight_fit, fronds = c(2, 5)), "diameter_mm")
  expect_error(kb_new_data(weight_macro_fit, diameter_mm = c(20, 40)), "fronds")
  expect_error(kb_new_data(size_nereo_fit, diameter_mm = 30), "no predictor")
  expect_error(kb_new_data(wetdry_nereo_fit), "no grouping factors")
  expect_error(kb_new_data(1), "must be a <kb_fit> object")
})

test_that("a grid predictor far outside the fitted range warns at prediction", {
  grid <- kb_new_data(weight_fit, diameter_mm = c(30, 500))
  expect_warning(kb_predict_weight(weight_fit, grid), "far outside")
})

test_that("site-year curves use each site-year's recorded density", {
  # one site-year at 30 mm equals predicting that site-year with its recorded
  # density supplied explicitly
  curve <- kb_predict_weight(
    weight_fit,
    kb_new_data(weight_fit, by = c("site", "year"), diameter_mm = 30)
  )
  row <- curve[curve$site == "site1" & curve$year == "2019", ]
  recorded <- weight_fit$meta$density_levels[["site1:2019"]]
  explicit <- kb_predict_weight(
    weight_fit,
    data.frame(diameter_mm = 30, site = "site1", year = "2019", stipes_m2 = recorded)
  )
  expect_equal(row$estimate, explicit$estimate)
})
