#
# Figures_terminal_decline.R
#
# copyright (c) 2026 - Rob Williams
#
# Fig. 12 for the terminal-decline analysis (notes/PLAN_terminal_decline.md). Run BodyWeight/terminal_decline.R first.
#   a  BXD body weight aligned on death, as a fraction of each mouse's peak, by diet
#   b  strain-mean morbidity span against strain-mean lifespan, by diet (Q1)
#   c  mean age at onset of terminal decline and mean morbidity span, by group (Q2, Q3)
#   d  per diem cost per mouse, free until 500 days: pension days and the decline surcharge (s = 4) (Q4)
#
# Run from the repository root:  Rscript BodyWeight/Figures_terminal_decline.R
#

library(svglite)

col.diet <- c(CD = "#a86a28", HF = "#2a78d6"); col.par <- "#e87ba4"; col.f1 <- "#008300"
ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"
fontfile <- function(bold, italic) {
  f <- systemfonts::match_font("Arial", italic = italic, bold = bold)$path
  if (!grepl("arial", f, ignore.case = TRUE)) f <- systemfonts::match_font("Liberation Sans", italic = italic, bold = bold)$path
  return(list(alias = "Arial", file = f))
}
arial <- list(sans = list(plain = fontfile(FALSE, FALSE), bold = fontfile(TRUE, FALSE),
                          italic = fontfile(FALSE, TRUE), bolditalic = fontfile(TRUE, TRUE)))

d <- read.table("output/Terminal_decline_by_mouse.txt", sep = "\t", header = TRUE, quote = "")
ww <- read.table("output/Terminal_decline_weighings.txt", sep = "\t", header = TRUE, quote = "")
tests <- read.table("output/Terminal_decline_tests.txt", sep = "\t", header = TRUE, quote = "")

svglite("output/Fig12_Terminal_decline.svg", width = 7.5, height = 6.8, user_fonts = arial, fix_text_size = FALSE)
par(family = "sans", col = ink, col.axis = ink2, col.lab = ink, fg = ink2, las = 1, mgp = c(2.6, 0.6, 0), tcl = -0.3)
layout(matrix(1:4, 2, byrow = TRUE))

# a: weight aligned on death, BXD strains
par(mar = c(4.2, 4.6, 1.8, 1))
br <- c(0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 400)
plot(c(400, 0), c(0.6, 1.1), xlim = c(400, 0), type = "n", axes = FALSE, xaxs = "i",
     xlab = "Days before death", ylab = "Body weight / peak")
