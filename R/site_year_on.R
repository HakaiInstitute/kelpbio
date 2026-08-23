# Whether the fit retained the site:year effect. A fit that omitted it holds
# prior-only bSiteYear / sSiteYear draws, which no surface may present as
# estimated. A missing flag (fits built before it was recorded) reads as on,
# since those fits always included the effect; only an explicit FALSE is off.
# Read through here rather than off meta directly, so the prediction engine and
# the model description cannot disagree about a legacy fit.
.site_year_on <- function(fit) {
  !isFALSE(fit$meta$site_year_on)
}
