#
# NAM_rectangularization.R
#
# copyright (c) 2026 - Rob Williams
#
# High fat + 1% nicotinamide (NAM) against high fat alone, within BXD strains, as set out in
# notes/PLAN_NAM_rectangularization.md (approved by Rob on 27 October 2026; exploratory).
#   N1  lifespan: mean age at death
#   N2  level of mortality at 600 days and MRDT (Gompertz, one level per strain x arm, one MRDT per arm)
#   N3  rectangularization: SD, interquartile range, CV and Keyfitz's H of age at death
#   N4  days in terminal decline (BodyWeight/morbidity_functions.R), for the 20 definitions of the one-at-a-time set
#       (the K2 setting drops weighings flagged by rules A, B, E or G of BodyWeight/weights_QC.R, which has covered the
#       NAM workbook since 27 October 2026)
# Primary design: TSRB only (all NAM mice were housed there), strains with at least 3 mice in each arm. The unit is
# the strain: mean over strains of the NAM - high fat difference, exact sign-flip P, delete-one-strain jackknife CI.
# Secondary design (N1, N2): every vivarium, with vivarium effects estimated from chow and high-fat mice.
#
# Run from the repository root:  Rscript Gompertz/NAM_rectangularization.R
# Writes output/NAM_rectangularization_tests.txt and output/NAM_by_strain.txt
#

library(readxl)
source("Gompertz/gompertz.R")
source("BodyWeight/morbidity_functions.R")

set.seed(20261027)
num <- function(v) suppressWarnings(as.numeric(v))

m <- as.data.frame(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal"))[, 1:7]
colnames(m) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
m <- m[!is.na(m[, "EarTag"]), ]
b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females",
                                               .name_repair = "minimal")))
nm <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_NAM_BodyWeight_Feb2026.xlsx", .name_repair = "minimal")))
m[, "Status"] <- ifelse(m[, "Diet"] == "NAM", nm[match(m[, "EarTag"], nm[, "EarTagNumberCurrent"]), "Status"],
                        b[match(m[, "EarTag"], b[, "EarTagNumberCurrent"]), "Status"])
m[, "Arm"] <- m[, "Diet"]
cat("Mice in the mapping file:", nrow(m), "; NAM:", sum(m[, "Diet"] == "NAM"), "; NAM with a status:", sum(!is.na(m[m[, "Diet"] == "NAM", "Status"])), "\n")

# Weighings: BXD workbook (age at weighing given) and NAM workbook (age = date of weighing - date of birth)
wt.bxd <- do.call(rbind, lapply(0:20, function(j) {
  wc <- if (j == 0) "Weight00 Baseline" else sprintf("Weight%02d", j); ac <- if (j == 0) "AgeAtSetUp" else sprintf("AgeAtWeight%02d", j)
  data.frame(EarTag = b[, "EarTagNumberCurrent"], age = num(b[, ac]), w = num(b[, wc]))
}))
to.date <- function(v) if (inherits(v, "POSIXct")) as.Date(v) else as.Date(num(v), origin = "1899-12-30")   # some columns hold Excel day numbers
born <- to.date(nm[, "DateOfBirth"])
wt.nam <- do.call(rbind, lapply(0:20, function(j) {
  wc <- if (j == 0) "Weight00Baseline" else sprintf("Weight%02d", j); dc <- if (j == 0) "DateWeightBaseline" else sprintf("DateWeight%02d", j)
  data.frame(EarTag = nm[, "EarTagNumberCurrent"], column = wc, age = as.numeric(to.date(nm[, dc]) - born), w = num(nm[, wc]))
}))
cat("NAM baseline weighings whose age (date - birth) differs from AgeAtSettingUp by more than 2 days:",
    sum(abs(wt.nam[seq_len(nrow(nm)), "age"] - num(nm[, "AgeAtSettingUp"])) > 2, na.rm = TRUE), "of", nrow(nm), "\n")
