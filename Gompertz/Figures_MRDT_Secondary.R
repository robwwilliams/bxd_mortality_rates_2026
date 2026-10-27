#
# Figures_MRDT_Secondary.R
#
# copyright (c) 2026 - Rob Williams
#
# Figures for the pre-registered secondary tests. Run Gompertz/MRDT_Secondary.R first.
# Conventions as in Figures_MRDT_Diet.R: svglite with Arial labels as single text elements; log scales in base 2.
#
#  Fig6_MRDT_ratios.svg            MRDT ratio, with 95% CI, for every registered, secondary and exploratory comparison
#  Fig7_Hazard_by_class.svg        mortality rate by age (60-day bins) with the fitted lines: (a, b) Chr 1 D and B strains,
#                                  (c, d) F1 hybrids and their inbred parents, on chow and on high fat
#

library(svglite)

ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"
# Haplotype colors follow Arends et al. 2026 (Fig. 2f): B ("black") dark purple, D ("dilute") orange. Their tan D
# (Fig. 3f) is too close to our chow brown. F1 hybrids green, inbred parents pink. The four pass the color-vision
# checks as a set; orange and pink fall below 3:1 contrast, so every series is named in its key.
col.class <- c(B = "#7d4598", D = "#ed8f22", Parents = "#e87ba4", F1 = "#008300")
fontfile <- function(bold, italic) {
  f <- systemfonts::match_font("Arial", italic = italic, bold = bold)$path
  if (!grepl("arial", f, ignore.case = TRUE)) f <- systemfonts::match_font("Liberation Sans", italic = italic, bold = bold)$path
  return(list(alias = "Arial", file = f))
}
arial <- list(sans = list(plain = fontfile(FALSE, FALSE), bold = fontfile(TRUE, FALSE),
                          italic = fontfile(FALSE, TRUE), bolditalic = fontfile(TRUE, TRUE)))
openSVG <- function(file, width = 7, height = 5) {
  svglite(file, width = width, height = height, user_fonts = arial, fix_text_size = FALSE)
  par(family = "sans", col = ink, col.axis = ink2, col.lab = ink, fg = ink2, las = 1, mgp = c(2.6, 0.6, 0), tcl = -0.3)
}

tests <- read.delim("output/MRDT_secondary_tests.txt")
expl <- read.delim("output/MRDT_exploratory_pergenotype.txt")
levels.out <- read.delim("output/MRDT_secondary_levels.txt")
binned <- read.delim("output/MRDT_secondary_binned_60d.txt")
row.of <- function(name, from = 200) tests[tests[, "test"] == name & tests[, "from"] == from, ]

### Figure 5: MRDT ratios
rows <- list(
  list("Registered tests, from 200 d", NULL),
  list("H1  Chr 1: D strains / B strains", row.of("H1 Chr1 D vs B")),
  list("H2  F1 hybrids / inbred parents", row.of("H2 F1 vs parents")),
  list("Secondary analyses (estimates only)", NULL),
  list("S1  Short x short F1s / short-lived parents", row.of("S1 short F1 vs short parents")),
  list("S1  Long x long F1s / long-lived parents", row.of("S1 long F1 vs long parents")),
  list("S2  B6D2F1, D2B6F1 / C57BL/6J, DBA/2J", row.of("S2 B6D2 F1s vs B6 and D2")),
  list("S3  Recombinant B-D / B strains", row.of("S3 recombinant B-D vs B")),
  list("S3  Recombinant D-B / B strains", row.of("S3 recombinant D-B vs B")),
  list("S4  D / B strains, chow only", row.of("S4 Chr1 D vs B, CD only")),
  list("S4  D / B strains, high fat only", row.of("S4 Chr1 D vs B, HF only")),
  list("S5  D / B strains, high fat + NAM", row.of("S5 NAM: Chr1 D vs B")),
  list("S6  H1 from 0 d", row.of("H1 Chr1 D vs B", 0)),
  list("S6  H1 from 365 d", row.of("H1 Chr1 D vs B", 365)),
  list("S6  H2 from 0 d", row.of("H2 F1 vs parents", 0)),
  list("S6  H2 from 365 d", row.of("H2 F1 vs parents", 365)),
  list("Exploratory: a level for each genotype", NULL),
  list("H1  D strains / B strains", expl[1, ]),
  list("H2  F1 hybrids / inbred parents", expl[2, ]),
  list("S1  Short x short F1s / short-lived parents", expl[3, ]),
  list("S1  Long x long F1s / long-lived parents", expl[4, ])
)
openSVG("output/Fig6_MRDT_ratios.svg", width = 7.5, height = 7.4)
par(mar = c(4.2, 16.5, 1, 7.2))
n <- length(rows); y <- rev(seq_len(n))
xr <- c(-2, 1.25)
plot(xr, c(0.5, n + 1.2), type = "n", axes = FALSE, xaxs = "i", xlab = "MRDT ratio (log2 scale)", ylab = "")
ticks <- c(0.25, 0.5, 1, 2)
abline(v = log2(c(ticks, 0.71, 1.41)), col = grid.col, lwd = 0.75)
abline(v = 0, col = ink2, lwd = 0.75)
axis(1, at = log2(ticks), labels = c("0.25", "0.50", "1", "2"), col = NA, col.ticks = ink2)
for (i in seq_len(n)) {
  r <- rows[[i]]
  if (is.null(r[[2]])) {                                            # group heading
    mtext(r[[1]], side = 2, at = y[i], las = 1, line = 16, adj = 0, cex = 0.78, font = 2, col = ink)
    next
  }
  x <- r[[2]]
  open <- i > which(sapply(rows, function(z) grepl("^Exploratory", z[[1]])))
  mtext(r[[1]], side = 2, at = y[i], las = 1, line = 15.5, adj = 0, cex = 0.75, col = ink)
  segments(max(x[, "delta.lo"], xr[1]), y[i], min(x[, "delta.hi"], xr[2]), y[i], col = ink2, lwd = 1.5)
  points(x[, "delta"], y[i], pch = 21, bg = if (open) "white" else ink, col = if (open) ink else "white", cex = 1.2, lwd = 1)
  mtext(sprintf("%.0f / %.0f d", x[, "MRDT2"], x[, "MRDT1"]), side = 4, at = y[i], las = 1, line = 0.4, cex = 0.7, col = ink2)
  if (i %in% 2:3) mtext(sprintf("P = %.2g", x[, "p"]), side = 4, at = y[i], las = 1, line = 4, cex = 0.7, col = ink)
}
mtext("MRDT", side = 4, at = n + 0.8, las = 1, line = 0.4, cex = 0.7, col = ink2)
mtext("P", side = 4, at = n + 0.8, las = 1, line = 4, cex = 0.7, col = ink2)
text(-0.06, n + 0.8, "\u2190 steeper", adj = c(1, 0.5), cex = 0.7, col = ink2)
text(0.06, n + 0.8, "flatter \u2192", adj = c(0, 0.5), cex = 0.7, col = ink2)
box(bty = "l", col = ink2)
dev.off()

