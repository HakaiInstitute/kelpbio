survey_nereo <- function() {
  subset(data_survey_sim_nereo, as.integer(site) <= 4)
}

test_that("tallied surveys give one row each, plants times mean weight per m2", {
  withr::local_seed(1)
  survey <- survey_nereo()
  p <- kb_predict_biomass_survey(weight_nereo_fit, size_nereo_fit, survey, progress = "none")
  expect_s3_class(p, "kb_predictions")
  expect_equal(nrow(p), nrow(survey))
  expect_identical(p$year, survey$year)
  expect_identical(p$survey_id, survey$survey_id)
  expect_true(all(c("weight_support", "size_support", "biomass_kg_m2") %in% names(p)))
  expect_identical(attr(p, "kb_response"), "biomass_kg_m2")

  withr::local_seed(1)
  groups <- tibble::tibble(site = as.character(survey$site), year = as.character(survey$year))
  first <- !duplicated(paste(groups$site, groups$year))
  mean_weight <- mean_weight_draws(
    weight_nereo_fit, size_nereo_fit, groups[first, ],
    new_levels = "sample", representative_site = NULL,
    n_plants = 100L, progress = "none", progress_dir = NULL
  )
  i <- match(paste(groups$site, groups$year), paste(groups$site, groups$year)[first])
  expected <- sweep(mean_weight[, i, drop = FALSE], 2, survey$plants / survey$survey_area_m2, "*")
  expect_equal(posterior::draws_of(p$biomass_kg_m2), expected, ignore_attr = TRUE)
})

test_that("a tallied survey with no plants has zero biomass", {
  p <- kb_predict_biomass_survey(
    weight_nereo_fit, size_nereo_fit, data_survey_sim_nereo,
    new_levels = "average", progress = "none"
  )
  zero <- data_survey_sim_nereo$plants == 0
  expect_true(any(zero))
  expect_true(all(posterior::draws_of(p$biomass_kg_m2)[, zero] == 0))
})

test_that("census surveys sum each plant's expected weight, half for a partial plant", {
  survey <- tibble::tibble(
    survey_id = c("s1", "s2"), site = "seal_ledge", year = "2019",
    survey_area_m2 = c(100, 50)
  )
  plants <- tibble::tibble(
    survey_id = "s1", fronds = c(4, 10), partial = c(FALSE, TRUE)
  )
  expect_snapshot(
    p <- kb_predict_biomass_survey(
      weight_macro_fit, plants, survey,
      per_area = FALSE, new_levels = "average"
    )
  )
  expected <- posterior_epred(
    weight_macro_fit,
    data.frame(site = "seal_ledge", year = "2019", fronds = c(4, 10)),
    new_levels = "average"
  )
  expect_equal(
    posterior::draws_of(p$biomass_kg)[, 1],
    expected[, 1] + 0.5 * expected[, 2],
    ignore_attr = TRUE
  )
  expect_true(all(posterior::draws_of(p$biomass_kg)[, 2] == 0))
  expect_false("size_support" %in% names(p))
})

test_that("an empty size census gives zero biomass for every survey", {
  survey <- subset(data_survey_sim_macro, as.integer(site) <= 2)
  expect_snapshot(
    p <- kb_predict_biomass_survey(
      weight_macro_fit, data_size_census_sim_macro[0, ], survey,
      new_levels = "average"
    )
  )
  expect_equal(nrow(p), nrow(survey))
  expect_true(all(posterior::draws_of(p$biomass_kg_m2) == 0))
})

test_that("a survey table with no rows errors", {
  expect_snapshot(
    kb_predict_biomass_survey(weight_nereo_fit, size_nereo_fit, data_survey_sim_nereo[0, ]),
    error = TRUE
  )
  survey <- data_survey_sim_macro[0, ]
  expect_error(
    kb_predict_biomass_survey(weight_macro_fit, data_size_census_sim_macro, survey),
    "at least one row"
  )
})

test_that("per_area divides by the surveyed area", {
  withr::local_seed(1)
  per_m2 <- kb_predict_biomass_survey(
    weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro,
    progress = "none"
  )
  withr::local_seed(1)
  total <- kb_predict_biomass_survey(
    weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro,
    per_area = FALSE, progress = "none"
  )
  expect_equal(
    posterior::draws_of(total$biomass_kg),
    sweep(posterior::draws_of(per_m2$biomass_kg_m2), 2, data_survey_sim_macro$survey_area_m2, "*"),
    ignore_attr = TRUE
  )
})

