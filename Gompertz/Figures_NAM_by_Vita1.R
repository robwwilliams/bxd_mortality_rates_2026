#
# Figures_NAM_by_Vita1.R - The grant's Figs 5 and 6 (NAM by Vita1 genotype), redrawn from the newest data
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026. Rob, of the Pilot Data of the June 2026 R01
# resubmission: "this is the key part redo with the newest data." Data: Beni Mozhui's file (data/original/
# BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv, with the corrected NAM ages), all vivaria, as the grant's figures read.
# Genotypes: strain calls at Vita1a (rsm10000000010, 5.02 Mb) and Vita1b (rsm10000000521, 23.52 Mb).
#   a,b  mean lifespan ± s.e. by genotype, HFD and HFD + NAM (the grant's Fig 5);
#   c,d  lifespans by diet within each Vita1b genotype, with means and mouse-level Tukey HSD (the grant's Fig 6).
# The statistics with the strain as the unit are in output/NAM_by_Vita1_mouse_level.txt (Gompertz/NAM_by_Vita1_mouse_level.R).
# Writes output/Fig_NAM_by_Vita1.svg
#   Rscript Gompertz/Figures_NAM_by_Vita1.R
#

library(svglite)
set.seed(20261124)
d <- read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM")[, 1:7]
colnames(d) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
d <- d[!is.na(d$EarTag) & d$Diet %in% c("CD", "HF", "NAM") & !is.na(as.numeric(d$Age)), ]; d$Age <- as.numeric(d$Age)
g <- read.table("../BxDLifeSpan/data/BXD_current_rev050423.geno", sep = "\t", skip = 23, header = TRUE, na.strings = c("U", "", "NA"), check.names = FALSE)
rownames(g) <- g$Locus; d <- d[d$Strain %in% colnames(g), ]
loci <- c(Vita1a = "rsm10000000010", Vita1b = "rsm10000000521")
cB <- "#7d4598"; cD <- "#ed8f22"; cCD <- "#a86a28"; cHF <- "#2a78d6"; cNAM <- "black"
lab <- c(CD = "CD", HF = "HFD", NAM = "HFD + NAM")
se <- function(v) sd(v) / sqrt(length(v))

svglite("output/Fig_NAM_by_Vita1.svg", width = 7.2, height = 6.4, bg = "white", system_fonts = list(sans = "Arial"), fix_text_size = FALSE)
layout(matrix(1:4, 2, byrow = TRUE)); par(mai = c(0.55, 0.7, 0.35, 0.15), cex = 0.72, mgp = c(2.2, 0.55, 0), tcl = -0.25, las = 1)
for(i in 1:2){
  l <- names(loci)[i]; G <- as.character(unlist(g[loci[l], d$Strain])); y <- d[G %in% c("B", "D") & d$Diet %in% c("HF", "NAM"), ]; y$G <- G[G %in% c("B", "D") & d$Diet %in% c("HF", "NAM")]
  m <- tapply(y$Age, list(y$G, y$Diet), mean); s <- tapply(y$Age, list(y$G, y$Diet), se); n <- table(y$G, y$Diet)
  plot(NA, xlim = c(0.6, 2.4), ylim = c(500, 680), xaxt = "n", bty = "l", xlab = "", ylab = "Lifespan (days)")
  axis(1, at = 1:2, labels = lab[c("HF", "NAM")])
  for(k in c("B", "D")){ co <- if(k == "B") cB else cD; x <- 1:2 + if(k == "B") -0.03 else 0.03
    lines(x, m[k, ], col = co, lwd = 1.6); arrows(x, m[k, ] - s[k, ], x, m[k, ] + s[k, ], angle = 90, code = 3, length = 0.04, col = co, lwd = 1.1)
    text(x[1] - 0.06, m[k, 1], k, col = co, font = 4, adj = 1) }
  mtext(letters[i], side = 3, line = 0.5, at = grconvertX(0.05, "nfc", "user"), adj = 0, font = 2, cex = 1.1)
  mtext(l, side = 3, line = 0.5, font = 4, cex = 0.95)
  mtext(sprintf("B: %d and %d mice; D: %d and %d", n["B", "HF"], n["B", "NAM"], n["D", "HF"], n["D", "NAM"]), side = 1, line = 2.3, cex = 0.62, col = "grey30")
}
G <- as.character(unlist(g[loci["Vita1b"], d$Strain]))
for(k in c("B", "D")){
  y <- d[G == k & !is.na(G), ]; y$Diet <- factor(y$Diet, levels = c("CD", "HF", "NAM"))
  plot(NA, xlim = c(0.5, 3.5), ylim = c(0, 1450), xaxt = "n", bty = "l", xlab = "", ylab = "Lifespan (days)")
  axis(1, at = 1:3, labels = lab)
  for(j in 1:3){ v <- y$Age[y$Diet == levels(y$Diet)[j]]; co <- c(cCD, cHF, cNAM)[j]
    points(j + runif(length(v), -0.28, 0.28), v, pch = 16, cex = 0.32, col = adjustcolor(co, 0.45))
    segments(j - 0.32, mean(v), j + 0.32, mean(v), lwd = 2.2, col = co) }
  tk <- TukeyHSD(aov(Age ~ Diet, y))$Diet; pr <- list(c(1, 2), c(1, 3), c(2, 3)); hy <- c(1230, 1330, 1150)[c(1, 2, 3)]
  star <- function(p) if(p < 1e-4) "***" else if(p <= 0.005) "**" else if(p <= 0.05) "*" else "ns"
  for(q in 1:3){ a <- pr[[q]]; p <- tk[c("HF-CD", "NAM-CD", "NAM-HF")[q], "p adj"]
    segments(a[1], hy[q], a[2], hy[q], lwd = 0.7); segments(a, hy[q], a, hy[q] - 25, lwd = 0.7)
    text(mean(a), hy[q] + 8, sprintf("%s (P = %.1g)", star(p), p), cex = 0.7, adj = c(0.5, 0)) }
  mtext(letters[2 + which(c("B", "D") == k)], side = 3, line = 0.5, at = grconvertX(0.05, "nfc", "user"), adj = 0, font = 2, cex = 1.1)
  mtext(bquote(bolditalic("Vita1b") * bold(":") ~ bolditalic(.(k)) ~ bold("genotypes")), side = 3, line = 0.5, cex = 0.95)
  mtext(paste(sprintf("%s %d", lab, table(y$Diet)), collapse = ", "), side = 1, line = 2.3, cex = 0.62, col = "grey30")
}
invisible(dev.off())
