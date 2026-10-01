test_that(".floor_on is off only for a power-law fit", {
  expect_true(.floor_on(list(meta = list(form = "packard_floor"))))
  expect_false(.floor_on(list(meta = list(form = "power"))))
  # a fit made before form was recorded had the floor
  expect_true(.floor_on(list(meta = list())))
})
