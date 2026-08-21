test_that(".site_year_on reads the flag, treating a missing one as on", {
  on <- structure(list(meta = list(site_year_on = TRUE)), class = "kb_fit")
  off <- structure(list(meta = list(site_year_on = FALSE)), class = "kb_fit")
  legacy <- structure(list(meta = list()), class = "kb_fit")

  expect_true(.site_year_on(on))
  expect_false(.site_year_on(off))
  # Fits built before the flag was recorded always included the effect.
  expect_true(.site_year_on(legacy))
})

test_that("the prediction engine and the model description agree on the flag", {
  # They read the flag independently, so a polarity mismatch would describe a
  # model that is not the one the predictions came from.
  s <- weight_fit$meta$site_levels[1]
  y <- weight_fit$meta$year_levels[1]
  grid <- data.frame(diameter = 40, site = s, year = y)

  for (flag in list(TRUE, FALSE, NULL)) {
    fit <- weight_fit
    fit$meta["site_year_on"] <- list(flag)

    described <- any(grepl(
      "bSiteYear",
      utils::capture.output(kb_model_describe(fit))
    ))

    off <- weight_fit
    off$meta$site_year_on <- FALSE
    contributes <- !isTRUE(all.equal(
      as.numeric(posterior::draws_of(.linpred(fit, grid, "average"))),
      as.numeric(posterior::draws_of(.linpred(off, grid, "average")))
    ))

    expect_identical(described, contributes)
  }
})
