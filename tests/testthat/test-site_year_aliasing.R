test_that("crossed multi-year data are not aliased", {
  d <- data.frame(
    site = c("a", "a", "b", "b"),
    year = c("2019", "2020", "2019", "2020")
  )
  expect_identical(site_year_aliasing(d), character(0))
})

test_that("a fully aliased design names both effects", {
  d <- data.frame(
    site = c("a", "b", "c"),
    year = c("2019", "2020", "2021")
  )
  expect_identical(site_year_aliasing(d), c("site", "year"))
})

test_that("one site over several years aliases site:year with year", {
  d <- data.frame(site = "a", year = c("2019", "2020", "2021"))
  expect_identical(site_year_aliasing(d), "year")
})

test_that("each site in a single year, years shared, aliases site:year with site", {
  d <- data.frame(
    site = c("a", "b", "c", "d"),
    year = c("2019", "2019", "2020", "2020")
  )
  expect_identical(site_year_aliasing(d), "site")
})

test_that("single-year data alias site:year with site", {
  d <- data.frame(site = c("a", "b"), year = c("2019", "2019"))
  expect_identical(site_year_aliasing(d), "site")
})

test_that("one site in one year aliases site:year with both effects", {
  d <- data.frame(site = c("a", "a"), year = c("2019", "2019"))
  expect_identical(site_year_aliasing(d), c("site", "year"))
})

test_that("zero-row data are not aliased", {
  d <- data.frame(site = character(0), year = character(0))
  expect_identical(site_year_aliasing(d), character(0))
})

test_that("partial crossing (some sites span years) is not aliased", {
  d <- data.frame(
    site = c("a", "a", "b"),
    year = c("2019", "2020", "2019")
  )
  expect_identical(site_year_aliasing(d), character(0))
})

test_that("site_year_aliasing uses values present, not unused factor levels", {
  d <- data.frame(
    site = factor(c("a", "a", "b", "b"), levels = c("a", "b", "c")),
    year = factor(c("2019", "2020", "2019", "2020"), levels = c("2019", "2020", "2021"))
  )
  expect_identical(site_year_aliasing(d), character(0))
})

test_that("notify_site_year warns on an aliased design, naming the main effects", {
  expect_snapshot(notify_site_year("site"))
  expect_snapshot(notify_site_year(c("site", "year")))
})

test_that("notify_site_year is silent for a supported design", {
  expect_no_warning(expect_no_message(notify_site_year(character(0))))
})
