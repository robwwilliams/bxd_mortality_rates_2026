#
# weights_QC.R
#
# copyright (c) 2026 - Rob Williams
#
# Flags body weighings that look wrong, for Suheeta Roy to review (Rob, 27 October 2026: "Pull out the anomalous F1s ...
# We can ask Suheeta to review the odd cases and decide whether there are extenuating circumstances"). Nothing is
# changed or dropped here; the workbooks in data/original/ stay as received. Every mouse in the sheets BXD_Females and
# NaturalDeath, and in the NAM workbook (added on 27 October 2026 with the same rules, after Rob's go-ahead), is
# checked, whether or not it is in our analyses. The rules, fixed before the list was looked at:
#   A  Out of range: heavier than 120 g, or lighter than 10 g at 60 days of age or older.
#   B  Isolated spike: more than 15% away from both neighboring weighings, in the same direction, while the two
#      neighbors agree within 5%.
#   C  Fast loss in an adult (120 days or older): more than 15% lost within 14 days, or more than 30% per 30 days.
#   D  Fast gain in an adult (300 days or older) at least 150 days after set-up: more than 30% gained between two
#      weighings. (Mice set up late gain fast on high fat for months after set-up; that gain is real.)
#   E  Weighed after the recorded age at death.
#   F  Age at weighing differs by more than 2 days from the date of weighing minus the date of birth (BXD and NAM
#      workbooks; the F1 workbook has no weighing dates).
#   G  Age at weighing lower than at the weighing before it in the workbook.
#
# Run from the repository root:  Rscript BodyWeight/weights_QC.R
# Writes qc/BodyWeight_flags.txt (one row per flagged weighing, with the mouse's whole series) and prints a summary
#

library(readxl)

num <- function(v) suppressWarnings(as.numeric(v))
day <- function(v) if (inherits(v, "POSIXct")) as.numeric(as.Date(v)) else as.numeric(as.Date(num(v), origin = "1899-12-30"))   # some columns hold Excel day numbers
long.weights <- function(x, tag, base.w, base.age, nw, dates) {          # one row per weighing, in workbook column order
  cols <- c(base.w, sprintf("Weight%02d", seq_len(nw))); ages <- c(base.age, sprintf("AgeAtWeight%02d", seq_len(nw)))
  dcol <- c("DateWeightBaseline", sprintf("DateWeight%02d", seq_len(nw)))
  do.call(rbind, lapply(seq_along(cols), function(j) data.frame(EarTag = tag, column = cols[j], order = j, age = num(x[, ages[j]]), w = num(x[, cols[j]]),
                                                                 date = if (dates) day(x[, dcol[j]]) else NA)))
}

