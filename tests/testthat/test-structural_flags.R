test_that(".density_on reads the recorded flag, missing as FALSE", {
  fit <- list(meta = list(density_on = TRUE))
  expect_true(.density_on(fit))
  fit$meta$density_on <- FALSE
  expect_false(.density_on(fit))
  # Only Nereocystis weight records the flag.
  fit$meta$density_on <- NULL
  expect_false(.density_on(fit))
})

test_that(".floor_on is off for a power-law fit", {
  expect_true(.floor_on(list(meta = list(form = "packard_floor"))))
  expect_false(.floor_on(list(meta = list(form = "power"))))
})

test_that(".site_year_on reads the recorded flag, missing as FALSE", {
  expect_true(.site_year_on(list(meta = list(site_year_on = TRUE))))
  expect_false(.site_year_on(list(meta = list(site_year_on = FALSE))))
  # As for wet/dry and carbon.
  expect_false(.site_year_on(list(meta = list())))
})

test_that("the prediction engine and the model description agree on the flag", {
  # Each reads the flag independently, so a polarity mismatch could slip by.
  s <- weight_nereo_fit$meta$site_levels[1]
  y <- weight_nereo_fit$meta$year_levels[1]
  grid <- data.frame(diameter_mm = 40, site = s, year = y)

  for (flag in list(TRUE, FALSE)) {
    fit <- weight_nereo_fit
    fit$meta["site_year_on"] <- list(flag)

    described <- any(grepl(
      "site_year_effect",
      utils::capture.output(kb_model_describe(fit))
    ))

    off <- weight_nereo_fit
    off$meta$site_year_on <- FALSE
    contributes <- !isTRUE(all.equal(
      as.numeric(posterior::draws_of(.linpred(fit, grid, "average"))),
      as.numeric(posterior::draws_of(.linpred(off, grid, "average")))
    ))

    expect_identical(described, contributes)
  }
})
