#' Validate Macrocystis Size Model Data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* size model, with appropriate types and values.
#'
#' Required columns: whole-number `fronds` (> 0), factor or character `site`, and
#' factor, character, or whole-number `year`, with no missing values.
#'
#' @details
#' `fronds` is the number of fronds reaching 1 m above the holdfast. The model
#' describes plants with at least one such frond, so a count of zero is an
#' error; remove those plants before fitting. The density data
#' ([kb_check_data_density_macro()]) must count the same plants, so leave them
#' out of the density counts too. Other columns are ignored.
#'
#' @inheritParams kb_check_data_size_nereo
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(
#'   fronds = c(3, 12), site = factor(c("a", "b")),
#'   year = c(2020, 2021)
#' )
#' kb_check_data_size_macro(data)
kb_check_data_size_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_data(data, x_name = x_name)
      chk::chk_superset(
        names(data),
        c("fronds", "site", "year"),
        x_name = x_name
      )
      fronds_name <- column_xname(x_name, "fronds")
      chk::chk_numeric(data$fronds, x_name = fronds_name)
      chk::chk_not_any_na(data$fronds, x_name = fronds_name)
      .chk_finite(data$fronds, fronds_name)
      .chk_frond_reaches_1m(data$fronds, x_name = fronds_name)
      chk::chk_whole_numeric(data$fronds, x_name = fronds_name)
      .chk_group_columns(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