abline(h = seq(0.6, 1.1, 0.1), v = seq(0, 400, 100), col = grid.col, lwd = 0.75)
axis(1, at = seq(0, 400, 100), col = NA, col.ticks = ink2); axis(2, at = seq(0.6, 1.1, 0.1), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (diet in c("CD", "HF")) {
  x <- ww[ww[, "Type"] == "BXD" & ww[, "Diet"] == diet, ]
  b <- cut(x[, "before"], br, right = FALSE)
  q <- do.call(rbind, lapply(split(x[, "rel"], b), quantile, c(0.25, 0.5, 0.75)))
  mid <- (head(br, -1) + br[-1]) / 2
  polygon(c(mid, rev(mid)), c(q[, 1], rev(q[, 3])), col = paste0(col.diet[diet], "40"), border = NA)
  lines(mid, q[, 2], col = col.diet[diet], lwd = 2)
  points(mid, q[, 2], pch = 21, bg = col.diet[diet], col = "white", cex = 1)
}
abline(h = 0.9, lty = 2, col = ink2)
text(395, 0.885, "90% of peak", adj = c(0, 1), cex = 0.7, col = ink2)
legend("bottomleft", legend = c("Chow (CD)", "High fat (HF)"), col = col.diet, lwd = 2, bty = "n", cex = 0.8, text.col = ink)
mtext("a", side = 3, line = 0.4, adj = -0.22, font = 2, cex = 1.2, col = ink)

# b: strain-mean morbidity span against strain-mean lifespan (strains with at least 6 mice)
par(mar = c(4.2, 4.6, 1.8, 1))
plot(c(350, 1000), c(0, 345), type = "n", axes = FALSE, xaxs = "i", yaxs = "i",
     xlab = "Strain mean age at death (days)", ylab = "Strain mean morbidity span (days)")
abline(h = seq(0, 300, 50), v = seq(400, 1000, 100), col = grid.col, lwd = 0.75)
axis(1, at = seq(400, 1000, 100), col = NA, col.ticks = ink2); axis(2, at = seq(0, 300, 50), col = NA, col.ticks = ink2)
box(bty = "l", col = ink2)
for (diet in c("CD", "HF")) {
  x <- d[d[, "Type"] == "BXD" & d[, "Diet"] == diet, ]
  ok <- names(which(table(x[, "Genotype"]) >= 6)); x <- x[x[, "Genotype"] %in% ok, ]
  s <- aggregate(cbind(Death, span) ~ Genotype, x, mean)
  points(s[, "Death"], s[, "span"], pch = 21, bg = paste0(col.diet[diet], "B3"), col = "white", lwd = 0.6, cex = 1.1)
  f <- lm(span ~ Death, s); xx <- range(s[, "Death"])
  lines(xx, predict(f, data.frame(Death = xx)), col = col.diet[diet], lwd = 2)
}
sl <- tests[tests[, "question"] == "Q1 span ~ lifespan, BXD strains (days per day)" & tests[, "subset"] == "all", ]
sl <- sl[sl[, "measure"] %in% c("span CD", "span HF"), ]
legend("topleft", legend = sprintf("%s: %.0f d per 100 d (P = %.2g)", c("Chow", "High fat"), 100 * sl[, "estimate"], sl[, "p"]),
       pch = 21, pt.bg = col.diet, col = "white", lwd = 2, lty = 1, bty = "n", cex = 0.72, text.col = ink)
mtext("b", side = 3, line = 0.4, adj = -0.22, font = 2, cex = 1.2, col = ink)

# c, d: groups
grp <- list("BXD, chow" = d[, "Type"] == "BXD" & is.na(d[, "Set"]) & d[, "Diet"] == "CD",
            "BXD, high fat" = d[, "Type"] == "BXD" & is.na(d[, "Set"]) & d[, "Diet"] == "HF",
            "Short-lived parents" = d[, "Type"] == "BXD" & d[, "Set"] %in% "Short",
            "Short x short F1s" = d[, "Type"] == "F1" & d[, "Set"] %in% "Short",
            "Long-lived parents" = d[, "Type"] == "BXD" & d[, "Set"] %in% "Long",
            "Long x long F1s" = d[, "Type"] == "F1" & d[, "Set"] %in% "Long")
gcol <- c(col.diet, col.par, col.f1, col.par, col.f1)
lab <- sub(" x ", " × ", names(grp))
y <- c(6.2, 5.2, 3.7, 2.7, 1.2, 0.2)
onset <- sapply(grp, function(k) mean(d[k, "Death"] - d[k, "span"])); span <- sapply(grp, function(k) mean(d[k, "span"]))
pension <- sapply(grp, function(k) mean(d[k, "pension"])); sur <- sapply(grp, function(k) mean(4 * d[k, "decline"]))
nm <- sapply(grp, sum)

par(mar = c(4.2, 8.6, 2.8, 1))
plot(c(0, 900), c(-0.4, 6.8), type = "n", axes = FALSE, xaxs = "i", yaxs = "i", xlab = "Mean age (days)", ylab = "")
abline(v = seq(0, 900, 100), col = grid.col, lwd = 0.75)
axis(1, at = seq(0, 900, 300), col = NA, col.ticks = ink2); axis(2, at = y, labels = lab, tick = FALSE, cex.axis = 0.8, col.axis = ink)
box(bty = "l", col = ink2)
rect(0, y - 0.32, onset, y + 0.32, col = paste0(gcol, "40"), border = NA)
rect(onset, y - 0.32, onset + span, y + 0.32, col = gcol, border = NA)
text(onset + span + 12, y, sprintf("%.0f d", span), adj = c(0, 0.5), cex = 0.7, col = ink)
abline(v = 500, lty = 2, col = ink2)
legend(x = 0, y = 7.75, legend = c("before decline", "in decline"), fill = c("#8a8a8a40", "#8a8a8a"), border = NA, bty = "n",
       cex = 0.7, text.col = ink, horiz = TRUE, xpd = NA)
mtext("c", side = 3, line = 1.4, adj = -0.55, font = 2, cex = 1.2, col = ink)

plot(c(0, 1000), c(-0.4, 6.8), type = "n", axes = FALSE, xaxs = "i", yaxs = "i", xlab = "Per diem cost per mouse (units)", ylab = "")
abline(v = seq(0, 1000, 250), col = grid.col, lwd = 0.75)
axis(1, at = seq(0, 1000, 250), col = NA, col.ticks = ink2); axis(2, at = y, labels = lab, tick = FALSE, cex.axis = 0.8, col.axis = ink)
box(bty = "l", col = ink2)
rect(0, y - 0.32, pension, y + 0.32, col = paste0(gcol, "40"), border = NA)
rect(pension, y - 0.32, pension + sur, y + 0.32, col = gcol, border = NA)
text(pension + sur + 10, y, sprintf("%.0f", pension + sur), adj = c(0, 0.5), cex = 0.7, col = ink)
legend(x = 0, y = 7.75, legend = c("days alive after 500", "4 × days in decline"), fill = c("#8a8a8a40", "#8a8a8a"), border = NA,
       bty = "n", cex = 0.7, text.col = ink, horiz = TRUE, xpd = NA)
mtext("d", side = 3, line = 1.4, adj = -0.55, font = 2, cex = 1.2, col = ink)
dev.off()
cat("Mice per group:", paste(names(nm), nm, sep = " = ", collapse = "; "), "\n")
