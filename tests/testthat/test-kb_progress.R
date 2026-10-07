test_that("kb_progress validates progress_dir", {
  expect_snapshot(error = TRUE, kb_progress(1))
  expect_snapshot(error = TRUE, kb_progress(c("a", "b")))
})

test_that("kb_progress delegates to the fraction reader", {
  d <- withr::local_tempdir()
  expect_identical(kb_progress(d), 0) # no artifact yet
  write_progress_manifest(d, chains = 2L, warmup = 4L, niters = 4L, nthin = 1L)
  write_fake_chain(file.path(d, "samples_1.csv"), n_rows = 8L, complete = TRUE)
  write_fake_chain(file.path(d, "samples_2.csv"), n_rows = 2L)
  expect_equal(kb_progress(d), (8 + 2) / 16)
})

test_that("kb_progress reads a prediction's record in preference to a fit's", {
  d <- withr::local_tempdir()
  write_progress_manifest(d, chains = 1L, warmup = 2L, niters = 2L, nthin = 1L)
  write_fake_chain(file.path(d, "samples.csv"), n_rows = 4L, complete = TRUE)
  expect_identical(kb_progress(d), 1)
  write_prediction_progress(d, 1L, 4L)
  expect_identical(kb_progress(d), 0.25)
})
