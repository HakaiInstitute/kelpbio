# Deviance Residuals

Posterior point estimates of the deviance residual at each observed row,
from the Student-t log-weight likelihood, matching
[`augment()`](https://generics.r-lib.org/reference/augment.html)'s
`residual` column.

## Usage

``` r
# S3 method for class 'kb_fit_weight'
residuals(object, ...)
```

## Arguments

- object:

  A `kb_fit_weight` object.

- ...:

  Unused.

## Value

A numeric vector of deviance residuals, length `nobs(object)`.

## Details

The deviance residual is computed per draw, then summarised with the
posterior median.

## See also

[`fitted()`](https://rdrr.io/r/stats/fitted.values.html) for fitted
values, and
[`augment()`](https://generics.r-lib.org/reference/augment.html).

Other generics:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`converged.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/converged.kb_fit.md),
[`fitted.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit_weight.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit_weight.md),
[`posterior_linpred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit_weight.md),
[`posterior_predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit_weight.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
residuals(fit_weight_sim_nereo)
#>   [1] -0.241872016  0.378468708 -0.053961040  1.110174664 -0.212433497
#>   [6]  1.193768936  0.199290846  0.582267761 -2.527594201 -1.016118242
#>  [11] -1.843456590  0.204411549 -1.790041397  0.694306845 -1.285383223
#>  [16]  0.245072285  1.110719577  0.766485380 -1.336669911  0.295624372
#>  [21] -0.409223226 -0.849536100  1.023095038  1.182671143  0.159868539
#>  [26]  1.912864932  1.380385786 -0.445537039 -0.827131848 -1.812372166
#>  [31] -0.695867690 -0.319060774  0.663160934 -0.306236391  0.049315588
#>  [36]  1.474737581  0.239952350  0.688914716 -1.980827395 -0.288061983
#>  [41]  2.211347139 -0.220151102 -0.121602787  1.720487118 -0.173367778
#>  [46] -0.436893255 -1.800950287 -0.123768257  0.402209892 -0.130550309
#>  [51] -1.892259958  0.441629272 -1.963935559  2.054910519  1.331997777
#>  [56]  0.220606582  1.133594570  0.019719137  0.181318548  0.055389746
#>  [61]  2.371458210 -0.420653222  0.657211642  0.110384505 -0.489410742
#>  [66] -1.593492477 -0.252258900 -1.279715269  0.118566882  0.467840921
#>  [71] -0.256698937  0.619688999  0.628629409 -0.152418996 -0.983832125
#>  [76] -0.915632719  0.017234181 -0.493099144 -0.401754982  2.305075422
#>  [81] -1.006846023  0.450167792  0.967352541 -1.099779125 -0.824609051
#>  [86]  1.592852877 -2.417242153  0.381877218 -0.324231933  1.274185371
#>  [91] -0.184372578  0.782041144 -0.637370496  0.013755466  1.877302789
#>  [96]  0.025372364 -0.434512283  0.684272831 -0.551540607  1.472048660
#> [101] -0.133286662  0.977105235  0.550323507 -0.924129347 -0.142806102
#> [106] -0.386405610  1.029526486 -0.321446190 -2.142434526  1.008288927
#> [111] -1.825124096  1.827828180  0.037856301 -0.751846980 -0.913416659
#> [116]  0.707926765  0.854785340 -0.821131395  0.398682335 -1.390422838
#> [121]  0.373681855 -1.495852083 -0.249836840 -0.268698000  1.382285613
#> [126] -0.405588286 -1.140606112  0.053499396  1.731587346  0.651439444
#> [131]  0.320194610 -0.907916751  0.668877656  0.908250852 -2.597331920
#> [136] -0.876122929  2.072819660 -0.406443194  0.005729624  0.506393040
#> [141] -1.360098740  0.744840131  0.449599159 -0.100285212 -1.020774329
#> [146] -0.006802240 -1.154461061 -0.676672171  1.217112230  1.636706938
#> [151] -1.271749504  0.473698309 -0.541554628 -1.764897824  0.969337319
#> [156]  1.306201018  1.378560611  2.445252117  2.319449818 -1.078018299
#> [161] -2.597629841 -0.852012127 -0.706903822  0.903352535  0.502215220
#> [166] -0.682022444  0.080389845  0.575822516  1.773328252 -0.347287694
#> [171]  1.003479122  1.511676179 -0.659505124 -0.600336183  0.011147662
#> [176] -1.151996989 -1.699416301 -0.465912500  1.589002118 -1.034266707
#> [181] -0.543482346 -1.655101529 -0.272902396 -0.299644741 -0.378695206
#> [186]  1.502194547 -0.920482803  1.382730760  0.984248554  0.809036564
#> [191]  1.376209494 -0.876160398  0.517728810 -0.350657231  1.004341595
#> [196]  1.645960362 -0.468219791 -1.338251063  0.938656989 -1.918223248
#> [201]  0.360329068  0.093849546 -0.615099436 -0.403030806  0.173828157
#> [206]  0.112801213 -2.312432408  0.890602568  1.710223343 -1.410550079
#> [211]  2.043026548  0.668837930 -1.541149643 -0.074683436 -1.178358749
#> [216]  0.068448064 -1.005954505  0.353805976 -0.661900488  0.836190189
#> [221] -1.639347085 -1.120389274  0.206028856 -0.601606943  1.251302888
#> [226]  0.081821053 -0.223588383 -0.012913485 -0.566110479 -0.589070182
#> [231]  0.991299805  1.430676807 -1.112590371  0.714118340
```
