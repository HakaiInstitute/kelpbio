size_nereo_data <- function() {
  data.frame(
    diameter_mm = c(20, 35, 50),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
}

test_that("assemble_size_nereo_data maps data to the Stan data block", {
  sd <- assemble_size_nereo_data(size_nereo_data(), kb_priors_size_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$diameter_mm, c(20, 35, 50))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_size_nereo_data encodes the flags and accepts zero-row data", {
  sd <- assemble_size_nereo_data(
    size_nereo_data()[0, ],
    kb_priors_size_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$diameter_mm, 0)
  expect_equal(sd$prior_only, 1L)
})
