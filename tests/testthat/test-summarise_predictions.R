test_that("summarise_predictions reduces the linpred to estimate/lower/upper", {
  grid <- build_by_grid(weight_nereo_fit, character(0), values = c(20, 40))
  lp <- .linpred(weight_nereo_fit, grid, "average")
  out <- summarise_predictions(
    weight_nereo_fit,
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
  for (fit in list(weight_nereo_fit, weight_macro_fit)) {
    values <- range(fit$data[[fit$meta$predictor]])
    grid <- build_by_grid(fit, character(0), values = values)
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
  # The species differ in predictor, so the check bites.
  expect_false(identical(
    weight_nereo_fit$meta$predictor,
    weight_macro_fit$meta$predictor
  ))
})

test_that("summarise_predictions honours conf_level and the curve flag", {
  grid <- build_by_grid(weight_nereo_fit, character(0), values = 30)
  lp <- .linpred(weight_nereo_fit, grid, "average")
  narrow <- summarise_predictions(
    weight_nereo_fit,
    grid,
    lp,
    character(0),
    0.5,
    stats::median,
    6
  )
  wide <- summarise_predictions(
    weight_nereo_fit,
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
      weight_nereo_fit,
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

test_that("summarise_draws_rows keeps the draws and applies estimate and sig_fig", {
  grid <- tibble::tibble(site = c("a", "b"))
  draws <- posterior::rvar(matrix(c(1:9 + 0.123456, 10 * (1:9)), ncol = 2))
  out <- summarise_draws_rows(
    grid,
    draws,
    group_vars = "site",
    conf_level = 0.95,
    estimate = max,
    sig_fig = 3,
    curve = FALSE,
    predictor = NULL,
    response = "weight_kg",
    keep_draws = TRUE
  )
  expect_identical(out$weight_kg, draws)
  expect_equal(out$estimate, c(9.12, 90))
  expect_equal(out$lower, signif(unname(posterior::quantile2(draws, 0.025)), 3))
  expect_false("weight_kg" %in% names(summarise_draws_rows(
    grid, draws, "site", 0.95, max, 3,
    curve = FALSE, predictor = NULL, response = "weight_kg"
  )))
})
