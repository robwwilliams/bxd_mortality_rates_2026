#
# compare_Danny.R
#
# copyright (c) 2026 - Rob Williams
#
# Sets the GN4AI-beta scans of GN4AI/test_drive.sh beside Danny Arends's strain-means maps at T-age 20 (his
# QTL_Lifespan_05Nov2026.xlsx, sheets CD and HF: signed -log10 P per marker), and checks locally which regression his
# maps are. Exploratory: the weighted regression was tried after the first comparison showed the maps differ.
#   - R/qtl's Haley-Knott LOD for two genotype classes is converted to -log10 P with the F test of the same regression:
#     F = (n - 2) (10^(2 LOD / n) - 1) on 1 and n - 2 d.f., n the strains mapped.
#   - GEMMA's -log10 p_lrt is used as it is, from both runners (ravanan and the wrapper), which should agree.
#   - Local check, on every 10th marker: strain means regressed on genotype (B against D; H and U left out), unweighted
#     as GeneNetwork maps them, and weighted by the number of mice per strain.
#
# Inputs not in git, in data/local/: Danny's workbook (from Arends_Figures_09Nov2026.zip) in Arends_Data_05Nov2026/, and
# the sheet "BXD Geno v8 in GN with U" of BXD_final_Genotypes_DGA_RWW_21Dec2025_based_on_v050423.xlsx (GeneNetwork's
# BXD.8 genotypes).
# Run from the repository root, after GN4AI/test_drive.sh:  Rscript GN4AI/compare_Danny.R
# Writes output/GN4AI/compare_Danny.txt and output/GN4AI/GN4AI_vs_Danny.svg
#

library(readxl)
library(svglite)

gz <- function(b, e) { f <- sprintf("output/GN4AI/%s_%s.tsv.gz", b, e); if (file.exists(f)) read.delim(gzfile(f)) else NULL }
neglog.lod <- function(lod, n) -pf((n - 2) * (10^(2 * lod / n) - 1), 1, n - 2, lower.tail = FALSE, log.p = TRUE) / log(10)
diets <- c(CD = "chow", HF = "high fat"); col.diet <- c(CD = "#a86a28", HF = "#2a78d6"); chrs <- c(1:19, "X")
m <- read.delim("output/GN4AI/strain_means_T20.txt")
geno <- as.data.frame(suppressMessages(suppressWarnings(read_excel("data/local/BXD_final_Genotypes_DGA_RWW_21Dec2025_based_on_v050423.xlsx",
                                                                  sheet = "BXD Geno v8 in GN with U", skip = 23))))
sink("output/GN4AI/compare_Danny.txt", split = TRUE)
res <- list()
for (d in names(diets)) {
  b <- paste0("lifespan_", d, "_T20"); s <- m[m[, "Column"] == b, ]; n <- nrow(s)
  x <- as.data.frame(suppressMessages(read_excel("data/local/Arends_Data_05Nov2026/QTL_Lifespan_05Nov2026.xlsx", sheet = d, col_names = FALSE)))
  x <- data.frame(marker = x[-1, 1], chr = x[-1, 2], Mb = as.numeric(x[-1, 5]), Danny = as.numeric(x[-1, which(unlist(x[1, ]) == "20")]))
  r <- gz(b, "rqtl"); g1 <- gz(b, "gemma_ravanan"); g2 <- gz(b, "gemma_wrapper")
  x[, "Rqtl.LOD"] <- r[match(x[, "marker"], r[, "name"]), "lod"]; x[, "Rqtl"] <- neglog.lod(x[, "Rqtl.LOD"], n)
  x[, "GEMMA"] <- -log10(g1[match(x[, "marker"], g1[, "rs"]), "p_lrt"]); x[, "GEMMA.wrapper"] <- -log10(g2[match(x[, "marker"], g2[, "rs"]), "p_lrt"])
  cat("\n=====", d, "(", diets[d], "):", n, "strain means;", nrow(x), "markers in Danny's map;", sum(!is.na(x[, "Rqtl"])), "in R/qtl,", sum(!is.na(x[, "GEMMA"])), "in GEMMA\n")
  cat("Correlation over markers, -log10 P: Danny with R/qtl", round(cor(abs(x[, "Danny"]), x[, "Rqtl"], use = "complete"), 3),
      "; Danny with GEMMA", round(cor(abs(x[, "Danny"]), x[, "GEMMA"], use = "complete"), 3), "; R/qtl with GEMMA", round(cor(x[, "Rqtl"], x[, "GEMMA"], use = "complete"), 3), "\n")
  cat("GEMMA, ravanan against the wrapper: largest difference in -log10 p", signif(max(abs(x[, "GEMMA"] - x[, "GEMMA.wrapper"]), na.rm = TRUE), 3), "\n")
  for (v in c("Danny", "Rqtl", "GEMMA")) { y <- abs(x[, v]); i <- which.max(y); cat(sprintf("  peak %-6s %-16s Chr %-2s %7.2f Mb  -log10 P %.2f\n", v, x[i, "marker"], x[i, "chr"], x[i, "Mb"], y[i])) }
  # local regressions on every 10th marker
  k <- seq(1, nrow(geno), by = 10); G <- as.matrix(geno[k, s[, "Strain"]]); G[G %in% c("H", "U")] <- NA
  fit <- function(w) sapply(seq_len(nrow(G)), function(i) { z <- G[i, ]; j <- !is.na(z); if (length(unique(z[j])) < 2) return(NA)
                                                             f <- lm(s[j, "Mean"] ~ z[j], weights = w[j]); -log10(anova(f)[1, 5]) })
  l <- data.frame(marker = geno[k, "Locus"], unweighted = fit(rep(1, n)), weighted = fit(s[, "n"]))
  j <- match(l[, "marker"], x[, "marker"])
  cat("Local regressions on", nrow(l), "markers. Unweighted: with R/qtl", round(cor(l[, "unweighted"], x[j, "Rqtl"], use = "complete"), 3),
      ", with Danny", round(cor(l[, "unweighted"], abs(x[j, "Danny"]), use = "complete"), 3), ". Weighted by mice per strain: with Danny",
      round(cor(l[, "weighted"], abs(x[j, "Danny"]), use = "complete"), 3), "(largest difference", round(max(abs(l[, "weighted"] - abs(x[j, "Danny"])), na.rm = TRUE), 2), ")\n")
  cat("Strongest marker per chromosome (-log10 P):\n")
  print(do.call(rbind, lapply(split(x, factor(x[, "chr"], levels = chrs)), function(z) data.frame(chr = z[1, "chr"],
        Danny = round(max(abs(z[, "Danny"])), 2), Rqtl = round(max(z[, "Rqtl"], na.rm = TRUE), 2), GEMMA = round(max(z[, "GEMMA"], na.rm = TRUE), 2)))), row.names = FALSE)
  res[[d]] <- x
}
sink()

