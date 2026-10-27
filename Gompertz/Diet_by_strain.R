#
# Diet_by_strain.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory, added after the diet results were seen: the effect of high fat within strains.
# Pooled over strains, a Cox model gives HF / CD = 1.44; stratified by strain it gives 1.78. Here:
#   1. the within-strain diet effect from a Gompertz fit with a level for each strain and one diet multiplier, which
#      also gives the within-strain MRDT, to compare with the pooled MRDT of 151 days;
#   2. the diet hazard ratio in each strain with at least 5 mice on each diet (Cox, each mouse at risk from set-up);
#   3. whether the strains differ in their diet effect: a likelihood-ratio test of diet x strain in the stratified
#      Cox model, Cochran's Q, and the DerSimonian-Laird between-strain s.d. (tau) of the log hazard ratio;
#   4. shrunken (empirical Bayes) estimates for each strain, and the smallest departure from the common effect that
#      each strain could detect.
#
# Data: as in MRDT_Diet.R (CD and HF females of 120 BXD strains, C57BL/6J, DBA/2J and the reciprocal B6D2 F1s).
# Run from the repository root:  Rscript Gompertz/Diet_by_strain.R
# Writes output/Diet_by_strain.txt (one row per strain) and output/Diet_by_strain_summary.txt
#

library(readxl)
library(survival)

mdata <- read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal")
mdata <- as.data.frame(mdata[, 1:7])
colnames(mdata) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
mdata <- mdata[!is.na(mdata[, "EarTag"]) & mdata[, "Diet"] %in% c("CD", "HF"), ]
mdata[, "Diet"] <- factor(mdata[, "Diet"], levels = c("CD", "HF"))
nt <- table(mdata[, "Strain"], mdata[, "Diet"])
cat("Genotypes:", nrow(nt), "; on both diets:", sum(nt[, "CD"] > 0 & nt[, "HF"] > 0),
    "; with at least 5 mice on each diet:", sum(nt[, "CD"] >= 5 & nt[, "HF"] >= 5), "\n")

# 1. Gompertz with a level for each strain and one diet multiplier theta: h = a_strain * theta^HF * exp(b * t).
#    For fixed (b, theta) the best a_strain has a closed form, so the fit is a search over two parameters.
strain.nll <- function(p, age, entry, hf, strain) {
  b <- exp(p[1]); w <- exp(p[2] * hf)
  S <- tapply(w * exp(b * entry) * expm1(b * (age - entry)) / b, strain, sum)
  d <- tapply(rep(1, length(age)), strain, sum)
  -(sum(d * log(d / S) - d) + b * sum(age) + p[2] * sum(hf))
}
hf <- as.numeric(mdata[, "Diet"] == "HF")
opt <- optim(c(log(log(2) / 150), log(1.5)), strain.nll, age = mdata[, "Age"], entry = mdata[, "SetupAge"], hf = hf,
             strain = mdata[, "Strain"], method = "BFGS", hessian = TRUE)
se <- sqrt(diag(solve(opt$hessian)))
gw <- c(MRDT = log(2) / exp(opt$par[1]), MRDT.lo = log(2) / exp(opt$par[1] + 1.96 * se[1]), MRDT.hi = log(2) / exp(opt$par[1] - 1.96 * se[1]),
        HR = exp(opt$par[2]), HR.lo = exp(opt$par[2] - 1.96 * se[2]), HR.hi = exp(opt$par[2] + 1.96 * se[2]))
cat(sprintf("\nGompertz, a level for each strain: MRDT %.0f d (95%% CI %.0f-%.0f); HF / CD %.2f (%.2f-%.2f)\n",
            gw["MRDT"], gw["MRDT.lo"], gw["MRDT.hi"], gw["HR"], gw["HR.lo"], gw["HR.hi"]))

# Pooled and stratified Cox, as in MRDT_Diet.R
sv <- Surv(mdata[, "SetupAge"], mdata[, "Age"], rep(1, nrow(mdata)))
cox.p <- coxph(sv ~ mdata[, "Diet"])
cox.s <- coxph(sv ~ mdata[, "Diet"] + strata(mdata[, "Strain"]))

