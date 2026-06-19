test_that(".vld_ predicates recognise a weight fit", {
  expect_true(.vld_kb_fit(weight_fit))
  expect_true(.vld_kb_fit_weight(weight_fit))
  expect_false(.vld_kb_fit_weight(1))
  expect_false(.vld_kb_fit(1))
})

test_that(".chk_kb_fit_weight passes a fit through invisibly", {
  expect_invisible(.chk_kb_fit_weight(weight_fit))
  expect_identical(.chk_kb_fit_weight(weight_fit), weight_fit)
})

test_that(".chk_kb_fit_weight errors on a non-fit", {
  bad <- 1
  expect_snapshot(error = TRUE, .chk_kb_fit_weight(bad))
})
