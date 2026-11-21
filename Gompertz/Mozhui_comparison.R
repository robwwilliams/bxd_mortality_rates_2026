#
# Mozhui_comparison.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory, written 21 November 2026 after both sets of results were seen: Beni Mozhui's strain-adjusted Gompertz
# fits of chow against high fat (https://squirrelb.github.io/BXD-Diet-Gompertz/, 20 November 2026) set beside ours.
# She fitted flexsurvreg(Surv(entry, death, event) ~ Diet + Strain, anc = list(shape = ~ Diet), dist = "gompertz"):
# a level for each strain, one diet multiplier on the level at birth, and a slope for each diet. Here:
#   1. her model, refitted with our own likelihood, to check that the data and fits agree;
#   2. whether diet changes the level, with the level measured at birth (her 'a') or at 600 days (our convention);
#   3. our model (a level for each strain x diet cell, one MRDT per diet, as in Fig. 15d) on the same mice;
#   4. delete-one-strain jackknives of the MRDT ratio under both models;
#   5. the change in median lifespan split into level and slope, with the level measured at birth or at 600 days.
#
# Data: as in MRDT_Diet.R (CD and HF females of 120 BXD strains, C57BL/6J, DBA/2J and the reciprocal B6D2 F1s).
# Run from the repository root:  Rscript Gompertz/Mozhui_comparison.R
# Writes output/Mozhui_comparison.txt
#

library(readxl)
source("Gompertz/gompertz.R")

mdata <- read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal")
mdata <- as.data.frame(mdata[, 1:7])
colnames(mdata) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
mdata <- mdata[!is.na(mdata[, "EarTag"]) & mdata[, "Diet"] %in% c("CD", "HF"), ]
mdata[, "Diet"] <- factor(mdata[, "Diet"], levels = c("CD", "HF"))
cat("Mice:", nrow(mdata), "; CD", sum(mdata[, "Diet"] == "CD"), "; HF", sum(mdata[, "Diet"] == "HF"),
    "; genotypes", length(unique(mdata[, "Strain"])), "\n")

# Her model: h = a_strain * theta^HF * exp(b_diet * (t - ref)). With ref = 0, theta is the HF / CD ratio at birth (her
# 'a'); with ref = 600, at 600 days. For fixed (b_CD, b_HF, theta) each strain's level has a closed form, so the fit is
# a search over three parameters. fix.theta = TRUE sets theta to 1; fix.b = TRUE gives both diets one slope.
mozhui.nll <- function(p, d, ref = 0, fix.theta = FALSE, fix.b = FALSE) {
  hf <- as.numeric(d[, "Diet"] == "HF")
  b <- exp(ifelse(hf == 1 & !fix.b, p[2], p[1])); lt <- if (fix.theta) 0 else p[3]
  w <- exp(lt * hf - b * ref)
  S <- tapply(w * exp(b * d[, "SetupAge"]) * expm1(b * (d[, "Age"] - d[, "SetupAge"])) / b, d[, "Strain"], sum)
  n <- tapply(rep(1, nrow(d)), d[, "Strain"], sum)
  -(sum(n * log(n / S) - n) + sum(b * (d[, "Age"] - ref)) + lt * sum(hf))
}
mozhui.fit <- function(d, ref = 0, fix.theta = FALSE, fix.b = FALSE) {
  o <- optim(c(log(log(2) / 120), log(log(2) / 100), 0.3), mozhui.nll, d = d, ref = ref, fix.theta = fix.theta,
             fix.b = fix.b, method = "BFGS", control = list(reltol = 1e-12, maxit = 1000))
  b <- exp(o$par[1:2]); if (fix.b) b[2] <- b[1]
  theta <- if (fix.theta) 1 else exp(o$par[3])
  list(b = b, MRDT = log(2) / b, theta = theta, logLik = -o$value,
       ratio.at = function(t) theta * exp((b[2] - b[1]) * (t - ref)))      # HF / CD at age t
}
lrt <- function(ll1, ll0) { x2 <- 2 * (ll1 - ll0); c(chisq = x2, p = pchisq(x2, 1, lower.tail = FALSE)) }
jack.ci <- function(est, loo) {                          # log2 ratio and its leave-one-out values; t on units - 1 d.f.
  n <- length(loo); se <- sqrt((n - 1) / n * sum((loo - mean(loo))^2)); tq <- qt(0.975, n - 1)
  2^c(est, est - tq * se, est + tq * se)
}

tb <- table(mdata[, "Strain"], mdata[, "Diet"])
subsets <- list("all genotypes" = mdata,
                "76 strains with >= 5 mice on each diet" = mdata[mdata[, "Strain"] %in% rownames(tb)[tb[, "CD"] >= 5 & tb[, "HF"] >= 5], ])
