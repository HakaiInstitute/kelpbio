test_that(".floor_on is off for a power-law fit", {
  expect_true(.floor_on(list(meta = list(form = "packard_floor"))))
  expect_false(.floor_on(list(meta = list(form = "power"))))
})

test_that(".presence_on reads the recorded flag, missing as FALSE", {
  expect_true(.presence_on(list(meta = list(presence_on = TRUE))))
  expect_false(.presence_on(list(meta = list())))
})

test_that(".site_year_on reads the recorded flag, missing as FALSE", {
  expect_true(.site_year_on(list(meta = list(site_year_on = TRUE))))
  expect_false(.site_year_on(list(meta = list(site_year_on = FALSE))))
  # As for wet/dry and carbon.
  expect_false(.site_year_on(list(meta = list())))
})