wt.bxd <- wt.bxd[!is.na(wt.bxd[, "age"]) & !is.na(wt.bxd[, "w"]), ]; wt.nam <- wt.nam[!is.na(wt.nam[, "age"]) & !is.na(wt.nam[, "w"]), ]
fl <- read.delim("qc/BodyWeight_flags.txt", quote = ""); fl <- fl[grepl("(^|; )[ABEG] ", fl[, "Rule"]), ]
wt.bxd[, "flagged"] <- paste(wt.bxd[, "EarTag"], wt.bxd[, "age"]) %in% paste(fl[fl[, "Workbook"] == "BXD", "EarTag"], fl[fl[, "Workbook"] == "BXD", "Age"])
wt.nam[, "flagged"] <- paste(wt.nam[, "EarTag"], wt.nam[, "column"]) %in% paste(fl[fl[, "Workbook"] == "NAM", "EarTag"], fl[fl[, "Workbook"] == "NAM", "Column"])
cat("NAM weighings flagged by rules A, B, E or G (dropped for the K2 setting):", sum(wt.nam[, "flagged"]), "\n")
cat("NAM weighings:", nrow(wt.nam), "for", length(unique(wt.nam[, "EarTag"])), "mice\n")

# ---- Statistics over strains ---------------------------------------------------------------------------------------
jack.se <- function(loo) { n <- length(loo); sqrt((n - 1) / n * sum((loo - mean(loo))^2)) }
strain.test <- function(dif) {                                # dif: one NAM - high fat difference per strain
  dif <- dif[is.finite(dif)]; n <- length(dif)
  if (n < 3) return(c(estimate = NA, lo = NA, hi = NA, p = NA, strains = n))
  est <- mean(dif); se <- jack.se(sapply(seq_len(n), function(u) mean(dif[-u])))
  flips <- as.matrix(expand.grid(rep(list(c(-1, 1)), n)))
  null <- flips %*% dif / n; tq <- qt(0.975, n - 1)
  c(estimate = est, lo = est - tq * se, hi = est + tq * se, p = mean(abs(null) >= abs(est) - 1e-9), strains = n)
}
keyfitz.H <- function(x) { x <- sort(x); mean(sapply(x, function(xi) mean(x[x >= xi] - xi))) / mean(x) }
tests <- c()
add <- function(design, deaths, q, measure, r, units, note = "") {
  tests <<- rbind(tests, data.frame(design = design, deaths = deaths, question = q, measure = measure, estimate = signif(r[1], 4), lo = signif(r[2], 4),
                                    hi = signif(r[3], 4), p = signif(r[4], 3), strains = r[5], units = units, note = note))
}

