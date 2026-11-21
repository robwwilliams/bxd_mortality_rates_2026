#
# strain_means.R
#
# copyright (c) 2026 - Rob Williams
#
# Strain means of age at death for a test drive of GN4AI-beta, GeneNetwork's new interface for AI agents (Pjotr Prins,
# November 2026). Rob, 21 November 2026: "What we might try to do using Beni's updated and corrected file is some
# mapping that Danny has already done." Exploratory.
#
# The means follow Danny Arends's strain-means maps (Fig. 2, top two rows): at a T-age, each strain with at least 3 mice
# alive beyond it, set-up age ignored. That rule gives his counts: 93 strains on chow and 87 on high fat at 50 days, and
# 14 on high fat at 770 days (qc/Mapping_files_QC.md). Parents and F1s are left out, as he left them out.
#   - Chow and high fat: from Beni Mozhui's file, whose chow and high-fat rows are the same as Danny's.
#   - NAM: from Beni's file (four corrected ages) and from Danny's file (one corrected, NAM 4558), to see what the other
#     three corrections do to a map.
#
# Run from the repository root:  Rscript GN4AI/strain_means.R [T-age, default 20]
# Writes output/GN4AI/strain_means_T<age>.txt and one basket body per column, output/GN4AI/basket_<name>.json, for
# GN4AI/test_drive.sh
#

library(readxl)
library(jsonlite)

T <- as.numeric(c(commandArgs(trailingOnly = TRUE), 20)[1])
cn <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
parents <- c("C57BL/6J", "DBA/2J", "B6D2F1", "D2B6F1")
beni <- read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM")[, 1:7]
danny <- as.data.frame(suppressMessages(suppressWarnings(read_excel("data/original/Arends_Data_05Nov2026/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.xlsx", skip = 10, col_names = FALSE))))[, 1:7]
colnames(beni) <- cn; colnames(danny) <- cn
beni <- beni[!is.na(beni[, "EarTag"]), ]; danny <- danny[!is.na(as.numeric(danny[, "EarTag"])), ]

means <- function(d, diet, name) {
  x <- d[d[, "Diet"] == diet & !d[, "Strain"] %in% parents & d[, "Age"] > T, ]
  n <- table(x[, "Strain"]); keep <- names(n)[n >= 3]
  data.frame(Column = name, Diet = diet, Strain = keep, n = as.numeric(n[keep]), Mean = round(tapply(x[, "Age"], x[, "Strain"], mean)[keep], 2))
}
m <- rbind(means(beni, "CD", paste0("lifespan_CD_T", T)), means(beni, "HF", paste0("lifespan_HF_T", T)),
           means(beni, "NAM", paste0("lifespan_NAM_T", T, "_Beni")), means(danny, "NAM", paste0("lifespan_NAM_T", T, "_Danny")))
dir.create("output/GN4AI", showWarnings = FALSE)
write.table(m, paste0("output/GN4AI/strain_means_T", T, ".txt"), sep = "\t", quote = FALSE, row.names = FALSE)
for (b in unique(m[, "Column"])) {
  x <- m[m[, "Column"] == b, ]
  body <- list(name = b, kind = "trait", description = paste0("Mean age at death (days) of BXD females on ", x[1, "Diet"], ", strains with at least 3 mice alive beyond ", T,
               " days (set-up age ignored), from ", if (grepl("Danny", b)) "Danny Arends's mapping file of 4 November 2026" else "Beni Mozhui's mapping file of 21 November 2026",
               "; bxd_mortality_rates_2026, GN4AI/strain_means.R"), values = data.frame(name = x[, "Strain"], value = x[, "Mean"]))
  writeLines(toJSON(body, auto_unbox = TRUE, digits = NA), paste0("output/GN4AI/basket_", b, ".json"))
}
print(aggregate(cbind(strains = 1, mice = n) ~ Column, m, sum))
x <- merge(m[grepl("Beni$", m[, "Column"]), c("Strain", "Mean")], m[grepl("Danny$", m[, "Column"]), c("Strain", "Mean")], by = "Strain", suffixes = c(".Beni", ".Danny"))
cat("\nNAM strain means that differ between Beni's and Danny's files:\n"); print(x[x[, "Mean.Beni"] != x[, "Mean.Danny"], ], row.names = FALSE)
