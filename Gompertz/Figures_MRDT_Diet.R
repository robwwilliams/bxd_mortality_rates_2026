#
# Figures_MRDT_Diet.R
#
# copyright (c) 2026 - Rob Williams
#
# Figures for the initial Gompertz analysis of chow (CD) versus high-fat (HF) females. Run Gompertz/MRDT_Diet.R first.
# SVG files are written with svglite, which keeps every label as one <text> element (editable in Illustrator).
# PNG previews: python3 tools/svg2png.py output/*.svg
#
#  Fig1_Gompertz_hazard.svg     log mortality rate by age, 30-day bins, with the Gompertz fits
#  Fig2_Survival_from200d.svg   Kaplan-Meier survival from 200 d with the Gompertz fits
#  Fig3_MRDT_estimates.svg      MRDT and 95% intervals by diet across the analyses
#  Fig4_Bootstrap_R0_MRDT.svg   bootstrap estimates of ln(R0) and MRDT: the Strehler-Mildvan ridge
#

library(readxl)
library(survival)
library(svglite)

source("Gompertz/gompertz.R")

col.diet <- c(CD = "#2a78d6", HF = "#eb6834")                     # categorical slots 1 and 2
lab.diet <- c(CD = "Chow (CD)", HF = "High fat (HF)")
ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"
# Labels are set in Arial. The SVG names "Arial"; text is measured with Arial or, where it is not installed,
# with its metric twin Liberation Sans, so widths match either way.
fontfile <- function(bold, italic) {
  f <- systemfonts::match_font("Arial", italic = italic, bold = bold)$path
  if (!grepl("arial", f, ignore.case = TRUE)) f <- systemfonts::match_font("Liberation Sans", italic = italic, bold = bold)$path
  return(list(alias = "Arial", file = f))
}
arial <- list(sans = list(plain = fontfile(FALSE, FALSE), bold = fontfile(TRUE, FALSE),
                          italic = fontfile(FALSE, TRUE), bolditalic = fontfile(TRUE, TRUE)))

openSVG <- function(file, width = 7, height = 5) {
  # fix_text_size = FALSE: no textLength attributes, so text stays freely editable in Illustrator
  svglite(file, width = width, height = height, user_fonts = arial, fix_text_size = FALSE)
  par(family = "sans", col = ink, col.axis = ink2, col.lab = ink, fg = ink2, las = 1, mgp = c(2.6, 0.6, 0), tcl = -0.3)
}

# Data, as in MRDT_Diet.R
mdata <- read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal")
mdata <- as.data.frame(mdata[, 1:7])
colnames(mdata) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
mdata <- mdata[!is.na(mdata[, "EarTag"]) & mdata[, "Diet"] %in% c("CD", "HF"), ]

results <- read.table("output/MRDT_by_diet.txt", sep = "\t", header = TRUE, check.names = FALSE)
tests <- read.table("output/MRDT_diet_tests.txt", sep = "\t", header = TRUE, check.names = FALSE)
binned <- read.table("output/hazard_binned_30d.txt", sep = "\t", header = TRUE)
boot <- read.table("output/MRDT_bootstrap.txt", sep = "\t", header = TRUE)
primary <- results[results[, "analysis"] == "Primary: all CD and HF females", ]
rownames(primary) <- primary[, "diet"]

ci.text <- function(d) sprintf("MRDT %.0f d (95%% CI %.0f-%.0f)", primary[d, "MRDT"], primary[d, "MRDT.lo"], primary[d, "MRDT.hi"])

### Figure 1: Gompertz plot
openSVG("output/Fig1_Gompertz_hazard.svg")
par(mar = c(4.2, 4.6, 1.2, 1.2))
plot(c(0, 1300), c(0.05, 100), type = "n", log = "y", xaxs = "i", axes = FALSE,
     xlab = "Age (days)", ylab = "Deaths per 1,000 mouse-days (log scale)")
