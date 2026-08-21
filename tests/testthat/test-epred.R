test_that("the internal generic's default aborts for a fit with no method", {
  # The only guard once the public method accepts any kb_fit.
  expect_error(
    .epred(structure(list(), class = c("kb_fit_other", "kb_fit")), 1),
    "no method for a <kb_fit_other>"
  )
})
