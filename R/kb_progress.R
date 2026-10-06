#' Completed Fraction of a Running Task
#'
#' The proportion completed by a fit or a long prediction writing to
#' `progress_dir`, as a number from 0 to 1.
#'
#' @details
#' Pass the same directory given as `progress_dir` to a `kb_fit_*` function or to
#' [kb_predict_plot_biomass()]. This reads progress from another R process: for
#' example, a Shiny app can run the task in the background and poll
#' `kb_progress()` from the main session to drive a progress indicator. It
#' returns `0` before the task has written anything and `1` once it has finished.
#' When a prediction and a fit share a directory, the prediction's progress is
#' reported once it has started; use a new directory for each task to keep them
#' apart.
#'
#' @param progress_dir A string giving the directory passed as `progress_dir` to
#'   the task.
#' @return A number between 0 and 1.
#' @export
#' @examples
#' progress_dir <- tempfile()
#' dir.create(progress_dir)
#' # Before a task has written anything, progress is 0.
#' kb_progress(progress_dir)
kb_progress <- function(progress_dir) {
  chk::chk_string(progress_dir)
  read_prediction_progress(progress_dir) %||% read_progress_fraction(progress_dir)
}
