#
# test_gompertz.R
#
# copyright (c) 2026 - Rob Williams
#
# Check that gompertz.fit recovers known parameters from simulated, left-truncated ages at death
# (1,000 animals per run, 200 runs), and that the slope test holds its nominal 5% error rate. Then check the
# class comparison used by the pre-registered secondary tests (see the end of the file).
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

# The class comparison of the secondary tests (gompertz.classes.compare with the strain jackknife), checked under the
# null: two classes of 30 strains with the same mean MRDT, two diets, 8 mice per strain and diet, entry by 200 d.
# Strains differ in level (sd 0.4 on the log scale) and in slope (sd 0.05 on log b), as real strains do.
# The jackknife test should reject about 5% of the time; the animal-level likelihood-ratio test, which treats mice
# of one strain as independent, may reject more often.
set.seed(2)
res <- c()
for (i in 1:200) {
  sim <- c()
  for (k in c("B", "D")) for (s in 1:30) for (diet in c("CD", "HF")) {
    a.s <- 2e-5 * exp(rnorm(1, 0, 0.4)) * ifelse(diet == "HF", 1.42, 1)
    b.s <- log(2) / 150 * exp(rnorm(1, 0, 0.05))
    setup <- sample(30:180, 8, replace = TRUE)
    age <- rgompertz.trunc(8, a.s, b.s, setup)
    sim <- rbind(sim, data.frame(class = k, strain = paste0(k, s), diet = diet, age = age))
  }
  sim <- sim[sim[, "age"] >= 200, ]
  entry <- rep(200, nrow(sim))
  cmp <- gompertz.classes.compare(sim[, "age"], entry, sim[, "diet"], sim[, "class"])
  jk <- gompertz.jackknife(sim[, "age"], entry, sim[, "diet"], sim[, "class"], sim[, "strain"])
  t <- cmp$delta / jk$se
  res <- rbind(res, c(delta = cmp$delta, p.jack = 2 * pt(-abs(t), jk$n - 1), p.lrt = unname(cmp$lrt["p"])))
}
cat("\nClass comparison under the null (200 runs): mean delta", round(mean(res[, "delta"]), 4), "\n")
cat("Jackknife test false-positive rate at 0.05:", mean(res[, "p.jack"] < 0.05), "\n")
cat("Animal-level LRT false-positive rate at 0.05:", mean(res[, "p.lrt"] < 0.05), "\n")
