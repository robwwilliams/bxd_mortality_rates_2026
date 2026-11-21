#
# mapping_files_QC.R
#
# copyright (c) 2026 - Rob Williams
#
# Checks the two files Danny Arends mapped from in November 2026 (data/original/Arends_Data_05Nov2026/) against the
# files we have: Suheeta Roy's mapping workbook of 23 October (ours), Beni Mozhui's newer CSV of 21 November, Suheeta's
# body-weight workbooks and the GeneNetwork export of BDL_10002. Rob, 21 November 2026: "look at the files Danny used
# for mapping which may not included this small number of fixes ... Beni's file has these correction. So do a QC and
# comparison of what Danny used first." Nothing is changed. Exploratory: the checks were chosen after the four NAM
# corrections in Beni's file were known.
#   1  Lifespan: every mouse and column of Danny's file against ours and Beni's.
#   2  Danny's sample sizes (the notes at the top of his file), recomputed from his rows.
#   3  The mice weighed after their recorded death (rule E of qc/BodyWeight_flags.txt): their age at death in each file.
#   4  Body weights: every weighing in Danny's file against Suheeta's workbooks, and his ages at death against his
#      lifespan file.
#
# Run from the repository root:  Rscript qc/mapping_files_QC.R
# Writes qc/mapping_files_QC.txt (one row per difference or flagged mouse) and prints a summary
#

library(readxl)

num <- function(v) suppressWarnings(as.numeric(v))
cn <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
parents <- c("C57BL/6J", "DBA/2J", "B6D2F1", "D2B6F1")                   # not mapped, as in the notes of Danny's file
mapping <- function(x) { x <- as.data.frame(x)[, 1:7]; colnames(x) <- cn; x <- x[!is.na(num(x[, "EarTag"])), ]; x[, "key"] <- paste(x[, "Diet"], x[, "EarTag"]); x }
out <- c()
add <- function(check, d, field, Danny, Ours = NA, Beni = NA, GN = NA, note = "") {
  out <<- rbind(out, data.frame(Check = check, Diet = d[, "Diet"], EarTag = d[, "EarTag"], Strain = d[, "Strain"], Field = field,
                                Danny = Danny, Ours = Ours, Beni = Beni, GN = GN, Note = note))
}

