#
# cauchy_review.R
#
# copyright (c) 2026 - Rob Williams
#
# Review of the Cauchy combination test of Arends et al. 2026 (Nature 654:437), Methods "Significance testing for
# actuarial analyses" and Table 1, as coded in ActuarialMapping/Cauchy.R of github.com/DannyArends/UM-HET3 (commit
# 132ca3f). Rob, 21 November 2026: "Please review the Cauchy code from the Nature paper and Danny's repo. We will need it
# in this paper too." Exploratory.
#   1. Reproduce Table 1c (Cauchy -logP of each Vita locus: combined, male, female) from the published LOD matrices
#      (Supplementary Table 9.1-9.3; T35 to T1100 in 15-day steps, 891 markers) with Danny's function: P = 10^-LOD at
#      each T-age, Cauchy combination over T-ages with equal weights, Benjamini-Hochberg over markers.
#   2. P from LOD on the right degrees of freedom. ProgressiveMapping.R's LOD is (n/2) log10(RSS0/RSS1) for four genotype
#      probabilities, a test on 3 d.f., so P = Pr(chi-square on 3 d.f. > 2 ln(10) LOD), not 10^-LOD.
#   3. LODs rounded to 0.00 in the tables give P = 1, and the Cauchy transform of P = 1 is minus infinity, which forces
#      the combined P to 1 whatever the other T-ages show. Count the markers affected.
#
# Inputs not in git, in data/local/: Arends_Supplementary_Tables_10Apr2026/S_Table_9_Vita_mapping_results_18Aug2025.xlsx
# and Table1_Vita_Loci_Expanded_clean_2026-10-26.xlsx
# Run from the repository root:  Rscript UMHET3/cauchy_review.R
# Writes output/UMHET3_cauchy_review.txt
#

library(readxl)

cauchycombination <- function(p){ pcauchy(mean(qcauchy(p, lower.tail = FALSE)), lower.tail = FALSE) }   # Danny's, unchanged
p.lod <- function(lod, df){ pchisq(2 * log(10) * lod, df, lower.tail = FALSE) }

f9 <- "data/local/Arends_Supplementary_Tables_10Apr2026/S_Table_9_Vita_mapping_results_18Aug2025.xlsx"
readLODs <- function(sheet){
  x <- as.data.frame(suppressMessages(read_excel(f9, sheet = sheet, col_names = FALSE)))
  i <- which(!is.na(suppressWarnings(as.numeric(x[, 3]))))[1]
  m <- suppressWarnings(sapply(x[i:nrow(x), -(1:2)], as.numeric))
  dimnames(m) <- list(x[i:nrow(x), 2], unlist(x[i - 1, -(1:2)]))
  m
}
lods <- list(Combined = readLODs("S_Table_9.1_Combined"), Male = readLODs("S_Table_9.2_Male"), Female = readLODs("S_Table_9.3_Female"))

# The Vita markers, as listed in Cauchy.R
vita <- c(Vita1a = "1_3010274", Vita1b = "1_24042124", Vita1c = "1_121483290", Vita1d = "1_167148678", Vita2a = "2_89156987",
          Vita2b = "2_112255823", Vita2c = "2_148442635", Vita3a = "3_83354281", Vita4a = "4_52524395", Vita4b = "4_154254581",
          Vita5a = "5_67573068", Vita6a = "6_93680853", Vita6b = "6_132762500", Vita9a = "9_34932404", Vita9b = "9_104091597",
          Vita9c = "9_124056586", Vita10a = "10_72780332", Vita11a = "11_6599922", Vita11b = "11_82176894", Vita11c = "11_113729074",
          Vita12a = "12_112855820", Vita13a = "13_83858506", Vita14a = "14_78415875", Vita14b = "14_101437466", Vita15a = "15_74248242",
          Vita15b = "15_99306167", Vita17a = "17_32883804", Vita18a = "18_52488251", VitaXa = "X_36008085", VitaXb = "X_150646933")
t1 <- as.data.frame(suppressMessages(read_excel("data/local/Table1_Vita_Loci_Expanded_clean_2026-10-26.xlsx", sheet = "Table_1c_Cauchy", col_names = FALSE)))
t1 <- t1[!is.na(suppressWarnings(as.numeric(t1[, 1]))), 2:5]
colnames(t1) <- c("Locus", "Combined", "Male", "Female")

