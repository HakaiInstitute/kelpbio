# Expected value of an intercept-only fit, one value per draw.
population_draws <- function(fit) {
  lp <- .linpred(fit, tibble::tibble(.rows = 1L), new_levels = "average")
  as.vector(posterior::draws_of(.epred(fit, lp)))
}
