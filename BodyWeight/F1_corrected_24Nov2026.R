#
# F1_corrected_24Nov2026.R - The BXD x BXD F1 lifespans of 24 November 2026, with our corrections
#
# Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026. Suheeta Roy's workbook data/original/
# AgingBXD_F1_Lifespan_BodyWeightData_24Nov2026.xlsx: 322 F1 females, all now dead (our last file had 310; why it lacked
# the other 12 is not known: 10 of them died before its date). The rules were fixed before any analysis of the new data was run:
#   - names: BXD73x65 and BXD73x77 are BXD73b crosses, and X between parents is x (Rob, 27 October 2026, as before);
#   - Euthanized counts as Natural (Rob, 27 October 2026, as before); 3312, injured in its cage, stays Other;
#   - 3694 and 4520 were weighed after their recorded deaths (Suheeta is asking Casey): "Pending", so that every analysis, which
#     takes natural deaths, leaves them out. --keep-pending yes writes the sensitivity table, with their recorded ages.
# The recorded values are kept in StrainName_recorded and CauseOfDeath_recorded. Column names are those of the earlier table.
#   Rscript BodyWeight/F1_corrected_24Nov2026.R [--keep-pending yes]
# Writes data/corrected/AgingBXD_F1_24Nov2026_corrected.txt (or ..._with_pending.txt)
#

library(readxl)
keep <- "--keep-pending" %in% commandArgs(trailingOnly = TRUE)
f <- as.data.frame(suppressMessages(read_excel("data/original/AgingBXD_F1_Lifespan_BodyWeightData_24Nov2026.xlsx", .name_repair = "minimal", guess_max = 400)))
f <- f[!is.na(f[, "EarTagNumberCurrent"]), ]
colnames(f)[colnames(f) == "StrainNameCurrent"] <- "StrainName"; colnames(f)[colnames(f) == "AgeAtSettingUp (days)"] <- "AgeAtSet Up (days)"
colnames(f)[colnames(f) == "Weight00Baseline"] <- "Weight00 Baseline"
f[, "StrainName_recorded"] <- f[, "StrainName"]; f[, "CauseOfDeath_recorded"] <- f[, "CauseOfDeath"]
f[, "StrainName"] <- sub("^BXD73x", "BXD73bx", sub("X(?=[0-9])", "x", sub("^BXD", "", f[, "StrainName"]), perl = TRUE))
f[, "StrainName"] <- sub("^BXD73x", "BXD73bx", paste0("BXD", sub("^BXD", "", f[, "StrainName"])))
f[f[, "CauseOfDeath"] == "Euthanized", "CauseOfDeath"] <- "Natural"
f[grepl("^Other", f[, "CauseOfDeath"]), "CauseOfDeath"] <- "Other"
if(!keep) f[f[, "EarTagNumberCurrent"] %in% c(3694, 4520), "CauseOfDeath"] <- "Pending"
for(v in c("DateOfBirth", "DateDietStart", "DateOfDeath")) f[, v] <- format(as.Date(f[, v]))
f[, "NotesByRoy"] <- trimws(gsub("\\s*[\r\n\t]+\\s*", " / ", trimws(f[, "NotesByRoy"])))
types <- c("BXD102x73b", "BXD102x77", "BXD170x172", "BXD172x197", "BXD197x170", "BXD197x9", "BXD65x102", "BXD65x77", "BXD73bx65", "BXD73bx77", "BXD77x65", "BXD9x170", "BXD9x172")
stopifnot(setequal(f[, "StrainName"], types), !anyDuplicated(f[, "EarTagNumberCurrent"]), all(f[, "Sex"] == "F"), is.numeric(f[, "AgeAtDeath (days)"]), !anyNA(f[, "AgeAtDeath (days)"]),
          all(as.numeric(as.Date(f[, "DateOfDeath"]) - as.Date(f[, "DateOfBirth"])) == f[, "AgeAtDeath (days)"]))
out <- if(keep) "data/corrected/AgingBXD_F1_24Nov2026_corrected_with_pending.txt" else "data/corrected/AgingBXD_F1_24Nov2026_corrected.txt"
write.table(f, out, sep = "\t", quote = FALSE, row.names = FALSE, na = "")
cat(out, ":", nrow(f), "mice;", paste(names(table(f[, "CauseOfDeath"])), table(f[, "CauseOfDeath"]), collapse = ", "), "\n")
