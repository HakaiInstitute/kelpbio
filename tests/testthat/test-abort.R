test_that(".fit_constructors reads the registered methods rather than a fixed list", {
  constructors <- .fit_constructors("kb_predict_weight")
  expect_setequal(
    constructors,
    c("kb_fit_weight_nereo", "kb_fit_weight_macro")
  )
  # Every name returned is an exported function that really has a method for the
  # generic, so adding a sub-model updates the hint without touching this code.
  for (constructor in constructors) {
    expect_true(constructor %in% getNamespaceExports(asNamespace("kelpbio")))
    expect_false(is.null(
      utils::getS3method("kb_predict_weight", constructor, optional = TRUE)
    ))
  }
})

test_that(".fit_constructors is empty for a generic that takes any fit", {
  # kb_fit is a parent class, not a constructor, so there is nothing to name.
  expect_length(.fit_constructors("kb_stancode"), 0)
  expect_length(.fit_constructors("samples"), 0)
})

test_that(".abort_no_method names the generic, the class, and the constructors", {
  fake <- structure(list(), class = c("kb_fit_weight_other", "kb_fit_weight"))
  expect_snapshot(
    error = TRUE,
    .abort_no_method("kb_predict_weight", fake)
  )
})

test_that(".abort_no_method falls back to the name pattern when no constructor applies", {
  expect_snapshot(
    error = TRUE,
    .abort_no_method("kb_stancode", structure(list(), class = "kb_fit_other"))
  )
})

test_that(".abort_no_method always aborts", {
  expect_error(.abort_no_method("kb_stancode", weight_fit))
})

test_that("a public verb on a fit with no methods aborts rather than returning", {
  fake <- structure(
    list(data = data.frame(weight = 1), meta = list()),
    class = c("kb_fit_other", "kb_fit")
  )
  expect_error(log_lik(fake), "no method for a <kb_fit_other>")
  expect_error(residuals(fake), "no method for a <kb_fit_other>")
  expect_error(fitted(fake), "no method for a <kb_fit_other>")
  expect_error(augment(fake), "no method for a <kb_fit_other>")
})

test_that("the internal-generic form names no generic, argument or constructor", {
  expect_snapshot(
    error = TRUE,
    .log_lik(structure(list(), class = c("kb_fit_other", "kb_fit")), 1)
  )
})
