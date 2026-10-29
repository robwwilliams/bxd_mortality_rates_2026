#
# landmark_single_weight.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory, added on 29 October 2026 after the results of landmark_trajectory.R were seen. Written by Claude at
# Rob's request; the definitions below were fixed before these models were fitted.
#   Part 1, landmark at 1 year (A1 mice, survival from 485 d): one weight at a fixed age (the weighing within 20 d of
#           90, 120, ..., 330 d), standardized within diet, against the A1 classes in the same mice, on each diet.
#   Part 2, landmark at 18 months (A3 mice, survival from 665 d): does a mouse's recent change in weight add to its size?
#     size     the weighing nearest 515 d, within 480-544 d
#     change   (size - the weighing nearest 365 d, within 320-410 d) per 100 d
#     of.peak  size as a percentage of the highest weight before 545 d
#     Each is standardized within diet. Cox models of survival from 665 d, stratified by diet, robust by strain;
#     likelihood-ratio tests of each term beyond size, and of class beyond size and change; within-strain versions
#     stratified by strain x diet; Harrell's concordance, and its difference between models.
#
# Run from the repository root after landmark_trajectory.R:  Rscript Trajectory/landmark_single_weight.R
# Writes output/Landmark_single_weight.txt
#

L <- readLines("Trajectory/landmark_trajectory.R")
eval(parse(text = L[1:(grep("^# Class model", L)[1] - 1)]))   # libraries, mice and the cleaned weighings W
sink("output/Landmark_single_weight.txt")
d0 <- read.delim("output/Landmark_mice.txt", check.names = FALSE)

# Weight and age of each mouse's weighing nearest to an age, within [lo, hi]; NA if none
near <- function(w, ids, target, lo, hi) {
  x <- w[w[, "age"] >= lo & w[, "age"] <= hi, ]
  x <- x[order(x[, "EarTag"], abs(x[, "age"] - target)), ]; x <- x[!duplicated(x[, "EarTag"]), ]
  x[match(ids, x[, "EarTag"]), c("age", "wt")]
}
zd <- function(v, diet) ave(v, diet, FUN = function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE))
cls.factor <- function(v) relevel(factor(v), ref = names(which.max(table(v))))
cstat <- function(f) round(unname(f$concordance["concordance"]), 3)
lr <- function(big, small) { s <- 2 * (big$loglik[2] - small$loglik[2]); k <- length(coef(big)) - length(coef(small))
  sprintf("LR %.1f, %d df, P = %.2g", s, k, pchisq(s, k, lower.tail = FALSE)) }

# Part 1: one weight at a fixed age, landmark at 1 year
cat("== Part 1: A1 mice, survival from 485 d. One weight within 20 d of each age, against the classes in the same mice ==\n")
d <- d0[d0[, "analysis"] == "A1 L365 g120", ]; d[, "cls"] <- cls.factor(d[, "cls"])
pre <- W[W[, "age"] < 365 & W[, "EarTag"] %in% d[, "EarTag"], ]
out <- NULL
for (a in seq(90, 330, 30)) {
  d[, "wt"] <- near(pre, d[, "EarTag"], a, a - 20, a + 20)[, "wt"]
  for (dt in c("CD", "HF")) {
    f <- d[d[, "Diet"] == dt & !is.na(d[, "wt"]), ]; f[, "z"] <- (f[, "wt"] - mean(f[, "wt"])) / sd(f[, "wt"])
    k <- coxph(Surv(entry, End, event) ~ z, f); kc <- coxph(Surv(entry, End, event) ~ cls, f)
    out <- rbind(out, data.frame(age = a, diet = dt, mice = nrow(f), C.weight = cstat(k), HR.perSD = round(exp(coef(k)), 2),
                                 P = signif(summary(k)$coefficients[, "Pr(>|z|)"], 2), C.class = cstat(kc)))
  }
}
print(out, row.names = FALSE)

# Part 1b: each mouse's first weighing is not a fixed-age weight, so its weight mixes age with size
cat("\n== Part 1b: A1 mice, the first weighing before 365 d ==\n")
first <- pre[order(pre[, "EarTag"], pre[, "age"]), ]; first <- first[!duplicated(first[, "EarTag"]), ]
d[, c("a0", "w0")] <- first[match(d[, "EarTag"], first[, "EarTag"]), c("age", "wt")]
for (dt in c("CD", "HF")) {
  f <- d[d[, "Diet"] == dt, ]
  f[, "z0"] <- (f[, "w0"] - mean(f[, "w0"])) / sd(f[, "w0"]); f[, "r0"] <- scale(resid(lm(w0 ~ splines::ns(a0, 3), f)))[, 1]
  k0 <- coxph(Surv(entry, End, event) ~ z0, f); k1 <- coxph(Surv(entry, End, event) ~ r0, f)
  cat(dt, ": n =", nrow(f), "; age (d) 5th, 50th, 95th percentiles", quantile(f[, "a0"], c(0.05, 0.5, 0.95)), "; correlation of age and weight",
      round(cor(f[, "a0"], f[, "w0"]), 2), "\n   weight as is: C", cstat(k0), "P", signif(summary(k0)$coefficients[, "Pr(>|z|)"], 2),
      "; adjusted for its age: C", cstat(k1), "HR/SD", round(exp(coef(k1)), 2), "P", signif(summary(k1)$coefficients[, "Pr(>|z|)"], 2), "\n")
}

