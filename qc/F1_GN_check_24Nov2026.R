#
# F1_GN_check_24Nov2026.R - Suheeta Roy's F1 workbook of 24 November 2026 against GeneNetwork's BDL_10002, mouse by mouse
#
# Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026. The two are joined by ear tag. Neither is assumed right:
# the rows below are questions for Suheeta and Casey. Analyses follow the workbook, the newer of the two.
#   Rscript qc/F1_GN_check_24Nov2026.R
# Writes qc/F1_GN_check_24Nov2026.txt
#

library(readxl)
e <- as.data.frame(read_excel("data/original/BDL_10002.xlsx", skip = 10, col_types = "text", .name_repair = "minimal"))
e <- e[grepl("^BXD.*[xX]BXD.*F1$", e[, "Strain"]) & e[, "Sex"] == "F" & e[, "Tx"] %in% c("CD", "HF"), ]
gn <- data.frame(tag = as.numeric(e[, "EarTag"]), type = paste0("BXD", sub("X", "x", gsub("BXD0*", "", sub("F1$", "", e[, "Strain"])))),
                 diet = e[, "Tx"], age = as.numeric(e[, "Value"]))
n <- read.delim("data/corrected/AgingBXD_F1_24Nov2026_corrected.txt", check.names = FALSE, quote = "")
wb <- data.frame(tag = n[, "EarTagNumberCurrent"], type = n[, "StrainName"], diet = n[, "DietCode"], age = n[, "AgeAtDeath (days)"], setup = n[, "AgeAtSet Up (days)"])
m <- merge(gn, wb, by = "tag", suffixes = c(".GN", ".workbook"), all = TRUE)
m <- m[is.na(m[, "age.GN"]) | is.na(m[, "age.workbook"]) | m[, "age.GN"] != m[, "age.workbook"] | m[, "type.GN"] != m[, "type.workbook"] | m[, "diet.GN"] != m[, "diet.workbook"], ]
m[, "note"] <- ifelse(is.na(m[, "age.workbook"]), "not in the workbook", ifelse(m[, "age.GN"] == m[, "age.workbook"], "cross or diet differs",
               ifelse(m[, "age.workbook"] - m[, "age.GN"] == m[, "setup"], "age differs by exactly the set-up age", "age differs")))
write.table(m, "qc/F1_GN_check_24Nov2026.txt", sep = "\t", quote = FALSE, row.names = FALSE, na = "")
print(m, row.names = FALSE)
