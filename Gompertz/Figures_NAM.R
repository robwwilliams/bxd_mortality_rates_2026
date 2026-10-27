#
# Figures_NAM.R
#
# copyright (c) 2026 - Rob Williams
#
# Fig. 14 for nicotinamide and rectangularization (notes/PLAN_NAM_rectangularization.md). Run
# Gompertz/NAM_rectangularization.R first. TSRB only, the 9 strains with at least 3 mice in each arm, all deaths.
#   a  mean age at death of each strain, high fat and high fat + NAM (N1)
#   b  SD of age at death of each strain (N3)
#   c  mean days in terminal decline of each strain, Part 4's definition (N4)
#   d  NAM - high fat difference in days in decline, for the 18 day-based definitions of the one-at-a-time set (N4)
#
# Run from the repository root:  Rscript Gompertz/Figures_NAM.R
#

library(svglite)

col.arm <- c(HF = "#2a78d6", NAM = "#0b0b0b")
ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"; pair <- "#b9b7b1"
fontfile <- function(bold, italic) {
  f <- systemfonts::match_font("Arial", italic = italic, bold = bold)$path
  if (!grepl("arial", f, ignore.case = TRUE)) f <- systemfonts::match_font("Liberation Sans", italic = italic, bold = bold)$path
  return(list(alias = "Arial", file = f))
}
arial <- list(sans = list(plain = fontfile(FALSE, FALSE), bold = fontfile(TRUE, FALSE),
                          italic = fontfile(FALSE, TRUE), bolditalic = fontfile(TRUE, TRUE)))

bs <- read.table("output/NAM_by_strain.txt", sep = "\t", header = TRUE, quote = "")
bs <- bs[bs[, "deaths"] == "all", ]
tests <- read.table("output/NAM_rectangularization_tests.txt", sep = "\t", header = TRUE, quote = "")
tests <- tests[tests[, "design"] == "TSRB" & tests[, "deaths"] == "all", ]

svglite("output/Fig14_NAM.svg", width = 7.5, height = 6.4, user_fonts = arial, fix_text_size = FALSE)
par(family = "sans", col = ink, col.axis = ink2, col.lab = ink, fg = ink2, las = 1, mgp = c(2.6, 0.6, 0), tcl = -0.3)
layout(matrix(1:4, 2, byrow = TRUE))

paired <- function(v, ylab, yl, test, units, letter) {
  par(mar = c(3.2, 4.6, 1.8, 5.6))
  plot(c(0.7, 2.3), yl, type = "n", axes = FALSE, xlab = "", ylab = ylab)
  abline(h = pretty(yl), col = grid.col, lwd = 0.75)
  axis(2, at = pretty(yl), col = NA, col.ticks = ink2)
  axis(1, at = 1:2, labels = c("High fat", "High fat + NAM"), tick = FALSE, col.axis = ink, line = -0.4)
  box(bty = "l", col = ink2)
  s <- unique(bs[, "Strain"])
  h <- bs[bs[, "Arm"] == "HF", ][match(s, bs[bs[, "Arm"] == "HF", "Strain"]), v]; n <- bs[bs[, "Arm"] == "NAM", ][match(s, bs[bs[, "Arm"] == "NAM", "Strain"]), v]
  segments(1, h, 2, n, col = pair, lwd = 1)
  points(rep(1, length(s)), h, pch = 21, bg = col.arm["HF"], col = "white", cex = 1.2)
  points(rep(2, length(s)), n, pch = 21, bg = col.arm["NAM"], col = "white", cex = 1.2)
  o <- order(n); yy <- n[o]; for (k in 2:length(yy)) yy[k] <- max(yy[k], yy[k - 1] + diff(yl) * 0.045)
  par(xpd = NA); text(2.12, yy, s[o], adj = c(0, 0.5), cex = 0.62, col = ink2); par(xpd = FALSE)
  t <- tests[tests[, "measure"] == test, ]
  f <- function(z) sub("^-", "−", if (units == "log2") sprintf("%.2f", z) else sprintf("%.0f", z))
  what <- if (units == "log2") "NAM / high fat, log2:" else "NAM − high fat:"
  mtext(sprintf("%s %s (95%% CI %s to %s), P = %.2g", what, f(t[, "estimate"]), f(t[, "lo"]), f(t[, "hi"]), t[, "p"]),
        side = 3, line = 0.2, adj = 0, cex = 0.62, col = ink2)
  mtext(letter, side = 3, line = 0.3, adj = -0.3, font = 2, cex = 1.15, col = ink)
}
paired("mean.age", "Strain mean age at death (days)", c(200, 800), "mean age at death (days)", "days", "a")
paired("sd.age", "Strain SD of age at death (days)", c(0, 250), "SD of age at death", "log2", "b")
paired("mean.days.in.decline", "Strain mean days in decline", c(0, 160), "P1.K1.O1.T1.L1 days", "days", "c")

# d: all day-based definitions of the one-at-a-time set
x <- tests[tests[, "question"] == "N4" & grepl(" days$", tests[, "measure"]) & !grepl("\\.G[12]\\.", tests[, "measure"]), ]
x[, "def"] <- sub(" days$", "", x[, "measure"]); x <- x[order(x[, "estimate"]), ]; yy <- seq_len(nrow(x))
par(mar = c(3.6, 7.2, 1.8, 1))
plot(c(-80, 45), c(0.5, nrow(x) + 0.5), type = "n", axes = FALSE, xlab = "NAM − high fat, days in decline", ylab = "", yaxs = "i")
abline(v = seq(-80, 40, 20), col = grid.col, lwd = 0.75); abline(v = 0, col = ink2, lwd = 0.75)
axis(1, at = seq(-80, 40, 40), col = NA, col.ticks = ink2); axis(2, at = yy, labels = x[, "def"], tick = FALSE, cex.axis = 0.6, col.axis = ink)
box(bty = "l", col = ink2)
segments(x[, "lo"], yy, x[, "hi"], yy, col = ink2, lwd = 1)
star <- x[, "def"] == "P1.K1.O1.T1.L1"
points(x[, "estimate"], yy, pch = 21, bg = ifelse(star, ink, "white"), col = ink, cex = 0.9)
mtext("d", side = 3, line = 0.3, adj = -0.55, font = 2, cex = 1.15, col = ink)
dev.off()
