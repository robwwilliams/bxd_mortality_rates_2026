#
# clean_table2.R
#
# copyright (c) 2026 - Rob Williams
#
# Clean copies of Arends et al. 2026 Supplementary Data Table 2: deaths and numbers alive per 15-day window by
# genotype (CH, CD, BH, BD) for the 29 Vita loci, for females, males and both sexes. As published, no file names its
# first column. The clean copies name it "T-age" and use plain hyphens, and every file is checked:
#   - the marginal columns: C = CH + CD, B = BH + BD, D = CD + BD, H = CH + BH;
#   - numbers alive fall by exactly the deaths (no censoring), every mouse dies, nGenotyped = the four alive columns;
#   - female + male = both sexes, for deaths, numbers alive and nTotal.
#
# Run: Rscript UMHET3/clean_table2.R data/original/Arends_2026_Supplementary_Table_2.zip data/umhet3/Table2
#

args <- commandArgs(trailingOnly = TRUE)
tmp <- tempfile(); unzip(args[1], exdir = tmp)
files <- list.files(tmp, "_deathsIn15Dwindows_.*\\.txt$", recursive = TRUE, full.names = TRUE)
files <- files[!grepl("__MACOSX", files)]
cn <- c("T-age", "CH", "CD", "BH", "BD", "C", "B", "D", "H", "CH_alive", "CD_alive", "BH_alive", "BD_alive", "nGenotyped", "nTotal")
dir.create(args[2], showWarnings = FALSE, recursive = TRUE)

problems <- c()
check <- function(ok, what) { if (!all(ok)) problems <<- c(problems, what) }
tables <- list()
for (f in files) {
  d <- read.delim(f, header = FALSE, skip = 1, col.names = cn, check.names = FALSE)
  d[["T-age"]] <- gsub("[^0-9]+", "-", d[["T-age"]])                  # "5–20" (en dash) becomes "5-20"
  nm <- sub("_deathsIn15Dwindows_(.*)\\.txt", " \\1", basename(f))
  check(d$C == d$CH + d$CD & d$B == d$BH + d$BD & d$D == d$CD + d$BD & d$H == d$CH + d$BH, paste(nm, "marginals"))
  for (g in c("CH", "CD", "BH", "BD")) {
    a <- d[[paste0(g, "_alive")]]
    check(head(a, -1) - head(d[[g]], -1) == a[-1], paste(nm, g, "alive does not fall by the deaths"))
    check(sum(d[[g]]) == a[1], paste(nm, g, "deaths do not sum to the mice"))
  }
  check(d$nGenotyped == d$CH_alive + d$CD_alive + d$BH_alive + d$BD_alive, paste(nm, "nGenotyped"))
  tables[[nm]] <- d
  write.table(d, file.path(args[2], basename(f)), sep = "\t", quote = FALSE, row.names = FALSE)
}
for (locus in unique(sub(" .*", "", names(tables)))) {
  fe <- tables[[paste(locus, "female")]]; ma <- tables[[paste(locus, "male")]]; bo <- tables[[paste(locus, "combined")]]
  check(as.matrix(fe[, -1]) + as.matrix(ma[, -1]) == as.matrix(bo[, -1]), paste(locus, "female + male differs from combined"))
}
cat(length(tables), "files written to", args[2], "\n")
if (length(problems) == 0) cat("All checks passed.\n") else cat("Problems:\n", paste(" ", problems, collapse = "\n"), "\n")
