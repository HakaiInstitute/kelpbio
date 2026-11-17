# One-row data frame of a dataset's example values, in each column's type.
example_data <- function(rows) {
  values <- Map(
    function(type, x) {
      switch(
        type,
        numeric = as.numeric(x),
        integer = as.integer(x),
        character = x,
        logical = as.logical(x),
        rvar = posterior::rvar(rep(as.numeric(x), 4))
      )
    },
    rows$type,
    rows$example
  )
  tibble::as_tibble(stats::setNames(values, rows$column))
}

check_data <- function(dataset) {
  getExportedValue("kelpbio", paste0("kb_check_data_", dataset))
}

# A size census matching the in situ example's survey_id.
census_example <- function() {
  example_data(kb_data_columns("size_census_nereo"))
}

test_that("kb_data_columns() describes each data check's data", {
  columns <- kb_data_columns()
  expect_named(
    columns,
    c(
      "dataset",
      "column",
      "required",
      "type",
      "units",
      "allowed",
      "description",
      "example"
    )
  )
  exports <- getNamespaceExports("kelpbio")
  checks <- grep("^kb_check_data_", exports, value = TRUE)
  expect_setequal(unique(columns$dataset), sub("^kb_check_data_", "", checks))
  expect_false(anyDuplicated(columns[c("dataset", "column")]) > 0)
  expect_type(columns$required, "logical")
  types <- c("numeric", "integer", "character", "logical", "rvar")
  expect_true(all(columns$type %in% types))
  expect_false(anyNA(columns[c("allowed", "description", "example")]))
  expect_true(all(grepl("^[A-Z].*\\.$", columns$description)))
})

test_that("kb_data_columns() returns one dataset's columns", {
  out <- kb_data_columns("wetdry_macro")
  expect_identical(out$column, c("wet_mass_g", "dry_mass_g"))
  expect_identical(unique(out$dataset), "wetdry_macro")
  expect_error(kb_data_columns("wetdry"), "dataset")
  expect_error(kb_data_columns(c("canopy", "in_situ")), "dataset")
})

test_that("each dataset's columns are in its simulated data", {
  for (dataset in unique(kb_data_columns()$dataset)) {
    rows <- kb_data_columns(dataset)
    species <- sub(".*_(nereo|macro)$", "\\1", dataset)
    sheet <- sub("_(nereo|macro)$", "", dataset)
    if (startsWith(dataset, "cover_calibration")) {
      next
    }
    matched <- if (species == dataset) {
      paste0("data_", dataset, "_sim_", c("nereo", "macro"))
    } else {
      paste0("data_", sheet, "_sim_", species)
    }
    data <- lapply(matched, get)
    for (d in data) {
      required <- rows$column[rows$required]
      expect_true(all(required %in% names(d)), label = dataset)
    }
    present <- unique(unlist(lapply(data, names)))
    expect_true(all(rows$column %in% present), label = dataset)
  }
})

test_that("cover calibration columns are in the survey biomass predictions", {
  biomass <- kb_predict_biomass_in_situ(
    fit_weight_sim_nereo,
    fit_size_sim_nereo,
    data_in_situ_sim_nereo[1:2, ],
    progress = "none"
  )
  for (dataset in c("cover_calibration_nereo", "cover_calibration_macro")) {
    expect_true(all(kb_data_columns(dataset)$column %in% names(biomass)))
  }
})

test_that("each dataset's examples pass its check", {
  for (dataset in unique(kb_data_columns()$dataset)) {
    data <- example_data(kb_data_columns(dataset))
    expect_silent(check_data(dataset)(data))
  }
})

test_that("each check requires exactly the dictionary's required columns", {
  for (dataset in unique(kb_data_columns()$dataset)) {
    rows <- kb_data_columns(dataset)
    data <- example_data(rows)
    required <- data[rows$column[rows$required]]
    if (dataset == "in_situ") {
      # plants, optional in the dictionary, is required without a size census.
      expect_silent(kb_check_data_in_situ(required, census_example()))
    } else {
      expect_silent(check_data(dataset)(required))
    }
    for (column in rows$column[rows$required]) {
      expect_error(
        check_data(dataset)(data[setdiff(names(data), column)]),
        label = paste(dataset, column)
      )
    }
  }
})
