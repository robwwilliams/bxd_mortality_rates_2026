#
# masses_notes.R
#
# copyright (c) 2026 - Rob Williams
#
# Do mice with a mass or a swollen abdomen lose less weight before death? Rob, 27 October 2026: "Fascinating that some
# mice resist weight loss but not death. Solid tumors? What types of murine cancers associated with tumor weights of 2
# to 6 g? We may have some data for Roy et al. 2021 in which we did a bit of pathology." Exploratory, written after the
# Part 4 results were seen.
#
# The only pathology in our files is free text: the columns NotesByRoy and NotesByIngels of the sheet BXD_Females.
# Some notes give gross findings at necropsy. A mouse with no note may still have had a tumor, so "neither" below means
# "nothing recorded", not "no tumor". Mice of the Part 4 sample (output/Terminal_decline_by_mouse.txt) fall in three
# groups, by keyword:
#   mass     a mass, tumor, swollen abdomen, abdominal fluid, ascites or enlarged spleen ("fatty mass" excluded)
#   thin     thin, weight loss, poor body condition or not eating, and no mass
#   neither  none of these
# The measure is the last weight as a fraction of peak (Part 4's peak: the highest weight at least 120 days before
# death), in mice weighed within 7 days of death.
#
# Run from the repository root:  Rscript BodyWeight/masses_notes.R   (after BodyWeight/terminal_decline.R)
# Writes output/Masses_notes.txt (one row per mouse with a mass or a necropsy note) and prints the summaries
#

library(readxl)

b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females", .name_repair = "minimal")))
note <- paste(ifelse(is.na(b[, "NotesByRoy"]), "", b[, "NotesByRoy"]), ifelse(is.na(b[, "NotesByIngels"]), "", b[, "NotesByIngels"]), sep = " | ")
note <- gsub("[\r\n\t]+", " ", note)
td <- read.delim("output/Terminal_decline_by_mouse.txt", quote = "")
td[, "note"] <- note[match(td[, "EarTag"], b[, "EarTagNumberCurrent"])]; td[is.na(td[, "note"]), "note"] <- ""
low <- tolower(td[, "note"])
mass <- grepl("mass|tumou?r|distend|distension|splenomeg|enlarged spleen|ascites|abdominal fluid|fluid-filled|fluid filled|abdfluid", low) & !grepl("fatty mass|renal mass", low)
thin <- grepl("thin|weight loss|wt\\.? loss|poor body|bcs|emaciat|won't eat|dehydrat|not thriving|can't eat|couldn", low)
td[, "group"] <- ifelse(mass, "mass", ifelse(thin, "thin", "neither"))
td[, "gap"] <- td[, "Death"] - td[, "last.weigh"]
td[, "necropsy"] <- grepl("necrops", low)
cat("Part 4 sample:", nrow(td), "mice; notes of any kind:", sum(td[, "note"] != " | "), "; necropsy notes:", sum(td[, "necropsy"]), "\n")
print(table(td[, "group"], td[, "Type"]))

w <- td[td[, "gap"] <= 7 & td[, "Status"] %in% c("Euthanized", "Natural"), ]
cat("\nWeighed within 7 days of death: last weight / peak, by group and status\n")
s <- do.call(rbind, lapply(split(w, list(w[, "group"], w[, "Status"]), drop = TRUE), function(z)
  data.frame(group = z[1, "group"], status = z[1, "Status"], mice = nrow(z), median = round(median(z[, "last.rel"]), 3),
             at.least.95 = round(mean(z[, "last.rel"] >= 0.95), 2), below.90 = round(mean(z[, "last.rel"] < 0.90), 2))))
print(s, row.names = FALSE)

cat(sprintf("\nMice with a mass recorded: %d of %d at 95%% of peak or more (%.0f%%), %d of %d below it (%.0f%%)\n",
            sum(w[, "last.rel"] >= 0.95 & w[, "group"] == "mass"), sum(w[, "last.rel"] >= 0.95), 100 * mean(w[w[, "last.rel"] >= 0.95, "group"] == "mass"),
            sum(w[, "last.rel"] < 0.95 & w[, "group"] == "mass"), sum(w[, "last.rel"] < 0.95), 100 * mean(w[w[, "last.rel"] < 0.95, "group"] == "mass")))

# Within strain: mass against neither, adjusted for diet, status and days from the last weighing to death
z <- w[w[, "group"] != "thin", ]; z[, "group"] <- relevel(factor(z[, "group"]), "neither")
f <- summary(lm(last.rel ~ group + Diet + Status + gap + Genotype, z))$coefficients["groupmass", ]
cat(sprintf("\nMass - neither, within strain: %+.3f of peak (95%% CI %+.3f to %+.3f), P = %.2g; %d mice\n",
            f[1], f[1] - 1.96 * f[2], f[1] + 1.96 * f[2], f[4], nrow(z)))

# Necropsy notes: what was found
nec <- tolower(sub("^.*?necrops", "", td[td[, "necropsy"], "note"], perl = TRUE))
nec <- sub("(tissues? collected|cadaver status|any additional notes).*$", "", nec)   # lists of tissues taken are not findings
cat("\nMice with necropsy notes:", length(nec), "; with an internal mass, enlarged organ or fluid:",
    sum(grepl("mass|tumou?r|enlarged|fluid|blood|ascites|cyst|nodul", nec)), "\n")
born <- format(as.Date(b[match(td[td[, "necropsy"], "EarTag"], b[, "EarTagNumberCurrent"]), "DateOfBirth"]), "%Y")
cat("Born:\n"); print(table(born))
k <- c(liver = "liver", spleen = "spleen", ovary = "ovar", kidney = "kidney|hydroneph", uterus = "uter", mesentery = "mesent", lung = "lung",
       "blood in a body cavity" = "blood", fluid = "fluid", heart = "heart")
cat("Findings named (a mouse can have several):\n"); print(sapply(k, function(p) sum(grepl(p, nec))))
x <- w[w[, "group"] == "mass" & w[, "necropsy"], ]
cat("\nNecropsied mice with a mass, weighed within 7 days of death:", nrow(x), "; at 95% of peak or more:", sum(x[, "last.rel"] >= 0.95), "\n")

out <- td[td[, "group"] == "mass" | td[, "necropsy"], c("EarTag", "Genotype", "Diet", "Status", "Death", "last.weigh", "gap", "last.rel", "group", "necropsy", "note")]
out[, "last.rel"] <- round(out[, "last.rel"], 3)
write.table(out[order(-out[, "last.rel"]), ], "output/Masses_notes.txt", sep = "\t", quote = FALSE, row.names = FALSE)