abline(h = c(0.1, 1, 10, 100), v = seq(200, 1200, 200), col = grid.col, lwd = 0.75)
axis(1, at = seq(0, 1300, 200), col = NA, col.ticks = ink2)
axis(2, at = c(0.1, 1, 10, 100), labels = c("0.1", "1", "10", "100"), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (d in c("CD", "HF")) {
  bn <- binned[binned[, "diet"] == d & binned[, "deaths"] > 0 & binned[, "atrisk"] >= 20, ]
  points(bn[, "mid"], 1000 * bn[, "rate"], pch = 21, bg = paste0(col.diet[d], "B3"), col = "white", lwd = 0.8,
         cex = 0.5 + 0.25 * sqrt(bn[, "deaths"]))
  t <- seq(100, 1250, 5)
  lines(t, 1000 * primary[d, "a"] * exp(primary[d, "b"] * t), col = col.diet[d], lwd = 2)
}
legend("topleft", legend = c(paste0(lab.diet["CD"], ", n = ", primary["CD", "n"], ": ", ci.text("CD")),
                             paste0(lab.diet["HF"], ", n = ", primary["HF", "n"], ": ", ci.text("HF"))),
       col = col.diet, lwd = 2, pch = 21, pt.bg = col.diet, pt.cex = 1, bty = "n", text.col = ink, cex = 0.85, inset = c(0.01, 0.01))
mtext(sprintf("Same slope: p = %.2f.  Shared MRDT %.0f d; HF raises mortality %.2f-fold at every age.",
              tests[1, "p.slope"], tests[1, "MRDT.sharedb"], tests[1, "HR.gompertz"]),
      side = 1, line = -1.4, adj = 0.97, cex = 0.75, col = ink2)
dev.off()

### Figure 2: survival from 200 days
openSVG("output/Fig2_Survival_from200d.svg")
par(mar = c(4.2, 4.6, 1.2, 1.2))
plot(c(200, 1300), c(0, 100), type = "n", xaxs = "i", yaxs = "i", axes = FALSE,
     xlab = "Age (days)", ylab = "Surviving, of those alive at 200 days (%)")
abline(h = seq(25, 100, 25), v = seq(400, 1200, 200), col = grid.col, lwd = 0.75)
axis(1, at = seq(200, 1300, 200), col = NA, col.ticks = ink2)
axis(2, at = seq(0, 100, 25), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (d in c("CD", "HF")) {
  s <- mdata[mdata[, "Diet"] == d & mdata[, "Age"] >= 200, ]
  km <- survfit(Surv(pmax(s[, "SetupAge"], 200), s[, "Age"], rep(1, nrow(s))) ~ 1)
  lines(c(200, km$time), 100 * c(1, km$surv), type = "s", col = col.diet[d], lwd = 1.5)
  t <- seq(200, 1300, 5)
  lines(t, 100 * exp(-(gompertz.H(t, primary[d, "a"], primary[d, "b"]) - gompertz.H(200, primary[d, "a"], primary[d, "b"]))),
        col = col.diet[d], lwd = 2, lty = 2)
  med <- median(s[, "Age"])
  text(med, 50, paste0(lab.diet[d], "\nmedian ", med, " d"), pos = ifelse(d == "CD", 4, 2), col = ink, cex = 0.8, offset = 0.6)
}
legend("topright", legend = c("Kaplan-Meier", "Gompertz fit"), lty = c(1, 2), lwd = c(1.5, 2), col = ink2,
       bty = "n", text.col = ink, cex = 0.85)
dev.off()

### Figure 3: MRDT estimates across analyses
rows <- c("Primary: all CD and HF females", "Primary, bootstrap", "Survived to 200 d", "Survived to 365 d",
          "BXD strains only", "Gompertz-Makeham", "Binned regression (from 200 d)")
labels <- c("Primary (Wald interval)", "Primary (bootstrap interval)", "Survived to 200 d", "Survived to 365 d",
            "BXD strains only", "Gompertz-Makeham", "Binned regression, from 200 d")
bsum <- read.table("output/MRDT_bootstrap_summary.txt", sep = "\t", header = TRUE)
est <- function(r, d) {
  if (r == "Primary, bootstrap") {
    q <- bsum[bsum[, "quantity"] == paste0("MRDT.", d), ]
    return(c(primary[d, "MRDT"], q[, "lo"], q[, "hi"]))
  }
  x <- results[results[, "analysis"] == r & results[, "diet"] == d, ]
  return(c(x[, "MRDT"], x[, "MRDT.lo"], x[, "MRDT.hi"]))
}
pslope <- setNames(tests[, "p.slope"], tests[, "analysis"])
openSVG("output/Fig3_MRDT_estimates.svg", width = 7.5, height = 4.6)
par(mar = c(4.2, 13.5, 1.6, 4.5))
y <- rev(seq_along(rows))
plot(c(120, 200), c(0.4, length(rows) + 0.6), type = "n", axes = FALSE, xlab = "Mortality rate doubling time (days)", ylab = "")
abline(v = seq(120, 200, 20), col = grid.col, lwd = 0.75)
axis(1, at = seq(120, 200, 20), col = NA, col.ticks = ink2)
axis(2, at = y, labels = labels, tick = FALSE, cex.axis = 0.85, col.axis = ink)
box(bty = "l", col = ink2)
for (i in seq_along(rows)) {
  for (d in c("CD", "HF")) {
    e <- est(rows[i], d); yy <- y[i] + ifelse(d == "CD", 0.15, -0.15)
    segments(e[2], yy, e[3], yy, col = col.diet[d], lwd = 2)
    points(e[1], yy, pch = 21, bg = col.diet[d], col = "white", cex = 1.3, lwd = 1)
  }
  if (rows[i] %in% names(pslope)) mtext(sprintf("p = %.2f", pslope[rows[i]]), side = 4, at = y[i], las = 1, line = 0.5, cex = 0.75, col = ink2)
}
mtext("Same slope?", side = 4, at = length(rows) + 0.75, las = 1, line = 0.5, cex = 0.75, col = ink2)
legend("bottomright", legend = lab.diet, pch = 21, pt.bg = col.diet, col = "white", pt.cex = 1.3, lwd = 2, lty = 0,
       bty = "n", text.col = ink, cex = 0.85)
dev.off()

### Figure 4: bootstrap estimates of ln(R0) and MRDT
openSVG("output/Fig4_Bootstrap_R0_MRDT.svg", width = 6, height = 5)
par(mar = c(4.2, 4.6, 1.2, 1.2))
plot(range(c(boot[, "loga.CD"], boot[, "loga.HF"])), c(120, 190), type = "n", axes = FALSE,
     xlab = "ln(R0), age-independent mortality (ln per day)", ylab = "Mortality rate doubling time (days)")
abline(h = seq(120, 190, 10), col = grid.col, lwd = 0.75)
axis(1, col = NA, col.ticks = ink2); axis(2, at = seq(120, 190, 10), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (d in c("CD", "HF")) {
  points(boot[, paste0("loga.", d)], boot[, paste0("MRDT.", d)], pch = 16, cex = 0.35, col = paste0(col.diet[d], "40"))
}
for (d in c("CD", "HF")) {
  points(primary[d, "lnR0"], primary[d, "MRDT"], pch = 21, bg = col.diet[d], col = "white", cex = 1.6, lwd = 1.2)
}
legend("topright", legend = paste0(lab.diet, ": ", nrow(boot), " bootstrap fits"), pch = 21, pt.bg = col.diet, col = "white",
       pt.cex = 1.3, bty = "n", text.col = ink, cex = 0.85)
mtext(sprintf("Estimates of ln(R0) and ln(b) correlate at r = %.2f (CD) and %.2f (HF)",
              cor(boot[, "loga.CD"], boot[, "logb.CD"]), cor(boot[, "loga.HF"], boot[, "logb.HF"])),
      side = 3, line = -4.4, adj = 0.03, cex = 0.75, col = ink2)
dev.off()
