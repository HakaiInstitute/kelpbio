test_that("assemble_weight_macro_data maps data and priors to the Stan data block", {
  data <- data.frame(
    fronds = c(3L, 8L, 5L),
    weight_kg = c(0.4, 2, 1),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    prior_only = FALSE
  )

  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$fronds, c(3, 8, 5))
  expect_equal(sd$weight_kg, c(0.4, 2, 1))
  expect_equal(sd$fronds_ref, exp(mean(log(c(3, 8, 5)))))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_weight_macro_data accepts zero-row data", {
  data <- data.frame(
    fronds = numeric(0),
    weight_kg = numeric(0),
    site = factor(character(0)),
    year = factor(character(0))
  )
  sd <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$fronds, 0)
  expect_equal(sd$fronds_ref, 5)
  expect_equal(sd$prior_only, 1L)
})
