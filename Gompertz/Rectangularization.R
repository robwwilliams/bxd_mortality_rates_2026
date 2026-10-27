#
# Rectangularization.R
#
# copyright (c) 2026 - Rob Williams
#
# Rectangularization side by side, as set out in notes/PLAN_NAM_rectangularization.md (N5, fixed before any curve was
# read; exploratory). For every comparison, the same measures of the three meanings of rectangularization:
#   absolute   SD and interquartile range of age at death; MRDT (under the Gompertz law the SD is about 1.85 x MRDT)
#   relative   CV of age at death and Keyfitz's H; the level of mortality at 600 days
#   lifespan   mean and median age at death
# Comparisons:
#   de Cabo's studies, from the published curves (tools/digitize_km.py; data/digitized/): metformin 0.1% and 1%
#     (Martin-Montalvo et al. 2013), nicotinamide 0.05% and 0.1% on the standard and the high-fat diet, and high fat
#     against the standard diet (Mitchell et al. 2018). One strain, so the unit is the mouse: 2,000 bootstrap resamples
#     of mice within arm.
#   BXD family: high fat against chow within strains (strains with at least 5 mice on each diet); short x short and
#     long x long F1 hybrids against their inbred parents (genotype x diet cells with at least 5 mice); high fat + NAM
#     against high fat (from Gompertz/NAM_rectangularization.R). The unit is the strain or genotype.
#
# Run from the repository root:  Rscript Gompertz/Rectangularization.R   (after tools/digitize_km.py and
# Gompertz/NAM_rectangularization.R)
# Writes output/Rectangularization_tests.txt, output/Rectangularization_by_arm.txt and output/Rectangularization.log
#

library(readxl)
library(parallel)
source("Gompertz/gompertz.R")

RNGkind("L'Ecuyer-CMRG")
set.seed(20261027)
num <- function(v) suppressWarnings(as.numeric(v))
iqr <- function(v) diff(quantile(v, c(0.25, 0.75), type = 7))
keyfitz.H <- function(x) { x <- sort(x); mean(sapply(x, function(xi) mean(x[x >= xi] - xi))) / mean(x) }
jack.se <- function(loo) { n <- length(loo); sqrt((n - 1) / n * sum((loo - mean(loo))^2)) }
tests <- c()
add <- function(comparison, source, measure, est, lo, hi, p, units, unit, note = "") {
  tests <<- rbind(tests, data.frame(comparison = comparison, source = source, measure = measure, estimate = signif(est, 4), lo = signif(lo, 4),
                                    hi = signif(hi, 4), p = signif(p, 3), units = units, unit = unit, note = note))
}
measures <- c("mean", "median", "sd", "iqr", "cv", "H", "mrdt", "h600")
scale.of <- c(mean = "days, difference", median = "days, difference", sd = "log2 ratio", iqr = "log2 ratio", cv = "log2 ratio",
              H = "difference", mrdt = "log2 ratio", h600 = "log2 ratio")
contrast <- function(t, c, k) unname(if (scale.of[k] == "log2 ratio") log2(t / c) else t - c)

