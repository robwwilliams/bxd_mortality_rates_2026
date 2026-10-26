#
# vcf_set_check.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory: is the paternal H excess on proximal Chr 1 a site effect or a genotyping-set effect? Reads the raw
# MonsterPlex calls of Arends et al. (Supplementary Table 5; VCF codes, 0 = C57BL/6J reference, 1 = any other strain)
# and the marker list (Supplementary Table 4.1). The table holds two sets of markers: set A, named by position
# (1_3010274), and set B, named by rsID (rs31443144). Each mouse was genotyped with one set (one mouse with both):
# set A covers JL and part of UM, set B the rest of UM and all of UT. The same SNP can appear in both sets.
# At every SNP each mouse inherits the odd strain's allele from one parent or not at all, so heterozygous calls (0/1)
# should be half the calls. A set that loses heterozygotes shows a lower fraction than the other set at the same SNP,
# and UM, genotyped with both sets, separates set from site.
#
# Run: Rscript UMHET3/vcf_set_check.R <S_Table_5_VCF_coded_genotypes_metadata_18Aug2025.xlsx> <S_Table_4_Primers_MonsterPlex_Mouse_20Aug2025.xlsx>
#        [<S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr>]   (optional: sets by cohort)
# Writes output/UMHET3_VCF_sets_by_marker.txt and output/UMHET3_VCF_set_by_mouse.txt
#

library(readxl)

v <- as.data.frame(read_excel(commandArgs(trailingOnly = TRUE)[1], skip = 11, col_types = "text"))
v <- v[!is.na(v$Marker), names(v) != "Index_row"]
m <- as.matrix(v[, -1]); rownames(m) <- v$Marker
p <- as.data.frame(read_excel(commandArgs(trailingOnly = TRUE)[2], sheet = 1, skip = 9, col_types = "text"))
p <- p[!is.na(p[, "SNP rsID"]), ]
pos <- setNames(paste0(p$Chr, "_", p[, "Position (Bp)"]), p[, "SNP rsID"])

isrs <- grepl("^rs", rownames(m))
key <- ifelse(isrs, pos[rownames(m)], rownames(m))   # every row named by chr_position
inA <- colSums(!is.na(m[!isrs, ])) > 0; inB <- colSums(!is.na(m[isrs, ])) > 0
set <- ifelse(inA & inB, "both", ifelse(inA, "A", ifelse(inB, "B", "none")))
site <- substr(colnames(m), 1, 2)
cat("Mice by site and genotyping set:\n"); print(table(site, set))
write.table(data.frame(GenoID = colnames(m), site, set), "output/UMHET3_VCF_set_by_mouse.txt", sep = "\t", quote = FALSE, row.names = FALSE)
if (length(commandArgs(trailingOnly = TRUE)) > 2) {
  x <- read.csv(commandArgs(trailingOnly = TRUE)[3], header = FALSE, colClasses = "character", row.names = 1, nrows = 10)
  cohort <- setNames(unlist(x["cohort", -1]), unlist(x["GenoID", -1]))
  cat("\nMice in the mapping file by site, cohort and genotyping set:\n")
  print(ftable(table(site = site, cohort = as.numeric(cohort[colnames(m)]), set = set)[, , c("A", "B")]))
}

# Heterozygous fraction at each SNP, by set and site
grp <- list(A.JL = set == "A" & site == "JL", A.UM = set == "A" & site == "UM", B.UM = set == "B" & site == "UM", B.UT = set == "B" & site == "UT")
het <- function(rows, cols) {
  x <- m[rows, cols, drop = FALSE]; n <- rowSums(!is.na(x))
  cbind(n = n, het = round(rowSums(x == "0/1", na.rm = TRUE) / pmax(n, 1), 3))
}
r <- data.frame(marker = rownames(m), position = key, set = ifelse(isrs, "B", "A"))
for (k in names(grp)) { h <- het(seq_len(nrow(m)), grp[[k]]); r[, paste0("n.", k)] <- h[, "n"]; r[, paste0("het.", k)] <- h[, "het"] }
r$odd.strain <- p$Strain[match(r$position, paste0(p$Chr, "_", p[, "Position (Bp)"]))]
r$targeted <- p$Targeted_or_Incidental[match(r$position, paste0(p$Chr, "_", p[, "Position (Bp)"]))]
write.table(r, "output/UMHET3_VCF_sets_by_marker.txt", sep = "\t", quote = FALSE, row.names = FALSE)

