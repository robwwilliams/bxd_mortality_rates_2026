#
# Reciprocal_F1.R
#
# copyright (c) 2026 - Rob Williams
#
# Survival of the reciprocal F1 hybrids of the BXD parents: B6D2F1 (C57BL/6J mother) against D2B6F1 (DBA/2J mother),
# on chow and high fat. Rob, 21 November 2026: "The difference between the survivorship structure of B6D2F1s and D2B6F1
# is quite large and really surprised me." Exploratory: run after he had seen the two crosses' survival.
#   - Ages and set-up ages from Suheeta Roy's curated file; birth dates and status (Natural, Euthanized) from her
#     body-weight workbook, matched by ear tag.
#   - Cox models with left truncation at set-up age (entry at set-up, every mouse dead), D2B6F1 against B6D2F1: per diet;
#     and the cross x diet interaction, by likelihood ratio. Each also for mice born 2011-2015 only, the years in which
#     both crosses were born.
#   - The cross is the unit here, with two genotypes, so only animal-level tests are possible. They are reported with
#     the confounds that go with them: birth year, vivarium, set-up age and euthanasia.
#
# Run from the repository root:  Rscript Gompertz/Reciprocal_F1.R
# Writes output/Reciprocal_F1.txt
#

library(readxl)
library(survival)
options(width = 220)

cn <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
m <- as.data.frame(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal"))[, 1:7]
colnames(m) <- cn
m <- m[!is.na(m[, "EarTag"]) & m[, "Strain"] %in% c("C57BL/6J", "DBA/2J", "B6D2F1", "D2B6F1"), ]
b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females", .name_repair = "minimal")))
i <- match(m[, "EarTag"], b[, "EarTagNumberCurrent"])
m[, "Born"] <- as.numeric(format(as.Date(b[i, "DateOfBirth"]), "%Y")); m[, "Status"] <- b[i, "Status"]
tally <- function(x) paste(names(table(x)), table(x), sep = ":", collapse = " ")

sink("output/Reciprocal_F1.txt", split = TRUE)
cat("Reciprocal F1s and their parents, BXD family females; ages in days. Vivarium 1 Nash, 2 Nash then TSRB, 3 TSRB.\n")
cat("Mice matched to the body-weight workbook:", sum(!is.na(i)), "of", nrow(m), "\n\n")
s <- do.call(rbind, lapply(split(m, list(m[, "Strain"], m[, "Diet"]), drop = TRUE), function(x) data.frame(Strain = x[1, "Strain"], Diet = x[1, "Diet"],
       n = nrow(x), median = median(x[, "Age"]), IQR = paste(quantile(x[, "Age"], c(0.25, 0.75), names = FALSE), collapse = "-"),
       range = paste(range(x[, "Age"]), collapse = "-"), setup = paste(range(x[, "SetupAge"]), collapse = "-"), vivarium = tally(x[, "Vivarium"]),
       born = tally(x[, "Born"]), euthanized = sum(x[, "Status"] == "Euthanized", na.rm = TRUE))))
print(s[order(s[, "Diet"], s[, "Strain"]), ], row.names = FALSE)

f <- m[m[, "Strain"] %in% c("B6D2F1", "D2B6F1"), ]; f[, "D2mother"] <- f[, "Strain"] == "D2B6F1"
hr <- function(x, lab) {
  fit <- coxph(Surv(SetupAge, Age, rep(1, nrow(x))) ~ D2mother, data = x); ci <- summary(fit)$conf.int
  cat(sprintf("%-26s %2d B6D2F1, %2d D2B6F1: hazard ratio D2B6F1 / B6D2F1 %.2f (95%% CI %.2f-%.2f), P = %.2g\n", lab,
              sum(!x[, "D2mother"]), sum(x[, "D2mother"]), ci[1], ci[3], ci[4], summary(fit)$coefficients[5]))
}
cat("\nCox models, entry at set-up age\n")
for (d in c("CD", "HF")) { hr(f[f[, "Diet"] == d, ], paste(d, "all")); hr(f[f[, "Diet"] == d & f[, "Born"] <= 2015, ], paste(d, "born 2011-2015")) }
for (lab in c("all", "born 2011-2015")) {
  x <- if (lab == "all") f else f[f[, "Born"] <= 2015, ]
  a <- coxph(Surv(SetupAge, Age, rep(1, nrow(x))) ~ D2mother + Diet, data = x); i <- coxph(Surv(SetupAge, Age, rep(1, nrow(x))) ~ D2mother * Diet, data = x)
  cat(sprintf("Cross x diet interaction, %s: likelihood ratio P = %.2g\n", lab, anova(a, i)[2, "Pr(>|Chi|)"]))
}
cat("\nAges at death of F1s born 2011-2015:\n"); x <- f[f[, "Born"] <= 2015, ]
print(tapply(x[, "Age"], list(x[, "Strain"], x[, "Diet"]), function(a) paste(sort(a), collapse = " ")))
cat("\nB6D2F1 born 2022:", sum(f[, "Born"] == 2022 & !f[, "D2mother"]), "; of them euthanized:", sum(f[, "Born"] == 2022 & f[, "Status"] == "Euthanized" & !f[, "D2mother"]),
    "; D2B6F1 euthanized:", sum(f[, "D2mother"] & f[, "Status"] == "Euthanized"), "of", sum(f[, "D2mother"]), "\n")
cat("\nEvery F1:\n"); print(f[order(f[, "Diet"], f[, "Strain"], f[, "Age"]), c("Diet", "Strain", "EarTag", "Age", "SetupAge", "Vivarium", "Born", "Status")], row.names = FALSE)
sink()
