test_that("summarise_rvar reduces an rvar to an estimate/lower/upper tibble", {
  rv <- posterior::rvar(matrix(seq_len(4000), nrow = 1000, ncol = 4))
  s <- summarise_rvar(rv, conf_level = 0.9)
  expect_s3_class(s, "tbl_df")
  expect_named(s, c("estimate", "lower", "upper"))
  expect_equal(nrow(s), 4L)
  expect_true(all(s$lower <= s$estimate & s$estimate <= s$upper))
})

test_that("summarise_rvar conf_level widens the interval", {
  rv <- posterior::rvar(matrix(seq_len(1000), nrow = 1000, ncol = 1))
  narrow <- summarise_rvar(rv, conf_level = 0.5)
  wide <- summarise_rvar(rv, conf_level = 0.95)
  expect_gt(wide$upper - wide$lower, narrow$upper - narrow$lower)
})
