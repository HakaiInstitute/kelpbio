# Fitted Weights

Posterior point estimates (median) of the expected weight at each
observed row, on the response scale, matching
[`augment()`](https://generics.r-lib.org/reference/augment.html)'s
`fitted` column. For the full posterior, use
[`posterior_epred()`](https://mc-stan.org/rstantools/reference/posterior_epred.html).

## Usage

``` r
# S3 method for class 'kb_fit_weight'
fitted(object, ...)
```

## Arguments

- object:

  A `kb_fit_weight` object.

- ...:

  Unused.

## Value

A numeric vector of fitted weights, length `nobs(object)`.

## See also

[`residuals()`](https://rdrr.io/r/stats/residuals.html) for deviance
residuals,
[`augment()`](https://generics.r-lib.org/reference/augment.html), and
[`posterior_epred()`](https://mc-stan.org/rstantools/reference/posterior_epred.html)
for the full posterior.

Other generics:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`converged.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/converged.kb_fit.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit_weight.md),
[`posterior_linpred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit_weight.md),
[`posterior_predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit_weight.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit_weight.md),
[`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
fitted(fit_weight_sim_nereo)
#>   [1] 0.42652068 0.17329241 0.05945690 0.44150554 0.06192467 0.34224205
#>   [7] 0.67234775 0.13227065 0.27893042 0.53355905 0.06046526 0.35368419
#>  [13] 0.10737515 0.16791582 0.04660292 0.06663802 0.17209421 0.43833345
#>  [19] 0.19656041 0.07182733 0.14130352 0.27547151 0.36381991 0.35257136
#>  [25] 0.27075576 0.06160671 0.11878009 0.37770732 0.09736670 0.32653697
#>  [31] 0.41136980 1.20076942 0.72729117 1.41775109 1.17995363 0.39803192
#>  [37] 0.14107678 0.34917763 0.16922229 1.74587390 0.75594818 0.52407011
#>  [43] 0.17906046 0.90367573 0.41615563 0.10334985 0.11703065 0.09775823
#>  [49] 0.17558169 0.17833562 0.26585330 1.57972582 0.11617791 0.17292803
#>  [55] 0.64799998 0.15607283 0.10588090 0.16056095 0.07315330 0.24311873
#>  [61] 0.25272852 0.10096449 0.39367242 0.13873664 0.01610386 0.30660377
#>  [67] 0.12436786 0.52277102 0.14056658 0.09230387 0.26878355 0.05845057
#>  [73] 0.19875565 0.82035279 0.07406268 0.57197382 0.07482359 0.23550773
#>  [79] 0.30008667 0.39714822 0.92809661 0.34633124 0.11588177 0.24789412
#>  [85] 0.15037641 0.85587130 0.64612006 0.27174788 0.38350555 0.35189526
#>  [91] 0.55490338 0.39504885 0.60385296 1.17083855 1.15805699 0.52305361
#>  [97] 0.19162914 0.57071645 0.58614424 0.16559858 0.81008302 0.48868293
#> [103] 0.03318095 0.26810347 0.20209744 0.11746054 0.05820692 0.21799393
#> [109] 0.13692579 0.31754441 0.71346117 0.13571435 0.29833978 0.26541720
#> [115] 0.21576211 0.07643497 0.30651831 0.16921709 0.08860227 0.23218124
#> [121] 0.02838610 0.26531559 0.44799031 0.53364924 0.05141130 0.15061913
#> [127] 0.43331275 0.46737325 0.20884867 0.52184683 0.21297199 0.22691991
#> [133] 0.05972885 0.76083523 0.14638420 0.30471761 0.13553078 0.03710682
#> [139] 0.35971366 0.16095506 0.10051791 0.26399868 0.10399289 0.14199030
#> [145] 0.18934806 0.09108863 1.24402855 0.45504682 0.68473854 0.38242876
#> [151] 0.77954744 0.23240866 0.26613780 1.71160906 0.30285608 0.48139580
#> [157] 0.08831512 0.19722035 0.19591692 0.89800819 0.11580953 0.21486404
#> [163] 0.18976710 0.30525078 0.61965747 0.42253327 0.34403103 0.05242845
#> [169] 0.64407956 1.03749778 0.20272795 0.81196403 0.20272795 0.52118355
#> [175] 0.09285026 0.11810492 0.12346343 0.03433683 0.04082646 0.21872923
#> [181] 0.14533662 0.10267445 0.57161069 0.97356090 0.17420757 0.32878045
#> [187] 0.17695244 0.29815423 0.27936945 0.88916692 0.17183363 0.11507237
#> [193] 0.10746558 0.26168289 0.29962677 0.42028555 0.17148624 0.16058640
#> [199] 0.12159820 0.16758773 0.05222077 0.29998441 0.05796981 0.21423929
#> [205] 0.52408969 0.08465373 0.10906845 0.22493089 0.08870756 0.05248963
#> [211] 0.73724839 0.27340883 0.18374576 0.26992752 0.83236693 0.87952414
#> [217] 0.69307685 0.22508729 0.12232132 0.10402379 0.11680908 0.10825624
#> [223] 0.17092744 0.13325282 0.21758791 0.28167804 0.36174303 0.13625449
#> [229] 0.67802932 0.15928350 0.23712028 0.20641119 0.33034188 0.20958199
```
