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
