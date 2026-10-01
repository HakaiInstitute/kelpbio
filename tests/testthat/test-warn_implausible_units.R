test_that("a column in the wrong unit warns, naming it and the expected unit", {
  expect_snapshot(warn_implausible_units(data.frame(diameter = c(2.5, 3.4, 4)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(weight = c(900, 1200)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(density = c(20000, 30000)), "`d`"))
  expect_warning(
    warn_implausible_units(data.frame(diameter = c(300, 500)), "`d`"),
    "unusually large for millimetres"
  )
})

test_that("plausible, empty, and all-NA columns do not warn", {
  expect_no_warning(
    warn_implausible_units(
      data.frame(diameter = c(20, 40), weight = c(1, 3), density = c(2, 5)),
      "`d`"
    )
  )
  expect_no_warning(warn_implausible_units(data.frame(diameter = numeric(0)), "`d`"))
  expect_no_warning(warn_implausible_units(data.frame(density = NA), "`d`"))
})

test_that("the median, not an extreme value, decides", {
  expect_no_warning(
    warn_implausible_units(data.frame(weight = c(1, 2, 3, 500)), "`d`")
  )
})
