# Expected unit of each data column that has one, read by the unit and range
# warnings. A sub-model reusing a column reuses its unit.
column_units <- c(
  diameter_mm = "millimetres",
  weight_kg = "kilograms",
  survey_area_m2 = "square metres",
  wet_mass_g = "grams",
  dry_mass_g = "grams",
  sample_mass_mg = "milligrams",
  carbon_mass_ug = "micrograms",
  nitrogen_mass_ug = "micrograms",
  canopy_area_m2 = "square metres",
  plot_area_m2 = "square metres",
  classified_area_m2 = "square metres",
  canopy_tide_height_m = "metres"
)

# Column-qualified name for chk error messages (bboudata convention).
column_xname <- function(x_name, col) {
  paste0("Column `", col, "` of ", x_name)
}

# The data dictionary: one row per dataset and column, returned by
# kb_data_columns(). The checks read their required columns from it and the
# data check topics build their column lists from it. `required` is whether
# the column must be present; `allowed` the values a check accepts.
data_columns <- local({
  m2 <- "m²"
  ug <- "µg"
  col <- function(
    column,
    required,
    type,
    units,
    allowed,
    description,
    example
  ) {
    tibble::tibble(
      column = column,
      required = required,
      type = type,
      units = units,
      allowed = allowed,
      description = description,
      example = example
    )
  }
  site <- function(what, example) {
    col("site", TRUE, "character", NA, "any text", what, example)
  }
  year <- function(what) {
    col("year", TRUE, "integer", NA, "whole number or text", what, "2024")
  }
  diameter <- function(what) {
    col("diameter_mm", TRUE, "numeric", "mm", "> 0", what, "26.8")
  }
  weight <- function(example) {
    col(
      "weight_kg",
      TRUE,
      "numeric",
      "kg",
      "> 0",
      "The plant's weight.",
      example
    )
  }
  fronds <- col(
    "fronds",
    TRUE,
    "integer",
    NA,
    "whole number >= 1",
    "The number of fronds reaching 1 m above the holdfast.",
    "5"
  )
  census_id <- col(
    "survey_id",
    TRUE,
    "character",
    NA,
    "a survey_id of the in situ data",
    "The survey the plant was counted in.",
    "otter_cove-2024-1"
  )
  partial <- col(
    "partial",
    FALSE,
    "logical",
    NA,
    "TRUE or FALSE",
    "Whether the plant counts as half, such as a plant on the edge of a transect.",
    "FALSE"
  )
  drone <- function(required, missing) {
    or_missing <- if (missing) ", or missing" else ""
    dplyr::bind_rows(
      col(
        "plot_area_m2",
        required,
        "numeric",
        m2,
        paste0("> 0", or_missing),
        "The area of the plot polygon the canopy cover is measured over.",
        "232.5"
      ),
      col(
        "canopy_area_m2",
        required,
        "numeric",
        m2,
        paste0(">= 0 and <= plot_area_m2", or_missing),
        "The canopy area delineated within the plot polygon.",
        "46.3"
      ),
      col(
        "canopy_tide_height_m",
        required,
        "numeric",
        "m",
        paste0("any number", or_missing),
        "The tide height when the canopy was imaged, relative to chart datum.",
        "0.75"
      )
    )
  }
  wetdry <- dplyr::bind_rows(
    col(
      "wet_mass_g",
      TRUE,
      "numeric",
      "g",
      "> 0",
      "The mass of the tissue sample before drying.",
      "4.16"
    ),
    col(
      "dry_mass_g",
      TRUE,
      "numeric",
      "g",
      "> 0 and < wet_mass_g",
      "The mass of the tissue sample after drying.",
      "0.33"
    )
  )
  element <- function(element, example) {
    dplyr::bind_rows(
      col(
        "sample_mass_mg",
        TRUE,
        "numeric",
        "mg",
        "> 0",
        "The mass of the dried tissue sample analysed.",
        "2.33"
      ),
      col(
        paste0(element, "_mass_ug"),
        TRUE,
        "numeric",
        ug,
        "> 0 and less than the sample mass",
        paste0("The mass of ", element, " measured in the sample."),
        example
      )
    )
  }
  cover_calibration <- dplyr::bind_rows(
    col(
      "biomass_kg_m2",
      TRUE,
      "rvar",
      paste0("kg/", m2),
      ">= 0",
      paste0("The draws of the survey's wet biomass per ", m2, "."),
      "1.9"
    ),
    site("The site surveyed.", "otter_cove"),
    year("The year of the survey."),
    drone(required = TRUE, missing = TRUE)
  )

  datasets <- list(
    weight_nereo = dplyr::bind_rows(
      diameter("The plant diameter, measured as in the size data."),
      weight("0.73"),
      site("The site the plant was sampled at.", "otter_cove"),
      year("The year the plant was sampled.")
    ),
    weight_macro = dplyr::bind_rows(
      fronds,
      weight("3.96"),
      site("The site the plant was sampled at.", "seal_ledge"),
      year("The year the plant was sampled.")
    ),
    size_sample_nereo = dplyr::bind_rows(
      diameter("The plant diameter, measured as in the weight data."),
      site("The site the plant was measured at.", "otter_cove"),
      year("The year the plant was measured.")
    ),
    size_census_nereo = dplyr::bind_rows(
      census_id,
      diameter("The plant diameter, measured as in the weight data."),
      partial
    ),
    size_census_macro = dplyr::bind_rows(
      census_id,
      fronds,
      partial
    ),
    in_situ = dplyr::bind_rows(
      col(
        "survey_id",
        TRUE,
        "character",
        NA,
        "text or number, unique to each survey",
        "The survey's identifier.",
        "otter_cove-2024-1"
      ),
      site("The site surveyed.", "otter_cove"),
      year("The year of the survey."),
      col(
        "survey_area_m2",
        TRUE,
        "numeric",
        m2,
        "> 0",
        "The area searched for plants.",
        "182.3"
      ),
      col(
        "plants",
        FALSE,
        "integer",
        NA,
        "whole number >= 0",
        "The number of plants counted, given only when sizes come from a size sample.",
        "360"
      ),
      drone(required = FALSE, missing = TRUE)
    ),
    canopy = dplyr::bind_rows(
      site("The site mapped.", "otter_cove"),
      year("The year of the map."),
      col(
        "canopy_area_m2",
        TRUE,
        "numeric",
        m2,
        ">= 0 and <= classified_area_m2",
        "The canopy area mapped.",
        "7528"
      ),
      col(
        "canopy_tide_height_m",
        TRUE,
        "numeric",
        "m",
        "any number",
        "The tide height when the canopy was imaged, relative to chart datum.",
        "1.0"
      ),
      col(
        "classified_area_m2",
        TRUE,
        "numeric",
        m2,
        "> 0",
        "The water area the canopy classification covered, including water where no canopy was found.",
        "18478"
      )
    ),
    wetdry_nereo = wetdry,
    wetdry_macro = wetdry,
    carbon_nereo = element("carbon", "594"),
    carbon_macro = element("carbon", "745"),
    nitrogen_nereo = element("nitrogen", "42.9"),
    nitrogen_macro = element("nitrogen", "45.1"),
    cover_calibration_nereo = cover_calibration,
    cover_calibration_macro = cover_calibration
  )
  dplyr::bind_rows(datasets, .id = "dataset")
})

# The names of a dataset's columns, the required ones only by default.
data_column_names <- function(dataset, required = TRUE) {
  rows <- data_columns[data_columns$dataset == dataset, ]
  if (required) {
    rows <- rows[rows$required, ]
  }
  rows$column
}

# The column lists of a data check topic, as markdown.
doc_data_columns <- function(dataset) {
  rows <- data_columns[data_columns$dataset == dataset, ]
  description <- sub("\\.$", "", rows$description)
  description <- paste0(
    tolower(substr(description, 1, 1)),
    substring(description, 2)
  )
  constraint <- ifelse(
    is.na(rows$units),
    rows$allowed,
    paste0(rows$units, ", ", rows$allowed)
  )
  item <- paste0("- `", rows$column, "`, ", description, " (", constraint, ").")
  section <- function(title, keep) {
    if (!any(keep)) {
      return(NULL)
    }
    c(title, "", item[keep], "")
  }
  paste(
    c(
      section("Required columns:", rows$required),
      section("Optional columns:", !rows$required)
    ),
    collapse = "\n"
  )
}
