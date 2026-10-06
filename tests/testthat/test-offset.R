test_that("a model with no offset contributes zero", {
  # Weight is measured per plant, so there is no survey effort to divide by.
  grid <- tibble::as_tibble(weight_fit$data)
  expect_identical(grid_offset(weight_fit, grid), 0)
  expect_identical(
    grid_offset(weight_macro_fit, tibble::as_tibble(weight_macro_fit$data)),
    0
  )
})

test_that("the offset is the log of the column meta names", {
  fit <- weight_fit
  fit$meta$offset <- "area"
  grid <- tibble::tibble(area = c(1, 10, 100))
  expect_equal(grid_offset(fit, grid), log(c(1, 10, 100)))
})

test_that("an offset is added elementwise over grid rows, not draws", {
  # A length-N vector added to a D x N draws matrix would recycle down columns
  # and silently give the wrong answer, so it is added while the linear predictor
  # is still an rvar.
  fit <- weight_fit
  fit$meta$offset <- "area"
  grid <- tibble::as_tibble(fit$data)
  grid$area <- seq_len(nrow(grid))

  base <- .linpred(fit, grid, "average")
  shifted <- base + grid_offset(fit, grid)

  expect_length(shifted, nrow(grid))
  # each row shifted by its own offset, on every draw
  expect_equal(
    posterior::draws_of(shifted),
    sweep(posterior::draws_of(base), 2L, log(grid$area), "+")
  )
})

test_that("a grid without the offset column takes one unit of it", {
  fit <- weight_fit
  fit$meta$offset <- "area"
  expect_identical(grid_offset(fit, tibble::tibble(site = factor("a"))), 0)
})
