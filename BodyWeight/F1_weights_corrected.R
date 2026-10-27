#
# F1_weights_corrected.R
#
# copyright (c) 2026 - Rob Williams
#
# The F1 body-weight table with our corrections, from the sheet NaturalDeath of
# data/original/AgingBXD_F1_BodyWeightData_Dec2024 copy.xlsx (which stays as received). Corrections, by Rob on 27 October 2026:
#   1. Six F1s labeled BXD73x65 or BXD73x77 are BXD73b crosses: only BXD73b was crossed. GeneNetwork (BDL_10002) already
#      lists these six ear tags (3092-3097) as BXD073b crosses, with the same ages at death.
#   2. Euthanized F1s count as natural deaths. They were euthanized within a week or two of natural death, judged by frailty,
#      to harvest organs for the biobank.
#   3. Spelling: X between the parents becomes x (BXD102X77 -> BXD102x77), as in the other names.
# The recorded values stay in the columns StrainName_recorded and CauseOfDeath_recorded. Line breaks inside the notes
# become " / " so that each mouse is one line of the text file.
#
# Run from the repository root:  Rscript BodyWeight/F1_weights_corrected.R
# Writes data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt
#

library(readxl)

f <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_F1_BodyWeightData_Dec2024 copy.xlsx", sheet = "NaturalDeath",
                                               .name_repair = "minimal")))
f[, "StrainName_recorded"] <- f[, "StrainName"]; f[, "CauseOfDeath_recorded"] <- f[, "CauseOfDeath"]
f[, "StrainName"] <- sub("^(BXD[0-9]+[a-wyz]?)X([0-9]+[a-wyz]?)$", "\\1x\\2", f[, "StrainName"])
f[, "StrainName"] <- sub("^BXD73x", "BXD73bx", f[, "StrainName"])
f[f[, "CauseOfDeath"] %in% "Euthanized", "CauseOfDeath"] <- "Natural"
for (v in c("NotesByIngels", "NotesByRoy")) f[, v] <- trimws(gsub("\\s*[\r\n\t]+\\s*", " / ", trimws(f[, v])))

cat("Strain names changed:\n"); print(table(paste(f[, "StrainName_recorded"], "->", f[, "StrainName"])[f[, "StrainName"] != f[, "StrainName_recorded"]]))
cat("Causes of death, recorded against corrected:\n"); print(table(f[, "CauseOfDeath_recorded"], f[, "CauseOfDeath"], useNA = "ifany"))
dir.create("data/corrected", showWarnings = FALSE)
write.table(f, "data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt", sep = "\t", quote = FALSE, row.names = FALSE, na = "")