test_that("pool_by pools surveys as total kg over total area", {
  withr::local_seed(1)
  rows <- kb_predict_biomass_survey(
    weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro,
    per_area = FALSE, progress = "none"
  )
  withr::local_seed(1)
  pooled <- kb_predict_biomass_survey(
    weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro,
    pool_by = c("site", "year"), progress = "none"
  )
  expect_named(pooled, c("site", "year", "biomass_kg_m2", "estimate", "lower", "upper"))
  key <- paste(rows$site, rows$year)
  k <- key[1]
  draws <- posterior::draws_of(rows$biomass_kg)[, key == k, drop = FALSE]
  area <- sum(data_survey_sim_macro$survey_area_m2[key == k])
  expect_equal(
    posterior::draws_of(pooled$biomass_kg_m2)[, paste(pooled$site, pooled$year) == k],
    rowSums(draws) / area,
    ignore_attr = TRUE
  )
})

test_that("invalid and mismatched inputs error", {
  expect_snapshot(
    kb_predict_biomass_survey(
      weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro, n_plants = 10
    ),
    error = TRUE
  )
  expect_snapshot(
    kb_predict_biomass_survey(weight_nereo_fit, data_size_census_sim_macro, data_survey_sim_macro),
    error = TRUE
  )
  expect_error(
    kb_predict_biomass_survey(weight_nereo_fit, size_nereo_fit, data_survey_sim_macro),
    "plants"
  )
  expect_error(
    kb_predict_biomass_survey(
      weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro, measure = "dry"
    ),
    "wetdry"
  )
  expect_error(
    kb_predict_biomass_survey(
      weight_nereo_fit, size_nereo_fit, data_survey_sim_nereo, pool_by = "zone"
    ),
    "zone"
  )
  expect_snapshot(
    kb_predict_biomass_survey(weight_nereo_fit, NULL, data_survey_sim_nereo),
    error = TRUE
  )
})

test_that("a repeated pool_by column pools as if named once", {
  args <- list(
    weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro,
    new_levels = "average", progress = "none"
  )
  once <- do.call(kb_predict_biomass_survey, c(args, list(pool_by = "site")))
  twice <- do.call(kb_predict_biomass_survey, c(args, list(pool_by = c("site", "site"))))
  expect_identical(twice, once)
})

test_that("several surveys in a site-year share its weight draws", {
  survey <- tibble::tibble(
    survey_id = 1:3,
    site = "otter_cove",
    year = 2020,
    survey_area_m2 = c(140, 100, 140),
    plants = c(110, 15, 90)
  )
  p <- kb_predict_biomass_survey(
    weight_nereo_fit, size_nereo_fit, survey,
    per_area = FALSE, new_levels = "average", progress = "none"
  )
  expect_equal(nrow(p), 3L)
  expect_identical(p$year, rep("2020", 3))
  expect_identical(p$survey_id, c("1", "2", "3"))
  per_plant <- sweep(posterior::draws_of(p$biomass_kg), 2, survey$plants, "/")
  expect_equal(per_plant[, 2], per_plant[, 1], ignore_attr = TRUE)
  expect_equal(per_plant[, 3], per_plant[, 1], ignore_attr = TRUE)
})

test_that("a sampled new site is shared by the census plants of its site-year", {
  survey <- tibble::tibble(
    survey_id = c("s1", "s2", "s3"),
    site = c("new_reef", "new_reef", "other_reef"),
    year = "2019",
    survey_area_m2 = 100
  )
  plants <- tibble::tibble(survey_id = survey$survey_id, fronds = 10)
  withr::local_seed(1)
  p <- kb_predict_biomass_survey(weight_macro_fit, plants, survey, per_area = FALSE)
  kg <- posterior::draws_of(p$biomass_kg)
  expect_equal(kg[, 2], kg[, 1], ignore_attr = TRUE)
  expect_false(isTRUE(all.equal(kg[, 3], kg[, 1])))
})

