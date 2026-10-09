# ---- Nereocystis -------------------------------------------------------------

test_that(".linpred returns a log-scale rvar aligned to the grid (nereo)", {
  grid <- data.frame(diameter_mm = c(20, 40, 60))
  lp <- .linpred(weight_nereo_fit, grid, new_levels = "average")
  expect_s3_class(lp, "rvar")
  expect_length(lp, 3L)
  expect_equal(posterior::ndraws(lp), posterior::ndraws(weight_nereo_fit$draws))
})

test_that("conditioning follows the grid columns (nereo)", {
  site1 <- weight_nereo_fit$meta$site_levels[1]
  bare <- data.frame(diameter_mm = c(30, 30))
  with_site <- data.frame(diameter_mm = c(30, 30), site = site1)

  lp_avg <- posterior::draws_of(.linpred(
    weight_nereo_fit,
    bare,
    "average"
  ))
  lp_site <- posterior::draws_of(.linpred(
    weight_nereo_fit,
    with_site,
    "average"
  ))
  expect_false(isTRUE(all.equal(as.numeric(lp_avg), as.numeric(lp_site))))
})

test_that("per-row resolution: known rows conditioned, new rows drawn (nereo)", {
  site1 <- weight_nereo_fit$meta$site_levels[1]
  grid <- data.frame(diameter_mm = c(30, 30), site = c(site1, "brand_new_site"))
  expect_no_error(.linpred(
    weight_nereo_fit,
    grid,
    new_levels = "sample"
  ))

  # Under "average" the known row matches a single-site call and the new row the
  # typical curve.
  lp_avg <- posterior::draws_of(.linpred(
    weight_nereo_fit,
    grid,
    "average"
  ))
  lp_known <- posterior::draws_of(
    .linpred(
      weight_nereo_fit,
      data.frame(diameter_mm = 30, site = site1),
      "average"
    )
  )
  lp_typical <- posterior::draws_of(
    .linpred(weight_nereo_fit, data.frame(diameter_mm = 30), "average")
  )
  expect_equal(lp_avg[, 1], lp_known[, 1])
  expect_equal(lp_avg[, 2], lp_typical[, 1])
})

test_that("sample widens vs average when a factor is omitted (nereo)", {
  withr::local_seed(1) # the "sample" path draws random effects; pin them
  grid <- data.frame(diameter_mm = c(20, 40, 60))
  sd_avg <- apply(
    posterior::draws_of(.linpred(weight_nereo_fit, grid, "average")),
    2,
    stats::sd
  )
  sd_smp <- apply(
    posterior::draws_of(.linpred(weight_nereo_fit, grid, "sample")),
    2,
    stats::sd
  )
  expect_true(all(sd_smp >= sd_avg))
})

test_that("a dropped site:year effect contributes nothing to the linear predictor", {
  on <- weight_nereo_fit
  on$meta$site_year_on <- TRUE
  off <- weight_nereo_fit
  off$meta$site_year_on <- FALSE
  s <- weight_nereo_fit$meta$site_levels[1]
  y <- weight_nereo_fit$meta$year_levels[1]
  grid <- data.frame(diameter_mm = 40, site = s, year = y)

  e_on <- exp(as.numeric(posterior::draws_of(.linpred(on, grid, "average"))))
  e_off <- exp(as.numeric(posterior::draws_of(.linpred(off, grid, "average"))))

  expect_false(isTRUE(all.equal(e_on, e_off)))
  # site:year acts on log(alpha), so the difference is site_year_effect[s, y] on
  # the log of the weight above the floor.
  floor <- as.numeric(posterior::draws_of(weight_nereo_fit$draws$weight_floor))
  si <- match(s, weight_nereo_fit$meta$site_levels)
  yi <- match(y, weight_nereo_fit$meta$year_levels)
  bsy <- posterior::draws_of(weight_nereo_fit$draws$site_year_effect)[, si, yi]
  expect_equal(log(e_on - floor) - log(e_off - floor), as.numeric(bsy))
})

test_that("a fitted site and year never observed together take no site:year effect under average", {
  fit <- size_nereo_fit
  s <- fit$meta$site_levels[1]
  y <- fit$meta$year_levels[1]
  fit$meta$site_year_levels <- setdiff(fit$meta$site_year_levels, site_year_key(s, y))
  grid <- data.frame(site = s, year = y)

  got <- posterior::draws_of(.linpred(fit, grid, "average"))
  draws <- fit$draws
  expected <- posterior::draws_of(
    draws$intercept + draws$site_effect[1] + draws$year_effect[1]
  )
  expect_equal(as.vector(got), as.vector(expected))
})

test_that("a macro fit gets the Macrocystis mean, not the Nereocystis one", {
  # Random effects zeroed: linear in log-fronds, no quadratic, no site slope.
  grid <- data.frame(fronds = c(2, 5, 10))
  draws <- weight_macro_fit$draws
  log_fc <- log(grid$fronds) - log(weight_macro_fit$meta$predictor_ref)
  expect_equal(
    posterior::draws_of(.linpred(weight_macro_fit, grid, "average")),
    posterior::draws_of(draws$intercept + draws$fronds_slope * log_fc),
    ignore_attr = TRUE
  )
})

test_that("a known year contributes its estimated year_effect main effect (macro)", {
  y <- weight_macro_fit$meta$year_levels[1]
  grid_year <- data.frame(fronds = 5, year = y)
  grid_bare <- data.frame(fronds = 5)
  diff <- posterior::draws_of(
    .linpred(weight_macro_fit, grid_year, "average")
  ) -
    posterior::draws_of(
      .linpred(weight_macro_fit, grid_bare, "average")
    )
  yi <- match(y, weight_macro_fit$meta$year_levels)
  byear <- posterior::draws_of(weight_macro_fit$draws$year_effect)[, yi]
  expect_equal(as.numeric(diff), as.numeric(byear))
})

