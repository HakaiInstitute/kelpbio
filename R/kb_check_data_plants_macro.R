#' Check Macrocystis plant data
#'
#' Check that `data` has the columns and values of a table of every counted
#' *Macrocystis pyrifera* plant, for [kb_predict_biomass_survey()].
#'
#' @details
#' Each row is one counted plant, an individual (sporophyte) identified by its
#' holdfast. Required columns:
#'
#' - `site`, `plot_id`, and `date`, the survey the plant was counted in (see
#'   [kb_check_data_survey()]).
#' - `fronds`, the number of fronds reaching 1 m above the holdfast (a whole
#'   number of at least 1), the predictor of the weight model
#'   ([kb_fit_weight_macro()]).
#'
#' An optional logical `partial` marks plants counted as half, such as plants
#' on the edge of a transect. Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of counted plants, one row per plant.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' kb_check_data_plants_macro(data_plants_sim_macro)
kb_check_data_plants_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_plants_data(data, "fronds", x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
