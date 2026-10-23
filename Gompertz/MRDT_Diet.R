#
# MRDT_Diet.R
#
# copyright (c) 2026 - Rob Williams
#
# Initial Gompertz analysis of BXD family females on chow (CD) versus high-fat diet (HF).
# Does the high-fat diet change the mortality rate doubling time (MRDT), the age-independent
# mortality (R0 = a), or both?
#
# Data: Suheeta Roy's curated file of females used for actuarial mapping (data/original/BXD_Mortality_for_Mapping_Arends.xlsx).
# Kept: CD and HF females of BXD strains, C57BL/6J, DBA/2J and their reciprocal F1s (B6D2F1, D2B6F1).
# Dropped: HF + NAM animals. (The file has no males and no BXD x BXD F1s.)
# Each animal is at risk from its age at set up (left truncation). All animals in the file died, so nothing is censored.
#
# Run from the repository root:  Rscript Gompertz/MRDT_Diet.R
#

library(readxl)
library(survival)

source("Gompertz/gompertz.R")

B <- 2000                                  # bootstrap replicates for the primary analysis

# Read the curated file; the column headers are on row 10
mdata <- read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal")
mdata <- as.data.frame(mdata[, 1:7])
colnames(mdata) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
mdata <- mdata[!is.na(mdata[, "EarTag"]), ]
mdata <- mdata[mdata[, "Diet"] %in% c("CD", "HF"), ]
mdata[, "Diet"] <- factor(mdata[, "Diet"], levels = c("CD", "HF"))
mdata[, "Type"] <- ifelse(mdata[, "Strain"] %in% c("C57BL/6J", "DBA/2J"), "Parent",
                   ifelse(mdata[, "Strain"] %in% c("B6D2F1", "D2B6F1"), "F1", "BXD"))
cat("Animals:", nrow(mdata), "\n"); print(table(mdata[, "Type"], mdata[, "Diet"]))

# The analyses: name, subset of animals, minimum age (animals must survive to it; entry is raised to it)
analyses <- list(
  list(name = "Primary: all CD and HF females",      keep = rep(TRUE, nrow(mdata)),     from = 0),
  list(name = "Survived to 200 d",                   keep = rep(TRUE, nrow(mdata)),     from = 200),
  list(name = "Survived to 365 d",                   keep = rep(TRUE, nrow(mdata)),     from = 365),
  list(name = "BXD strains only",                    keep = mdata[, "Type"] == "BXD", from = 0)
)

results <- c()
tests <- c()
for (an in analyses) {
  sdata <- mdata[an$keep & mdata[, "Age"] >= an$from, ]
  entry <- pmax(sdata[, "SetupAge"], an$from)
  cmp <- gompertz.compare(sdata[, "Age"], entry, sdata[, "Diet"])
  for (diet in levels(sdata[, "Diet"])) {
    f <- cmp$fits[[diet]]
    results <- rbind(results, data.frame(analysis = an$name, method = "Gompertz MLE", diet = diet, n = f$n,
                                         a = f$a, b = f$b, lnR0 = log(f$a), MRDT = f$MRDT,
                                         MRDT.lo = f$MRDT.lo, MRDT.hi = f$MRDT.hi, cor.lna.lnb = cov2cor(f$vcov)[1, 2]))
  }
  cox <- coxph(Surv(entry, sdata[, "Age"], rep(1, nrow(sdata))) ~ sdata[, "Diet"])
  zph <- cox.zph(cox)
  cox.s <- coxph(Surv(entry, sdata[, "Age"], rep(1, nrow(sdata))) ~ sdata[, "Diet"] + strata(sdata[, "Strain"]))
  tests <- rbind(tests, data.frame(analysis = an$name, n.CD = sum(sdata[, "Diet"] == "CD"), n.HF = sum(sdata[, "Diet"] == "HF"),
                                   p.slope = cmp$slope["p"], p.R0.given.slope = cmp$R0["p"], p.any = cmp$any["p"],
                                   MRDT.sharedb = cmp$sharedb["MRDT"], HR.gompertz = cmp$sharedb["HR"],
                                   HR.gompertz.lo = cmp$sharedb["HR.lo"], HR.gompertz.hi = cmp$sharedb["HR.hi"],
                                   HR.cox = exp(coef(cox)), HR.cox.lo = exp(confint(cox))[1], HR.cox.hi = exp(confint(cox))[2],
                                   p.cox.PH = zph$table[1, "p"], HR.cox.strain = exp(coef(cox.s)),
                                   HR.cox.strain.lo = exp(confint(cox.s))[1], HR.cox.strain.hi = exp(confint(cox.s))[2],
                                   shift.predicted = cmp$sharedb["MRDT"] * log2(cmp$sharedb["HR"]),
                                   median.CD = median(sdata[sdata[, "Diet"] == "CD", "Age"]),
                                   median.HF = median(sdata[sdata[, "Diet"] == "HF", "Age"])))
}