# 2. The diet hazard ratio in each strain with at least 5 mice on each diet
keep <- rownames(nt)[nt[, "CD"] >= 5 & nt[, "HF"] >= 5]
per <- do.call(rbind, lapply(keep, function(s) {
  d <- mdata[mdata[, "Strain"] == s, ]
  f <- coxph(Surv(d[, "SetupAge"], d[, "Age"], rep(1, nrow(d))) ~ d[, "Diet"])
  data.frame(strain = s, n.CD = sum(d[, "Diet"] == "CD"), n.HF = sum(d[, "Diet"] == "HF"),
             median.CD = median(d[d[, "Diet"] == "CD", "Age"]), median.HF = median(d[d[, "Diet"] == "HF", "Age"]),
             logHR = unname(coef(f)), se = unname(sqrt(vcov(f)[1, 1])))
}))

# 3. Do the strains differ in their diet effect?
k <- mdata[mdata[, "Strain"] %in% keep, ]
svk <- Surv(k[, "SetupAge"], k[, "Age"], rep(1, nrow(k)))
m0 <- coxph(svk ~ k[, "Diet"] + strata(k[, "Strain"]))
m1 <- coxph(svk ~ k[, "Diet"]:factor(k[, "Strain"]) + strata(k[, "Strain"]))
lrt <- 2 * (m1$loglik[2] - m0$loglik[2]); lrt.df <- length(keep) - 1
w <- 1 / per$se^2; mu.fe <- sum(w * per$logHR) / sum(w)
Q <- sum(w * (per$logHR - mu.fe)^2)
tau2 <- max(0, (Q - lrt.df) / (sum(w) - sum(w^2) / sum(w)))            # DerSimonian-Laird
I2 <- max(0, (Q - lrt.df) / Q)
wr <- 1 / (per$se^2 + tau2); mu.re <- sum(wr * per$logHR) / sum(wr); se.re <- sqrt(1 / sum(wr))
cat(sprintf("\n%d strains with >= 5 mice per diet (%d mice)\n", length(keep), nrow(k)))
cat(sprintf("  Stratified Cox in these strains: HF / CD %.2f (%.2f-%.2f)\n", exp(coef(m0)), exp(confint(m0))[1], exp(confint(m0))[2]))
cat(sprintf("  Diet x strain, likelihood-ratio test: chi-square %.1f on %d df, P = %.2g\n", lrt, lrt.df, pchisq(lrt, lrt.df, lower.tail = FALSE)))
mv0 <- coxph(svk ~ k[, "Diet"] + strata(k[, "Strain"], k[, "Vivarium"]))     # the same test within strain x vivarium
mv1 <- coxph(svk ~ k[, "Diet"]:factor(k[, "Strain"]) + strata(k[, "Strain"], k[, "Vivarium"]))
lrt.v <- 2 * (mv1$loglik[2] - mv0$loglik[2])
cat(sprintf("  The same test within strain x vivarium: chi-square %.1f on %d df, P = %.2g\n", lrt.v, lrt.df, pchisq(lrt.v, lrt.df, lower.tail = FALSE)))
cat(sprintf("  Cochran's Q %.1f on %d df, P = %.2g; I2 = %.0f%%; tau (s.d. of the log HR between strains) = %.2f\n",
            Q, lrt.df, pchisq(Q, lrt.df, lower.tail = FALSE), 100 * I2, sqrt(tau2)))
cat(sprintf("  Random-effects mean HF / CD %.2f (%.2f-%.2f)\n", exp(mu.re), exp(mu.re - 1.96 * se.re), exp(mu.re + 1.96 * se.re)))

