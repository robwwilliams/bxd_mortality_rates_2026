#
# actuarial_means.R
#
# copyright (c) 2026 - Rob Williams
#
# Strain means of age at death at every T-age of Danny Arends's actuarial maps (Fig. 2, top two rows), for mapping on
# GN4AI-beta. Rob, 21 November 2026: "You are not doing the full actuarial scan in 30 day truncation steps right? That
# is what we want to do emulating Danny's figures." Exploratory.
#   - T-ages 20 to 800 days in 30-day steps. Danny's QTL_Lifespan_05Nov2026.xlsx runs from 20 to 770; its 27th column,
#     headed 770 like the 26th, is empty. 800 days was added to test that column before it was found empty.
#   - His rule: each strain with at least 3 mice alive at T (age at death >= T), set-up age ignored, parents and F1s left
#     out. Alive at T, not beyond it as in GN4AI/strain_means.R: only that gives the strain counts printed on his Fig. 2
#     (52 on high fat at 650 days and 30 at 710, against 50 and 29). The two rules agree at 20 days.
#   - Chow and high fat from Beni Mozhui's file, whose chow and high-fat rows are the same as Danny's.
#
# Run from the repository root:  Rscript GN4AI/actuarial_means.R
# Writes output/GN4AI/actuarial/strain_means.txt and one request body per diet and T-age,
# data/local/GN4AI/actuarial/<diet>_T<age>_body.json, for GN4AI/actuarial_scan.sh
#

library(jsonlite)

Tages <- seq(20, 800, by = 30)
parents <- c("C57BL/6J", "DBA/2J", "B6D2F1", "D2B6F1")
d <- read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM")[, 1:7]
colnames(d) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
d <- d[!is.na(d[, "EarTag"]) & !d[, "Strain"] %in% parents, ]

m <- NULL
for (diet in c("CD", "HF")) for (T in Tages) {
  x <- d[d[, "Diet"] == diet & d[, "Age"] >= T, ]
  n <- table(x[, "Strain"]); keep <- names(n)[n >= 3]
  m <- rbind(m, data.frame(Diet = diet, T = T, Strain = keep, n = as.numeric(n[keep]), Mean = round(tapply(x[, "Age"], x[, "Strain"], mean)[keep], 2)))
}
dir.create("output/GN4AI/actuarial", showWarnings = FALSE); dir.create("data/local/GN4AI/actuarial", showWarnings = FALSE)
write.table(m, "output/GN4AI/actuarial/strain_means.txt", sep = "\t", quote = FALSE, row.names = FALSE)
for (diet in c("CD", "HF")) for (T in Tages) {
  x <- m[m[, "Diet"] == diet & m[, "T"] == T, ]
  body <- list(group = "BXD", trait_name = paste0("BXD::lifespan_", diet, "_T", T), samples = data.frame(name = x[, "Strain"], value = x[, "Mean"]))
  writeLines(toJSON(body, auto_unbox = TRUE, digits = NA), paste0("data/local/GN4AI/actuarial/", diet, "_T", T, "_body.json"))
}
print(xtabs(~ T + Diet, m))
