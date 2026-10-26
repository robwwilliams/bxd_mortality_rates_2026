#
# vita_sex_stratified.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory: does a genotype contrast at a Vita locus change MRDT within each sex? Males and females have very
# different MRDTs, so pooling them mixes two Gompertz curves. Here each sex has its own level for each genotype and its
# own slope; the contrast's effect on slope is then added, first shared by both sexes, then separate for each sex.
# Contrasts: paternalD (CD and BD against CH and BH; for Vita1a) or BD (BD against the other three; for Vita1b).
#
# Input: the female and male files of Arends et al. Supplementary Data Table 2 for one locus (data/umhet3/Table2/).
# Run:   Rscript UMHET3/vita_sex_stratified.R <Vita1a_..._female.txt> <Vita1a_..._male.txt> [paternalD | BD]
#

read.t2 <- function(f, sex) {
  d <- read.delim(f, header = FALSE, skip = 1,
                  col.names = c("window", "CH", "CD", "BH", "BD", "C", "B", "D", "H",
                                "CH_alive", "CD_alive", "BH_alive", "BD_alive", "nGenotyped", "nTotal"))
  lt <- c()
  for (g in c("CH", "CD", "BH", "BD")) {
    x <- d[, g]; atrisk <- d[, paste0(g, "_alive")]
    lt <- rbind(lt, data.frame(sex = sex, geno = g, age = as.numeric(sub("[^0-9].*", "", d$window)) + 7.5,
                               deaths = x, atrisk = atrisk, exposure = 15 * (atrisk - x / 2)))
  }
  lt
}
args <- commandArgs(trailingOnly = TRUE)
contrast <- if (length(args) > 2) args[3] else "paternalD"
lt <- rbind(read.t2(args[1], "F"), read.t2(args[2], "M"))
lt$k <- as.numeric(if (contrast == "BD") lt$geno == "BD" else substr(lt$geno, 2, 2) == "D")
cat(sprintf("Contrast %s: %s against %s\n", contrast, if (contrast == "BD") "BD" else "CD + BD", if (contrast == "BD") "CH + CD + BH" else "CH + BH"))

for (from in c(42, 200, 365)) {
  s <- lt[lt$age >= from & lt$atrisk >= 20 & lt$exposure > 0, ]
  m0 <- glm(deaths ~ sex:geno + sex:I(age / 100) + offset(log(exposure)), family = poisson, data = s)
  m1 <- update(m0, . ~ . + I(age / 100):k)
  m2 <- update(m0, . ~ . + sex:I(age / 100):k)
  b <- coef(m2)
  cat(sprintf("\nFrom %d d\n", from))
  for (x in c("F", "M")) {
    b0 <- b[paste0("sex", x, ":I(age/100)")]; b1 <- b0 + b[paste0("sex", x, ":I(age/100):k")]
    nd <- expand.grid(sex = x, geno = unique(s$geno), age = c(600, 860), exposure = 1000)
    nd$k <- as.numeric(if (contrast == "BD") nd$geno == "BD" else substr(nd$geno, 2, 2) == "D")
    nd$h <- predict(m2, nd, type = "response")
    r <- tapply(nd$h, list(nd$k, nd$age), function(h) exp(mean(log(h))))   # geometric mean over the genotypes in a group
    cat(sprintf("  %s: MRDT %.0f d against %.0f d; mortality ratio %.2f at 600 d, %.2f at 860 d\n",
                x, log(2) / b1 * 100, log(2) / b0 * 100, r["1", "600"] / r["0", "600"], r["1", "860"] / r["0", "860"]))
  }
  bs <- coef(m1)["I(age/100):k"]; se <- sqrt(vcov(m1)["I(age/100):k", "I(age/100):k"])
  cat(sprintf("  Shared change in slope: %+.3f per 100 d (95%% CI %+.3f to %+.3f), P = %.2g\n", bs, bs - 1.96 * se,
              bs + 1.96 * se, anova(m0, m1, test = "LRT")[2, "Pr(>Chi)"]))
  cat(sprintf("  Does the change in slope differ by sex? P = %.2g\n", anova(m1, m2, test = "LRT")[2, "Pr(>Chi)"]))
}
