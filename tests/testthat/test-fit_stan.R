# Tests for the shared sampling engine helpers. The fit_stan() orchestration
# itself is exercised end-to-end through the kb_fit_* tests (it needs a compiled
# stanmodel and real sampling); the pure helpers are tested directly here.

test_that("resolve_cores respects mc.cores, caps at available, floors at 1", {
  avail <- parallel::detectCores()
  old <- options(mc.cores = 1)
  on.exit(options(old), add = TRUE)
  expect_identical(resolve_cores(NULL, 4L), 1L) # NULL -> mc.cores
  expect_identical(resolve_cores(1L, 4L), 1L) # explicit honoured
  expect_identical(resolve_cores(0L, 4L), 1L) # floored at 1 (max(1L, .))
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

test_that("with_quiet_sampler passes the value and warnings through when muffle = FALSE", {
  expect_identical(with_quiet_sampler(42L, muffle = FALSE), 42L)
  expect_warning(
    with_quiet_sampler(warning("some divergent transitions"), muffle = FALSE),
    "divergent"
  )
})

test_that("with_quiet_sampler muffles only HMC diagnostics when muffle = TRUE", {
  expect_identical(with_quiet_sampler(42L, muffle = TRUE), 42L)
  # sampler diagnostic warnings are muffled ...
  expect_no_warning(
    with_quiet_sampler(warning("There were 3 divergent transitions"), muffle = TRUE)
  )
  expect_no_warning(with_quiet_sampler(warning("R-hat is too high"), muffle = TRUE))
  # ... but genuine warnings from elsewhere still reach the user
  expect_warning(
    with_quiet_sampler(warning("something unrelated"), muffle = TRUE),
    "unrelated"
  )
})
