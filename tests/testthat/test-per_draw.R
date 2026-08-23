test_that(".per_draw returns D x N, one row per draw", {
  mu <- matrix(1:6, nrow = 3) # 3 draws, 2 observations
  out <- .per_draw(mu, c(10, 20), function(y, mu_d, d) y + mu_d + d)
  expect_equal(dim(out), c(3L, 2L))
  # the orientation is the contract: loo() silently misreads a transposed matrix
  expect_equal(out[2, ], c(10, 20) + mu[2, ] + 2)
})

test_that(".per_draw passes the draw index for draw-varying parameters", {
  mu <- matrix(0, nrow = 4, ncol = 1)
  sd <- c(1, 2, 3, 4)
  out <- .per_draw(mu, 0, function(y, mu_d, d) sd[d])
  expect_equal(as.vector(out), sd)
})
