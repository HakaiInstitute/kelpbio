# .linpred(): the model mean on the link scale, plus the two shared entry points
# (.linpred_obs, data_linpred) and the terminal default.

# ---- Nereocystis -------------------------------------------------------------

test_that(".linpred returns a log-scale rvar aligned to the grid (nereo)", {
  grid <- data.frame(diameter_mm = c(20, 40, 60))
  lp <- .linpred(weight_fit, grid, new_levels = "average")
  expect_s3_class(lp, "rvar")
  expect_length(lp, 3L)
  expect_equal(posterior::ndraws(lp), posterior::ndraws(weight_fit$draws))
})

test_that("conditioning follows the grid columns (nereo)", {
  site1 <- weight_fit$meta$site_levels[1]
  bare <- data.frame(diameter_mm = c(30, 30))
  with_site <- data.frame(diameter_mm = c(30, 30), site = site1)

  lp_avg <- posterior::draws_of(.linpred(
    weight_fit,
    bare,
    "average"
  ))
  lp_site <- posterior::draws_of(.linpred(
    weight_fit,
    with_site,
    "average"
  ))
  # Conditioning on a specific site shifts the mean off the typical (zeroed)
  # curve, so the two differ.
  expect_false(isTRUE(all.equal(as.numeric(lp_avg), as.numeric(lp_site))))
})

test_that("per-row resolution: known rows conditioned, new rows drawn (nereo)", {
  site1 <- weight_fit$meta$site_levels[1]
  grid <- data.frame(diameter_mm = c(30, 30), site = c(site1, "brand_new_site"))
  # Must not error on the unknown level.
  expect_no_error(.linpred(
    weight_fit,
    grid,
    new_levels = "sample"
  ))

  # Under "average" the conditioned components are deterministic: the known row
  # matches a single-site call, and the new row matches the typical curve.
  lp_avg <- posterior::draws_of(.linpred(
    weight_fit,
    grid,
    "average"
  ))
  lp_known <- posterior::draws_of(
    .linpred(
      weight_fit,
      data.frame(diameter_mm = 30, site = site1),
      "average"
    )
  )
  lp_typical <- posterior::draws_of(
    .linpred(weight_fit, data.frame(diameter_mm = 30), "average")
  )
  expect_equal(lp_avg[, 1], lp_known[, 1])
  expect_equal(lp_avg[, 2], lp_typical[, 1])
})

test_that("sample widens vs average when a factor is omitted (nereo)", {
  withr::local_seed(1) # the "sample" path draws random effects; pin them
  grid <- data.frame(diameter_mm = c(20, 40, 60))
  sd_avg <- apply(
    posterior::draws_of(.linpred(weight_fit, grid, "average")),
    2,
    stats::sd
  )
  sd_smp <- apply(
    posterior::draws_of(.linpred(weight_fit, grid, "sample")),
    2,
    stats::sd
  )
  expect_true(all(sd_smp >= sd_avg))
})

test_that("a dropped site:year effect contributes nothing to the linear predictor", {
  on <- weight_fit
  on$meta$site_year_on <- TRUE
  off <- weight_fit
  off$meta$site_year_on <- FALSE
  s <- weight_fit$meta$site_levels[1]
  y <- weight_fit$meta$year_levels[1]
  grid <- data.frame(diameter_mm = 40, site = s, year = y)

  e_on <- exp(as.numeric(posterior::draws_of(.linpred(on, grid, "average"))))
  e_off <- exp(as.numeric(posterior::draws_of(.linpred(off, grid, "average"))))

  # removing the term shifts the mean, so the two are not identical
  expect_false(isTRUE(all.equal(e_on, e_off)))
  # site:year acts on log(alpha), so the removed contribution is exactly the
  # conditioned bSiteYear[s, y] draws on the log of the weight above the floor
  floor <- as.numeric(posterior::draws_of(weight_fit$draws$bFloor))
  si <- match(s, weight_fit$meta$site_levels)
  yi <- match(y, weight_fit$meta$year_levels)
  bsy <- posterior::draws_of(weight_fit$draws$bSiteYear)[, si, yi]
  expect_equal(log(e_on - floor) - log(e_off - floor), as.numeric(bsy))
})

test_that("a macro fit gets the Macrocystis mean, not the Nereocystis one", {
  # With every random effect zeroed the mean reduces to its population terms, so
  # this pins the dispatched formula: linear in log-fronds, no quadratic and no
  # site slope. A missing registration would reach .linpred.default and abort.
  grid <- data.frame(fronds = c(2, 5, 10))
  draws <- weight_macro_fit$draws
  log_fc <- log(grid$fronds) - log(weight_macro_fit$meta$predictor_ref)
  expect_equal(
    posterior::draws_of(.linpred(weight_macro_fit, grid, "average")),
    posterior::draws_of(draws$bWeight + draws$bFronds * log_fc),
    ignore_attr = TRUE
  )
})

