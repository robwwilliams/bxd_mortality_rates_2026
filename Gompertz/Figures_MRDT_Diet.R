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
#  Fig2_Survival_from200d.svg   (a) Kaplan-Meier survival from 200 d with the Gompertz fits; (b) survivorship
#                                differences by T-age (Arends et al. 2026 Fig. 1b style)
#  Fig3_MRDT_estimates.svg      MRDT and 95% intervals by diet across the analyses
#  Fig4_Bootstrap_R0_MRDT.svg   bootstrap estimates of log2(R0) and MRDT: the Strehler-Mildvan ridge
#
# Log scales are base 2 throughout: on Fig 1, one gridline is one doubling of mortality.
#

library(readxl)
library(survival)
library(svglite)

source("Gompertz/gompertz.R")

col.diet <- c(CD = "#a86a28", HF = "#2a78d6")                     # chow brown; HF blue (the "blue diet"); pair passes the CVD and contrast checks
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
doublings <- 2^(-3:5)                                              # 0.125 to 32: one gridline per doubling
plot(c(0, 1200), c(0.1, 40), type = "n", log = "y", xaxs = "i", yaxs = "i", axes = FALSE,
     xlab = "Age (days)", ylab = "Deaths per 1,000 mouse-days (log2 scale)")
abline(h = doublings, v = seq(200, 1200, 200), col = grid.col, lwd = 0.75)
axis(1, at = seq(0, 1200, 200), col = NA, col.ticks = ink2)
axis(2, at = doublings, labels = c("0.125", "0.25", "0.50", 2^(0:5)), col = NA, col.ticks = ink2, cex.axis = 0.9)
box(bty = "l", col = ink2)
for (d in c("CD", "HF")) {
  bn <- binned[binned[, "diet"] == d & binned[, "deaths"] > 0 & binned[, "atrisk"] >= 20, ]
  points(bn[, "mid"], 1000 * bn[, "rate"], pch = 21, bg = paste0(col.diet[d], "B3"), col = "white", lwd = 0.8,
         cex = 0.5 + 0.25 * sqrt(bn[, "deaths"]))
  t <- seq(min(bn[, "mid"]), max(bn[, "mid"]), 5)                  # fits drawn only over the ages with data
  lines(t, 1000 * primary[d, "a"] * exp(primary[d, "b"] * t), col = col.diet[d], lwd = 2)
}
legend("topleft", legend = c(paste0(lab.diet["CD"], ", n = ", primary["CD", "n"], ": ", ci.text("CD")),
                             paste0(lab.diet["HF"], ", n = ", primary["HF", "n"], ": ", ci.text("HF"))),
       col = col.diet, lwd = 2, pch = 21, pt.bg = col.diet, pt.cex = 1, bty = "n", text.col = ink, cex = 0.85, inset = c(0.01, 0.01))
text(1185, 0.125, adj = c(1, 0), cex = 0.75, col = ink2,
     sprintf("Same slope: p = %.2f. Shared MRDT %.0f d.\nHF raises mortality %.2f-fold (%.2f doublings) at every age.",
             tests[1, "p.slope"], tests[1, "MRDT.sharedb"], tests[1, "HR.gompertz"], tests[1, "HR.doublings"]))
dev.off()

### Figure 2: survival from 200 days (a) and its companion survivorship-difference plot (b), as in Arends et al. 2026 Fig. 1b
surv <- read.table("output/survivorship_by_Tage.txt", sep = "\t", header = TRUE)
surv <- surv[pmin(surv[, "n.CD"], surv[, "n.HF"]) >= 20, ]          # plot only while both diets keep 20 or more mice
openSVG("output/Fig2_Survival_from200d.svg", width = 7, height = 8.6)
layout(matrix(1:2, ncol = 1), heights = c(1, 0.9))
par(mar = c(4.2, 4.6, 1.6, 1.2))
plot(c(200, 1200), c(0, 100), type = "n", xaxs = "i", yaxs = "i", axes = FALSE,
     xlab = "Age (days)", ylab = "Surviving, of those alive at 200 days (%)")
