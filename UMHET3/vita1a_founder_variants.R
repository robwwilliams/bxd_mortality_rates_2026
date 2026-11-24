#
# vita1a_founder_variants.R - Which founders carry which variants in Vita1a: a test of the allelic-series reading of the
# opposite signs of Vita1a in BXD and UM-HET3
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026, after the signs were seen. Rob asked for
# the search ("Thanks for pointing out the allelic series ... The file you really want is the large 628 Mb ZIP file ... you
# only need Chr 1. But Supplement Table 1 is the one that provides the summary so start with that.").
#   - The question. In BXD the D allele lives longer (D - B > 0, at every T-age); in UM-HET3 the paternal D lives shorter
#     (D - H < 0, at every T-age to T860). With additive effects, both hold only if the alleles rank H > D > B. A variant
#     carried by DBA/2J alone (D-private: B6 = C3H = BALB/c) moves D - B and D - H the same way, so it cannot give opposite
#     signs by itself; that includes the 11 kb LTR in Atp6v1h, which to Rob's knowledge only D carries. Opposite signs need
#     variants at which C3H/HeJ differs from DBA/2J and the C3H allele lives longer: C3H-private sites (B6 = DBA/2 = BALB/c
#     != C3H), which BXD cannot see, or sites at which C3H differs from both B6 and DBA/2.
#   - Data: Arends et al. 2026 Supplementary Table 17, Founders.snps.1.vcf.gz (bcftools mpileup calls on GRCm38, = mm10, for
#     BALB/cByJ, C57BL/6NJ, C3H/HeJ and DBA/2J; SNPs and short indels, no structural variants). C57BL/6NJ stands for B6.
#   - Filters: every founder called and homozygous (heterozygous calls in inbred strains are artefacts), depth at least 5
#     in each founder, QUAL at least 30.
#   - Windows (mm10): the BXD block (4.858-5.316 Mb: all mapped BXD strains and F1 types share genotypes there at T770,
#     holding Tcea1, Rgs20 and Atp6v1h); its proximal flank (3.0-4.858 Mb, where the UM-HET3 paternal peak's markers lie,
#     with Xkr4, Rp1, Sox17, Mrpl15 and Lypla1); and its distal flank (5.316-7.0 Mb, Oprk1 to St18).
#   - Patterns: each site's alleles in the order C (BALB/cByJ), B (C57BL/6NJ), H (C3H/HeJ), D (DBA/2J), e.g. "0001" for
#     D-private. Counts by window and by gene, and which contrasts each pattern touches: BXD (B != D), UM-HET3 paternal
#     (D != H), UM-HET3 maternal (B != C).
# Inputs (not in git): data/local/founder_vcf/Founders.snps.1.vcf.gz, extracted from
# data/local/Arends_Supplementary_Table_17_Founder_sequence_variants_18Aug2025.zip
# Writes output/Vita1a_founder_variants.txt and output/Vita1a_founder_variants_sites.txt
#   Rscript UMHET3/vita1a_founder_variants.R
#

options(width = 200)
vcf <- "data/local/founder_vcf/Founders.snps.1.vcf.gz"
lo <- 3.0e6; hi <- 7.0e6
windows <- data.frame(name = c("proximal flank", "BXD block", "distal flank"), from = c(3.0e6, 4.858261e6, 5.316455e6), to = c(4.858261e6, 5.316455e6, 7.0e6))
genes <- data.frame(gene = c("Xkr4", "Rp1", "Sox17", "Mrpl15", "Lypla1", "Tcea1", "Rgs20", "Atp6v1h", "Oprk1", "Npbwr1", "Rb1cc1", "Alkal1", "St18"),
                    from = c(3.205901, 3.999557, 4.490931, 4.773206, 4.807788, 4.857814, 4.909576, 5.070018, 5.588466, 5.913707, 6.206197, 6.359218, 6.487231) * 1e6,
                    to = c(3.671498, 4.409241, 4.497354, 4.785739, 4.84841, 4.897909, 5.070285, 5.162529, 5.606131, 5.917398, 6.276648, 6.394731, 6.86094) * 1e6)   # Supplementary Table 1 (mm10)

