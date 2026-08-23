test_that("by_linpred returns the grid, the by axis and its linpred", {
  res <- by_linpred(weight_fit, "site", "average")
  expect_named(res, c("grid", "by", "linpred"))
  expect_identical(res$by, "site")
  expect_s3_class(res$linpred, "rvar")
  expect_length(res$linpred, nrow(res$grid))
})

test_that("by_linpred normalises a NULL grouping", {
  res <- by_linpred(weight_fit, NULL, "average")
  expect_identical(res$by, character(0))
  expect_length(res$linpred, nrow(res$grid))
})

test_that("by_linpred validates the fit and the new_levels axis", {
  expect_error(by_linpred(1, NULL, "average"), "kb_fit")
  expect_error(by_linpred(weight_fit, NULL, "bogus"), "new_levels")
})

test_that("by_linpred reports a rate, because its grid takes the neutral offset", {
  # build_by_grid() gives a generated grid one unit of the offset column, so the
  # offset is log(1) and the summary is per unit of survey effort. Proven on a fit
  # that has an offset at all: for the weight models the column is absent.
  fit <- weight_fit
  fit$meta$offset <- "area"
  res <- by_linpred(fit, "site", "average")

  expect_true(all(res$grid$area == 1))
  expect_equal(
    posterior::draws_of(res$linpred),
    posterior::draws_of(.linpred(fit, res$grid, "average"))
  )
})
