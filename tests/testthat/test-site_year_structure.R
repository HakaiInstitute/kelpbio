test_that("site_year_structure keeps the effect for crossed multi-year data", {
  d <- data.frame(
    site = c("a", "a", "b", "b"),
    year = c("2019", "2020", "2019", "2020")
  )
  s <- site_year_structure(d)
  expect_true(s$on)
  expect_identical(s$aliased, character(0))
})

test_that("site_year_structure flags a fully aliased design", {
  d <- data.frame(
    site = c("a", "b", "c"),
    year = c("2019", "2020", "2021")
  )
  s <- site_year_structure(d)
  expect_true(s$on)
  expect_identical(s$aliased, c("site", "year"))
})

test_that("one site over several years aliases site:year with year", {
  d <- data.frame(site = "a", year = c("2019", "2020", "2021"))
  expect_identical(site_year_structure(d)$aliased, "year")
})

test_that("each site in a single year, years shared, aliases site:year with site", {
  d <- data.frame(
    site = c("a", "b", "c", "d"),
    year = c("2019", "2019", "2020", "2020")
  )
  expect_identical(site_year_structure(d)$aliased, "site")
})

test_that("site_year_structure omits the effect for single-year data", {
  d <- data.frame(site = c("a", "b"), year = c("2019", "2019"))
  s <- site_year_structure(d)
  expect_false(s$on)
  expect_identical(s$aliased, character(0))
})

test_that("partial crossing (some sites span years) is not aliased", {
  d <- data.frame(
    site = c("a", "a", "b"),
    year = c("2019", "2020", "2019")
  )
  s <- site_year_structure(d)
  expect_true(s$on)
  expect_identical(s$aliased, character(0))
})

test_that("site_year_structure uses values present, not unused factor levels", {
  d <- data.frame(
    site = factor(c("a", "b"), levels = c("a", "b", "c")),
    year = factor(c("2019", "2019"), levels = c("2019", "2020"))
  )
  # Only one year present, despite the extra level.
  expect_false(site_year_structure(d)$on)
})

test_that("notify_site_year warns on an aliased design, naming the main effects", {
  expect_snapshot(notify_site_year(list(on = TRUE, aliased = "site")))
  expect_snapshot(notify_site_year(list(on = TRUE, aliased = c("site", "year"))))
})

test_that("notify_site_year reports an omitted effect unless progress is none", {
  expect_message(
    notify_site_year(list(on = FALSE, aliased = character(0))),
    "site:year effect is omitted"
  )
  expect_no_message(
    notify_site_year(list(on = FALSE, aliased = character(0)), progress = "none")
  )
})

test_that("notify_site_year is silent for a supported design", {
  expect_no_warning(
    expect_no_message(notify_site_year(list(on = TRUE, aliased = character(0))))
  )
})