sink("output/UMHET3_cauchy_review.txt", split = TRUE)
cat("Cauchy combination test of Arends et al. 2026: review (exploratory)\n")
cat("Published LOD matrices: T-ages", rownames(lods[[1]])[1], "to", rownames(lods[[1]])[nrow(lods[[1]])], "(", nrow(lods[[1]]), "), markers", ncol(lods[[1]]), "\n")
res <- data.frame(Locus = names(vita))
for(s in names(lods)){
  L <- lods[[s]]
  zero <- colSums(L == 0, na.rm = TRUE) > 0
  bh <- function(p) -log10(p.adjust(p, "BH"))
  danny <- apply(L, 2, function(l) cauchycombination(10^-l))
  df3 <- apply(L, 2, function(l) cauchycombination(p.lod(l, 3)))
  df3.nozero <- apply(L, 2, function(l) cauchycombination(p.lod(l[l > 0], 3)))
  cat(sprintf("\n%s: markers with a LOD of 0.00 at some T-age (Cauchy P forced to 1): %d of %d\n", s, sum(zero), length(zero)))
  res[, paste0(s, ".published")] <- as.numeric(t1[match(names(vita), t1[, "Locus"]), s])
  res[, paste0(s, ".Danny")] <- round(bh(danny)[vita], 2)
  res[, paste0(s, ".3df")] <- round(bh(df3)[vita], 2)
  hit <- names(vita)[zero[vita]]
  for(v in hit){
    l <- L[, vita[v]]
    cat(sprintf("  %s %s: peak LOD %.2f at %s; LODs of 0.00 at %d T-ages; BH-adjusted Cauchy -logP leaving them out: %.2f (P = 10^-LOD), %.2f (3 d.f.)\n", s, v, max(l, na.rm = TRUE),
                names(l)[which.max(l)], sum(l == 0, na.rm = TRUE), bh(apply(L, 2, function(z) cauchycombination(10^-z[z > 0])))[vita[v]], bh(df3.nozero)[vita[v]]))
  }
  cat(sprintf("  markers with BH-adjusted Cauchy -logP >= 1.5: Danny's conversion %d; 3 d.f. %d; 3 d.f. leaving out LODs of 0.00 %d\n",
              sum(bh(danny) >= 1.5), sum(bh(df3) >= 1.5), sum(bh(df3.nozero) >= 1.5)))
}
cat("\nVita loci, BH-adjusted Cauchy -logP: published (Table 1c), recomputed with Danny's code (P = 10^-LOD), and with P on 3 d.f.\n")
print(res, row.names = FALSE)
for(s in names(lods)){
  d <- res[, paste0(s, ".Danny")] - res[, paste0(s, ".published")]
  cat(sprintf("%s: recomputed minus published, median %.2f, range %.2f to %.2f; Vita loci at >= 1.5: published %d, Danny %d, 3 d.f. %d\n", s, median(d, na.rm = TRUE),
              min(d, na.rm = TRUE), max(d, na.rm = TRUE), sum(res[, paste0(s, ".published")] >= 1.5, na.rm = TRUE), sum(res[, paste0(s, ".Danny")] >= 1.5), sum(res[, paste0(s, ".3df")] >= 1.5)))
}
cat("\nLOD thresholds of the paper (3.65, 3.95, 4.65 = -log10 of 0.10, 0.05, 0.01 over 442 tests) as P values for a LOD on 3 d.f.:\n")
for(L in c(3.65, 3.95, 4.65)) cat(sprintf("  LOD %.2f: -log10 P = %.2f on 3 d.f. (%.2f on 1 d.f.); genome-wide P with 442 tests = %.2f\n", L, -log10(p.lod(L, 3)), -log10(p.lod(L, 1)), min(1, 442 * p.lod(L, 3))))
for(a in c(0.10, 0.05, 0.01)) cat(sprintf("  genome-wide %.2f over 442 tests needs LOD %.2f on 3 d.f.\n", a, qchisq(a / 442, 3, lower.tail = FALSE) / (2 * log(10))))
sink()