# ---- Primary design: TSRB, strains with at least 3 mice in each arm ----------------------------------------------
by.strain <- c()
for (deaths in c("all", "natural")) {
  x <- m[m[, "Arm"] %in% c("HF", "NAM") & m[, "Vivarium"] == 3, ]
  if (deaths == "natural") x <- x[x[, "Status"] %in% "Natural", ]
  tb <- table(x[, "Strain"], x[, "Arm"]); ok <- rownames(tb)[tb[, "HF"] >= 3 & tb[, "NAM"] >= 3]
  x <- x[x[, "Strain"] %in% ok, ]
  cat(sprintf("\n== Primary, %s deaths: %d strains, %d NAM and %d high-fat mice\n", deaths, length(ok), sum(x[, "Arm"] == "NAM"), sum(x[, "Arm"] == "HF")))
  per <- function(f) sapply(ok, function(s) f(x[x[, "Strain"] == s & x[, "Arm"] == "NAM", "Age"]) - f(x[x[, "Strain"] == s & x[, "Arm"] == "HF", "Age"]))
  # N1
  add("TSRB", deaths, "N1", "mean age at death (days)", strain.test(per(mean)), "days, NAM - high fat")
  # N3
  lr <- function(f) sapply(ok, function(s) log2(f(x[x[, "Strain"] == s & x[, "Arm"] == "NAM", "Age"]) / f(x[x[, "Strain"] == s & x[, "Arm"] == "HF", "Age"])))
  iqr <- function(v) diff(quantile(v, c(0.25, 0.75), type = 7))
  add("TSRB", deaths, "N3", "SD of age at death", strain.test(lr(sd)), "log2 ratio, NAM / high fat")
  add("TSRB", deaths, "N3", "interquartile range of age at death", strain.test(lr(iqr)), "log2 ratio, NAM / high fat", "strains with a zero range dropped")
  add("TSRB", deaths, "N3", "CV of age at death", strain.test(lr(function(v) sd(v) / mean(v))), "log2 ratio, NAM / high fat")
  add("TSRB", deaths, "N3", "Keyfitz's H", strain.test(per(keyfitz.H)), "difference, NAM - high fat")
  # N2: one level per strain x arm, one MRDT per arm; euthanized mice censored for natural deaths
  y <- m[m[, "Arm"] %in% c("HF", "NAM") & m[, "Vivarium"] == 3 & m[, "Strain"] %in% ok, ]
  ev <- if (deaths == "all") rep(1, nrow(y)) else as.numeric(y[, "Status"] %in% "Natural")
  cmp <- gompertz.classes.compare(y[, "Age"], y[, "SetupAge"], y[, "Strain"], y[, "Arm"], ev)
  jk <- gompertz.jackknife(y[, "Age"], y[, "SetupAge"], y[, "Strain"], y[, "Arm"], y[, "Strain"], ev)
  tq <- qt(0.975, jk$n - 1)
  add("TSRB", deaths, "N2", "MRDT", c(cmp$delta, cmp$delta - tq * jk$se, cmp$delta + tq * jk$se, NA, jk$n), "log2 ratio, NAM / high fat",
      sprintf("MRDT high fat %.0f d, NAM %.0f d; animal-level LRT P = %.2g", cmp$fits$HF$MRDT, cmp$fits$NAM$MRDT, cmp$lrt["p"]))
  h <- function(k) cmp$fits[[k]]$h.ref[ok]
  add("TSRB", deaths, "N2", "level of mortality at 600 days", strain.test(log2(h("NAM") / h("HF"))), "log2 ratio, NAM / high fat")
  add("TSRB", deaths, "N3", "Gompertz-implied SD of age at death (1.85 x MRDT)", c(1.85 * cmp$fits$NAM$MRDT - 1.85 * cmp$fits$HF$MRDT, NA, NA, NA, length(ok)),
      "days, NAM - high fat", sprintf("high fat %.0f d, NAM %.0f d", 1.85 * cmp$fits$HF$MRDT, 1.85 * cmp$fits$NAM$MRDT))
  # N4: days in decline, for the 20 one-at-a-time definitions
  sp <- do.call(rbind, lapply(seq_len(nrow(x)), function(i) {
    z <- if (x[i, "Arm"] == "NAM") wt.nam[wt.nam[, "EarTag"] == x[i, "EarTag"], ] else wt.bxd[wt.bxd[, "EarTag"] == x[i, "EarTag"], ]
    k1 <- morbidity.all(z[, "age"], z[, "w"], x[i, "Age"], "hf", "K1")
    k2 <- morbidity.all(z[!z[, "flagged"], "age"], z[!z[, "flagged"], "w"], x[i, "Age"], "hf", "K2")
    if (is.null(k1) || is.null(k2)) return(NULL)
    data.frame(EarTag = x[i, "EarTag"], Strain = x[i, "Strain"], Arm = x[i, "Arm"], Age = x[i, "Age"], t(c(k1, k2)), check.names = FALSE)
  }))
  oat <- c("P1.K1.O1.T1.L1", "P2.K1.O1.T1.L1", "P3.K1.O1.T1.L1", "P4.K1.O1.T1.L1", "P1.K2.O1.T1.L1", "P1.K1.O2.T1.L1", "P1.K1.O3.T1.L1",
           "P1.K1.O4.T1.L1", "P1.K1.O5.T1.L1", "P1.K1.O6.L1", "P1.K1.O7.T1.L1", "K1.O8.L1", "P1.K1.O9.L1", "P1.K1.O10.T1.L1",
           "P1.K1.O1.T2.L1", "P1.K1.O1.T1.L2", "P1.K1.O1.T1.L3", "P1.K1.O1.T1.L4", "P1.K1.G1.L2", "P1.K1.G2.L2")
  tb4 <- table(sp[, "Strain"], sp[, "Arm"]); ok4 <- rownames(tb4)[tb4[, "HF"] >= 3 & tb4[, "NAM"] >= 3]
  cat("N4: mice with a peak at least 120 days before death:", nrow(sp), "; strains with at least 3 in each arm:", length(ok4), "\n")
  for (def in oat) for (form in c("days", "share")) {
    v <- if (form == "days") sp[, def] else sp[, def] / sp[, "Age"]
    dif <- sapply(ok4, function(s) mean(v[sp[, "Strain"] == s & sp[, "Arm"] == "NAM"]) - mean(v[sp[, "Strain"] == s & sp[, "Arm"] == "HF"]))
    add("TSRB", deaths, "N4", paste(def, form), strain.test(dif), if (form == "days") "days (or burden), NAM - high fat" else "share of life, NAM - high fat",
        if (def == "P1.K1.O1.T1.L1") "Part 4's definition" else "")
  }
  # Strain-by-strain table
  by.strain <- rbind(by.strain, do.call(rbind, lapply(ok, function(s) do.call(rbind, lapply(c("HF", "NAM"), function(arm) {
    v <- x[x[, "Strain"] == s & x[, "Arm"] == arm, "Age"]; q <- sp[sp[, "Strain"] == s & sp[, "Arm"] == arm, "P1.K1.O1.T1.L1"]
    data.frame(deaths = deaths, Strain = s, Arm = arm, mice = length(v), mean.age = round(mean(v)), median.age = median(v), sd.age = round(sd(v)),
               iqr.age = round(iqr(v)), cv = round(sd(v) / mean(v), 3), H = round(keyfitz.H(v), 3),
               h600 = signif(cmp$fits[[arm]]$h.ref[s], 3), mice.weighed = length(q), mean.days.in.decline = round(mean(q)))
  })))))
}

