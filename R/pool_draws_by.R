# Per-draw sums of the row draws (D x N) within `pool_by` groups (character(0)
# sums all rows), returning the group keys, each row's group, and a D x G
# matrix. With `area` (length N, or D x N), each sum is divided by its group's
# summed area, giving the group's value per unit area. Summing draws, not
# summaries, keeps the limits of a group's total correct.
pool_draws_by <- function(grid, draws, pool_by, area = NULL) {
  keys <- tibble::as_tibble(grid)[pool_by]
  if (length(pool_by)) {
    groups <- dplyr::distinct(keys)
    # Character groups sort alphabetically ignoring case, then by case, the
    # same on every machine; factors keep their level order.
    sort_keys <- lapply(groups, function(x) {
      if (is.character(x)) list(tolower(x), x) else list(x)
    })
    ord <- do.call(order, c(unlist(sort_keys, recursive = FALSE), method = "radix"))
    groups <- groups[ord, , drop = FALSE]
    id <- match(do.call(paste, c(keys, sep = "\r")), do.call(paste, c(groups, sep = "\r")))
  } else {
    groups <- tibble::tibble(.rows = 1L)
    id <- rep(1L, nrow(grid))
  }
  # rowsum() orders by ascending id, which is the order of `groups`.
  sums <- t(rowsum(t(draws), id))
  if (!is.null(area)) {
    if (!is.matrix(area)) {
      area <- matrix(area, nrow = nrow(draws), ncol = length(area), byrow = TRUE)
    }
    sums <- sums / t(rowsum(t(area), id))
  }
  list(groups = groups, id = id, draws = sums)
}