res <- NULL
for (nm in names(subsets)) {
  d <- subsets[[nm]]
  cat(sprintf("\n==== %s: %d mice, %d genotypes ====\n", nm, nrow(d), length(unique(d[, "Strain"]))))

  # 1-2. Her model
  full <- mozhui.fit(d); one.b <- mozhui.fit(d, fix.b = TRUE)
  t.b <- lrt(full$logLik, one.b$logLik)
  t.a <- sapply(c(0, 600), function(ref) lrt(full$logLik, mozhui.fit(d, ref = ref, fix.theta = TRUE)$logLik))
  cat(sprintf("Her model: MRDT CD %.1f d, HF %.1f d; does diet change the slope? LR %.1f, P = %.2g\n",
              full$MRDT[1], full$MRDT[2], t.b["chisq"], t.b["p"]))
  cat(sprintf("  HF / CD mortality at birth %.2f, 300 d %.2f, 600 d %.2f, 900 d %.2f\n",
              full$ratio.at(0), full$ratio.at(300), full$ratio.at(600), full$ratio.at(900)))
  cat(sprintf("  Does diet change the level (slopes free)? At birth: LR %.2f, P = %.2g. At 600 d: LR %.1f, P = %.2g\n",
              t.a["chisq", 1], t.a["p", 1], t.a["chisq", 2], t.a["p", 2]))

  # 3. Our model
  ours <- gompertz.classes.compare(d[, "Age"], d[, "SetupAge"], d[, "Strain"], d[, "Diet"])
  cat(sprintf("Our model (a level for each strain x diet cell): MRDT CD %.1f d, HF %.1f d; LR %.1f, P = %.2g\n",
              ours$fits$CD$MRDT, ours$fits$HF$MRDT, ours$lrt["chisq"], ours$lrt["p"]))

  # 4. Delete-one-strain jackknives of MRDT HF / MRDT CD
  u <- unique(d[, "Strain"])
  ci.m <- jack.ci(log2(full$MRDT[2] / full$MRDT[1]),
                  sapply(u, function(s) { f <- mozhui.fit(d[d[, "Strain"] != s, ]); log2(f$MRDT[2] / f$MRDT[1]) }))
  ci.o <- jack.ci(ours$delta, gompertz.jackknife(d[, "Age"], d[, "SetupAge"], d[, "Strain"], d[, "Diet"], d[, "Strain"])$loo)
  cat(sprintf("MRDT HF / CD (delete-one-strain jackknife 95%% CI): her model %.2f (%.2f-%.2f); ours %.2f (%.2f-%.2f)\n",
              ci.m[1], ci.m[2], ci.m[3], ci.o[1], ci.o[2], ci.o[3]))

  res <- rbind(res,
    data.frame(mice = nm, model = "Mozhui: level per strain, one diet multiplier", MRDT.CD = full$MRDT[1], MRDT.HF = full$MRDT[2],
               ratio = ci.m[1], ratio.lo = ci.m[2], ratio.hi = ci.m[3], LR.slope = t.b["chisq"], P.slope = t.b["p"],
               HR.birth = full$ratio.at(0), HR.600 = full$ratio.at(600), LR.level.birth = t.a["chisq", 1],
               P.level.birth = t.a["p", 1], LR.level.600 = t.a["chisq", 2], P.level.600 = t.a["p", 2]),
    data.frame(mice = nm, model = "ours: level per strain x diet cell", MRDT.CD = ours$fits$CD$MRDT, MRDT.HF = ours$fits$HF$MRDT,
               ratio = ci.o[1], ratio.lo = ci.o[2], ratio.hi = ci.o[3], LR.slope = ours$lrt["chisq"], P.slope = ours$lrt["p"],
               HR.birth = NA, HR.600 = NA, LR.level.birth = NA, P.level.birth = NA, LR.level.600 = NA, P.level.600 = NA))

  # 5. Where to measure the level: split the change in median lifespan (from birth, for a strain at the median chow
  #    level) into a level part and a slope part. Shapley split: the average of the two orders of change.
  if (nm == "all genotypes") {
    cd <- d[d[, "Diet"] == "CD", ]; b1 <- full$b[1]; b2 <- full$b[2]
    a0 <- exp(median(log(tapply(rep(1, nrow(cd)), cd[, "Strain"], sum) /
                         tapply(exp(b1 * cd[, "SetupAge"]) * expm1(b1 * (cd[, "Age"] - cd[, "SetupAge"])) / b1, cd[, "Strain"], sum))))
    med <- function(a, b) log1p(b * log(2) / a) / b                         # median age at death from birth
    a2 <- a0 * full$theta
    for (ref in c(0, 600)) {
      at <- function(level, b) level / exp(b * ref)                          # R0 from the level at the reference age
      L1 <- a0 * exp(b1 * ref); L2 <- a2 * exp(b2 * ref)
      lev <- ((med(at(L2, b1), b1) - med(a0, b1)) + (med(a2, b2) - med(at(L1, b2), b2))) / 2
      slo <- ((med(at(L1, b2), b2) - med(a0, b1)) + (med(a2, b2) - med(at(L2, b1), b1))) / 2
      cat(sprintf("  Level measured at %3d d: median CD %.0f d, HF %.0f d; change %.0f d = level %.0f + slope %.0f\n",
                  ref, med(a0, b1), med(a2, b2), med(a2, b2) - med(a0, b1), lev, slo))
    }
  }
}
num <- sapply(res, is.numeric); res[num] <- signif(res[num], 4)
write.table(res, "output/Mozhui_comparison.txt", sep = "\t", quote = FALSE, row.names = FALSE)