# ---- de Cabo's studies: ages at death from the published curves ----------------------------------------------------
# For an arm of n mice, the k-th age at death is the first age at which survival is at or below 1 - (k - 1/2) / n.
# Fig. 1a was read from weekly markers, so a death seen at week w happened during the week before it (w - 1/2).
pseudo.ages <- function(week, s, n, weekly) {
  q <- 100 * (1 - (seq_len(n) - 0.5) / n)
  7 * (sapply(q, function(v) min(week[s <= v + 1e-9])) - if (weekly) 0.5 else 0)
}
arm.stats <- function(x, entry, start = NULL) {
  f <- gompertz.fit(x, rep(entry, length(x)), start = start)
  c(mean = mean(x), median = median(x), sd = sd(x), iqr = unname(iqr(x)), cv = sd(x) / mean(x), H = keyfitz.H(x),
    mrdt = f$MRDT, h600 = f$a * exp(f$b * 600))
}
dc <- list(
  list(file = "MartinMontalvo2013_Fig1a.txt", weekly = TRUE, start = 378, ctrl = "SD", n = c(SD = 83, Met0.1 = 64),
       label = c(SD = "standard diet", Met0.1 = "metformin 0.1%"), study = "Martin-Montalvo 2013", group = "metformin 0.1%"),
  list(file = "MartinMontalvo2013_Fig1b.txt", weekly = FALSE, start = 378, ctrl = "SD", n = c(SD = 88, Met1 = 90),
       label = c(SD = "standard diet", Met1 = "metformin 1%"), study = "Martin-Montalvo 2013", group = "metformin 1%"),
  list(file = "Mitchell2018_Fig1A.txt", weekly = FALSE, start = 392, ctrl = "SD", n = c(SD = 100, SDL = 100, SDH = 100),
       label = c(SD = "standard diet", SDL = "NAM 0.05%", SDH = "NAM 0.1%"), study = "Mitchell 2018", group = "standard diet"),
  list(file = "Mitchell2018_Fig1B.txt", weekly = FALSE, start = 392, ctrl = "HFD", n = c(HFD = 100, HFDL = 100, HFDH = 100),
       label = c(HFD = "high fat", HFDL = "high fat + NAM 0.05%", HFDH = "high fat + NAM 0.1%"), study = "Mitchell 2018", group = "high fat"))
ages <- list(); by.arm <- c()
for (d in dc) {
  cv <- read.delim(file.path("data/digitized", d$file), comment.char = "#", check.names = FALSE)
  for (a in names(d$n)) {
    key <- paste(sub("\\.txt$", "", d$file), a)
    ages[[key]] <- list(x = pseudo.ages(cv[, "week"], cv[, a], d$n[a], d$weekly), entry = d$start, study = d$study)
    st <- arm.stats(ages[[key]]$x, d$start)
    by.arm <- rbind(by.arm, data.frame(study = d$study, arm = d$label[a], mice = d$n[a], t(round(st[1:6], 3)), mrdt = round(st["mrdt"], 1),
                                       h600.per1000 = signif(1000 * st["h600"], 3), row.names = NULL))
  }
}
cat("de Cabo's arms, from the published curves (ages in days):\n"); print(by.arm, row.names = FALSE)
mm <- by.arm[by.arm[, "study"] == "Martin-Montalvo 2013", ]
cat(sprintf("\nCheck against the paper: change in mean lifespan, metformin 0.1%% %+.1f%% (paper +5.83%%), metformin 1%% %+.1f%% (paper -14.4%%)\n",
            100 * (mm[2, "mean"] / mm[1, "mean"] - 1), 100 * (mm[4, "mean"] / mm[3, "mean"] - 1)))

dc.compare <- function(tkey, ckey, comparison, B = 2000) {
  t <- ages[[tkey]]; c <- ages[[ckey]]
  st.t <- arm.stats(t$x, t$entry); st.c <- arm.stats(c$x, c$entry)
  est <- sapply(measures, function(k) contrast(st.t[k], st.c[k], k))
  boot <- do.call(rbind, mclapply(seq_len(B), function(i) {
    bt <- tryCatch(arm.stats(sample(t$x, replace = TRUE), t$entry), error = function(e) rep(NA, 8))
    bc <- tryCatch(arm.stats(sample(c$x, replace = TRUE), c$entry), error = function(e) rep(NA, 8))
    names(bt) <- names(bc) <- names(st.t)
    sapply(measures, function(k) contrast(bt[k], bc[k], k))
  }, mc.cores = 16, mc.set.seed = TRUE))
  for (k in measures) {
    b <- boot[, k]; b <- b[is.finite(b)]
    add(comparison, t$study, k, est[k], quantile(b, 0.025), quantile(b, 0.975), min(1, 2 * min(mean(b <= 0), mean(b >= 0))),
        length(t$x) + length(c$x), "mouse", sprintf("%d bootstrap resamples", length(b)))
  }
}
dc.compare("MartinMontalvo2013_Fig1a Met0.1", "MartinMontalvo2013_Fig1a SD", "metformin 0.1% vs standard diet")
dc.compare("MartinMontalvo2013_Fig1b Met1", "MartinMontalvo2013_Fig1b SD", "metformin 1% vs standard diet")
dc.compare("Mitchell2018_Fig1A SDL", "Mitchell2018_Fig1A SD", "NAM 0.05% vs standard diet")
dc.compare("Mitchell2018_Fig1A SDH", "Mitchell2018_Fig1A SD", "NAM 0.1% vs standard diet")
dc.compare("Mitchell2018_Fig1B HFDL", "Mitchell2018_Fig1B HFD", "NAM 0.05% vs high fat")
dc.compare("Mitchell2018_Fig1B HFDH", "Mitchell2018_Fig1B HFD", "NAM 0.1% vs high fat")
dc.compare("Mitchell2018_Fig1B HFD", "Mitchell2018_Fig1A SD", "high fat vs standard diet")

