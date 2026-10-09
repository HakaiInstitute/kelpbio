#' Validate Macrocystis Cover Biomass Model Data
#'
#' Check that `data` contains the drone-survey columns required to fit the
#' *Macrocystis pyrifera* cover biomass model, and that `biomass`, when supplied, is valid
#' in situ biomass to pair with it.
#'
#' Required columns of `data`: numeric `canopy_area_m2` (m², >= 0),
#' `plot_area_m2` (m², > 0 and at least `canopy_area_m2`), `tide_height_m`
#' (m), factor or character `site`, and factor, character, or whole-number
#' `year`, with no missing values.
#'
#' Required columns of `biomass`: factor or character `site` and factor,
#' character, or whole-number `year`, one row per site-year, and numeric
#' `estimate`, `lower`, and `upper` (kg/m², > 0, with `lower <= estimate <= upper`
#' and `lower < upper`), with no missing values.
#'
#' @details
#' Each row of `data` is one drone survey of a plot. `canopy_area_m2` is the
#' canopy area the drone imagery delineated within the plot, `plot_area_m2` the
#' plot area, and `tide_height_m` the tide height at the survey (chart datum). A
#' survey with no delineated canopy has a `canopy_area_m2` of 0. `data` must not
#' have `estimate`, `lower`, or `upper` columns, since the response comes from
#' `biomass`.
#'
#' `biomass` holds the in situ wet biomass (kg per m²) of each site-year and its
#' compatibility limits, such as the output of a biomass prediction. Other
#' columns of either data frame are ignored.
#'
#' @param data A data frame of drone surveys, one row per survey.
#' @param biomass A data frame of in situ wet biomass, one row per site-year, or
#'   `NULL` to check `data` only.
#' @param x_name A string naming `data` in error messages.
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(
#'   canopy_area_m2 = c(60, 0), plot_area_m2 = c(200, 210),
#'   tide_height_m = c(0.5, 1.1), site = c("a", "b"), year = c("2020", "2021")
#' )
#' biomass <- data.frame(
#'   site = c("a", "b"), year = c("2020", "2021"),
#'   estimate = c(2.8, 0.05), lower = c(1.2, 0.02), upper = c(6.1, 0.12)
#' )
#' kb_check_data_cover_biomass_macro(data, biomass)
kb_check_data_cover_biomass_macro <- function(
  data,
  biomass = NULL,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(.chk_cover_biomass_data(data, biomass, x_name), rlang::current_env())
  invisible(data)
}
