# values beyond half the minimum or twice the maximum warn

    Code
      warn_outside_range(fit, c(3, 30, 150), "diameter")
    Condition
      Warning:
      2 values of diameter lie far outside the fitted range (10 to 50).
      i Check that the values are in millimetres.

# a column without a unit gets no unit hint

    Code
      warn_outside_range(fit_with(fronds = c(1, 20)), 100, "fronds")
    Condition
      Warning:
      1 value of fronds lies far outside the fitted range (1 to 20).

