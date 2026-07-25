# write_fake_chain() is defined in helper-progress.R.

test_that("progress_rows_per_chain counts thinned warmup plus post-warmup draws", {
  expect_identical(progress_rows_per_chain(75L, 75L, 1L), 150L)
  expect_identical(progress_rows_per_chain(40L, 40L, 3L), 54L) # ceil(40/3) + 40
})

test_that("count_chain_rows counts complete rows and ignores comments and torn rows", {
  d <- withr::local_tempdir()
  f <- file.path(d, "samples_1.csv")
  expect_identical(count_chain_rows(file.path(d, "absent.csv")), 0L)
  write_fake_chain(f, n_fields = 5L, n_rows = 4L)
  expect_identical(count_chain_rows(f), 4L)
  write_fake_chain(f, n_fields = 5L, n_rows = 4L, torn = TRUE)
  expect_identical(count_chain_rows(f), 4L) # torn trailing row ignored
})

test_that("chain_is_complete detects the Elapsed Time footer", {
  d <- withr::local_tempdir()
  f <- file.path(d, "samples_1.csv")
  write_fake_chain(f, n_rows = 2L, complete = FALSE)
  expect_false(chain_is_complete(f))
  write_fake_chain(f, n_rows = 2L, complete = TRUE)
  expect_true(chain_is_complete(f))
  expect_false(chain_is_complete(file.path(d, "absent.csv")))
})

test_that("read_progress_fraction is 0 with no artifact, partway mid-run, 1 when complete", {
  d <- withr::local_tempdir()
  expect_identical(read_progress_fraction(d), 0) # no manifest yet
  # warmup = niters = 4, nthin = 1 -> 8 rows/chain, 2 chains -> 16 total
  write_progress_manifest(d, chains = 2L, warmup = 4L, niters = 4L, nthin = 1L)
  expect_identical(read_progress_fraction(d), 0) # manifest but no CSVs
  write_fake_chain(file.path(d, "samples_1.csv"), n_rows = 8L, complete = TRUE)
  write_fake_chain(file.path(d, "samples_2.csv"), n_rows = 4L)
  expect_equal(read_progress_fraction(d), (8 + 4) / 16)
  write_fake_chain(file.path(d, "samples_2.csv"), n_rows = 8L, complete = TRUE)
  expect_identical(read_progress_fraction(d), 1)
})

test_that("read_progress_fraction caps an over-full chain and never exceeds 1", {
  d <- withr::local_tempdir()
  write_progress_manifest(d, chains = 1L, warmup = 4L, niters = 4L, nthin = 1L)
  # a single chain has no _1 suffix (see progress_chain_files)
  write_fake_chain(file.path(d, "samples.csv"), n_rows = 20L)
  expect_identical(read_progress_fraction(d), 1)
})

test_that("progress_chain_files matches rstan's single- vs multi-chain naming", {
  d <- withr::local_tempdir()
  expect_identical(progress_chain_files(d, 1L), file.path(d, "samples.csv"))
  expect_identical(
    progress_chain_files(d, 3L),
    file.path(d, c("samples_1.csv", "samples_2.csv", "samples_3.csv"))
  )
})

test_that("resolve_progress_dir honours a supplied dir, else temp for bar only", {
  d <- withr::local_tempdir()
  supplied <- resolve_progress_dir("none", d)
  expect_identical(supplied, list(dir = d, owned = FALSE))

  none <- resolve_progress_dir("none", NULL)
  expect_identical(none, list(dir = NULL, owned = FALSE))

  bar <- resolve_progress_dir("bar", NULL)
  withr::defer(unlink(bar$dir, recursive = TRUE))
  expect_true(bar$owned)
  expect_true(dir.exists(bar$dir))
})

test_that("progress_reporter binds a bar for 'bar' and a no-op otherwise", {
  expect_s3_class(progress_reporter("bar"), "kb_reporter_bar")
  expect_s3_class(progress_reporter("none"), "kb_reporter_noop")
  expect_s3_class(progress_reporter("verbose"), "kb_reporter_noop")
})

test_that("the no-op reporter methods run silently", {
  r <- noop_reporter()
  expect_silent(r$start(10))
  expect_silent(r$update(5))
  expect_silent(r$finish())
})

test_that("the bar reporter runs its lifecycle without error", {
  # force cli to actually render, so the format string ({cli::pb_bar}, ...) is
  # evaluated in the reporter's environment (guards the base-parent env fix).
  withr::local_options(cli.dynamic = TRUE, cli.progress_show_after = 0)
  r <- bar_reporter()
  expect_no_error({
    r$start(10)
    r$update(5)
    r$update(10) # reaches total: cli auto-terminates the bar here
    r$update(10) # tolerated no-op on the since-terminated bar
    r$finish()
  })
})