abline(h = seq(25, 100, 25), v = seq(400, 1200, 200), col = grid.col, lwd = 0.75)
axis(1, at = seq(200, 1200, 200), col = NA, col.ticks = ink2)
axis(2, at = seq(0, 100, 25), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (d in c("CD", "HF")) {
  s <- mdata[mdata[, "Diet"] == d & mdata[, "Age"] >= 200, ]
  km <- survfit(Surv(pmax(s[, "SetupAge"], 200), s[, "Age"], rep(1, nrow(s))) ~ 1)
  lines(c(200, km$time), 100 * c(1, km$surv), type = "s", col = col.diet[d], lwd = 1.5)
  t <- seq(200, 1200, 5)
  lines(t, 100 * exp(-(gompertz.H(t, primary[d, "a"], primary[d, "b"]) - gompertz.H(200, primary[d, "a"], primary[d, "b"]))),
        col = col.diet[d], lwd = 2, lty = 2)
  med <- median(s[, "Age"])
  text(med, 50, paste0(lab.diet[d], "\nmedian ", med, " d"), pos = ifelse(d == "CD", 4, 2), col = ink, cex = 0.8, offset = 0.6)
}
legend("topright", legend = c("Kaplan-Meier", "Gompertz fit"), lty = c(1, 2), lwd = c(1.5, 2), col = ink2,
       bty = "n", text.col = ink, cex = 0.85)
mtext("a", side = 3, line = 0.2, adj = -0.1, font = 2, cex = 1.2, col = ink)

par(mar = c(4.2, 4.6, 2.2, 1.2))
plot(c(200, 1200), c(-60, 60), type = "n", xaxs = "i", axes = FALSE,
     xlab = "T-age: mice alive at this age (days)", ylab = "Mean age at death vs both diets (days)")
abline(h = seq(-60, 60, 20), v = seq(400, 1200, 200), col = grid.col, lwd = 0.75)
abline(h = 0, col = ink2, lwd = 0.75)
axis(1, at = seq(200, 1200, 200), col = NA, col.ticks = ink2)
axis(2, at = seq(-60, 60, 20), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (d in c("CD", "HF")) {                                         # shading first, so no band hides a line
  m <- surv[, paste0("delta.", d)]; e <- surv[, paste0("sem.", d)]
  polygon(c(surv[, "Tage"], rev(surv[, "Tage"])), c(m + e, rev(m - e)), col = paste0(col.diet[d], "80"), border = NA)   # 50% shading, as in Arends et al.
}
for (d in c("CD", "HF")) {
  m <- surv[, paste0("delta.", d)]
  lines(surv[, "Tage"], m, col = col.diet[d], lwd = 2)
  text(215, m[1] + ifelse(d == "CD", 13, -13), lab.diet[d], adj = c(0, 0.5), col = ink, cex = 0.8)
}
nT <- surv[surv[, "Tage"] %in% c(395, 605, 800, 935), ]
text(nT[, "Tage"], 57, paste0(nT[, "n.CD"], " / ", nT[, "n.HF"]), cex = 0.7, col = ink2)
text(1005, 57, "mice alive (CD / HF)", adj = c(0, 0.5), cex = 0.7, col = ink2)
text(1190, -55, "Lines: mean; shading: \u00b11 s.e.m.", adj = c(1, 0.5), cex = 0.8, col = ink2)
mtext("b", side = 3, line = 0.6, adj = -0.1, font = 2, cex = 1.2, col = ink)
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

### Figure 4: bootstrap estimates of log2(R0) and MRDT
openSVG("output/Fig4_Bootstrap_R0_MRDT.svg", width = 6, height = 5)
par(mar = c(4.2, 4.6, 1.2, 1.2))
k <- log2(1000)                                                    # x axis: R0 per 1,000 mouse-days, log2 scale
plot(range(c(boot[, "log2R0.CD"], boot[, "log2R0.HF"])) + k, c(120, 190), type = "n", axes = FALSE,
     xlab = "R0, deaths per 1,000 mouse-days at age 0 (log2 scale)", ylab = "Mortality rate doubling time (days)")
abline(h = seq(120, 190, 10), col = grid.col, lwd = 0.75)
r0.ticks <- c(0.125, 0.15, 0.175, 0.2, 0.25, 0.3)
axis(1, at = log2(r0.ticks), labels = r0.ticks, col = NA, col.ticks = ink2); axis(2, at = seq(120, 190, 10), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (d in c("CD", "HF")) {
  points(boot[, paste0("log2R0.", d)] + k, boot[, paste0("MRDT.", d)], pch = 16, cex = 0.35, col = paste0(col.diet[d], "40"))
}
for (d in c("CD", "HF")) {
  points(primary[d, "log2R0"] + k, primary[d, "MRDT"], pch = 21, bg = col.diet[d], col = "white", cex = 1.6, lwd = 1.2)
}
legend("topright", legend = paste0(lab.diet, ": ", nrow(boot), " bootstrap fits"), pch = 21, pt.bg = col.diet, col = "white",
       pt.cex = 1.3, bty = "n", text.col = ink, cex = 0.85)
mtext(sprintf("Estimates of R0 and MRDT correlate at r = %.2f (CD) and %.2f (HF)",
              cor(boot[, "log2R0.CD"], log2(boot[, "MRDT.CD"])), cor(boot[, "log2R0.HF"], log2(boot[, "MRDT.HF"]))),
      side = 3, line = -4.4, adj = 0.03, cex = 0.75, col = ink2)
dev.off()
