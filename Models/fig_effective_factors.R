#
# fig_effective_factors.R
#
# copyright (c) 2026 - Rob Williams
#
# Figure: model predictions (Models/effective_factors.R) against the F1 data. Run Models/effective_factors.R first.
# Run from the repository root:  Rscript Models/fig_effective_factors.R
#
library(svglite)
sp <- "output/"
src <- readLines("Gompertz/MRDT_Secondary.R")
suppressWarnings(eval(parse(text = src[1:(grep("^tests <- c\\(\\); levels.out", src) - 1)])))
d <- h2.data(200)
life <- tapply(d$Age, d$Strain, mean)
gain <- sapply(unique(d$Strain[d$Class == "F1"]), function(s) {
  p <- f1.parents(s); unname(life[s] - mean(life[p]))
})
grp <- sapply(names(gain), function(s) if (all(f1.parents(s) %in% short.parents)) "Short" else "Long")
obs <- list(SxS = gain[grp == "Short"], LxL = gain[grp == "Long"])
print(round(sort(gain))); print(sapply(obs, mean))

m <- read.delim(paste0(sp, "Model_effective_factors.txt"))
get <- function(model, loci, stat) unlist(m[m$model == model & m$loci == loci & m$stat == stat, c("median", "p10", "p90")])

ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"
fontfile <- function(bold, italic) {
  f <- systemfonts::match_font("Arial", italic = italic, bold = bold)$path
  if (!grepl("arial", f, ignore.case = TRUE)) f <- systemfonts::match_font("Liberation Sans", italic = italic, bold = bold)$path
  list(alias = "Arial", file = f)
}
arial <- list(sans = list(plain = fontfile(FALSE, FALSE), bold = fontfile(TRUE, FALSE), italic = fontfile(FALSE, TRUE), bolditalic = fontfile(TRUE, TRUE)))
svglite(paste0(sp, "Model_effective_factors.svg"), width = 7.5, height = 3.9, user_fonts = arial, fix_text_size = FALSE)
par(family = "sans", col = ink, col.axis = ink2, col.lab = ink, fg = ink2, las = 1, mgp = c(2.6, 0.6, 0), tcl = -0.3, mfrow = c(1, 2), mar = c(5.2, 4.4, 1.4, 0.6))
cases <- list(c("A", 10), c("B", 10), c("A", 200), c("B", 200))
labs <- c("10 loci\nmultiply", "10 loci\nadd", "200 loci\nmultiply", "200 loci\nadd", "Observed")
# a: F1 gain over mid-parent
plot(c(0.5, 5.5), c(-50, 1050), type = "n", axes = FALSE, xlab = "", ylab = "F1 gain over mid-parent (days)")
abline(h = seq(0, 1000, 200), col = grid.col, lwd = 0.75); abline(h = 0, col = ink2, lwd = 0.75)
axis(2, at = seq(0, 1000, 200), col = NA, col.ticks = ink2, cex.axis = 0.85)
for (k in 1:5) mtext(labs[k], side = 1, at = k, line = 1.6, cex = 0.68, col = ink)
box(bty = "l", col = ink2)
for (i in 1:4) for (st in c("SxS", "LxL")) {
  v <- get(cases[[i]][1], cases[[i]][2], paste0("gain.", st)); x <- i + ifelse(st == "SxS", -0.12, 0.12)
  segments(x, v[2], x, v[3], col = ink2, lwd = 1.5)
  points(x, v[1], pch = 21, bg = if (st == "SxS") ink else "white", col = ink, cex = 1.2)
}
for (st in c("SxS", "LxL")) {
  x <- 5 + ifelse(st == "SxS", -0.12, 0.12)
  points(rep(x, length(obs[[st]])), obs[[st]], pch = 16, cex = 0.5, col = ink2)
  points(x, mean(obs[[st]]), pch = 21, bg = if (st == "SxS") ink else "white", col = ink, cex = 1.2)
}
legend("topleft", legend = c("Short x short F1s", "Long x long F1s"), pch = 21, pt.bg = c(ink, "white"), col = ink, bty = "n", cex = 0.75, text.col = ink)
mtext("a", side = 3, line = 0.2, adj = -0.2, font = 2, cex = 1.1, col = ink)
# b: MRDT by group
plot(c(0.5, 5.5), c(50, 345), type = "n", axes = FALSE, xlab = "", ylab = "MRDT, one per group (days)")
abline(h = seq(50, 300, 50), col = grid.col, lwd = 0.75)
axis(2, at = seq(50, 300, 50), col = NA, col.ticks = ink2, cex.axis = 0.85)
for (k in 1:5) mtext(labs[k], side = 1, at = k, line = 1.6, cex = 0.68, col = ink)
box(bty = "l", col = ink2)
obs.mrdt <- c(Short.Parents = 139.2, Short.F1 = 86.0, Long.Parents = 94.4, Long.F1 = 87.7)   # per-genotype levels (exploratory refit)
for (i in 1:5) for (st in c("Short", "Long")) {
  x <- i + ifelse(st == "Short", -0.14, 0.14)
  pv <- if (i < 5) get(cases[[i]][1], cases[[i]][2], paste0("MRDT.", st, ".Parents"))[1] else obs.mrdt[paste0(st, ".Parents")]
  fv <- if (i < 5) get(cases[[i]][1], cases[[i]][2], paste0("MRDT.", st, ".F1"))[1] else obs.mrdt[paste0(st, ".F1")]
  arrows(x, pv, x, fv, length = 0.05, col = ink2, lwd = 1.2)
  points(x, pv, pch = 22, bg = if (st == "Short") ink else "white", col = ink, cex = 1.1)
  points(x, fv, pch = 21, bg = if (st == "Short") ink else "white", col = ink, cex = 1.1)
}
legend("topleft", legend = c("Parents (square) to F1 (circle)", "filled: short-lived set", "open: long-lived set"), bty = "n", cex = 0.72, text.col = ink2)
mtext("b", side = 3, line = 0.2, adj = -0.2, font = 2, cex = 1.1, col = ink)
dev.off()