test_that("data_linpred resolves NULL new_data to the observed rows", {
  res <- data_linpred(weight_nereo_fit, NULL, "average")
  expect_named(res, c("grid", "group_vars", "linpred", "curve"))
  expect_equal(nrow(res$grid), nrow(weight_nereo_fit$data))
  expect_equal(res$group_vars, c("site", "year"))
  expect_equal(
    posterior::draws_of(res$linpred),
    posterior::draws_of(.linpred_obs(weight_nereo_fit))
  )
})

test_that("data_linpred checks new_data and new_levels before computing", {
  expect_error(
    data_linpred(weight_nereo_fit, data.frame(fronds = 5), "average"),
    "diameter_mm"
  )
  expect_error(
    data_linpred(weight_nereo_fit, data.frame(diameter_mm = 30), "bogus"),
    class = "rlang_error"
  )
  res <- data_linpred(weight_nereo_fit, data.frame(diameter_mm = 30), "average")
  expect_equal(res$group_vars, character(0))
})

test_that("data_linpred rejects empty new_data and missing site or year", {
  expect_error(
    data_linpred(weight_nereo_fit, data.frame(diameter_mm = numeric(0)), "average"),
    "at least one row"
  )
  expect_error(
    data_linpred(weight_nereo_fit, data.frame(diameter_mm = 30, site = NA), "average"),
    "site"
  )
  expect_error(
    data_linpred(size_nereo_fit, data.frame(year = NA_real_), "average"),
    "year"
  )
  expect_error(
    data_linpred(weight_nereo_fit, data.frame(diameter_mm = Inf), "average"),
    "finite"
  )
  res <- data_linpred(weight_nereo_fit, data.frame(diameter_mm = 30, year = 2099), "average")
  expect_equal(res$group_vars, "year")
})

test_that("a numeric year in new_data names the fitted level and becomes a factor", {
  year <- size_nereo_fit$meta$year_levels[1]
  numeric <- data_linpred(size_nereo_fit, data.frame(year = as.numeric(year)), "average")
  character <- data_linpred(size_nereo_fit, data.frame(year = year), "average")
  expect_identical(numeric$grid$year, factor(year))
  expect_equal(numeric$linpred, character$linpred)
  expect_error(
    data_linpred(size_nereo_fit, data.frame(year = 2020.5), "average"),
    "whole numbers"
  )
})

test_that("new_data errors name the verb the user called", {
  err <- expect_error(
    kb_predict_weight(weight_nereo_fit, data.frame(diameter_mm = 30, site = NA))
  )
  expect_identical(err$call[[1]], quote(kb_predict_weight))
})

test_that("the observed-data paths reject a zero-observation fit", {
  fit0 <- weight_nereo_fit
  fit0$data <- fit0$data[0, ]
  expect_error(.linpred_obs(fit0), "no observed data")
  expect_error(data_linpred(fit0, NULL, "average"), "no observed data")
  expect_error(fitted(fit0), "no observed data")
  expect_error(residuals(fit0), "no observed data")
  expect_error(augment(fit0), "no observed data")
  expect_error(posterior_epred(fit0), "no observed data")
  expect_s3_class(
    data_linpred(fit0, data.frame(diameter_mm = 30), "average")$linpred,
    "rvar"
  )
})

test_that("density shifts log(alpha) by density_slope times standardised density", {
  grid <- data.frame(diameter_mm = 40, stipes_m2 = 7)
  off <- weight_nereo_fit
  off$meta$density_on <- FALSE
  e_on <- exp(as.numeric(posterior::draws_of(.linpred(weight_nereo_fit, grid, "average"))))
  e_off <- exp(as.numeric(posterior::draws_of(.linpred(off, grid, "average"))))
  floor <- as.numeric(posterior::draws_of(weight_nereo_fit$draws$weight_floor))
  b_density <- as.numeric(posterior::draws_of(weight_nereo_fit$draws$density_slope))
  z <- (7 - weight_nereo_fit$meta$density_mean) / weight_nereo_fit$meta$density_sd
  expect_equal(log(e_on - floor) - log(e_off - floor), b_density * z)
})

test_that("new_data predictions work for a model with no continuous predictor", {
  # Guards the range check indexing the grid with NULL.
  fit <- weight_nereo_fit
  fit$meta$predictor <- NULL
  expect_no_error(data_linpred(fit, data.frame(diameter_mm = 30), "average"))
})

test_that("a power-law fit's mean is log(alpha) + diameter_power * log(x), with no floor", {
  grid <- data.frame(diameter_mm = c(15, 40), stipes_m2 = 4)
  power <- weight_nereo_fit
  power$meta$form <- "power"
  lp_power <- posterior::draws_of(.linpred(power, grid, "average"))
  lp_floor <- posterior::draws_of(.linpred(weight_nereo_fit, grid, "average"))
  floor <- as.numeric(posterior::draws_of(weight_nereo_fit$draws$weight_floor))
  expect_equal(exp(lp_power), exp(lp_floor) - floor, ignore_attr = TRUE)
  b_power <- as.numeric(posterior::draws_of(weight_nereo_fit$draws$diameter_power))
  expect_equal(
    lp_power[, 2] - lp_power[, 1],
    b_power * (log(40) - log(15)),
    ignore_attr = TRUE
  )
})