test_that("representative_site lends a fitted site's effects on both paths", {
  tallied <- function(site, ...) {
    survey <- tibble::tibble(
      survey_id = "s1", site = site, year = "2020",
      survey_area_m2 = 100, plants = 20
    )
    kb_predict_biomass_survey(
      weight_nereo_fit, size_nereo_fit, survey,
      new_levels = "average", progress = "none", ...
    )
  }
  expect_equal(
    posterior::draws_of(tallied("new_reef", representative_site = "otter_cove")$biomass_kg_m2),
    posterior::draws_of(tallied("otter_cove")$biomass_kg_m2)
  )

  census <- function(site, ...) {
    survey <- tibble::tibble(
      survey_id = "s1", site = site, year = "2019", survey_area_m2 = 100
    )
    plants <- tibble::tibble(survey_id = "s1", fronds = c(4, 10))
    kb_predict_biomass_survey(weight_macro_fit, plants, survey, new_levels = "average", ...)
  }
  expect_equal(
    posterior::draws_of(census("new_reef", representative_site = "seal_ledge")$biomass_kg_m2),
    posterior::draws_of(census("seal_ledge")$biomass_kg_m2)
  )

  expect_snapshot(tallied("new_reef", representative_site = "nowhere"), error = TRUE)
  expect_error(census("new_reef", representative_site = "nowhere"), "nowhere")
})

test_that("the census join ignores the type of survey_id", {
  survey <- subset(data_survey_sim_macro, as.integer(site) <= 2)
  plants <- subset(data_size_census_sim_macro, survey_id %in% survey$survey_id)
  run <- function(survey, plants) {
    kb_predict_biomass_survey(
      weight_macro_fit, plants, survey,
      new_levels = "average", progress = "none"
    )$biomass_kg_m2
  }
  expected <- posterior::draws_of(run(survey, plants))
  as_factor <- function(x) transform(x, survey_id = factor(survey_id))
  expect_equal(posterior::draws_of(run(as_factor(survey), plants)), expected)
  numbered <- function(x) transform(x, survey_id = match(survey_id, survey$survey_id))
  expect_equal(posterior::draws_of(run(numbered(survey), numbered(plants))), expected)
})

test_that("pool_by sums kg on the draws when per_area is FALSE", {
  args <- list(
    weight_macro_fit, data_size_census_sim_macro, data_survey_sim_macro,
    per_area = FALSE, new_levels = "average", progress = "none"
  )
  rows <- do.call(kb_predict_biomass_survey, args)
  pooled <- do.call(kb_predict_biomass_survey, c(args, list(pool_by = "site")))
  expect_identical(attr(pooled, "kb_response"), "biomass_kg")
  draws <- posterior::draws_of(rows$biomass_kg)
  for (s in as.character(pooled$site)) {
    expect_equal(
      posterior::draws_of(pooled$biomass_kg)[, as.character(pooled$site) == s],
      rowSums(draws[, as.character(rows$site) == s, drop = FALSE]),
      ignore_attr = TRUE
    )
  }
})

test_that("numeric survey ids and years come back as character and pool by year", {
  survey <- transform(
    survey_nereo(),
    survey_id = seq_along(survey_id),
    year = as.integer(as.character(year))
  )
  withr::local_seed(1)
  p <- kb_predict_biomass_survey(
    weight_nereo_fit, size_nereo_fit, survey,
    new_levels = "average", progress = "none"
  )
  expect_identical(p$survey_id, as.character(survey$survey_id))
  expect_identical(p$year, as.character(survey$year))
  withr::local_seed(1)
  pooled <- kb_predict_biomass_survey(
    weight_nereo_fit, size_nereo_fit, survey,
    new_levels = "average", progress = "none", pool_by = "year"
  )
  expect_identical(pooled$year, sort(unique(as.character(survey$year))))
})

test_that("a numeric survey id joins a census id written in full", {
  survey <- tibble::tibble(survey_id = 100000, site = "seal_ledge", year = 2019, survey_area_m2 = 100)
  census <- tibble::tibble(survey_id = "100000", fronds = c(4, 10))
  p <- kb_predict_biomass_survey(weight_macro_fit, census, survey, new_levels = "average")
  expect_true(all(posterior::draws_of(p$biomass_kg_m2) > 0))
})
