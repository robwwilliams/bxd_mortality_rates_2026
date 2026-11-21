#
# actuarial_compare.R
#
# copyright (c) 2026 - Rob Williams
#
# Sets GN4AI-beta's actuarial scans (GN4AI/actuarial_scan.sh) beside Danny Arends's actuarial strain-means maps (his
# QTL_Lifespan_05Nov2026.xlsx, sheets CD and HF: signed -log10 P per marker and T-age) and draws both in the layout of
# his Fig. 2, top two rows. Rob, 21 November 2026: "You are not doing the full actuarial scan in 30 day truncation steps
# right? That is what we want to do emulating Danny's figures." Exploratory.
#   - GN4AI's R/qtl2 LOD is converted to -log10 P with the chi-square test on 1 d.f., as in GN4AI/compare_Danny.R. GN4AI
#     returns no effect direction, so the sign is taken from the strain means: B strains' mean minus D strains' mean.
#   - Local check at every marker and T-age: strain means regressed on genotype (B against D; H and U left out), weighted
#     by the number of mice per strain, without kinship. At 20 days this reproduces Danny's map (r = 0.98).
#   - Danny's maps run from 20 to 770 days. His 27th column, headed 770 like the 26th, is empty in every sheet, so the
#     scans at 800 days have nothing to compare with.
#   - The heat maps show every T-age from 20 to 770 days and label every 60 days, as his do. Rob: "The mean survivorship
#     data MUST be mapped with kinship to be accurate", so GN4AI's scans are drawn with LOCO kinship.
#
# Inputs not in git, in data/local/: the scans of GN4AI/actuarial_scan.sh, Danny's workbook in Arends_Data_05Nov2026/,
# and the BXD.8 genotypes (sheet "BXD Geno v8 in GN with U" of BXD_final_Genotypes_DGA_RWW_21Dec2025_based_on_v050423.xlsx).
# Run from the repository root:  Rscript GN4AI/actuarial_compare.R
# Writes output/GN4AI/actuarial/compare_Danny.txt, <diet>_qtl2_<kinship>.tsv.gz (LOD by marker and T-age, both diets)
# and actuarial_maps.svg (with a PNG preview from tools/svg2png.py)
#

library(readxl)
library(svglite)

Tages <- seq(20, 770, by = 30); shown <- Tages; labeled <- seq(50, 770, by = 60)
diets <- c(CD = "chow", HF = "high fat"); chrs <- c(1:19, "X")
col.hap <- c(B = "#7d4598", D = "#ed8f22")
chisq.p <- function(lod) -pchisq(2 * log(10) * lod, 1, lower.tail = FALSE, log.p = TRUE) / log(10)
m <- read.delim("output/GN4AI/actuarial/strain_means.txt")
geno <- as.data.frame(suppressMessages(suppressWarnings(read_excel("data/local/BXD_final_Genotypes_DGA_RWW_21Dec2025_based_on_v050423.xlsx",
                                                                  sheet = "BXD Geno v8 in GN with U", skip = 23))))

# Weighted regression of strain means on B against D at every marker, from sums: signed -log10 P (positive: B higher)
regress <- function(markers, s, w) {
  G <- as.matrix(geno[match(markers, geno[, "Locus"]), s[, "Strain"]])
  B <- (G == "B") & !is.na(G); D <- (G == "D") & !is.na(G); y <- s[, "Mean"]
  WB <- B %*% w; WD <- D %*% w; SB <- B %*% (w * y); SD <- D %*% (w * y); Q <- B %*% (w * y^2) + D %*% (w * y^2)
  n <- rowSums(B) + rowSums(D); W <- WB + WD; S <- SB + SD
  between <- SB^2 / WB + SD^2 / WD - S^2 / W; within <- Q - S^2 / W - between
  F <- between / (within / (n - 2)); p <- -pf(F, 1, n - 2, lower.tail = FALSE, log.p = TRUE) / log(10)
  p[WB == 0 | WD == 0 | n < 4] <- NA
  as.vector(sign(SB / WB - SD / WD) * p)
}

