#
# Figures_onset_definitions.R
#
# copyright (c) 2026 - Rob Williams
#
# Fig. 13 for the comparison of onset definitions (notes/PLAN_morbidity_definitions.md). Run
# BodyWeight/onset_definitions.R first.
#   a-e  specification curves: every definition's estimate in units of its standard error, sorted, for C1 (chow,
#        high fat), C2, C3 and C4, in days in decline (or the graded burden)
#   f    validity: concordance of the version of each rule that could be known at the time, by group
#   g    share of definitions that agree with Part 4's verdict, by the setting of each choice
#
# Run from the repository root:  Rscript BodyWeight/Figures_onset_definitions.R
#

library(svglite)

col.diet <- c(CD = "#a86a28", HF = "#2a78d6"); col.f1 <- "#008300"
ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"; dots <- "#9a9893"
fontfile <- function(bold, italic) {
  f <- systemfonts::match_font("Arial", italic = italic, bold = bold)$path
  if (!grepl("arial", f, ignore.case = TRUE)) f <- systemfonts::match_font("Liberation Sans", italic = italic, bold = bold)$path
  return(list(alias = "Arial", file = f))
}
arial <- list(sans = list(plain = fontfile(FALSE, FALSE), bold = fontfile(TRUE, FALSE),
                          italic = fontfile(FALSE, TRUE), bolditalic = fontfile(TRUE, TRUE)))

tests <- read.table("output/Onset_definitions_tests.txt", sep = "\t", header = TRUE, quote = "")
validity <- read.table("output/Onset_definitions_validity.txt", sep = "\t", header = TRUE, quote = "")
by.choice <- read.table("output/Onset_definitions_by_choice.txt", sep = "\t", header = TRUE, quote = "")
summ <- read.table("output/Onset_definitions_summary.txt", sep = "\t", header = TRUE, quote = "")
star <- "P1.K1.O1.T1.L1"; best <- "P1.K1.G1.L2"
tests[, "t"] <- with(tests, estimate / ((hi - lo) / (2 * qt(0.975, units - 1))))

svglite("output/Fig13_Onset_definitions.svg", width = 7.5, height = 9.6, user_fonts = arial, fix_text_size = FALSE)
par(family = "sans", col = ink, col.axis = ink2, col.lab = ink, fg = ink2, las = 1, mgp = c(2.4, 0.6, 0), tcl = -0.3)
layout(matrix(c(1, 2, 3, 4, 5, 6, 7, 7, 7), 3, byrow = TRUE), heights = c(1, 1, 1.25))

# a-e: specification curves
lab <- c("C1 chow" = "C1: decline ~ lifespan, chow", "C1 high fat" = "C1: decline ~ lifespan, high fat",
         "C2 short x short" = "C2: short × short F1s − parents", "C3 long x long" = "C3: long × long F1s − parents",
         "C4 high fat - chow" = "C4: high fat − chow, within strains")
for (k in seq_along(lab)) {
  x <- tests[tests[, "conclusion"] == names(lab)[k] & tests[, "form"] == "days", ]; x <- x[order(x[, "t"]), ]
  tq <- qt(0.975, x[1, "units"] - 1); s <- summ[summ[, "conclusion"] == names(lab)[k] & summ[, "form"] == "days", ]
  yl <- range(c(-tq, tq, x[, "t"])) * 1.08
  par(mar = c(3.6, 4.2, 1.6, 0.8))
  plot(c(1, nrow(x)), yl, type = "n", axes = FALSE, xlab = "Definitions, ranked", ylab = "Estimate / s.e.")
  rect(1, -tq, nrow(x), tq, col = "#f1f0ec", border = NA)
  abline(h = 0, col = ink2, lwd = 0.75)
  axis(1, at = c(1, 200, 400, nrow(x)), col = NA, col.ticks = ink2); axis(2, col = NA, col.ticks = ink2)
  box(bty = "l", col = ink2)
  points(seq_len(nrow(x)), x[, "t"], pch = 16, cex = 0.32, col = dots)
  i <- which(x[, "definition"] == star); j <- which(x[, "definition"] == best)
  points(j, x[j, "t"], pch = 23, cex = 1.3, col = ink, bg = "white", lwd = 1.2)
  points(i, x[i, "t"], pch = 21, cex = 1.3, col = "white", bg = ink, lwd = 0.8)
  text(1, yl[2], lab[k], adj = c(0, 1), cex = 0.78, col = ink)
  text(nrow(x), yl[1], sprintf("%s; verdict as Part 4: %.0f%%", s[, "verdict"], 100 * s[, "share.same.verdict"]), adj = c(1, 0), cex = 0.68, col = ink2)
  mtext(letters[k], side = 3, line = 0.3, adj = -0.25, font = 2, cex = 1.15, col = ink)
}