# ---- Secondary design: every vivarium -----------------------------------------------------------------------------
tb <- table(m[, "Strain"], m[, "Arm"]); ok <- rownames(tb)[tb[, "HF"] >= 3 & tb[, "NAM"] >= 3]
x <- m[m[, "Strain"] %in% ok, ]
cat(sprintf("\n== Secondary, every vivarium: %d strains; %d NAM, %d high-fat and %d chow mice\n", length(ok), sum(x[, "Arm"] == "NAM"),
            sum(x[, "Arm"] == "HF"), sum(x[, "Arm"] == "CD")))
cat("High-fat and chow mice by vivarium:\n"); print(table(x[, "Arm"], x[, "Vivarium"]))
fit.nam <- function(z) { z[, "Arm"] <- relevel(factor(z[, "Arm"]), "HF"); unname(coef(lm(Age ~ Strain + Arm + factor(Vivarium), z))["ArmNAM"]) }
est <- fit.nam(x); se <- jack.se(sapply(ok, function(s) fit.nam(x[x[, "Strain"] != s, ]))); tq <- qt(0.975, length(ok) - 1)
add("every vivarium", "all", "N1", "mean age at death (days), adjusted for vivarium", c(est, est - tq * se, est + tq * se, 2 * pt(-abs(est / se), length(ok) - 1), length(ok)),
    "days, NAM - high fat", "P from the jackknife t")
y <- x[x[, "Arm"] %in% c("HF", "NAM"), ]
cmp <- gompertz.classes.compare(y[, "Age"], y[, "SetupAge"], paste(y[, "Strain"], y[, "Vivarium"]), y[, "Arm"])
jk <- gompertz.jackknife(y[, "Age"], y[, "SetupAge"], paste(y[, "Strain"], y[, "Vivarium"]), y[, "Arm"], y[, "Strain"]); tq <- qt(0.975, jk$n - 1)
add("every vivarium", "all", "N2", "MRDT", c(cmp$delta, cmp$delta - tq * jk$se, cmp$delta + tq * jk$se, NA, jk$n), "log2 ratio, NAM / high fat",
    sprintf("MRDT high fat %.0f d, NAM %.0f d; animal-level LRT P = %.2g", cmp$fits$HF$MRDT, cmp$fits$NAM$MRDT, cmp$lrt["p"]))

# ---- Birth cohort (added after the results were seen; exploratory) -------------------------------------------------
# NAM mice at TSRB were born mostly in 2021, their high-fat controls mostly in 2016-2019. Cohorts born up to 2021 have
# all died, so the data freeze does not cut them short. Cox models on age, with entry at set-up (left truncation),
# stratified by strain.
library(survival)
born.b <- to.date(b[, "DateOfBirth"])
m[, "Year"] <- as.numeric(format(as.Date(ifelse(m[, "Diet"] == "NAM", born[match(m[, "EarTag"], nm[, "EarTagNumberCurrent"])],
                                                born.b[match(m[, "EarTag"], b[, "EarTagNumberCurrent"])]), origin = "1970-01-01"), "%Y"))