# Danny's maps against GN4AI's R/qtl and GEMMA scans, chow above and high fat below
svglite("output/GN4AI/GN4AI_vs_Danny.svg", width = 7, height = 5.2, system_fonts = list(sans = "Arial"))
par(mfrow = c(2, 1), mar = c(2.6, 3.6, 1.6, 0.6), mgp = c(2.2, 0.6, 0), cex = 0.75, family = "sans")
for (d in names(res)) {
  x <- res[[d]]; x <- x[order(factor(x[, "chr"], levels = chrs), x[, "Mb"]), ]; x[, "Danny"] <- abs(x[, "Danny"])
  len <- tapply(x[, "Mb"], factor(x[, "chr"], levels = chrs), max); off <- cumsum(c(0, len[-20] + 10)); names(off) <- chrs
  pos <- x[, "Mb"] + off[as.character(x[, "chr"])]
  plot(pos, x[, "Danny"], type = "n", ylim = c(0, 1.18 * max(4.5, unlist(x[, c("Danny", "Rqtl", "GEMMA")]), na.rm = TRUE)), xaxt = "n", bty = "l",
       xlab = "", ylab = expression(-log[10] * italic(P)), main = paste0(c(CD = "a", HF = "b")[d], "  Strain means on ", diets[d]), adj = 0, font.main = 2)
  rect(off[seq(2, 20, 2)], -1, off[seq(2, 20, 2)] + len[seq(2, 20, 2)], 10, col = "#f2f2f2", border = NA)
  for (k in split(seq_along(pos), x[, "chr"])) {
    lines(pos[k], x[k, "Danny"], col = "black", lwd = 1.4)
    lines(pos[k], x[k, "Rqtl"], col = col.diet[d], lwd = 0.9)
    lines(pos[k], x[k, "GEMMA"], col = "grey45", lwd = 0.8, lty = 2)
  }
  th <- read.delim("output/GN4AI/rqtl_perm1000_thresholds.txt"); th <- th[th[, "basket"] == paste0("lifespan_", d, "_T20"), ]
  abline(h = neglog.lod(th[, "significant"], as.numeric(table(m[, "Column"])[paste0("lifespan_", d, "_T20")])), col = col.diet[d], lty = 3, lwd = 0.9)
  mtext(chrs, side = 1, at = off + len / 2, line = 0.5, cex = 0.64)
  legend("top", c("Danny Arends (weighted by mice)", "GN4AI R/qtl", "GN4AI GEMMA", "R/qtl significant (1,000 permutations)"), col = c("black", col.diet[d], "grey45", col.diet[d]),
         lwd = c(1.4, 0.9, 0.8, 0.9), lty = c(1, 1, 2, 3), bty = "n", cex = 0.8, ncol = 2, inset = 0)
}
invisible(dev.off())
