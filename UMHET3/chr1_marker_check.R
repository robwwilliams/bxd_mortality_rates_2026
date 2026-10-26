#
# chr1_marker_check.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory: are the 2:1 paternal H : D counts at Vita1a and Vita1b real transmission distortion, or genotyping error?
# Reads the R/qtl 4-way cross file of Arends et al. (Supplementary Table 7) and counts, at every marker, the calls that
# name the father's haplotype (H = C3H/HeJ, D = DBA/2J) and the mother's (C = BALB/cByJ, B = C57BL/6J), overall and
# by site. R/qtl 4-way codes: 1 = CH, 2 = BH, 3 = CD, 4 = BD (A = C, B = B, C = H, D = D in R/qtl's letters); 5 / 6 =
# mother C / B, father unknown; 7 / 8 = father H / D, mother unknown. The codes are confirmed on X, where every
# daughter carries her father's X, which in a C3D2F1 father is C3H: females have codes 1 and 2 only.
#
# Run: Rscript UMHET3/chr1_marker_check.R <S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr>
# Writes output/UMHET3_markers_genome.txt and output/UMHET3_markers_chr1_by_site.txt
#

x <- read.csv(commandArgs(trailingOnly = TRUE)[1], header = FALSE, colClasses = "character")
site <- c("1.0" = "JL", "2.0" = "UM", "3.0" = "UT")[unlist(x[3, -(1:3)])]   # GenoID prefixes JL, UM, UT
g <- x[-(1:10), ]; m <- as.matrix(g[, -(1:3)])

counts <- function(m) data.frame(patH = rowSums(m == "7" | m == "1" | m == "2"), patD = rowSums(m == "8" | m == "3" | m == "4"),
                                 matC = rowSums(m == "5" | m == "1" | m == "3"), matB = rowSums(m == "6" | m == "2" | m == "4"),
                                 called = rowSums(m != ""))
r <- data.frame(marker = g[, 1], chr = g[, 2], Mb = as.numeric(g[, 3]), counts(m))
r$patH.frac <- round(r$patH / (r$patH + r$patD), 3); r$matC.frac <- round(r$matC / (r$matC + r$matB), 3)
write.table(r, "output/UMHET3_markers_genome.txt", sep = "\t", quote = FALSE, row.names = FALSE)

a <- r[r$chr != "X" & r$patH + r$patD >= 500, ]
cat("Autosomal markers with >= 500 paternal calls:", nrow(a), "; fraction paternal H, median", median(a$patH.frac),
    "; 1st-99th percentile", quantile(a$patH.frac, c(0.01, 0.99)), "\n")
cat("Markers outside 0.42-0.58:\n"); print(a[a$patH.frac > 0.58 | a$patH.frac < 0.42, c("marker", "patH", "patD", "patH.frac")], row.names = FALSE)

# Proximal Chr 1, by site
s <- g[, 2] == "1" & as.numeric(g[, 3]) < 60
bysite <- do.call(rbind, lapply(c("JL", "UM", "UT"), function(k) {
  data.frame(site = k, marker = g[s, 1], Mb = as.numeric(g[s, 3]), counts(m[s, site == k]))
}))
bysite$patH.frac <- round(bysite$patH / (bysite$patH + bysite$patD), 3)
write.table(bysite, "output/UMHET3_markers_chr1_by_site.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nProximal Chr 1 markers that call the father: fraction H (calls) by site\n")
p <- bysite[bysite$patH + bysite$patD > 0, ]
print(reshape(transform(p, v = sprintf("%.2f (%d)", patH.frac, patH + patD))[, c("site", "marker", "Mb", "v")],
              idvar = c("marker", "Mb"), timevar = "site", direction = "wide"), row.names = FALSE)

# Pairs of SNPs a few bp apart: in the mice called at both, do they agree?
pat <- function(mk) { v <- m[g[, 1] == mk, ]; ifelse(v %in% c("7", "1", "2"), "H", ifelse(v %in% c("8", "3", "4"), "D", NA)) }
mat <- function(mk) { v <- m[g[, 1] == mk, ]; ifelse(v %in% c("5", "1", "3"), "C", ifelse(v %in% c("6", "2", "4"), "B", NA)) }

# At Vita1b: the father's call at 31.06 Mb by the mother's haplotype at 24.0 Mb, by site
t31 <- as.data.frame(table(site = site, mother = mat("1_24042124"), father = pat("1_31062737")))
t31 <- reshape(t31, idvar = c("site", "mother"), timevar = "father", direction = "wide")
colnames(t31) <- c("site", "mother", "father.D", "father.H"); t31$fracH <- round(t31$father.H / (t31$father.H + t31$father.D), 3)
write.table(t31, "output/UMHET3_31Mb_father_by_mother.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nFather's call at 1_31062737 by mother's haplotype at 1_24042124:\n"); print(t31, row.names = FALSE)
for (pr in list(c("1_3010272", "1_3010274"), c("1_31062758", "1_31062737"))) {
  a1 <- pat(pr[1]); a2 <- pat(pr[2]); both <- !is.na(a1) & !is.na(a2); only2 <- is.na(a1) & !is.na(a2)
  cat(sprintf("\n%s and %s: called at both %d, agreeing %d, fraction H %.2f; called only at %s %d, fraction H %.2f\n",
              pr[1], pr[2], sum(both), sum(a1[both] == a2[both]), mean(a2[both] == "H"), pr[2], sum(only2), mean(a2[only2] == "H")))
}