m[, "cohort"] <- m[, "Year"] - 2018
cox.hr <- function(f, z, term) { s <- summary(coxph(f, data = z)); c(s$conf.int[term, c(1, 3, 4)], s$coefficients[term, "Pr(>|z|)"]) }
z <- m[m[, "Arm"] %in% c("CD", "HF") & m[, "Vivarium"] == 3 & m[, "Year"] <= 2021, ]
cat(sprintf("\n== Birth cohort: chow and high-fat mice at TSRB born 2015-2021, %d mice\n", nrow(z)))
cat("Births by year:\n"); print(table(z[, "Arm"], z[, "Year"]))
cat("Share euthanized by birth year:\n"); print(round(tapply(z[, "Status"] == "Euthanized", list(z[, "Arm"], z[, "Year"]), mean), 2))
r <- cox.hr(Surv(SetupAge, Age, rep(1, nrow(z))) ~ strata(Strain) + Arm + cohort, z, "cohort"); b.year <- log(r[1])
add("TSRB, birth cohort", "all", "N1 cohort", "hazard ratio per later birth year, chow and high fat", c(r, NA), "hazard ratio", sprintf("%d mice born 2015-2021", nrow(z)))
r <- summary(lm(Age ~ Strain + Arm + SetupAge + Year, z))$coefficients["Year", ]
add("TSRB, birth cohort", "all", "N1 cohort", "change in age at death per later birth year, chow and high fat",
    c(r[1], r[1] - 1.96 * r[2], r[1] + 1.96 * r[2], r[4], NA), "days per year", "linear model with strain, diet and age at set-up")
x <- m[m[, "Arm"] %in% c("HF", "NAM") & m[, "Vivarium"] == 3, ]
tb <- table(x[, "Strain"], x[, "Arm"]); x <- x[x[, "Strain"] %in% rownames(tb)[tb[, "HF"] >= 3 & tb[, "NAM"] >= 3], ]
cat("Primary design, births by year:\n"); print(table(x[, "Arm"], x[, "Year"]))
add("TSRB, birth cohort", "all", "N1 cohort", "NAM / high fat hazard ratio, primary design", c(cox.hr(Surv(SetupAge, Age, rep(1, nrow(x))) ~ strata(Strain) + Arm, x, "ArmNAM"), NA),
    "hazard ratio", "no adjustment for birth year")
add("TSRB, birth cohort", "all", "N1 cohort", "NAM / high fat hazard ratio, primary design, adjusted for birth year",
    c(cox.hr(Surv(SetupAge, Age, rep(1, nrow(x))) ~ strata(Strain) + Arm + offset(b.year * cohort), x, "ArmNAM"), NA), "hazard ratio",
    "trend per birth year fixed at the chow and high-fat estimate")
y <- m[m[, "Arm"] %in% c("HF", "NAM") & m[, "Vivarium"] == 3 & m[, "Year"] %in% 2018:2020, ]
tb <- table(y[, "Strain"], y[, "Arm"]); y <- y[y[, "Strain"] %in% rownames(tb)[tb[, "HF"] >= 1 & tb[, "NAM"] >= 1], ]
add("TSRB, birth cohort", "all", "N1 cohort", "NAM / high fat hazard ratio, both born 2018-2020", c(cox.hr(Surv(SetupAge, Age, rep(1, nrow(y))) ~ strata(Strain) + Arm, y, "ArmNAM"),
    length(unique(y[, "Strain"]))), "hazard ratio", sprintf("%d NAM and %d high-fat mice", sum(y[, "Arm"] == "NAM"), sum(y[, "Arm"] == "HF")))

write.table(tests, "output/NAM_rectangularization_tests.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(by.strain, "output/NAM_by_strain.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\n"); print(tests[tests[, "question"] != "N4" | grepl("Part 4", tests[, "note"]), ], row.names = FALSE)
cat("\nN4, all 20 definitions, all deaths, in days:\n"); print(tests[tests[, "question"] == "N4" & tests[, "deaths"] == "all" & grepl(" days$", tests[, "measure"]), c("measure", "estimate", "lo", "hi", "p", "strains")], row.names = FALSE)
cat("\nBy strain (all deaths):\n"); print(by.strain[by.strain[, "deaths"] == "all", ], row.names = FALSE)