### Figure 6: hazard by class, with the fitted lines of the registered model
openSVG("output/Fig7_Hazard_by_class.svg", width = 7.5, height = 6.6)
par(mfrow = c(2, 2), mar = c(4, 4.4, 1.6, 0.8))
doublings <- 2^(-3:6)
panels <- list(c("H1", "CD", "a"), c("H1", "HF", "b"), c("H2", "CD", "c"), c("H2", "HF", "d"))
names.test <- c(H1 = "H1 Chr1 D vs B", H2 = "H2 F1 vs parents")
lab.class <- c(B = "B strains", D = "D strains", Parents = "Inbred parents", F1 = "F1 hybrids")
lab.diet <- c(CD = "chow", HF = "high fat")
for (p in panels) {
  tst <- p[1]; diet <- p[2]
  x <- tests[tests[, "test"] == names.test[tst] & tests[, "from"] == 200, ]
  cls <- c(x[, "class1"], x[, "class2"]); mrdt <- c(x[, "MRDT1"], x[, "MRDT2"])
  plot(c(200, 1200), c(0.1, 80), type = "n", log = "y", xaxs = "i", yaxs = "i", axes = FALSE,
       xlab = "Age (days)", ylab = "Deaths per 1,000 mouse-days (log2 scale)", cex.lab = 0.9)
  abline(h = doublings, v = seq(400, 1200, 200), col = grid.col, lwd = 0.75)
  axis(1, at = seq(200, 1200, 200), col = NA, col.ticks = ink2, cex.axis = 0.85)
  axis(2, at = doublings, labels = c("0.125", "0.25", "0.50", 2^(0:6)), col = NA, col.ticks = ink2, cex.axis = 0.8)
  box(bty = "l", col = ink2)
  leg <- c()
  for (j in 1:2) {
    bn <- binned[binned[, "test"] == tst & binned[, "class"] == cls[j] & binned[, "diet"] == diet &
                 binned[, "deaths"] > 0 & binned[, "atrisk"] >= 10, ]
    points(bn[, "mid"], 1000 * bn[, "rate"], pch = 21, bg = paste0(col.class[cls[j]], "B3"), col = "white", lwd = 0.8,
           cex = 0.5 + 0.25 * sqrt(bn[, "deaths"]))
    h600 <- levels.out[levels.out[, "test"] == names.test[tst] & levels.out[, "from"] == 200 &
                       levels.out[, "class"] == cls[j] & levels.out[, "cell"] == diet, ]
    t <- seq(min(bn[, "mid"]), max(bn[, "mid"]), 5)
    lines(t, h600[, "h600.per1000"] * 2^((t - 600) / mrdt[j]), col = col.class[cls[j]], lwd = 2)
    leg <- c(leg, sprintf("%s, n = %d: MRDT %.0f d", lab.class[cls[j]], h600[, "n"], mrdt[j]))
  }
  legend("topleft", legend = leg, col = col.class[cls], lwd = 2, pch = 21, pt.bg = col.class[cls], pt.cex = 1, bty = "n",
         text.col = ink, cex = 0.75, inset = c(0.01, 0.01))
  text(1185, 0.125, lab.diet[diet], adj = c(1, 0), cex = 0.8, col = ink2)
  mtext(p[3], side = 3, line = 0.2, adj = -0.18, font = 2, cex = 1.1, col = ink)
}
dev.off()
