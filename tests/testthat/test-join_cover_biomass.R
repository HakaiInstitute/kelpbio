surveys <- data.frame(
  site = c("a", "b", "a", "c", "c"),
  year = c("2020", "2020", "2020", "2021", "2021"),
  canopy_area_m2 = c(10, 20, 30, 40, 50)
)
biomass <- data.frame(
  site = factor(c("b", "a", "d")),
  year = factor(c("2020", "2020", "2020")),
  estimate = c(2, 1, 9),
  lower = c(1, 0.5, 4),
  upper = c(4, 2, 18)
)

test_that("each survey takes its site-year's biomass, keeping survey order", {
  out <- join_cover_biomass(surveys[1:3, ], biomass)
  expect_named(out, c("data", "unmatched"))
  expect_equal(out$data$canopy_area_m2, c(10, 20, 30))
  expect_equal(out$data$estimate, c(1, 2, 1))
  expect_equal(out$data$lower, c(0.5, 1, 0.5))
  expect_equal(out$data$upper, c(2, 4, 2))
  expect_identical(out$unmatched, character(0))
})

test_that("unpaired surveys are dropped silently, one key per survey returned", {
  expect_no_message(out <- join_cover_biomass(surveys, biomass))
  expect_equal(nrow(out$data), 3L)
  expect_identical(out$unmatched, c("c:2021", "c:2021"))
})

test_that("no paired survey errors", {
  expect_error(join_cover_biomass(surveys[4:5, ], biomass), "No survey")
})

test_that("zero-row surveys pass through", {
  out <- join_cover_biomass(surveys[0, ], biomass[0, ])
  expect_equal(nrow(out$data), 0L)
  expect_true(all(c("estimate", "lower", "upper") %in% names(out$data)))
})

test_that("notify_cover_unmatched counts surveys and lists their site-years", {
  expect_snapshot(notify_cover_unmatched(c("c:2021", "c:2021")))
  expect_snapshot(notify_cover_unmatched("c:2021"))
})

test_that("notify_cover_unmatched is silent when all surveys pair or progress is none", {
  expect_no_message(notify_cover_unmatched(character(0)))
  expect_no_message(notify_cover_unmatched("c:2021", progress = "none"))
  expect_invisible(notify_cover_unmatched("c:2021", progress = "none"))
})