# Part 2: recent change in weight beyond size, landmark at 18 months
cat("\n== Part 2: A3 mice, survival from 665 d ==\n")
d <- d0[d0[, "analysis"] == "A3 L545 g120", ]; d[, "cls"] <- cls.factor(d[, "cls"])
pre <- W[W[, "age"] < 545 & W[, "EarTag"] %in% d[, "EarTag"], ]
d[, c("a.now", "w.now")] <- near(pre, d[, "EarTag"], 515, 480, 544)
d[, c("a.then", "w.then")] <- near(pre, d[, "EarTag"], 365, 320, 410)
pk <- tapply(pre[, "wt"], pre[, "EarTag"], max); d[, "peak"] <- pk[as.character(d[, "EarTag"])]
d[, "change"] <- 100 * (d[, "w.now"] - d[, "w.then"]) / (d[, "a.now"] - d[, "a.then"])
d[, "of.peak"] <- 100 * d[, "w.now"] / d[, "peak"]
e <- d[complete.cases(d[, c("w.now", "w.then")]), ]
for (v in c("w.now", "change", "of.peak")) e[, paste0(v, ".z")] <- zd(e[, v], e[, "Diet"])
cat("A3 mice:", nrow(d), "; with both weighings:", nrow(e), "; deaths:", sum(e[, "event"]), "; strains:", length(unique(e[, "Genotype"])), "\n")
print(aggregate(cbind(a.then, w.then, a.now, w.now, change, of.peak) ~ Diet, e, function(x) round(median(x), 1)))
cat("SD of change (g per 100 d) and of % of peak, by diet:\n"); print(aggregate(cbind(change, of.peak) ~ Diet, e, function(x) round(sd(x), 1)))
cat("Share of mice lighter at about 515 d than at about 365 d:", round(tapply(e[, "change"] < 0, e[, "Diet"], mean), 2), "(CD, HF)\n")
cat("Correlation of size and change:", round(cor(e[, "w.now.z"], e[, "change.z"]), 2), "; of size and % of peak:", round(cor(e[, "w.now.z"], e[, "of.peak.z"]), 2), "\n")

ms <- list(size = "w.now.z", change = "change.z", of.peak = "of.peak.z", class = "cls",
           size.change = "w.now.z + change.z", size.of.peak = "w.now.z + of.peak.z", size.change.class = "w.now.z + change.z + cls")
fs <- lapply(ms, function(m) coxph(as.formula(paste("Surv(entry, End, event) ~", m, "+ strata(Diet)")), e))
rb <- lapply(ms, function(m) coxph(as.formula(paste("Surv(entry, End, event) ~", m, "+ strata(Diet)")), e, cluster = Genotype))
cat("\nModels (stratified by diet): concordance, and hazard ratios per SD with robust P values\n")
for (m in names(ms)) {
  s <- summary(rb[[m]])$coefficients; s <- s[!grepl("^cls", rownames(s)), , drop = FALSE]
  cat(sprintf("%-18s C %.3f  ", m, cstat(fs[[m]])), paste(rownames(s), "HR", round(s[, "exp(coef)"], 2), "P", signif(s[, "Pr(>|z|)"], 2), collapse = "; "), "\n")
}
cat("\nNested tests (stratified by diet)\n")
cat("change beyond size:          ", lr(fs$size.change, fs$size), "\n")
cat("% of peak beyond size:       ", lr(fs$size.of.peak, fs$size), "\n")
cat("class beyond size and change:", lr(fs$size.change.class, fs$size.change), "\n")
cat("size and change beyond class:", lr(fs$size.change.class, fs$class), "\n")
cc <- concordance(fs$size.change, fs$class); dv <- cc$concordance[1] - cc$concordance[2]; se <- sqrt(cc$var[1, 1] + cc$var[2, 2] - 2 * cc$var[1, 2])
cat("C(size + change) - C(class):", round(dv, 4), "; 95% CI", round(dv - 1.96 * se, 4), "to", round(dv + 1.96 * se, 4), "\n")

cat("\nWithin strains (stratified by strain x diet)\n")
ws <- lapply(ms, function(m) coxph(as.formula(paste("Surv(entry, End, event) ~", m, "+ strata(Genotype, Diet)")), e))
cat("change beyond size:", lr(ws$size.change, ws$size), "; class alone:", sprintf("LR %.1f", 2 * diff(ws$class$loglik)),
    "; size and change: HR", paste(round(exp(coef(ws$size.change)), 2), collapse = ", "), "\n")

cat("\nEach diet on its own: concordance\n")
for (dt in c("CD", "HF")) {
  f <- e[e[, "Diet"] == dt, ]
  cat(dt, ": n =", nrow(f), sapply(c(size = "w.now.z", change = "change.z", size.change = "w.now.z + change.z", class = "cls"), function(m)
    cstat(coxph(as.formula(paste("Surv(entry, End, event) ~", m)), f))), "(size, change, size + change, class)\n")
}
sink()