# Gompertz-Makeham: adds an age-independent hazard c (primary data set)
for (diet in levels(mdata[, "Diet"])) {
  sdata <- mdata[mdata[, "Diet"] == diet, ]
  f <- gompertz.fit(sdata[, "Age"], sdata[, "SetupAge"], makeham = TRUE)
  results <- rbind(results, data.frame(analysis = "Gompertz-Makeham", method = "Gompertz-Makeham MLE", diet = diet, n = f$n,
                                       a = f$a, b = f$b, lnR0 = log(f$a), MRDT = f$MRDT,
                                       MRDT.lo = f$MRDT.lo, MRDT.hi = f$MRDT.hi, cor.lna.lnb = cov2cor(f$vcov)[1, 2]))
  cat(diet, "Makeham c =", signif(f$c, 3), "per day\n")
}

# Classic binned regression (de Magalhaes et al. 2018): 30-day occurrence/exposure rates from 200 d onward
binned <- c()
for (diet in levels(mdata[, "Diet"])) {
  sdata <- mdata[mdata[, "Diet"] == diet, ]
  bn <- gompertz.binned(sdata[, "Age"], sdata[, "SetupAge"], width = 30)
  binned <- rbind(binned, data.frame(diet = diet, bn))
  reg <- gompertz.regression(bn, from = 200)
  results <- rbind(results, data.frame(analysis = "Binned regression (from 200 d)", method = "Weighted regression", diet = diet,
                                       n = nrow(sdata), a = reg["a"], b = reg["b"], lnR0 = log(reg["a"]), MRDT = reg["MRDT"],
                                       MRDT.lo = reg["MRDT.lo"], MRDT.hi = reg["MRDT.hi"], cor.lna.lnb = NA))
}

# Bootstrap of the primary analysis: percentile intervals for MRDT and the HF - CD difference
boot <- gompertz.bootstrap(mdata[, "Age"], mdata[, "SetupAge"], mdata[, "Diet"], B = B, seed = 20261023)
boot[, "MRDT.diff"] <- boot[, "MRDT.HF"] - boot[, "MRDT.CD"]
bsum <- t(sapply(c("MRDT.CD", "MRDT.HF", "MRDT.diff"), function(x) {
  c(estimate = median(boot[, x]), lo = quantile(boot[, x], 0.025, names = FALSE), hi = quantile(boot[, x], 0.975, names = FALSE))
}))
print(round(bsum, 1))
cat("Bootstrap correlation of ln(a) and ln(b): CD", round(cor(boot[, "loga.CD"], boot[, "logb.CD"]), 3),
    " HF", round(cor(boot[, "loga.HF"], boot[, "logb.HF"]), 3), "\n")

rownames(results) <- NULL; rownames(tests) <- NULL
print(results[, c("analysis", "diet", "n", "MRDT", "MRDT.lo", "MRDT.hi", "lnR0")], digits = 4)
print(tests, digits = 3)

write.table(results, "output/MRDT_by_diet.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(tests, "output/MRDT_diet_tests.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(binned, "output/hazard_binned_30d.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(boot, "output/MRDT_bootstrap.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(data.frame(quantity = rownames(bsum), bsum), "output/MRDT_bootstrap_summary.txt", sep = "\t", quote = FALSE, row.names = FALSE)
