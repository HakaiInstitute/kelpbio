test_that(".group_vars is the package-wide grouping set", {
  expect_identical(.group_vars(), c("site", "year"))
})

test_that(".fit_levels reads a factor's fitted levels, empty when unused", {
  expect_identical(.fit_levels(weight_nereo_fit, "site"), weight_nereo_fit$meta$site_levels)
  expect_identical(.fit_levels(weight_nereo_fit, "year"), weight_nereo_fit$meta$year_levels)
  none <- structure(list(meta = list()), class = "kb_fit")
  expect_length(.fit_levels(none, "site"), 0L)
  expect_length(.fit_levels(none, "year"), 0L)
})

test_that("validate_by normalises NULL and passes a valid grouping through", {
  expect_identical(validate_by(NULL), character(0))
  expect_identical(validate_by("site"), "site")
  expect_identical(validate_by("year"), "year")
  expect_identical(validate_by(c("site", "year")), c("site", "year"))
})

test_that("validate_by rejects a factor no model groups by", {
  expect_error(validate_by("bogus"), "Invalid")
  expect_error(validate_by(1), "character")
})

test_that("site_year_key joins site and year with a colon", {
  expect_identical(
    site_year_key(factor(c("a", "b")), c(2020, 2021)),
    c("a:2020", "b:2021")
  )
})

test_that("id_text writes whole numbers in full", {
  expect_identical(id_text(c(100000, 2021, 1234567890123456)), c("100000", "2021", "1234567890123456"))
  expect_identical(id_text(c(2.5, NA)), c("2.5", NA))
})

test_that("id_text keeps text and factor levels", {
  expect_identical(id_text(factor(c("b", "a"))), c("b", "a"))
  expect_identical(id_text("1e+05"), "1e+05")
})

test_that("ids_as_character converts numeric year and survey_id", {
  d <- data.frame(site = 1, year = c(2021, 2022), survey_id = c(100000, 2.5))
  out <- ids_as_character(d)
  expect_identical(out$year, c("2021", "2022"))
  expect_identical(out$survey_id, c("100000", "2.5"))
  expect_identical(out$site, c(1, 1))
})

test_that("ids_as_character keeps character and factor columns", {
  d <- data.frame(year = factor("2021"), survey_id = "s1")
  expect_identical(ids_as_character(d), d)
})

test_that("with_year makes year a factor after site", {
  d <- data.frame(diameter_mm = 30, year = c("2021", "2019"), site = "a")
  out <- with_year(d)
  expect_named(out, c("diameter_mm", "site", "year"))
  expect_identical(levels(out$year), c("2019", "2021"))
  expect_identical(as.character(out$year), c("2021", "2019"))
})

test_that("with_year gives a numeric year its character level", {
  out <- with_year(data.frame(site = "a", year = c(2021, 2019)))
  expect_identical(levels(out$year), c("2019", "2021"))
})

test_that("with_year keeps a factor's level order", {
  d <- data.frame(site = "a", year = factor(c("2021", "2019"), levels = c("2021", "2019")))
  expect_identical(levels(with_year(d)$year), c("2021", "2019"))
})