test_that("a known year contributes its estimated bYear main effect (macro)", {
  # macro has a standalone year main effect: conditioning on a known year shifts
  # the mean by exactly that year's bYear draws (site and site:year absent).
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
  byear <- posterior::draws_of(weight_macro_fit$draws$bYear)[, yi]
  expect_equal(as.numeric(diff), as.numeric(byear))
})

test_that("data_linpred resolves NULL new_data to the observed rows", {
  res <- data_linpred(weight_fit, NULL, "average")
  expect_named(res, c("grid", "group_vars", "linpred"))
  expect_equal(nrow(res$grid), nrow(weight_fit$data))
  expect_equal(res$group_vars, c("site", "year"))
  expect_equal(
    posterior::draws_of(res$linpred),
    posterior::draws_of(.linpred_obs(weight_fit))
  )
})

test_that("data_linpred checks new_data and new_levels before computing", {
  # the predictor column is checked by the fit's own .chk_new_data method
  expect_error(
    data_linpred(weight_fit, data.frame(fronds = 5), "average"),
    "diameter_mm"
  )
  expect_error(
    data_linpred(weight_fit, data.frame(diameter_mm = 30), "bogus"),
    class = "rlang_error"
  )
  # no grouping column supplied, so there is nothing to condition on
  res <- data_linpred(weight_fit, data.frame(diameter_mm = 30), "average")
  expect_equal(res$group_vars, character(0))
})

test_that("the observed-data paths reject a zero-observation fit", {
  # one guard at the shared entry, so every verb that predicts at the stored
  # data reports it the same way instead of failing inside the rvar arithmetic
  fit0 <- weight_fit
  fit0$data <- fit0$data[0, ]
  expect_error(.linpred_obs(fit0), "no observed data")
  expect_error(data_linpred(fit0, NULL, "average"), "no observed data")
  expect_error(fitted(fit0), "no observed data")
  expect_error(residuals(fit0), "no observed data")
  expect_error(augment(fit0), "no observed data")
  expect_error(posterior_epred(fit0), "no observed data")
  # supplied new_data still works: the fit's parameters are estimable
  expect_s3_class(
    data_linpred(fit0, data.frame(diameter_mm = 30), "average")$linpred,
    "rvar"
  )
})

test_that("density shifts log(alpha) by bDensity times standardised density", {
  grid <- data.frame(diameter_mm = 40, stipes_m2 = 7)
  off <- weight_fit
  off$meta$density_on <- FALSE
  e_on <- exp(as.numeric(posterior::draws_of(.linpred(weight_fit, grid, "average"))))
  e_off <- exp(as.numeric(posterior::draws_of(.linpred(off, grid, "average"))))
  floor <- as.numeric(posterior::draws_of(weight_fit$draws$bFloor))
  b_density <- as.numeric(posterior::draws_of(weight_fit$draws$bDensity))
  z <- (7 - weight_fit$meta$density_mean) / weight_fit$meta$density_sd
  expect_equal(log(e_on - floor) - log(e_off - floor), b_density * z)
})

test_that("new_data predictions work for a model with no continuous predictor", {
  # the range check must skip, not index the grid with NULL
  fit <- weight_fit
  fit$meta$predictor <- NULL
  expect_no_error(data_linpred(fit, data.frame(diameter_mm = 30), "average"))
})

test_that("a power-law fit's mean is log(alpha) + bPower * log(x), with no floor", {
  grid <- data.frame(diameter_mm = c(15, 40), stipes_m2 = 4)
  power <- weight_fit
  power$meta$form <- "power"
  lp_power <- posterior::draws_of(.linpred(power, grid, "average"))
  lp_floor <- posterior::draws_of(.linpred(weight_fit, grid, "average"))
  floor <- as.numeric(posterior::draws_of(weight_fit$draws$bFloor))
  # removing the floor from the packard_floor mean gives the power-law mean
  expect_equal(exp(lp_power), exp(lp_floor) - floor, ignore_attr = TRUE)
  # and it is linear in log(diameter)
  b_power <- as.numeric(posterior::draws_of(weight_fit$draws$bPower))
  expect_equal(
    lp_power[, 2] - lp_power[, 1],
    b_power * (log(40) - log(15)),
    ignore_attr = TRUE
  )
})
