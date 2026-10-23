#
# test_gompertz.R
#
# copyright (c) 2026 - Rob Williams
#
# Check that gompertz.fit recovers known parameters from simulated, left-truncated ages at death
# (1,000 animals per run, 200 runs), and that the slope test holds its nominal 5% error rate.
#

source("Gompertz/gompertz.R")

# Draw ages at death from a Gompertz law, conditional on surviving to the entry age
rgompertz.trunc <- function(n, a, b, entry) {
  # S(t | entry) = exp(-(H(t) - H(entry))); invert for t
  u <- runif(n)
  log(exp(b * entry) - (b / a) * log(u)) / b
}

set.seed(1)
a <- 2e-5; b <- log(2) / 120          # MRDT of 120 days
res <- c()
for (i in 1:200) {
  entry <- sample(30:300, 1000, replace = TRUE)
  age <- rgompertz.trunc(1000, a, b, entry)
  f <- gompertz.fit(age, entry)
  grp <- rep(c("A", "B"), each = 500)
  cmp <- gompertz.compare(age, entry, grp)   # same law in both groups: the slope test should reject ~5%
  res <- rbind(res, c(MRDT = f$MRDT, covered = f$MRDT.lo <= 120 & f$MRDT.hi >= 120, p.slope = cmp$slope["p"]))
}
cat("True MRDT 120 d; mean estimate", round(mean(res[, "MRDT"]), 1), "d\n")
cat("95% CI coverage:", mean(res[, "covered"]), "\n")
cat("Slope test false-positive rate at 0.05:", mean(res[, 3] < 0.05), "\n")