# f: validity, highest weight so far, all weighings
v <- validity[validity[, "K"] == "K1" & (grepl("^Pmax\\.", validity[, "rule"]) | validity[, "rule"] == "O8"), ]
v[, "rule"] <- sub("^Pmax\\.", "", v[, "rule"]); v[v[, "rule"] == "G", "rule"] <- "G1, G2"
mv <- sort(tapply(v[, "concordance"], v[, "rule"], mean)); yy <- seq_along(mv)
par(mar = c(3.6, 4.2, 1.6, 0.8))
plot(c(0.45, 0.72), c(0.5, length(mv) + 0.5), type = "n", axes = FALSE, xlab = "Concordance", ylab = "", yaxs = "i")
abline(v = seq(0.45, 0.7, 0.05), col = grid.col, lwd = 0.75)
axis(1, at = seq(0.5, 0.7, 0.1), col = NA, col.ticks = ink2); axis(2, at = yy, labels = names(mv), tick = FALSE, cex.axis = 0.8, col.axis = ink)
box(bty = "l", col = ink2)
gc <- c("Chow BXDs" = col.diet[["CD"]], "High-fat BXDs" = col.diet[["HF"]], "F1s" = col.f1)
for (g in names(gc)) { z <- v[v[, "group"] == g, ]; points(z[, "concordance"], yy[match(z[, "rule"], names(mv))], pch = 16, cex = 0.8, col = gc[g]) }
segments(mv, yy - 0.3, mv, yy + 0.3, col = ink, lwd = 1.5)
legend(0.44, 3.6, legend = names(gc), pch = 16, col = gc, bty = "n", cex = 0.7, text.col = ink)
mtext("f", side = 3, line = 0.3, adj = -0.25, font = 2, cex = 1.15, col = ink)

# g: share agreeing with Part 4's verdict, by setting
cols <- c("C1 chow|days", "C1 chow|share", "C1 high fat|days", "C1 high fat|share", "C2 short x short|days", "C2 short x short|share",
          "C3 long x long|days", "C3 long x long|share", "C4 high fat - chow|days", "C4 high fat - chow|share")
rows <- c("P1", "P2", "P3", "P4", "K1", "K2", paste0("O", c(1:10)), "G1", "G2", "T1", "T2", "L1", "L2", "L3", "L4")
M <- sapply(cols, function(cc) { p <- strsplit(cc, "|", fixed = TRUE)[[1]]
  z <- by.choice[by.choice[, "conclusion"] == p[1] & by.choice[, "form"] == p[2], ]; z[match(rows, z[, "setting"]), "share.same.verdict"] })
par(mar = c(5.2, 10.2, 2.6, 0.8))
plot(c(0.5, length(rows) + 0.5), c(0.5, length(cols) + 0.5), type = "n", axes = FALSE, xlab = "", ylab = "", xaxs = "i", yaxs = "i")
shade <- function(p) gray(1 - 0.85 * p)
for (r in seq_along(rows)) for (c in seq_along(cols)) {
  p <- M[r, c]; rect(r - 0.5, length(cols) - c + 0.5, r + 0.5, length(cols) - c + 1.5, col = if (is.na(p)) "white" else shade(p), border = "white", lwd = 1.5)
  if (!is.na(p)) text(r, length(cols) - c + 1, sprintf("%.0f", 100 * p), cex = 0.55, col = if (p > 0.55) "white" else ink)
}
clab <- sub("\\|days", ", days", sub("\\|share", ", share of life", sub(" x ", " × ", sub(" - ", " − ", cols))))
axis(2, at = rev(seq_along(cols)), labels = clab, tick = FALSE, cex.axis = 0.68, col.axis = ink)
axis(1, at = seq_along(rows), labels = rows, tick = FALSE, cex.axis = 0.72, col.axis = ink, line = -0.6)
mtext(c("Plateau", "Weighings", "Onset rule", "Timing", "Last gap"), side = 1, line = 1.6, at = c(2.5, 5.5, 12.5, 19.5, 22.5), cex = 0.62, col = ink2)
segments(c(4.5, 6.5, 18.5, 20.5), 0.5, c(4.5, 6.5, 18.5, 20.5), length(cols) + 0.5, col = ink, lwd = 1)
mtext("g", side = 3, line = 1.1, adj = -0.14, font = 2, cex = 1.15, col = ink)
mtext("Percentage of the definitions with each setting that reach the verdict of Part 4's definition", side = 3, line = 0.3, adj = 0, cex = 0.62, col = ink2)
dev.off()
