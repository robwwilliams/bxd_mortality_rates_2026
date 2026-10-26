#
# vita_sex_stratified.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory: does the paternal D haplotype at a Vita locus change MRDT within each sex? Males and females have very
# different MRDTs, so pooling them mixes two Gompertz curves. Here each sex has its own level for each genotype and its
# own slope; the paternal D effect on slope is then added, first shared by both sexes, then separate for each sex.
#
# Input: the female and male files of Arends et al. Supplementary Data Table 2 for one locus.
# Run:   Rscript UMHET3/vita_sex_stratified.R <Vita1a_..._female.txt> <Vita1a_..._male.txt>
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
lt <- rbind(read.t2(args[1], "F"), read.t2(args[2], "M"))
lt$paternalD <- as.numeric(substr(lt$geno, 2, 2) == "D")

for (from in c(42, 200, 365)) {
  s <- lt[lt$age >= from & lt$atrisk >= 20 & lt$exposure > 0, ]
  m0 <- glm(deaths ~ sex:geno + sex:I(age / 100) + offset(log(exposure)), family = poisson, data = s)
  m1 <- update(m0, . ~ . + I(age / 100):paternalD)
  m2 <- update(m0, . ~ . + sex:I(age / 100):paternalD)
  b <- coef(m2)
  cat(sprintf("\nFrom %d d\n", from))
  for (x in c("F", "M")) {
    bH <- b[paste0("sex", x, ":I(age/100)")]; bD <- bH + b[paste0("sex", x, ":I(age/100):paternalD")]
    cat(sprintf("  %s: MRDT paternal H %.0f d, paternal D %.0f d\n", x, log(2) / bH * 100, log(2) / bD * 100))
  }
  bs <- coef(m1)["I(age/100):paternalD"]; se <- sqrt(vcov(m1)["I(age/100):paternalD", "I(age/100):paternalD"])
  cat(sprintf("  Shared D change in slope: %+.3f per 100 d (95%% CI %+.3f to %+.3f), P = %.2g\n", bs, bs - 1.96 * se,
              bs + 1.96 * se, anova(m0, m1, test = "LRT")[2, "Pr(>Chi)"]))
  cat(sprintf("  Does the D change in slope differ by sex? P = %.2g\n", anova(m1, m2, test = "LRT")[2, "Pr(>Chi)"]))
}