# A SNP genotyped by both sets, as one row: set A's calls from its position row, set B's from its rsID row
a <- r[r$set == "A", ]; b <- r[r$set == "B" & !is.na(r$position), ]
both <- merge(a[, c("position", "odd.strain", "targeted", "n.A.JL", "het.A.JL", "n.A.UM", "het.A.UM")],
              b[, c("position", "marker", "n.B.UM", "het.B.UM", "n.B.UT", "het.B.UT")], by = "position")
both$A <- with(both, round((n.A.JL * het.A.JL + n.A.UM * het.A.UM) / (n.A.JL + n.A.UM), 3))
both$B <- with(both, round((n.B.UM * het.B.UM + n.B.UT * het.B.UT) / (n.B.UM + n.B.UT), 3))
both <- both[!grepl("^X_", both$position) & both$n.A.JL + both$n.A.UM >= 200 & both$n.B.UM + both$n.B.UT >= 200, ]   # X: males are hemizygous
cat("\nAutosomal SNPs called by both sets (>= 200 mice in each):", nrow(both), "; heterozygous fraction, set B minus set A: median",
    median(both$B - both$A), "; 1st-99th percentile", quantile(both$B - both$A, c(0.01, 0.99)), "\n")
cat("SNPs where the sets differ by more than 0.10:\n")
print(both[abs(both$B - both$A) > 0.10, c("position", "marker", "odd.strain", "targeted", "n.A.JL", "het.A.JL", "n.A.UM", "het.A.UM",
                                          "n.B.UM", "het.B.UM", "n.B.UT", "het.B.UT")], row.names = FALSE)
cat("\nSet B SNPs with no set A row, outside 0.40-0.60 heterozygous:\n")
print(b[!(b$position %in% a$position) & b$n.B.UM + b$n.B.UT >= 200 & (b$het.B.UM < 0.4 | b$het.B.UT < 0.4 | b$het.B.UM > 0.6 | b$het.B.UT > 0.6),
        c("marker", "position", "odd.strain", "targeted", "n.B.UM", "het.B.UM", "n.B.UT", "het.B.UT")], row.names = FALSE)

# Does a lost heterozygote at 31.06 Mb depend on the mother? The mother's haplotype from the B6-specific SNP at 24.04 Mb
# (0/1 = mother B, 1/1 = mother C); the father's D allele at 31.06 Mb shows as 0/1.
cat("\nCalls at 31.06 Mb (D2 allele) by the mother's haplotype at 24.04 Mb:\n")
mother <- ifelse(set == "A", m["1_24042124", ], m["rs32645812", ]); mother <- c("0/1" = "B", "1/1" = "C")[mother]
father <- ifelse(set == "A", m["1_31062737", ], m["rs230225148", ])
print(table(set.site = paste(set, site), mother = mother, call.31.06 = father))
cat("\nCalls at 3.01 Mb (D2 allele) by the mother's haplotype at 6.25 Mb (set A) or 7.97 Mb (set B):\n")
mother <- ifelse(set == "A", m["1_6249843", ], m["rs32436834", ]); mother <- c("0/1" = "B", "1/1" = "C")[mother]
father <- ifelse(set == "A", m["1_3010274", ], m["rs31443144", ])
print(table(set.site = paste(set, site), mother = mother, call.3.01 = father))
