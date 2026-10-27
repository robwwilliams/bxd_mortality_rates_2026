#
# Figures_Rectangularization.R
#
# copyright (c) 2026 - Rob Williams
#
# Fig. 15: rectangularization side by side (N5 of notes/PLAN_NAM_rectangularization.md; exploratory). Run
# Gompertz/Rectangularization.R first. One row per comparison, the same rows in every panel:
#   a  change in mean age at death (days)
#   b  SD of age at death (ratio; absolute spread)
#   c  CV of age at death (ratio; spread relative to lifespan)
#   d  MRDT (ratio)
#   e  level of mortality at 600 days (ratio)
# BXD comparisons (circles) use the strain or genotype as the unit; de Cabo's (squares) use the mouse.
#
# Run from the repository root:  Rscript Gompertz/Figures_Rectangularization.R
#

library(svglite)

ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"; band <- "#f1f0ec"
col.hf <- "#2a78d6"; col.f1 <- "#008300"; col.nam <- "#0b0b0b"; col.met <- "#8a8984"
fontfile <- function(bold, italic) {
  f <- systemfonts::match_font("Arial", italic = italic, bold = bold)$path
  if (!grepl("arial", f, ignore.case = TRUE)) f <- systemfonts::match_font("Liberation Sans", italic = italic, bold = bold)$path
  return(list(alias = "Arial", file = f))
}
arial <- list(sans = list(plain = fontfile(FALSE, FALSE), bold = fontfile(TRUE, FALSE),
                          italic = fontfile(FALSE, TRUE), bolditalic = fontfile(TRUE, TRUE)))

tests <- read.delim("output/Rectangularization_tests.txt", quote = "")
tests <- tests[!grepl("^check:", tests[, "note"]), ]
rows <- data.frame(
  comparison = c("high fat vs chow", "short x short F1s vs short-lived parents", "long x long F1s vs long-lived parents", "NAM 1% vs high fat",
                 "high fat vs standard diet", "NAM 0.05% vs standard diet", "NAM 0.1% vs standard diet", "NAM 0.05% vs high fat",
                 "NAM 0.1% vs high fat", "metformin 0.1% vs standard diet", "metformin 1% vs standard diet"),
  label = c("High fat vs chow", "Short × short F1s vs parents", "Long × long F1s vs parents", "High fat + 1% NAM vs high fat",
            "High fat vs standard diet", "0.05% NAM vs standard diet", "0.1% NAM vs standard diet", "High fat + 0.05% NAM vs high fat",
            "High fat + 0.1% NAM vs high fat", "0.1% metformin vs standard diet", "1% metformin vs standard diet"),
  col = c(col.hf, col.f1, col.f1, col.nam, col.hf, col.nam, col.nam, col.nam, col.nam, col.met, col.met),
  pch = c(21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22))
yy <- c(13, 12, 11, 10, 7, 6, 5, 4, 3, 2, 1)                     # a gap between the two sets of studies

svglite("output/Fig15_Rectangularization.svg", width = 7.5, height = 3.9, user_fonts = arial, fix_text_size = FALSE)
par(family = "sans", col = ink, col.axis = ink2, col.lab = ink, fg = ink2, las = 1, mgp = c(2.2, 0.5, 0), tcl = -0.25, oma = c(0, 13.2, 0, 0))
layout(matrix(1:5, 1))
panel <- function(k, xlab, xl, at, labels, ratio, letter, grid = at) {
  par(mar = c(3.4, 0.6, 1.8, 0.6))
  plot(xl, c(0.4, 14.2), type = "n", axes = FALSE, xlab = xlab, ylab = "", yaxs = "i", cex.lab = 0.85)
  abline(v = grid, col = grid.col, lwd = 0.75); abline(v = 0, col = ink2, lwd = 0.75)
  axis(1, at = at, labels = labels, col = NA, col.ticks = ink2, cex.axis = 0.8)
  for (i in seq_len(nrow(rows))) {
    r <- tests[tests[, "comparison"] == rows[i, "comparison"] & tests[, "measure"] == k, ]
    if (!nrow(r)) { text(mean(xl), yy[i], "—", col = ink2, cex = 0.8); next }
    lo <- max(r[, "lo"], xl[1]); hi <- min(r[, "hi"], xl[2])
    segments(lo, yy[i], hi, yy[i], col = rows[i, "col"], lwd = 1.2)
    if (r[, "lo"] < xl[1]) arrows(lo + 0.02 * diff(xl), yy[i], lo, yy[i], length = 0.04, col = rows[i, "col"], lwd = 1.2)
    if (r[, "hi"] > xl[2]) arrows(hi - 0.02 * diff(xl), yy[i], hi, yy[i], length = 0.04, col = rows[i, "col"], lwd = 1.2)
    points(min(max(r[, "estimate"], xl[1]), xl[2]), yy[i], pch = rows[i, "pch"], bg = rows[i, "col"], col = "white", cex = 1.25, lwd = 0.8)
  }
  mtext(letter, side = 3, line = 0.4, adj = 0, font = 2, cex = 0.95, col = ink)
}
r2 <- c(-1.5, -1, -0.5, 0, 0.5, 1)
panel("mean", "Change in mean age\nat death (days)", c(-260, 260), c(-200, 0, 200), c("−200", "0", "200"), FALSE, "a", seq(-200, 200, 100))
par(xpd = NA)
text(-290, yy, rows[, "label"], adj = c(1, 0.5), cex = 0.85, col = ink)
text(-290, c(14, 8), c("BXD family females (unit: strain)", "C57BL/6 males, de Cabo (unit: mouse)"), adj = c(1, 0.5), cex = 0.85, font = 2, col = ink)
par(xpd = FALSE)
panel("sd", "SD of age at death\n(ratio)", c(-1.25, 1.25), c(-1, 0, 1), c("0.5", "1", "2"), TRUE, "b", r2[2:6])
panel("cv", "CV of age at death\n(ratio)", c(-1.25, 1.25), c(-1, 0, 1), c("0.5", "1", "2"), TRUE, "c", r2[2:6])
panel("mrdt", "MRDT\n(ratio)", c(-1.25, 1.25), c(-1, 0, 1), c("0.5", "1", "2"), TRUE, "d", r2[2:6])
panel("h600", "Mortality at 600 days\n(ratio)", c(-2, 3.3), c(-2, 0, 2), c("0.25", "1", "4"), TRUE, "e", -2:3)
dev.off()
