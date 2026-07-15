# Tests for the data-derived site:year structure and its user notices.

test_that("site_year_structure keeps the effect for crossed multi-year data", {
  d <- data.frame(
    site = c("a", "a", "b", "b"),
    year = c("2019", "2020", "2019", "2020")
  )
  s <- kelpbio:::site_year_structure(d)
  expect_true(s$on)
  expect_false(s$aliased)
})

test_that("site_year_structure flags a fully aliased design", {
  d <- data.frame(
    site = c("a", "b", "c"),
    year = c("2019", "2020", "2021")
  )
  s <- kelpbio:::site_year_structure(d)
  expect_true(s$on)
  expect_true(s$aliased)
})

test_that("site_year_structure omits the effect for single-year data", {
  d <- data.frame(site = c("a", "b"), year = c("2019", "2019"))
  s <- kelpbio:::site_year_structure(d)
  expect_false(s$on)
  expect_false(s$aliased)
})

test_that("partial crossing (some sites span years) is not aliased", {
  d <- data.frame(
    site = c("a", "a", "b"),
    year = c("2019", "2020", "2019")
  )
  s <- kelpbio:::site_year_structure(d)
  expect_true(s$on)
  expect_false(s$aliased)
})

test_that("site_year_structure uses values present, not unused factor levels", {
  d <- data.frame(
    site = factor(c("a", "b"), levels = c("a", "b", "c")),
    year = factor(c("2019", "2019"), levels = c("2019", "2020"))
  )
  # only one year is actually present -> effect omitted, despite the extra level
  expect_false(kelpbio:::site_year_structure(d)$on)
})

test_that("notify_site_year warns on an aliased design", {
  expect_warning(
    kelpbio:::notify_site_year(list(on = TRUE, aliased = TRUE)),
    "not separately identifiable"
  )
})

test_that("notify_site_year reports an omitted effect unless quiet", {
  expect_message(
    kelpbio:::notify_site_year(list(on = FALSE, aliased = FALSE)),
    "site:year effect is omitted"
  )
  expect_no_message(
    kelpbio:::notify_site_year(list(on = FALSE, aliased = FALSE), quiet = TRUE)
  )
})

test_that("notify_site_year is silent for a supported design", {
  expect_no_warning(
    expect_no_message(kelpbio:::notify_site_year(list(on = TRUE, aliased = FALSE)))
  )
})
