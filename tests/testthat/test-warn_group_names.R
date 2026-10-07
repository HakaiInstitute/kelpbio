test_that("a site or year with a comma or bracket warns, naming the values", {
  expect_snapshot(warn_group_names(
    data.frame(site = c("North Reef, inner", "b", "North Reef, inner"), year = "2020"),
    "`d`"
  ))
  expect_warning(
    warn_group_names(data.frame(site = "a", year = "2020[a]"), "`d`"),
    "2020\\[a\\]"
  )
})

test_that("plain names, including spaces, raise no warning", {
  expect_no_warning(
    warn_group_names(data.frame(site = c("North Reef", "b"), year = "2020"), "`d`")
  )
  expect_no_warning(warn_group_names(data.frame(x = "a,b"), "`d`"))
})

test_that("the data checks warn on ambiguous group names", {
  data <- data_size_sim_macro
  data$site <- as.character(data$site)
  data$site[1] <- "North Reef, inner"
  expect_warning(kb_check_data_size_macro(data), "comma or square bracket")
})