# 4. Shrunken estimates, and how far a strain's ratio must sit from the common one to be detected (two-sided, 5%)
per$HR <- exp(per$logHR); per$HR.lo <- exp(per$logHR - 1.96 * per$se); per$HR.hi <- exp(per$logHR + 1.96 * per$se)
per$HR.shrunk <- exp(mu.re + tau2 / (tau2 + per$se^2) * (per$logHR - mu.re))
per$p.vs.common <- 2 * pnorm(-abs(per$logHR - mu.fe) / per$se)
per$detectable.fold <- exp(1.96 * per$se)
per <- per[order(per$HR), ]
cat("\nLargest strains (detectable fold departure from the common ratio, in either direction):\n")
print(head(per[order(-pmin(per$n.CD, per$n.HF)), c("strain", "n.CD", "n.HF", "HR", "HR.lo", "HR.hi", "HR.shrunk", "p.vs.common", "detectable.fold")], 8),
      row.names = FALSE, digits = 3)
cat(sprintf("\nStrains whose ratio differs from the common one at P < 0.05: %d of %d (%.1f expected by chance)\n",
            sum(per$p.vs.common < 0.05), nrow(per), 0.05 * nrow(per)))
b6d2 <- per[per$strain %in% c("C57BL/6J", "DBA/2J"), ]
z <- diff(b6d2$logHR) / sqrt(sum(b6d2$se^2))
cat(sprintf("C57BL/6J against DBA/2J: HF / CD %.2f against %.2f; P = %.2f for a difference\n",
            b6d2$HR[b6d2$strain == "C57BL/6J"], b6d2$HR[b6d2$strain == "DBA/2J"], 2 * pnorm(-abs(z))))
f1 <- per[per$strain %in% c("B6D2F1", "D2B6F1"), ]                   # reciprocal F1s: same nuclear genome, different mother
z <- diff(f1$logHR) / sqrt(sum(f1$se^2))
cat(sprintf("B6D2F1 (B6 mother) against D2B6F1 (D2 mother): HF / CD %.2f against %.2f; P = %.2f for a difference\n",
            f1$HR[f1$strain == "B6D2F1"], f1$HR[f1$strain == "D2B6F1"], 2 * pnorm(-abs(z))))

write.table(per, "output/Diet_by_strain.txt", sep = "\t", quote = FALSE, row.names = FALSE)
summ <- data.frame(estimate = c("Cox, pooled", "Gompertz, pooled", "Cox, stratified by strain", "Gompertz, level for each strain",
                                "Random-effects mean of per-strain Cox"),
                   strains = c(nrow(nt), nrow(nt), sum(nt[, "CD"] > 0 & nt[, "HF"] > 0), nrow(nt), length(keep)),
                   HR = c(exp(coef(cox.p)), NA, exp(coef(cox.s)), gw["HR"], exp(mu.re)),
                   HR.lo = c(exp(confint(cox.p))[1], NA, exp(confint(cox.s))[1], gw["HR.lo"], exp(mu.re - 1.96 * se.re)),
                   HR.hi = c(exp(confint(cox.p))[2], NA, exp(confint(cox.s))[2], gw["HR.hi"], exp(mu.re + 1.96 * se.re)),
                   MRDT = c(NA, NA, NA, gw["MRDT"], NA), MRDT.lo = c(NA, NA, NA, gw["MRDT.lo"], NA), MRDT.hi = c(NA, NA, NA, gw["MRDT.hi"], NA))
tests <- read.table("output/MRDT_diet_tests.txt", sep = "\t", header = TRUE)[1, ]   # the pooled Gompertz, from MRDT_Diet.R
summ[2, c("HR", "HR.lo", "HR.hi", "MRDT")] <- tests[, c("HR.gompertz", "HR.gompertz.lo", "HR.gompertz.hi", "MRDT.sharedb")]
summ$heterogeneity <- c(rep("", 4), sprintf("LRT chi2 %.1f, %d df, P = %.2g; tau = %.2f; I2 = %.0f%%", lrt, lrt.df,
                                            pchisq(lrt, lrt.df, lower.tail = FALSE), sqrt(tau2), 100 * I2))
write.table(summ, "output/Diet_by_strain_summary.txt", sep = "\t", quote = FALSE, row.names = FALSE)
