test_that("the level comes from the argument, the recorded attribute, or 0.95", {
  b <- data.frame(site = "a")
  expect_identical(cover_conf_level(b, NULL), 0.95)
  expect_identical(cover_conf_level(b, 0.9), 0.9)
  recorded <- structure(b, kb_conf_level = 0.8)
  expect_identical(cover_conf_level(recorded, NULL), 0.8)
  expect_identical(cover_conf_level(recorded, 0.8), 0.8)
  expect_identical(
    cover_conf_level(structure(b, kb_conf_level = NA_real_), NULL),
    0.95
  )
})

test_that("a contradicting or invalid level errors", {
  recorded <- structure(data.frame(site = "a"), kb_conf_level = 0.8)
  expect_snapshot(cover_conf_level(recorded, 0.95), error = TRUE)
  expect_error(cover_conf_level(data.frame(), 1))
  expect_error(cover_conf_level(data.frame(), "0.9"))
})
