test_that("summarise_predictions reduces the linpred to estimate/lower/upper", {
  grid <- build_by_grid(weight_fit, character(0), values = c(20, 40))
  lp <- .linpred(weight_fit, grid, "average")
  out <- summarise_predictions(
    weight_fit,
    grid,
    lp,
    group_vars = character(0),
    conf_level = 0.95,
    estimate = stats::median,
    sig_fig = 3
  )
  expect_s3_class(out, "kb_predictions")
  expect_true(all(c("estimate", "lower", "upper") %in% names(out)))
  expect_equal(nrow(out), 2L)
  expect_true(all(out$lower <= out$estimate & out$estimate <= out$upper))
})

test_that("the response and predictor names come from the fit, not a constant", {
  # The summariser is shared by every sub-model, so it must carry no knowledge of
  # weight or diameter.
  for (fit in list(weight_fit, weight_macro_fit)) {
    grid <- build_by_grid(fit, character(0), values = c(2, 5))
    out <- summarise_predictions(
      fit,
      grid,
      .linpred(fit, grid, "average"),
      character(0),
      0.95,
      stats::median,
      3
    )
    expect_identical(attr(out, "kb_predictor"), fit$meta$predictor)
    expect_identical(attr(out, "kb_response"), fit$meta$response)
  }
  # and the two species really do differ in the predictor, so the check bites
  expect_false(identical(
    weight_fit$meta$predictor,
    weight_macro_fit$meta$predictor
  ))
})

test_that("summarise_predictions honours conf_level and the curve flag", {
  grid <- build_by_grid(weight_fit, character(0), values = 30)
  lp <- .linpred(weight_fit, grid, "average")
  narrow <- summarise_predictions(
    weight_fit,
    grid,
    lp,
    character(0),
    0.5,
    stats::median,
    6
  )
  wide <- summarise_predictions(
    weight_fit,
    grid,
    lp,
    character(0),
    0.99,
    stats::median,
    6
  )
  expect_lt(narrow$upper - narrow$lower, wide$upper - wide$lower)
  expect_false(attr(narrow, "kb_curve"))
  expect_true(attr(
    summarise_predictions(
      weight_fit,
      grid,
      lp,
      character(0),
      0.95,
      stats::median,
      3,
      curve = TRUE
    ),
    "kb_curve"
  ))
})

test_that("summarise_predictions applies estimate per row, not to the rvar", {
  grid <- build_by_grid(weight_fit, character(0), values = c(20, 40))
  lp <- .linpred(weight_fit, grid, "average")
  out <- summarise_predictions(
    weight_fit,
    grid,
    lp,
    character(0),
    0.95,
    mean,
    6
  )
  # colMeans() rather than repeating the apply() the function itself runs: an
  # independent route to the same number, so the check is not a tautology
  expected <- signif(
    colMeans(posterior::draws_of(.epred(weight_fit, lp))),
    6
  )
  expect_equal(out$estimate, expected)
})
