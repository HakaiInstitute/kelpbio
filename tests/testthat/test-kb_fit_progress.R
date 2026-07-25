# kb_fit_progress() is a thin wrapper over read_progress_fraction() (the fraction
# logic is tested in test-progress.R). write_fake_chain() is in helper-progress.R.

test_that("kb_fit_progress validates progress_dir", {
  expect_snapshot(error = TRUE, kb_fit_progress(1))
  expect_snapshot(error = TRUE, kb_fit_progress(c("a", "b")))
})

test_that("kb_fit_progress delegates to the fraction reader", {
  d <- withr::local_tempdir()
  expect_identical(kb_fit_progress(d), 0) # no artifact yet
  write_progress_manifest(d, chains = 2L, warmup = 4L, niters = 4L, nthin = 1L)
  write_fake_chain(file.path(d, "samples_1.csv"), n_rows = 8L, complete = TRUE)
  write_fake_chain(file.path(d, "samples_2.csv"), n_rows = 2L)
  expect_equal(kb_fit_progress(d), (8 + 2) / 16)
})
