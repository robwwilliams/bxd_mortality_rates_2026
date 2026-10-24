#
# vita1a_gompertz.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory: does the paternal D haplotype at Vita1a in UM-HET3 change the level of mortality or its doubling time?
# Gompertz fits (Poisson regression on deaths per 15 days, with exposure) by genotype, with one slope per paternal
# (H, D) or maternal (C, B) haplotype, and the D/H mortality ratio by age window.
#
# Input: the output of UMHET3/extract_vita1a_deaths.py (data not stored here).
# Run:   Rscript UMHET3/vita1a_gompertz.R <vita1a_deaths_15d.txt>
#
# Open questions for Danny Arends: (1) the column order (labels CH, BH, BD, CD; hazards match Table 1b only as CH, CD,
# BH, BD, the order used here); (2) the counts are 2:1, paternal H : paternal D (2,096 : 1,037), not 1:1:1:1;
# (3) which mice (3,133 of 6,438) and which sex the table covers.
#

d <- read.delim(commandArgs(trailingOnly = TRUE)[1])
colnames(d)[2:5] <- c("CH", "CD", "BH", "BD")
cat("Deaths by genotype:", colSums(d[, 2:5]), "\n")

lt <- c()
for (g in c("CH", "CD", "BH", "BD")) {
  x <- d[, g]; N <- sum(x)
  atrisk <- N - c(0, head(cumsum(x), -1))
  lt <- rbind(lt, data.frame(geno = g, age = d$age + 7.5, deaths = x, atrisk = atrisk, exposure = 15 * (atrisk - x / 2)))
}
lt$maternal <- substr(lt$geno, 1, 1); lt$paternal <- substr(lt$geno, 2, 2)

mrdt <- function(m, nm) {
  b <- coef(m)[nm] / 100; se <- sqrt(vcov(m)[nm, nm]) / 100
  round(c(MRDT = log(2) / b, lo = log(2) / (b + 1.96 * se), hi = log(2) / (b - 1.96 * se)))
}
for (from in c(42, 200, 365)) {
  s <- lt[lt$age >= from & lt$atrisk >= 20 & lt$exposure > 0, ]
  m.one <- glm(deaths ~ geno + I(age / 100) + offset(log(exposure)), family = poisson, data = s)
  m.pat <- glm(deaths ~ geno + I(age / 100):paternal + offset(log(exposure)), family = poisson, data = s)
  m.mat <- glm(deaths ~ geno + I(age / 100):maternal + offset(log(exposure)), family = poisson, data = s)
  cat(sprintf("\nFrom %d d\n", from))
  cat("  Paternal H MRDT", mrdt(m.pat, "I(age/100):paternalH"), "  D", mrdt(m.pat, "I(age/100):paternalD"),
      sprintf("  equal slopes P = %.2g\n", anova(m.one, m.pat, test = "LRT")[2, "Pr(>Chi)"]))
  cat("  Maternal C MRDT", mrdt(m.mat, "I(age/100):maternalC"), "  B", mrdt(m.mat, "I(age/100):maternalB"),
      sprintf("  equal slopes P = %.2g\n", anova(m.one, m.mat, test = "LRT")[2, "Pr(>Chi)"]))
  nd <- expand.grid(geno = c("CH", "BH", "CD", "BD"), age = c(600, 860)); nd$paternal <- substr(nd$geno, 2, 2); nd$exposure <- 1000
  nd$deaths.per.1000 <- predict(m.pat, nd, type = "response")
  print(reshape(nd[, c("geno", "age", "deaths.per.1000")], idvar = "geno", timevar = "age", direction = "wide"), digits = 3, row.names = FALSE)
}

# Paternal D / H mortality ratio by age window
pool <- function(x) { N <- sum(x); atrisk <- N - c(0, head(cumsum(x), -1)); list(deaths = x, exposure = 15 * (atrisk - x / 2)) }
H <- pool(d$CH + d$BH); D <- pool(d$CD + d$BD)
win <- cut(d$age, breaks = c(200, 350, 500, 650, 800, 900, 1000, 1100, 1250))
r <- data.frame(window = levels(win),
                H.rate = tapply(H$deaths, win, sum) / tapply(H$exposure, win, sum) * 1000,
                D.rate = tapply(D$deaths, win, sum) / tapply(D$exposure, win, sum) * 1000,
                D.deaths = tapply(D$deaths, win, sum), H.deaths = tapply(H$deaths, win, sum))
r$ratio <- r$D.rate / r$H.rate
r$lo <- exp(log(r$ratio) - 1.96 * sqrt(1 / r$D.deaths + 1 / r$H.deaths))
r$hi <- exp(log(r$ratio) + 1.96 * sqrt(1 / r$D.deaths + 1 / r$H.deaths))
cat("\nPaternal D / H mortality ratio by age window\n"); print(r, digits = 3, row.names = FALSE)
