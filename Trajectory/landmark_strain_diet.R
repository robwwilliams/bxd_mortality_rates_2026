#
# landmark_strain_diet.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory, added on 29 October 2026 after the results of landmark_trajectory.R were seen.
# How strongly do the landmark classes, body weight and weight gain track diet, strain and genotype type
# (BXD strain, parental strain or F1 hybrid)? And what do the mice of each class actually weigh, by diet?
#   Observed weights: mean of the weighings in each age bin, by class and diet (A1, A2, A3, and the whole-record classes).
#   Strain: one-way ANOVA intraclass correlation within diet, over strain x diet groups with at least 5 mice;
#           share of mice in their group's most common class, against class labels shuffled within diet (2,000 times).
#
# Run from the repository root after landmark_trajectory.R:  Rscript Trajectory/landmark_strain_diet.R
# Writes output/Landmark_strain_diet.txt
#

L <- readLines("Trajectory/landmark_trajectory.R")
eval(parse(text = L[1:(grep("^# Class model", L)[1] - 1)]))   # libraries, mice and the cleaned weighings W
set.seed(seed)
sink("output/Landmark_strain_diet.txt")

d0 <- read.delim("output/Landmark_mice.txt", check.names = FALSE)

# Mean observed weight by class, diet and age bin
observed <- function(label, breaks, trim = FALSE) {
  d <- d0[d0[, "analysis"] == label & !is.na(d0[, "cls"]), ]; d <- d[!duplicated(d[, "EarTag"]), ]
  w <- W[W[, "EarTag"] %in% d[, "EarTag"] & W[, "age"] < max(breaks), ]
  if (trim) w <- w[w[, "age"] <= w[, "End"] - 120, ]
  w[, "cls"] <- d[match(w[, "EarTag"], d[, "EarTag"]), "cls"]
  w[, "bin"] <- cut(w[, "age"], breaks, right = FALSE)
  cat("\n==", label, "==\nMice by class and diet\n"); print(table(class = d[, "cls"], diet = d[, "Diet"]))
  for (dt in c("CD", "HF")) {
    x <- w[w[, "Diet"] == dt, ]
    cat("Mean observed weight (g) by age (days),", dt, "\n"); print(round(tapply(x[, "wt"], list(class = x[, "cls"], age = x[, "bin"]), mean), 1))
  }
}
observed("A1 L365 g120", c(0, 150, 210, 270, 330, 365))
observed("A2 L365 g0", c(0, 150, 210, 270, 330, 365))
observed("A3 L545 g120", c(0, 150, 240, 330, 420, 480, 545))
observed("B1 whole record", c(0, 150, 270, 390, 510, 630, 750, 2000))
observed("B2 whole record minus last 120 d", c(0, 150, 270, 390, 510, 630, 750, 2000), trim = TRUE)

# A1: weight, gain, diet, genotype type and strain
d <- d0[d0[, "analysis"] == "A1 L365 g120", ]
pre <- W[W[, "age"] < 365 & W[, "EarTag"] %in% d[, "EarTag"], ]
first <- pre[order(pre[, "EarTag"], pre[, "age"]), ]; first <- first[!duplicated(first[, "EarTag"]), ]
last <- pre[order(pre[, "EarTag"], -pre[, "age"]), ]; last <- last[!duplicated(last[, "EarTag"]), ]
d[, c("a0", "w0")] <- first[match(d[, "EarTag"], first[, "EarTag"]), c("age", "wt")]
d[, c("a1", "w1")] <- last[match(d[, "EarTag"], last[, "EarTag"]), c("age", "wt")]
d[, "gain"] <- 100 * (d[, "w1"] - d[, "w0"]) / (d[, "a1"] - d[, "a0"])   # g per 100 days
d[, "type"] <- ifelse(grepl("^BXD", d[, "Genotype"]), "BXD", ifelse(d[, "Genotype"] %in% c("C57BL/6J", "DBA/2J"), "parent", "F1"))
d[, "grp"] <- paste(d[, "Genotype"], d[, "Diet"])

cat("\n== A1: diet ==\nMean age (d) and weight (g) at the first weighing and the last before 365 d, and gain (g per 100 d)\n")
print(aggregate(cbind(a0, w0, a1, w1, gain) ~ Diet, d, function(x) round(mean(x), 1)))
print(table(class = d[, "cls"], diet = d[, "Diet"])); print(round(100 * prop.table(table(class = d[, "cls"], diet = d[, "Diet"]), 2), 1))
print(chisq.test(table(d[, "cls"], d[, "Diet"])))

cat("\n== A1: genotype type ==\n")
print(table(class = d[, "cls"], type = d[, "type"])); print(round(100 * prop.table(table(class = d[, "cls"], type = d[, "type"]), 2), 1))
print(table(diet = d[, "Diet"], type = d[, "type"]))

# Intraclass correlation, one-way ANOVA estimator
icc <- function(y, g) {
  a <- anova(lm(y ~ factor(g))); msb <- a[1, "Mean Sq"]; msw <- a[2, "Mean Sq"]
  n <- table(g); N <- sum(n); n0 <- (N - sum(n^2) / N) / (length(n) - 1)
  (msb - msw) / (msb + (n0 - 1) * msw)
}
g5 <- names(which(table(d[, "grp"]) >= 5)); e <- d[d[, "grp"] %in% g5, ]
cat("\n== A1: strain, within diet (strain x diet groups with >= 5 mice:", length(g5), "groups,", nrow(e), "mice) ==\n")
out <- do.call(rbind, lapply(c("CD", "HF"), function(dt) {
  x <- e[e[, "Diet"] == dt, ]
  data.frame(diet = dt, mice = nrow(x), groups = length(unique(x[, "grp"])), first.weight = icc(x[, "w0"], x[, "grp"]),
             weight.before.365 = icc(x[, "w1"], x[, "grp"]), gain = icc(x[, "gain"], x[, "grp"]),
             t(sapply(1:4, function(k) setNames(icc(as.numeric(x[, "cls"] == k), x[, "grp"]), paste0("class", k)))))
}))
print(cbind(out[, 1:3], round(out[, -(1:3)], 2)), row.names = FALSE)

modal <- function(cl, g) sum(tapply(cl, g, function(v) max(table(v)))) / length(cl)
obs <- modal(e[, "cls"], e[, "grp"])
perm <- replicate(2000, { cl <- e[, "cls"]; for (dt in c("CD", "HF")) { i <- e[, "Diet"] == dt; cl[i] <- sample(cl[i]) }; modal(cl, e[, "grp"]) })
cat("\nShare of mice in their strain x diet group's most common class: observed", round(obs, 3), "; labels shuffled within diet: mean",
    round(mean(perm), 3), ", 95% range", paste(round(quantile(perm, c(0.025, 0.975)), 3), collapse = "-"), "\n")
g10 <- names(which(table(d[, "grp"]) >= 10)); s <- tapply(d[d[, "grp"] %in% g10, "cls"], d[d[, "grp"] %in% g10, "grp"], function(v) max(table(v)) / length(v))
cat("Groups with >= 10 mice:", length(s), "; with every mouse in one class:", sum(s == 1), "\n")

sink()
