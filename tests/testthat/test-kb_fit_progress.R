# Exercises the public reader against fixture progress-artifact directories; the
# end-to-end path (an actual fit writing the artifact) is covered, skip_on_cran,
# in test-kb_fit_weight_nereo.R. write_fake_chain() is defined in helper-progress.R.

test_that("kb_fit_progress validates progress_dir", {
  expect_snapshot(error = TRUE, kb_fit_progress(1))
  expect_snapshot(error = TRUE, kb_fit_progress(c("a", "b")))
})

test_that("kb_fit_progress is 0 on an empty or artifact-free directory", {
  d <- withr::local_tempdir()
  expect_identical(kb_fit_progress(d), 0)
})

test_that("kb_fit_progress returns the completed fraction mid-run", {
  d <- withr::local_tempdir()
  write_progress_manifest(d, chains = 2L, warmup = 4L, niters = 4L, nthin = 1L)
  write_fake_chain(file.path(d, "samples_1.csv"), n_rows = 8L, complete = TRUE)
  write_fake_chain(file.path(d, "samples_2.csv"), n_rows = 2L)
  expect_equal(kb_fit_progress(d), (8 + 2) / 16)
})

test_that("kb_fit_progress returns 1 once every chain is complete", {
  d <- withr::local_tempdir()
  write_progress_manifest(d, chains = 2L, warmup = 4L, niters = 4L, nthin = 1L)
  write_fake_chain(file.path(d, "samples_1.csv"), n_rows = 8L, complete = TRUE)
  write_fake_chain(file.path(d, "samples_2.csv"), n_rows = 8L, complete = TRUE)
  expect_identical(kb_fit_progress(d), 1)
})

test_that("kb_fit_progress does not error on a torn read", {
  d <- withr::local_tempdir()
  write_progress_manifest(d, chains = 1L, warmup = 4L, niters = 4L, nthin = 1L)
  write_fake_chain(file.path(d, "samples_1.csv"), n_rows = 3L, torn = TRUE)
  expect_no_error(p <- kb_fit_progress(d))
  expect_equal(p, 3 / 8)
})
