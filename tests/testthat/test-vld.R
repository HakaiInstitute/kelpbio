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
  expect_true(.vld_new_data_weight_nereo(data.frame(diameter = 30)))
  expect_false(.vld_new_data_weight_nereo(data.frame(x = 1)))
  expect_false(.vld_new_data_weight_nereo(1))
  expect_false(.vld_new_data_weight_nereo(list(diameter = 30)))
})

test_that(".vld_new_data_weight_macro requires a data frame with fronds", {
  expect_true(.vld_new_data_weight_macro(data.frame(fronds = 5)))
  expect_false(.vld_new_data_weight_macro(data.frame(diameter = 30)))
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

test_that(".vld_observed_data is TRUE only for a fit with rows", {
  fit0 <- weight_fit
  fit0$data <- fit0$data[0, ]
  expect_true(.vld_observed_data(weight_fit))
  expect_false(.vld_observed_data(fit0))
})