# ---- BXD family: statistics over strains or genotypes --------------------------------------------------------------
over.units <- function(dif) {                                  # one difference per strain; sign flips (exact up to 15 strains)
  dif <- dif[is.finite(dif)]; n <- length(dif); est <- mean(dif)
  se <- jack.se(sapply(seq_len(n), function(u) mean(dif[-u])))
  flips <- if (n <= 15) as.matrix(expand.grid(rep(list(c(-1, 1)), n))) else matrix(sample(c(-1, 1), 10000 * n, replace = TRUE), ncol = n)
  null <- flips %*% dif / n; tq <- qt(0.975, n - 1)
  c(est, est - tq * se, est + tq * se, mean(abs(null) >= abs(est) - 1e-9), n)
}
cell.stats <- function(x) c(mean = mean(x), median = median(x), sd = sd(x), iqr = unname(iqr(x)), cv = sd(x) / mean(x), H = keyfitz.H(x))

m <- as.data.frame(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal"))[, 1:7]
colnames(m) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
m <- m[!is.na(m[, "EarTag"]), ]

# High fat against chow, within strains
x <- m[m[, "Diet"] %in% c("CD", "HF"), ]
tb <- table(x[, "Strain"], x[, "Diet"]); ok <- rownames(tb)[tb[, "CD"] >= 5 & tb[, "HF"] >= 5]; x <- x[x[, "Strain"] %in% ok, ]
cat(sprintf("\nHigh fat vs chow: %d strains with at least 5 mice on each diet; %d chow and %d high-fat mice\n", length(ok), sum(x[, "Diet"] == "CD"), sum(x[, "Diet"] == "HF")))
cs <- lapply(c("CD", "HF"), function(dd) t(sapply(ok, function(s) cell.stats(x[x[, "Strain"] == s & x[, "Diet"] == dd, "Age"])))); names(cs) <- c("CD", "HF")
for (k in measures[1:6]) { r <- over.units(contrast(cs$HF[, k], cs$CD[, k], k)); add("high fat vs chow", "BXD", k, r[1], r[2], r[3], r[4], r[5], "strain") }
cmp <- gompertz.classes.compare(x[, "Age"], x[, "SetupAge"], x[, "Strain"], x[, "Diet"])
jk <- gompertz.jackknife(x[, "Age"], x[, "SetupAge"], x[, "Strain"], x[, "Diet"], x[, "Strain"]); tq <- qt(0.975, jk$n - 1)
add("high fat vs chow", "BXD", "mrdt", cmp$delta, cmp$delta - tq * jk$se, cmp$delta + tq * jk$se, NA, jk$n, "strain",
    sprintf("MRDT chow %.0f d, high fat %.0f d; animal-level LRT chi2 = %.1f, P = %.2g", cmp$fits$CD$MRDT, cmp$fits$HF$MRDT, cmp$lrt["chisq"], cmp$lrt["p"]))
r <- over.units(log2(cmp$fits$HF$h.ref[ok] / cmp$fits$CD$h.ref[ok])); add("high fat vs chow", "BXD", "h600", r[1], r[2], r[3], r[4], r[5], "strain")
# Checks on the MRDT within strains, which pooled fits (Part 1) do not show: larger cells, and a simulation of the bias
# that many small cells, each with its own level, could give when both diets share one MRDT
for (k in c(10, 15)) {
  s <- rownames(tb)[tb[, "CD"] >= k & tb[, "HF"] >= k]; y <- x[x[, "Strain"] %in% s, ]
  cmp.k <- gompertz.classes.compare(y[, "Age"], y[, "SetupAge"], y[, "Strain"], y[, "Diet"])
  add("high fat vs chow", "BXD", "mrdt", cmp.k$delta, NA, NA, cmp.k$lrt["p"], length(s), "strain",
      sprintf("check: strains with at least %d mice on each diet; MRDT chow %.0f d, high fat %.0f d; P is the animal-level LRT", k, cmp.k$fits$CD$MRDT, cmp.k$fits$HF$MRDT))
}
rgomp <- function(n, a, b) log(1 - b / a * log(runif(n))) / b
sim <- sapply(1:40, function(i) {
  lv <- setNames(exp(rnorm(length(ok), log(1e-4), 0.6)), ok); b <- log(2) / cmp$fits$CD$MRDT; y <- x
  y[, "Age"] <- sapply(seq_len(nrow(y)), function(j) { repeat { t <- rgomp(1, lv[y[j, "Strain"]] * ifelse(y[j, "Diet"] == "HF", 1.8, 1), b); if (t > y[j, "SetupAge"]) return(t) } })
  gompertz.classes.compare(y[, "Age"], y[, "SetupAge"], y[, "Strain"], y[, "Diet"])$delta
})
add("high fat vs chow", "BXD", "mrdt", mean(sim), quantile(sim, 0.025), quantile(sim, 0.975), NA, length(ok), "strain",
    sprintf("check: 40 simulations with one true MRDT (%.0f d) for both diets and the same strains, cell sizes and set-up ages; the estimate is the bias", cmp$fits$CD$MRDT))

# F1 hybrids against their inbred parents (cells: genotype x diet)
f <- read.delim("data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt", check.names = FALSE, quote = "")
f <- f[f[, "CauseOfDeath"] %in% "Natural" & !is.na(num(f[, "AgeAtDeath (days)"])), ]
f[, "StrainName"] <- sub("^BXD([0-9]+[a-wyz]?)x([0-9]+[a-wyz]?)$", "BXD\\1xBXD\\2", f[, "StrainName"])
short.parents <- c("BXD9", "BXD170", "BXD172", "BXD197"); long.parents <- c("BXD65", "BXD73b", "BXD77", "BXD102")
set.of <- function(g) { p <- strsplit(g, "x")[[1]]; if (all(p %in% short.parents)) "Short" else if (all(p %in% long.parents)) "Long" else NA }
hy <- rbind(data.frame(Genotype = f[, "StrainName"], Diet = f[, "DietCode"], Age = num(f[, "AgeAtDeath (days)"]), SetupAge = num(f[, "AgeAtSet Up (days)"]), Type = "F1"),
            data.frame(m[m[, "Strain"] %in% c(short.parents, long.parents) & m[, "Diet"] %in% c("CD", "HF"), c("Strain", "Diet", "Age", "SetupAge")], Type = "Parents",
                       row.names = NULL, check.names = FALSE, fix.empty.names = FALSE)[, c(1:4, 5)] |> setNames(c("Genotype", "Diet", "Age", "SetupAge", "Type")))
hy[, "Set"] <- sapply(hy[, "Genotype"], set.of)
hy <- hy[!is.na(hy[, "Set"]) & hy[, "Diet"] %in% c("CD", "HF"), ]
hy[is.na(hy[, "SetupAge"]), "SetupAge"] <- 21
for (set in c("Short", "Long")) {
  z <- hy[hy[, "Set"] == set, ]
  cells <- aggregate(Age ~ Genotype + Type + Diet, z, length); cells <- cells[cells[, "Age"] >= 5, 1:3]
  z <- z[paste(z[, "Genotype"], z[, "Diet"]) %in% paste(cells[, "Genotype"], cells[, "Diet"]), ]
  cells <- cbind(cells, t(sapply(seq_len(nrow(cells)), function(i) cell.stats(z[z[, "Genotype"] == cells[i, "Genotype"] & z[, "Diet"] == cells[i, "Diet"], "Age"]))))
  geno <- unique(cells[, c("Genotype", "Type")])
  label <- sprintf("%s F1s vs %s-lived parents", if (set == "Short") "short x short" else "long x long", tolower(set))
  cat(sprintf("\n%s: %d F1 types and %d parental strains; %d F1 and %d parental mice in cells of 5 or more\n", label,
              sum(geno[, "Type"] == "F1"), sum(geno[, "Type"] == "Parents"), sum(z[, "Type"] == "F1"), sum(z[, "Type"] == "Parents")))
  effect <- function(cc, v) { if (length(unique(cc[, "Type"])) < 2) return(NA); unname(coef(lm(v ~ Type + Diet, data.frame(cc[, c("Type", "Diet")], v = v)))["TypeParents"]) }
  test.cells <- function(v) {                                # F1 minus parents, adjusted for diet; jackknife and exact permutation over genotypes
    est <- -effect(cells, v)
    se <- jack.se(sapply(geno[, "Genotype"], function(u) -effect(cells[cells[, "Genotype"] != u, ], v[cells[, "Genotype"] != u])))
    combos <- combn(nrow(geno), sum(geno[, "Type"] == "F1"))
    null <- apply(combos, 2, function(k) { ty <- setNames(ifelse(seq_len(nrow(geno)) %in% k, "F1", "Parents"), geno[, "Genotype"])
                                           cc <- cells; cc[, "Type"] <- ty[cc[, "Genotype"]]; -effect(cc, v) })
    tq <- qt(0.975, nrow(geno) - 1)
    c(est, est - tq * se, est + tq * se, mean(abs(null) >= abs(est) - 1e-9), nrow(geno))
  }
  for (k in measures[1:6]) {
    v <- if (scale.of[k] == "log2 ratio") log2(cells[, k]) else cells[, k]
    r <- test.cells(v); add(label, "BXD", k, r[1], r[2], r[3], r[4], r[5], "genotype", "adjusted for diet")
  }
  cell <- paste(z[, "Genotype"], z[, "Diet"])
  cmp <- gompertz.classes.compare(z[, "Age"], z[, "SetupAge"], cell, factor(z[, "Type"], levels = c("Parents", "F1")))
  jk <- gompertz.jackknife(z[, "Age"], z[, "SetupAge"], cell, factor(z[, "Type"], levels = c("Parents", "F1")), z[, "Genotype"]); tq <- qt(0.975, jk$n - 1)
  add(label, "BXD", "mrdt", cmp$delta, cmp$delta - tq * jk$se, cmp$delta + tq * jk$se, NA, jk$n, "genotype",
      sprintf("MRDT parents %.0f d, F1s %.0f d; animal-level LRT chi2 = %.1f, P = %.2g", cmp$fits$Parents$MRDT, cmp$fits$F1$MRDT, cmp$lrt["chisq"], cmp$lrt["p"]))
  h <- c(cmp$fits$Parents$h.ref, cmp$fits$F1$h.ref)
  r <- test.cells(log2(h[paste(cells[, "Genotype"], cells[, "Diet"])])); add(label, "BXD", "h600", r[1], r[2], r[3], r[4], r[5], "genotype", "adjusted for diet")
}

# High fat + NAM against high fat (Gompertz/NAM_rectangularization.R: TSRB, 9 strains, all deaths)
nt <- read.delim("output/NAM_rectangularization_tests.txt", quote = "")
nt <- nt[nt[, "design"] == "TSRB" & nt[, "deaths"] == "all", ]
pick <- c(mean = "mean age at death (days)", sd = "SD of age at death", iqr = "interquartile range of age at death", cv = "CV of age at death",
          H = "Keyfitz's H", mrdt = "MRDT", h600 = "level of mortality at 600 days")
for (k in names(pick)) { r <- nt[nt[, "measure"] == pick[k], ]; add("NAM 1% vs high fat", "BXD", k, r[, "estimate"], r[, "lo"], r[, "hi"], r[, "p"], r[, "strains"], "strain",
                                                                   "from output/NAM_rectangularization_tests.txt") }

tests[, "scale"] <- scale.of[tests[, "measure"]]
write.table(tests, "output/Rectangularization_tests.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(by.arm, "output/Rectangularization_by_arm.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nAll comparisons (log2 ratios for sd, iqr, cv, mrdt and h600; days for mean and median):\n")
print(tests[, c("comparison", "measure", "estimate", "lo", "hi", "p", "units")], row.names = FALSE)
