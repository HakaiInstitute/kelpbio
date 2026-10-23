test_that("assemble_weight_nereo_data maps data and priors to the Stan data block", {
  data <- data.frame(
    diameter_mm = c(20, 35, 50),
    weight_kg = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 42,
    prior_only = FALSE
  )

  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$diameter_mm, c(20, 35, 50))
  expect_equal(sd$weight_kg, c(0.5, 2, 4))
  expect_equal(sd$diameter_ref, 42)
  expect_equal(sd$prior_only, 0L)
  expect_equal(sd$floor_on, 1L)
})

test_that("assemble_weight_nereo_data encodes floor_on as 0/1", {
  data <- data.frame(
    diameter_mm = c(20, 35),
    weight_kg = c(0.5, 2),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    floor_on = FALSE
  )
  expect_equal(sd$floor_on, 0L)
})

test_that("assemble_weight_nereo_data accepts zero-row data", {
  data <- data.frame(
    diameter_mm = numeric(0),
    weight_kg = numeric(0),
    site = factor(character(0)),
    year = factor(character(0))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$diameter_mm, 0)
  expect_equal(sd$prior_only, 1L)
})
