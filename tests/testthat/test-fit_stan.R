# Tests for the shared sampling engine helpers. The fit_stan() orchestration
# itself is exercised end-to-end through the kb_fit_* tests (it needs a compiled
# stanmodel and real sampling); the pure helpers are tested directly here.

test_that("resolve_cores respects mc.cores, caps at available, floors at 1", {
  avail <- parallel::detectCores()
  old <- options(mc.cores = 1)
  on.exit(options(old), add = TRUE)
  expect_identical(resolve_cores(NULL, 4L), 1L) # NULL -> mc.cores
  expect_identical(resolve_cores(1L, 4L), 1L) # explicit honoured
  expect_gte(resolve_cores(NULL, 4L), 1L) # floored at 1
  skip_if(is.na(avail), "detectCores() returned NA")
  expect_lte(resolve_cores(1000L, 4L), avail) # never oversubscribe
})

test_that("resolve_cores falls back to chains when mc.cores is unset", {
  old <- options(mc.cores = NULL)
  on.exit(options(old), add = TRUE)
  avail <- parallel::detectCores()
  expected <- if (is.na(avail)) 2L else min(2L, avail)
  expect_identical(resolve_cores(NULL, 2L), expected)
})

test_that("with_quiet_sampler returns the expression value under either setting", {
  expect_identical(with_quiet_sampler(42L, quiet = TRUE), 42L)
  expect_identical(with_quiet_sampler(42L, quiet = FALSE), 42L)
})

test_that("with_quiet_sampler propagates warnings when quiet = FALSE", {
  expect_warning(
    with_quiet_sampler(warning("some divergent transitions"), quiet = FALSE),
    "divergent"
  )
})

test_that("with_quiet_sampler muffles HMC diagnostic warnings when quiet = TRUE", {
  expect_no_warning(
    with_quiet_sampler(warning("There were 3 divergent transitions"), quiet = TRUE)
  )
  expect_no_warning(
    with_quiet_sampler(warning("R-hat is too high"), quiet = TRUE)
  )
})

test_that("with_quiet_sampler still surfaces non-HMC warnings when quiet = TRUE", {
  # only the sampler's own diagnostic warnings are muffled; genuine warnings
  # from elsewhere must still reach the user.
  expect_warning(
    with_quiet_sampler(warning("something unrelated"), quiet = TRUE),
    "unrelated"
  )
})
