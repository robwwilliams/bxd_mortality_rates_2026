#
# founder_patterns.R - Founder-specific variants of the four UM-HET3 founders (two of them the BXD parents), counted by
# pattern in bins along proximal Chr 1 and distal Chr 2, for the zoom figures
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026. Rob: "We definitely want a very tight zoom
# for the bioRxiv paper and the next grant application of this region with the LTR prominently displayed, as well as any
# other strain specific oddities that might help us make sense of what is going on across the proximal 40 Mb on Chr 1 and
# much of Chr 2."
#   - Data and filters as in vita1a_founder_variants.R: Arends et al. 2026 Supplementary Table 17 (SNPs and short indels,
#     GRCm38 = mm10; BALB/cByJ, C57BL/6NJ, C3H/HeJ, DBA/2J), every founder called and homozygous, depth >= 5, QUAL >= 30.
#   - Patterns, founders in the order C B H D: D-private, C3H-private, B6-private, BALB/c-private, H = D against C = B,
#     B = H against C = D, B = D against C = H, and three or more alleles.
#   - Bins: 250 kb on Chr 1 from 0 to 45 Mb, and on Chr 2 from 100 to 182 Mb.
# Inputs (not in git): data/local/founder_vcf/Founders.snps.<1|2>.vcf.gz, extracted from the Supplementary Table 17 ZIP
# Writes output/founder_patterns_chr1_0-45Mb.txt and output/founder_patterns_chr2_100-182Mb.txt
#   Rscript UMHET3/founder_patterns.R
#

labels <- c("0001" = "D-private", "0010" = "C3H-private", "0100" = "B6-private", "0111" = "BALB/c-private",
            "0011" = "H = D, against C = B", "0110" = "B = H, against C = D", "0101" = "B = D, against C = H")
binned <- function(chr, lo, hi, bin = 250e3){
  con <- gzfile(sprintf("data/local/founder_vcf/Founders.snps.%s.vcf.gz", chr), "r"); keep <- character(0)
  repeat{
    x <- readLines(con, n = 200000); if(length(x) == 0) break
    x <- x[!startsWith(x, "#")]; if(length(x) == 0) next
    pos <- as.numeric(sub("^[^\t]*\t([0-9]+)\t.*", "\\1", x))
    keep <- c(keep, x[pos >= lo & pos < hi])
    if(max(pos) >= hi) break
  }
  close(con)
  f <- do.call(rbind, strsplit(keep, "\t")); rm(keep)
  pos <- as.numeric(f[, 2]); qual <- as.numeric(f[, 6])
  call <- sub(":.*", "", f[, 10:13]); dp <- suppressWarnings(as.numeric(sub("^[^:]*:[^:]*:", "", f[, 10:13]))); dim(dp) <- dim(call)
  hom <- matrix(grepl("^([0-9])/\\1$", call), ncol = 4)
  ok <- rowSums(hom) == 4 & rowSums(dp >= 5, na.rm = TRUE) == 4 & qual >= 30
  a <- matrix(suppressWarnings(as.integer(sub("/.*", "", call[ok, , drop = FALSE]))), ncol = 4); pos <- pos[ok]
  v <- apply(a, 1, function(z) length(unique(z)) > 1); a <- a[v, , drop = FALSE]; pos <- pos[v]
  pat <- apply(a, 1, function(z) paste(match(z, unique(z)) - 1, collapse = ""))
  lab <- ifelse(pat %in% names(labels), labels[pat], "three or more alleles")
  b <- floor(pos / bin) * bin
  t <- table(factor(b, levels = seq(lo, hi - bin, bin)), factor(lab, levels = c(labels, "three or more alleles")))
  out <- data.frame(chr = chr, bin.from.Mb = as.numeric(rownames(t)) / 1e6, as.data.frame.matrix(t), check.names = FALSE)
  cat(sprintf("Chr %s %g-%g Mb: %d variable sites pass the filters\n", chr, lo / 1e6, hi / 1e6, length(pos)))
  out
}
write.table(binned("1", 0, 45e6), "output/founder_patterns_chr1_0-45Mb.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(binned("2", 100e6, 182e6), "output/founder_patterns_chr2_100-182Mb.txt", sep = "\t", quote = FALSE, row.names = FALSE)
