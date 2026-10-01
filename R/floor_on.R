# Whether the Nereocystis weight fit includes the weight floor: every form but
# the power law does. A fit made before `form` existed has no meta$form and was
# fitted with the floor, so a missing form reads as TRUE.
.floor_on <- function(fit) {
  !identical(fit$meta$form, "power")
}
