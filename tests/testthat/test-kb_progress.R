test_that("kb_progress validates progress_dir", {
  expect_snapshot(error = TRUE, kb_progress(1))
})

test_that("kb_progress reads a prediction's record in preference to a fit's", {
  d <- withr::local_tempdir()
  write_progress_manifest(d, chains = 1L, warmup = 2L, niters = 2L, nthin = 1L)
  write_fake_chain(file.path(d, "samples.csv"), n_rows = 4L, complete = TRUE)
  expect_identical(kb_progress(d), 1)
  write_prediction_progress(d, 1L, 4L)
  expect_identical(kb_progress(d), 0.25)
})