dir <- "data/original/Arends_Data_05Nov2026/"
dl <- suppressMessages(suppressWarnings(read_excel(paste0(dir, "BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.xlsx"), skip = 10, col_names = FALSE)))
danny <- mapping(dl); danny[, "Note"] <- as.data.frame(dl)[!is.na(num(as.data.frame(dl)[, 2])), 8]
ours <- mapping(suppressMessages(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal")))
beni <- mapping(read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM"))
gn <- as.data.frame(suppressWarnings(read_excel("data/original/BDL_10002.xlsx", skip = 10, .name_repair = "minimal")))
gn.age <- function(d) gn[match(paste0(ifelse(d[, "Diet"] == "NAM", "N", "L"), sprintf("%04d", num(d[, "EarTag"]))), gn[, "Name"]), "Value"]

### 1  Lifespan files
cat("Mice by diet, and duplicated diet + ear tag:\n")
for (f in c("danny", "ours", "beni")) { d <- get(f); cat(sprintf("  %-5s", f)); print(c(table(d[, "Diet"]), duplicated = sum(duplicated(d[, "key"])))) }
for (f in c("ours", "beni")) {
  d <- get(f); lab <- c(ours = "Ours", beni = "Beni")[f]
  only <- d[!d[, "key"] %in% danny[, "key"], ]
  if (nrow(only)) { add(1, only, "not in Danny's file", NA, note = paste("in", lab, "only")); cat("\nIn", lab, "but not in Danny's file:\n"); print(table(only[, "Diet"], only[, "Strain"])) }
  cat("In Danny's file but not in", lab, ":", sum(!danny[, "key"] %in% d[, "key"]), "\n")
}
j.ours <- match(danny[, "key"], ours[, "key"]); j.beni <- match(danny[, "key"], beni[, "key"])
for (v in c("Strain", "Age", "SetupAge", "Vivarium")) {
  i <- which(as.character(danny[, v]) != as.character(ours[j.ours, v]) | as.character(danny[, v]) != as.character(beni[j.beni, v]))
  cat(v, "differs in", length(i), "mice\n")
  if (length(i)) add(1, danny[i, ], v, danny[i, v], ours[j.ours[i], v], beni[j.beni[i], v], if (v == "Age") gn.age(danny[i, ]) else NA,
                     ifelse(is.na(danny[i, "Note"]), "", paste0("Danny's note: ", danny[i, "Note"])))
}
print(out[out[, "Check"] == 1 & out[, "Field"] != "not in Danny's file", -1], row.names = FALSE)

### 2  Danny's sample sizes
m <- danny[!danny[, "Strain"] %in% parents, ]
cat("\nDanny's notes: 1,934 CD and HF (CD 1,044, HFD 890); mapped 929 on CD, 818 on HFD, 143 on NAM (1,890);",
    "vivarium 1/2/3 = 395/163/371 on CD and 395/208/215 on HFD. Recomputed:\n")
print(table(danny[, "Diet"])); print(table(m[, "Diet"])); print(table(Vivarium = m[, "Vivarium"], m[, "Diet"]))
cat("Parents and F1s by diet:\n"); print(table(danny[danny[, "Strain"] %in% parents, "Strain"], danny[danny[, "Strain"] %in% parents, "Diet"]))

### 3  Mice weighed after their recorded death
fl <- read.delim("qc/BodyWeight_flags.txt", colClasses = "character")
e <- fl[grepl("(^|; )E ", fl[, "Rule"]) & fl[, "Workbook"] %in% c("BXD", "NAM"), ]
e[, "Last"] <- sapply(strsplit(e[, "Series"], " "), function(s) max(num(sub(":.*", "", s))))
e <- e[!duplicated(paste(e[, "Workbook"], e[, "EarTag"])), ]
e[, "key"] <- paste(e[, "Diet"], e[, "EarTag"])
e <- e[e[, "key"] %in% c(danny[, "key"], ours[, "key"]), ]                     # mice in a mapping file
d <- e[, c("Diet", "EarTag", "Strain")]
age <- function(f) get(f)[match(e[, "key"], get(f)[, "key"]), "Age"]
mapped <- e[, "key"] %in% m[, "key"]
add(3, d, "age at death; weighed after it", age("danny"), age("ours"), age("beni"), gn.age(d),
    paste0("last weighed at ", e[, "Last"], " days", ifelse(mapped, "", "; not mapped by Danny")))
x <- out[out[, "Check"] == 3, ]
x[, "After"] <- e[, "Last"] - num(ifelse(is.na(x[, "Danny"]), x[, "Ours"], x[, "Danny"]))
cat("\nMice in a mapping file weighed after their recorded death:", nrow(x), "; in Danny's mapped set:", sum(mapped),
    "; corrected in Danny's file:", sum(mapped & x[, "Danny"] != x[, "Ours"]), "; corrected in Beni's:", sum(!is.na(x[, "Beni"]) & x[, "Beni"] != x[, "Ours"]), "\n")
print(x[order(-x[, "After"]), c("Diet", "EarTag", "Strain", "Danny", "Ours", "Beni", "GN", "After", "Note")], row.names = FALSE)
# How far each strain mean could move: each mouse dies no earlier than its last weighing (a lower bound on the true age)
y <- x[mapped & x[, "After"] > 0, ]; y[, "cell"] <- paste(y[, "Strain"], y[, "Diet"])
s <- do.call(rbind, lapply(split(y, y[, "cell"]), function(z) {
  c <- m[m[, "Strain"] == z[1, "Strain"] & m[, "Diet"] == z[1, "Diet"], ]; a <- num(c[, "Age"]); lo <- a
  lo[match(z[, "EarTag"], c[, "EarTag"])] <- num(z[, "Danny"]) + z[, "After"]
  data.frame(Strain = z[1, "Strain"], Diet = z[1, "Diet"], n = length(a), mice = nrow(z), mean = round(mean(a)), at.least = round(mean(lo)), shift = round(mean(lo) - mean(a)))
}))
cat("\nStrain means in Danny's mapped set, as recorded and with each flagged mouse living at least to its last weighing:\n")
print(s[order(-s[, "shift"]), ], row.names = FALSE)

### 4  Body weights
long <- function(x, tag, base.w, base.age, nw) {                           # one row per weighing, in workbook column order
  cols <- c(base.w, sprintf("Weight%02d", seq_len(nw))); ages <- c(base.age, sprintf("AgeAtWeight%02d", seq_len(nw)))
  do.call(rbind, lapply(seq_along(cols), function(j) data.frame(EarTag = tag, column = sprintf("Weight%02d", j - 1), age = num(x[, ages[j]]), w = num(x[, cols[j]]))))
}
dw <- suppressWarnings(as.data.frame(read_excel(paste0(dir, "BXD_BodyWeight_AllDiets_Dataset_Mapping_Arends.xlsx"), skip = 4, .name_repair = "minimal")))
dw <- dw[!is.na(num(dw[, 2])), ]
dw <- data.frame(EarTag = num(dw[, 2]), Diet = dw[, 3], Strain = dw[, 4], Status = dw[, 7], Death = num(dw[, 8]), dw[, 12:54], check.names = FALSE)
b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females", .name_repair = "minimal")))
nm <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_NAM_BodyWeight_Feb2026.xlsx", .name_repair = "minimal")))
wb <- rbind(data.frame(EarTag = num(b[, "EarTagNumberCurrent"]), Diet = b[, "Diet"], Strain = b[, "StrainName"], Status = b[, "Status"], Death = num(b[, "AgeAtDeath"]), row = seq_len(nrow(b)), book = "BXD"),
            data.frame(EarTag = num(nm[, "EarTagNumberCurrent"]), Diet = nm[, "Diet"], Strain = nm[, "StrainName"], Status = nm[, "Status"], Death = num(nm[, "AgeAtDeath"]), row = seq_len(nrow(nm)), book = "NAM"))
wb <- wb[!duplicated(paste(wb[, "Diet"], wb[, "EarTag"])) | !paste(wb[, "Diet"], wb[, "EarTag"]) %in% paste(dw[, "Diet"], dw[, "EarTag"]), ]
dw[, "key"] <- paste(dw[, "Diet"], dw[, "EarTag"]); wb[, "key"] <- paste(wb[, "Diet"], wb[, "EarTag"])
cat("\nBody weights: Danny's file has", nrow(dw), "mice (duplicated diet + ear tag:", sum(duplicated(dw[, "key"])), ")\n"); print(table(dw[, "Diet"]))
cat("Not in Suheeta's workbooks:", sum(!dw[, "key"] %in% wb[, "key"]), "; not in Danny's lifespan file:", sum(!dw[, "key"] %in% danny[, "key"]),
    "; in his mapped lifespan set but without body weights:", sum(!m[, "key"] %in% dw[, "key"]), "\n")
print(table(m[!m[, "key"] %in% dw[, "key"], "Diet"]))
i <- match(dw[, "key"], wb[, "key"]); k <- match(dw[, "key"], danny[, "key"])
cat("Strain differs from the workbooks:", sum(dw[, "Strain"] != wb[i, "Strain"], na.rm = TRUE), "; status differs:", sum(dw[, "Status"] != wb[i, "Status"], na.rm = TRUE), "\n")
cat("Status in Danny's body-weight file:\n"); print(table(dw[, "Status"], dw[, "Diet"]))
s <- which(dw[, "Death"] != danny[k, "Age"] | dw[, "Death"] != wb[i, "Death"])
cat("Age at death differs between Danny's body-weight file, his lifespan file and the workbooks:", length(s), "mice\n")
if (length(s)) add(4, dw[s, ], "age at death: Danny = his body-weight file, Ours = Suheeta's workbook", dw[s, "Death"], wb[i[s], "Death"], NA, gn.age(dw[s, ]),
                   paste0("his lifespan file: ", danny[k[s], "Age"]))
W <- long(dw, dw[, "EarTag"], "Weight00 Baseline", "AgeAtSetUp (Days)", 20); W[, "key"] <- rep(dw[, "key"], 21)
B <- rbind(long(b, num(b[, "EarTagNumberCurrent"]), "Weight00 Baseline", "AgeAtSetUp", 20), long(nm, num(nm[, "EarTagNumberCurrent"]), "Weight00Baseline", "AgeAtSettingUp", 20))
B[, "key"] <- c(rep(paste(b[, "Diet"], num(b[, "EarTagNumberCurrent"])), 21), rep(paste(nm[, "Diet"], num(nm[, "EarTagNumberCurrent"])), 21))
B <- B[!duplicated(paste(B[, "key"], B[, "column"])), ]
j <- match(paste(W[, "key"], W[, "column"]), paste(B[, "key"], B[, "column"]))
same <- function(p, q) (is.na(p) & is.na(q)) | (!is.na(p) & !is.na(q) & abs(p - q) < 1e-6)
dif <- which(!same(W[, "w"], B[j, "w"]) | (!is.na(W[, "w"]) & !same(W[, "age"], B[j, "age"])))
cat("Weighings in Danny's file:", sum(!is.na(W[, "w"])), "; differing from the workbooks in weight or age:", length(dif), "\n")
if (length(dif)) {
  r <- match(W[dif, "key"], dw[, "key"])
  add(4, dw[r, ], paste0(W[dif, "column"], ": weight (age)"), sprintf("%s (%s)", W[dif, "w"], W[dif, "age"]), sprintf("%s (%s)", B[j[dif], "w"], B[j[dif], "age"]))
  print(out[out[, "Check"] == 4 & grepl("^Weight", out[, "Field"]), c("Diet", "EarTag", "Strain", "Field", "Danny", "Ours")], row.names = FALSE)
}
k <- match(W[, "key"], danny[, "key"])
late <- which(!is.na(W[, "w"]) & W[, "age"] > danny[k, "Age"])
cat("Weighings in Danny's body-weight file after the age at death in his lifespan file:", length(late), "in", length(unique(W[late, "key"])), "mice\n")
print(table(sub(" .*", "", W[late, "key"])))
r <- match(unique(W[late, "key"]), dw[, "key"])
add(4, dw[r, ], "weighings after his age at death", as.numeric(table(W[late, "key"])[dw[r, "key"]]), NA, NA, NA,
    paste0("age at death ", dw[r, "Death"], "; weighed to ", tapply(W[late, "age"], W[late, "key"], max)[dw[r, "key"]]))

write.table(out, "qc/mapping_files_QC.txt", sep = "\t", quote = FALSE, row.names = FALSE, na = "")