sink("output/GN4AI/actuarial/compare_Danny.txt", split = TRUE)
res <- list()
for (d in names(diets)) {
  x <- as.data.frame(suppressMessages(read_excel("data/local/Arends_Data_05Nov2026/QTL_Lifespan_05Nov2026.xlsx", sheet = d, col_names = FALSE)))
  map <- data.frame(marker = x[-1, 1], chr = x[-1, 2], Mb = as.numeric(x[-1, 5]))
  cat("\n", d, ": values in Danny's 27th column (headed 770):", sum(!is.na(suppressWarnings(as.numeric(x[-1, 32])))), "\n")
  danny <- sapply(x[-1, 6:31], as.numeric); colnames(danny) <- paste0("T", Tages)
  auto <- map[, "chr"] != "X"
  out <- list(); local <- danny * NA
  for (k in c("loco", "none")) {
    L <- sapply(Tages, function(T) { q <- read.delim(gzfile(sprintf("data/local/GN4AI/actuarial/%s_T%d_qtl2_%s.tsv.gz", d, T, k)))
                                     q[match(map[, "marker"], q[, "marker"]), "lod"] })
    colnames(L) <- paste0("T", Tages); out[[k]] <- L
    gz <- gzfile(sprintf("output/GN4AI/actuarial/%s_qtl2_%s.tsv.gz", d, k), "w")
    write.table(cbind(map, round(L, 4))[auto, ], gz, sep = "\t", quote = FALSE, row.names = FALSE); close(gz)
  }
  for (i in seq_along(Tages)) {
    s <- m[m[, "Diet"] == d & m[, "T"] == Tages[i], ]
    local[, i] <- regress(map[, "marker"], s, s[, "n"])
    for (k in c("loco", "none")) out[[k]][, i] <- sign(regress(map[, "marker"], s, rep(1, nrow(s)))) * chisq.p(out[[k]][, i])
  }
  agree <- mean(sign(danny[, 1]) == sign(local[, 1]), na.rm = TRUE)
  cat("\n=====", d, "(", diets[d], "):", nrow(map), "markers in Danny's map,", sum(auto), "autosomal\n")
  cat("Danny's sign at 20 days agrees with the sign of the B mean minus the D mean at", round(100 * agree, 1), "% of markers\n")
  if (agree < 0.5) { danny <- -danny; cat("  so his values are negated here: positive means the B allele lives longer\n") }
  r <- function(a, b) round(cor(abs(a[auto]), abs(b[auto]), use = "complete"), 3)
  pk <- function(v) { v[!auto] <- NA; i <- which.max(abs(v)); sprintf("Chr %s %.1f Mb %s %.2f", map[i, "chr"], map[i, "Mb"], c("D", "", "B")[sign(v[i]) + 2], abs(v[i])) }
  tab <- data.frame(T = Tages, strains = as.numeric(table(m[m[, "Diet"] == d, "T"])[as.character(Tages)]),
                    r.weighted = sapply(seq_along(Tages), function(i) r(danny[, i], local[, i])),
                    r.qtl2.none = sapply(seq_along(Tages), function(i) r(danny[, i], out$none[, i])),
                    r.qtl2.loco = sapply(seq_along(Tages), function(i) r(danny[, i], out$loco[, i])),
                    r.loco.none = sapply(seq_along(Tages), function(i) r(out$loco[, i], out$none[, i])),
                    peak.Danny = sapply(seq_along(Tages), function(i) pk(danny[, i])),
                    peak.qtl2.loco = sapply(seq_along(Tages), function(i) pk(out$loco[, i])))
  cat("Correlation over autosomal markers of |-log10 P|, Danny against: the local weighted regression, GN4AI R/qtl2 without and with LOCO kinship;",
      "then GN4AI with kinship against without. Peaks are autosomal, with the allele whose strains live longer.\n")
  print(tab, row.names = FALSE)
  top <- function(v) sapply(chrs[-20], function(ch) { k <- which(map[, "chr"] == ch); a <- abs(v[k, , drop = FALSE]); i <- which(a == max(a, na.rm = TRUE), arr.ind = TRUE)[1, ]
                                                      sprintf("%.2f (%.0f Mb, T%d, %s)", a[i[1], i[2]], map[k[i[1]], "Mb"], Tages[i[2]], c("D", "", "B")[sign(v[k[i[1]], i[2]]) + 2]) })
  cat("Strongest -log10 P on each autosome over all T-ages (position, T-age, allele whose strains live longer):\n")
  print(data.frame(chr = chrs[-20], Danny = top(danny), qtl2.none = top(out$none), qtl2.loco = top(out$loco)), row.names = FALSE)
  res[[d]] <- list(map = map, Danny = danny, loco = out$loco, n = tab[, "strains"])
}
sink()

