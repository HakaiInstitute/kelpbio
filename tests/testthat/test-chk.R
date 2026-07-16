test_that(".chk_kb_fit passes a fit through invisibly and errors on a non-fit", {
  expect_invisible(.chk_kb_fit(weight_fit))
  expect_identical(.chk_kb_fit(weight_fit), weight_fit)
  expect_error(.chk_kb_fit(1), "kb_fit")
})

test_that(".chk_kb_fit_weight passes a fit through invisibly", {
  expect_invisible(.chk_kb_fit_weight(weight_fit))
  expect_identical(.chk_kb_fit_weight(weight_fit), weight_fit)
})

test_that(".chk_kb_fit_weight errors on a non-fit", {
  bad <- 1
  expect_snapshot(error = TRUE, .chk_kb_fit_weight(bad))
})

test_that(".chk_new_data_weight_nereo passes valid new_data through invisibly", {
  d <- data.frame(diameter = c(20, 40))
  expect_invisible(.chk_new_data_weight_nereo(d))
  expect_identical(.chk_new_data_weight_nereo(d), d)
})

test_that(".chk_new_data_weight_nereo errors on a non-data-frame or missing diameter", {
  not_df <- 1
  no_diameter <- data.frame(x = 1)
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(not_df))
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(no_diameter))
})