### Read the sites in 3-7 Mb (the file is sorted by position)
con <- gzfile(vcf, "r"); keep <- character(0)
repeat{
  x <- readLines(con, n = 50000); if(length(x) == 0) break
  x <- x[!startsWith(x, "#")]; if(length(x) == 0) next
  pos <- as.numeric(sub("^[^\t]*\t([0-9]+)\t.*", "\\1", x))
  keep <- c(keep, x[pos >= lo & pos <= hi])
  if(max(pos) > hi) break
}
close(con)
f <- do.call(rbind, strsplit(keep, "\t"))
site <- data.frame(pos = as.numeric(f[, 2]), ref = f[, 4], alt = f[, 5], qual = as.numeric(f[, 6]), indel = grepl("^INDEL", f[, 8]))
gt <- f[, 10:13]; colnames(gt) <- c("C", "B", "H", "D")
call <- sub(":.*", "", gt); dp <- suppressWarnings(as.numeric(sub("^[^:]*:[^:]*:", "", gt)))
dim(dp) <- dim(call)
hom <- matrix(grepl("^([0-9])/\\1$", call), ncol = 4)
ok <- rowSums(hom) == 4 & rowSums(dp >= 5, na.rm = TRUE) == 4 & site$qual >= 30
allele <- matrix(as.integer(sub("/.*", "", call)), ncol = 4); colnames(allele) <- c("C", "B", "H", "D")
site <- site[ok, ]; allele <- allele[ok, , drop = FALSE]
v <- apply(allele, 1, function(a) length(unique(a)) > 1)                           # variable among the four founders
site <- site[v, ]; allele <- allele[v, , drop = FALSE]
pat <- apply(allele, 1, function(a){ m <- match(a, unique(a)) - 1; paste(m, collapse = "") })   # relabeled so C's allele is 0
site$pattern <- pat
site$BXD <- allele[, "B"] != allele[, "D"]; site$paternal <- allele[, "D"] != allele[, "H"]; site$maternal <- allele[, "B"] != allele[, "C"]
site$window <- cut(site$pos, c(windows$from, windows$to[3]), labels = windows$name, right = FALSE, include.lowest = TRUE)
site$gene <- sapply(site$pos, function(p){ g <- genes$gene[p >= genes$from & p <= genes$to]; if(length(g)) paste(g, collapse = "/") else "" })
labels <- c("0001" = "D-private", "0010" = "H-private (C3H)", "0100" = "B-private (B6)", "0111" = "C-private (BALB/c)",
            "0011" = "H = D, against C = B", "0101" = "B = D, against C = H", "0110" = "B = H, against C = D", "0012" = "three alleles")
site$label <- ifelse(pat %in% names(labels), labels[pat], ifelse(apply(allele, 1, function(a) length(unique(a))) > 2, "three or more alleles", pat))

sink("output/Vita1a_founder_variants.txt", split = TRUE)
cat("Vita1a, Chr 1 3.0-7.0 Mb (mm10): founder variants of Arends et al. 2026 Supplementary Table 17, homozygous calls in all four\n")
cat("founders, depth >= 5, QUAL >= 30. Founders: C = BALB/cByJ, B = C57BL/6NJ, H = C3H/HeJ, D = DBA/2J. SNPs and short indels only.\n\n")
cat(sprintf("%d sites read; %d pass the filters and vary among the founders (%d indels)\n\n", nrow(f), nrow(site), sum(site$indel)))
tab <- table(site$label, site$window); tab <- tab[order(-rowSums(tab)), , drop = FALSE]
cat("Sites by pattern and window (which contrasts a pattern touches: BXD = B vs D; pat = UM-HET3 paternal D vs H; mat = maternal B vs C):\n")
touch <- sapply(rownames(tab), function(l){ s <- site[site$label == l, ][1, ]; paste(c(if(s$BXD) "BXD", if(s$paternal) "pat", if(s$maternal) "mat"), collapse = "+") })
print(cbind(as.data.frame.matrix(tab), touches = touch))
cat("\nIn the BXD block, by gene:\n")
b <- site[site$window == "BXD block", ]
print(table(ifelse(b$gene == "", "intergenic", b$gene), b$label))
cat("\nBXD block sites that can give opposite signs (C3H differs from DBA/2J and from B6 at the same site, or C3H-private):\n")
opp <- b[b$label %in% c("H-private (C3H)", "three alleles", "three or more alleles", "B = D, against C = H"), ]
print(opp[, c("pos", "ref", "alt", "pattern", "label", "gene", "indel")], row.names = FALSE)
sink()
write.table(site, "output/Vita1a_founder_variants_sites.txt", sep = "\t", quote = FALSE, row.names = FALSE)

### Coding sites in the block, and what the flat UM-HET3 maternal map rules out
cds <- read.delim("UMHET3/vita1a_refseq_cds_mm10.txt", comment.char = "#")             # RefSeq coding exons, saved from the UCSC API
b$coding <- sapply(b$pos, function(p){ g <- unique(cds$gene[p >= cds$cds_from & p <= cds$cds_to]); if(length(g)) paste(g, collapse = "/") else "" })
sink("output/Vita1a_founder_variants.txt", append = TRUE, split = TRUE)
cat("\nCoding sites in the BXD block (RefSeq coding exons of Tcea1, Rgs20 and Atp6v1h):\n")
print(b[b$coding != "", c("pos", "ref", "alt", "pattern", "label", "coding", "BXD", "paternal", "maternal")], row.names = FALSE)
cat("\nReading, with additive effects: the UM-HET3 maternal map is flat at Vita1a in both sexes (median -log10 P about 0 from 3 to 8 Mb),\n")
cat("so patterns that touch the maternal contrast (B-private, C-private, B = H against C = D, B = D against C = H, three alleles)\n")
cat("are unlikely to carry large effects. That leaves, for BXD, D-private sites (also seen by the paternal contrast, with the same\n")
cat("sign) and H = D against C = B sites (BXD only). The UM-HET3 paternal reversal (H > D) then needs C3H-private sites, which\n")
cat("BXD cannot see, whose C3H allele lives longer by more than the D-private allele does. The Rgs20 start codon change of\n")
cat("NM_001290372 (4,923,964; carried by BALB/c and C3H) touches the maternal contrast too, so the flat maternal map argues against it.\n")
sink()