# Heat maps in the layout of Danny's Fig. 2: chromosomes across, T-age up, signed -log10 P binned 1-2, 2-3, 3-4, 4-5, >5
shade <- function(col) colorRampPalette(c("white", col, "black"))(13)[c(4, 6, 7, 8, 10)]
pal <- c(rev(shade(col.hap["D"])), "white", shade(col.hap["B"]))                       # D higher (negative) to B higher
bin <- function(v) { b <- pmin(floor(abs(v)), 5); b[is.na(b)] <- 0; ifelse(b == 0, 6, 6 + sign(v) * b) }
len <- tapply(res$CD$map[, "Mb"], factor(res$CD$map[, "chr"], levels = chrs), max)
off <- cumsum(c(0, len[-20] + 25)); names(off) <- chrs
svglite("output/GN4AI/actuarial/actuarial_maps.svg", width = 7, height = 8.2, system_fonts = list(sans = "Arial"))
layout(matrix(1:5, ncol = 1), heights = c(1, 1, 1, 1, 0.42))
par(mar = c(1.6, 3.2, 1.5, 2.9), mgp = c(2, 0.4, 0), cex = 0.7, family = "sans", tcl = -0.2)
panels <- list(list("CD", "Danny", "a", "Chow, Danny Arends: strain means weighted by mice, no kinship"),
               list("CD", "loco",  "b", "Chow, GN4AI R/qtl2: strain means, LOCO kinship (autosomes only)"),
               list("HF", "Danny", "c", "High fat, Danny Arends: strain means weighted by mice, no kinship"),
               list("HF", "loco",  "d", "High fat, GN4AI R/qtl2: strain means, LOCO kinship (autosomes only)"))
for (p in panels) {
  z <- res[[p[[1]]]]; v <- z[[p[[2]]]]; map <- z$map
  plot(NA, xlim = c(0, max(off + len)), ylim = c(min(shown) - 15, max(shown) + 15), xaxs = "i", yaxs = "i", axes = FALSE, xlab = "", ylab = "")
  for (T in shown) {
    j <- which(Tages == T); cl <- bin(v[, j])
    for (ch in chrs) {
      k <- which(map[, "chr"] == ch); k <- k[order(map[k, "Mb"])]; if (!length(k)) next
      x0 <- map[k, "Mb"]; x1 <- c(x0[-1], len[ch]); run <- c(TRUE, diff(cl[k]) != 0)
      g <- cumsum(run); st <- tapply(x0, g, min); en <- tapply(x1, g, max); cc <- tapply(cl[k], g, `[`, 1)
      keep <- cc != 6
      if (any(keep)) rect(off[ch] + st[keep], T - 15, off[ch] + en[keep], T + 15, col = pal[cc[keep]], border = NA)
    }
  }
  rect(off, min(shown) - 15, off + len, max(shown) + 15, border = "black", lwd = 0.6)
  axis(2, at = labeled, las = 1, lwd = 0, lwd.ticks = 0.5, cex.axis = 0.8)
  axis(4, at = labeled, labels = z$n[match(labeled, Tages)], las = 1, lwd = 0, lwd.ticks = 0.5, cex.axis = 0.75)
  mtext(chrs, side = 1, at = off + len / 2, line = 0.3, cex = 0.62)
  mtext("T-age (days)", side = 2, line = 2.1, cex = 0.62); mtext("Strains", side = 4, line = 1.7, cex = 0.62)
  mtext(p[[3]], side = 3, line = 0.3, adj = -0.045, font = 2, cex = 0.85); mtext(p[[4]], side = 3, line = 0.3, adj = 0, cex = 0.7)
}
par(mar = c(0.5, 3.2, 0.3, 2.9)); plot(NA, xlim = c(0, 12), ylim = c(0, 3), axes = FALSE, xlab = "", ylab = "")
labs <- c("1–2", "2–3", "3–4", "4–5", ">5")
for (h in c("D", "B")) {
  y <- if (h == "B") 2 else 0.9; x0 <- 3.2
  text(x0 - 0.1, y + 0.2, paste0(c(B = "B allele", D = "D allele")[h], " lives longer"), adj = 1, cex = 0.8)
  rect(x0 + 0:4 * 0.9, y, x0 + 0:4 * 0.9 + 0.85, y + 0.4, col = shade(col.hap[h]), border = "grey60", lwd = 0.3)
  text(x0 + 0:4 * 0.9 + 0.425, y - 0.25, labs, cex = 0.7)
}
text(8.1, 1.6, expression(-log[10] * italic(P) * " at each marker and T-age; white below 1"), adj = 0, cex = 0.8)
invisible(dev.off())