b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females", .name_repair = "minimal")))
f <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_F1_BodyWeightData_Dec2024 copy.xlsx", sheet = "NaturalDeath", .name_repair = "minimal")))
nm <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_NAM_BodyWeight_Feb2026.xlsx", .name_repair = "minimal")))
m <- as.data.frame(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal"))[, 1:3]
mice <- rbind(data.frame(Workbook = "BXD", EarTag = b[, "EarTagNumberCurrent"], Strain = b[, "StrainName"], Diet = b[, "Diet"], Status = b[, "Status"],
                         Death = num(b[, "AgeAtDeath"]), Born = day(b[, "DateOfBirth"]),
                         Analyzed = b[, "EarTagNumberCurrent"] %in% m[m[, 3] %in% c("CD", "HF"), 2]),
              data.frame(Workbook = "F1", EarTag = f[, "EarTagNumberCurrent"], Strain = f[, "StrainName"], Diet = f[, "DietCode"], Status = f[, "CauseOfDeath"],
                         Death = num(f[, "AgeAtDeath (days)"]), Born = NA,
                         Analyzed = f[, "CauseOfDeath"] %in% c("Natural", "Euthanized") & !is.na(num(f[, "AgeAtDeath (days)"]))),
              data.frame(Workbook = "NAM", EarTag = nm[, "EarTagNumberCurrent"], Strain = nm[, "StrainName"], Diet = nm[, "Diet"], Status = nm[, "Status"],
                         Death = num(nm[, "AgeAtDeath"]), Born = day(nm[, "DateOfBirth"]),
                         Analyzed = nm[, "EarTagNumberCurrent"] %in% m[m[, 3] %in% "NAM", 2]))
W <- rbind(cbind(Workbook = "BXD", long.weights(b, b[, "EarTagNumberCurrent"], "Weight00 Baseline", "AgeAtSetUp", 20, TRUE)),
           cbind(Workbook = "F1", long.weights(f, f[, "EarTagNumberCurrent"], "Weight00 Baseline", "AgeAtSet Up (days)", 18, FALSE)),
           cbind(Workbook = "NAM", long.weights(nm, nm[, "EarTagNumberCurrent"], "Weight00Baseline", "AgeAtSettingUp", 20, TRUE)))
W <- W[!is.na(W[, "w"]) & !is.na(W[, "age"]), ]
key <- paste(mice[, "Workbook"], mice[, "EarTag"]); W[, "key"] <- paste(W[, "Workbook"], W[, "EarTag"])
cat("Mice:", nrow(mice), "(BXD workbook", sum(mice[, "Workbook"] == "BXD"), "; F1 workbook", sum(mice[, "Workbook"] == "F1"), "; NAM workbook",
    sum(mice[, "Workbook"] == "NAM"), ")  weighings:", nrow(W), "\n")

flags <- do.call(rbind, lapply(split(W, W[, "key"]), function(z) {
  i <- match(z[1, "key"], key); out <- c()
  flag <- function(r, rule) out <<- rbind(out, data.frame(row = r, rule = rule))
  for (r in seq_len(nrow(z))) {
    if (z[r, "w"] > 120 || (z[r, "w"] < 10 && z[r, "age"] >= 60)) flag(r, "A out of range")
    if (!is.na(mice[i, "Death"]) && z[r, "age"] > mice[i, "Death"]) flag(r, "E after death")
    if (!is.na(z[r, "date"]) && !is.na(mice[i, "Born"]) && abs(z[r, "date"] - mice[i, "Born"] - z[r, "age"]) > 2) flag(r, "F age disagrees with date")
    if (r > 1 && z[r, "age"] < z[r - 1, "age"]) flag(r, "G age lower than the weighing before")
  }
  o <- order(z[, "age"]); n <- length(o)
  if (n >= 3) for (k in 2:(n - 1)) {
    p <- z[o[k - 1], "w"]; w <- z[o[k], "w"]; q <- z[o[k + 1], "w"]
    if (abs(log(w / p)) > log(1.15) && abs(log(w / q)) > log(1.15) && sign(w - p) == sign(w - q) && abs(log(q / p)) < log(1.05)) flag(o[k], "B isolated spike")
  }
  if (n >= 2) for (k in 2:n) {
    a0 <- z[o[k - 1], "age"]; a1 <- z[o[k], "age"]; w0 <- z[o[k - 1], "w"]; w1 <- z[o[k], "w"]; gap <- a1 - a0
    if (a0 >= 120 && gap > 0 && ((gap <= 14 && w1 < 0.85 * w0) || (w0 - w1) / w0 * 30 / gap > 0.30)) flag(o[k], "C fast loss")
    if (a0 >= 300 && a0 - z[o[1], "age"] >= 150 && w1 > 1.30 * w0) flag(o[k], "D fast gain")
  }
  if (is.null(out)) return(NULL)
  out <- aggregate(rule ~ row, out, paste, collapse = "; ")
  series <- paste(sprintf("%d:%s", round(z[o, "age"]), format(z[o, "w"], trim = TRUE)), collapse = " ")
  do.call(rbind, lapply(seq_len(nrow(out)), function(j) {
    r <- out[j, "row"]; k <- which(o == r)
    data.frame(mice[i, c("Workbook", "EarTag", "Strain", "Diet", "Status", "Death", "Analyzed")], Column = z[r, "column"], Age = z[r, "age"], Weight = z[r, "w"],
               PrevAge = if (k > 1) z[o[k - 1], "age"] else NA, PrevWeight = if (k > 1) z[o[k - 1], "w"] else NA,
               NextAge = if (k < n) z[o[k + 1], "age"] else NA, NextWeight = if (k < n) z[o[k + 1], "w"] else NA,
               Rule = out[j, "rule"], Series = series)
  }))
}))
flags <- flags[order(flags[, "Workbook"], flags[, "EarTag"], flags[, "Age"]), ]
colnames(flags)[colnames(flags) == "Death"] <- "AgeAtDeath"
write.table(flags, "qc/BodyWeight_flags.txt", sep = "\t", quote = FALSE, row.names = FALSE, na = "")

cat("\nFlagged weighings by rule and workbook (a weighing can break more than one rule):\n")
r <- strsplit(flags[, "Rule"], "; "); print(table(unlist(r), rep(flags[, "Workbook"], lengths(r))))
cat("\nFlagged weighings:", nrow(flags), " mice:", nrow(unique(flags[, c("Workbook", "EarTag")])),
    " of them in our analyses:", nrow(unique(flags[flags[, "Analyzed"], c("Workbook", "EarTag")])), "\n")
cat("\nRules A-D, every flagged weighing:\n")
x <- flags[grepl("^[ABCD]|; [ABCD]", flags[, "Rule"]), ]
print(x[, c("Workbook", "EarTag", "Strain", "Diet", "Status", "AgeAtDeath", "Analyzed", "Age", "Weight", "PrevAge", "PrevWeight", "NextAge", "NextWeight", "Rule")], row.names = FALSE)
