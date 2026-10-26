#
# Figures_Part3.R
#
# copyright (c) 2026 - Rob Williams
#
# Figures for Part 3 of the report (UM-HET3 Vita1a and Vita1b). Exploratory. Run first:
#   UMHET3/clean_table2.R, UMHET3/chr1_marker_check.R, UMHET3/vita1_site_check.R and Gompertz/MRDT_Secondary.R
# Conventions as in Gompertz/Figures_MRDT_Secondary.R: svglite with Arial labels as single text elements; log scales
# in base 2. Paternal D is orange and maternal B dark purple, as in Arends et al.; the haplotype each is compared with
# (paternal H, maternal C) is grey. UM-HET3 sites: JL black circles, UM teal triangles, UT magenta squares.
#
#  Fig8_UMHET3_Chr1_genotype_calls.svg  (a) fraction of paternal calls that are H at each proximal Chr 1 marker, by
#                                       site; (b) at 31.06 Mb, by the mother's haplotype at 24.0 Mb
#  Fig9_UMHET3_Vita1a_by_sex.svg        (a, b) mortality by paternal Vita1a haplotype, females and males (Table 2);
#                                       (c, d) the D / H mortality ratio by age window, by site
#  Fig10_BXD_vs_UMHET3_females.svg      (a) mortality of BXD chow females by Chr 1 haplotype and of UM-HET3 females by
#                                       paternal Vita1a haplotype; (b) the D / B and D / H mortality ratios by age window
#
# Run from the repository root:  Rscript UMHET3/Figures_Part3.R
#

library(svglite)

ink <- "#0b0b0b"; ink2 <- "#52514e"; grid.col <- "#e4e3df"
col.hap <- c(B = "#7d4598", D = "#ed8f22", H = "#8a8a8a", C = "#8a8a8a")
col.site <- c(JL = "#222222", UM = "#17898b", UT = "#c2185b"); pch.site <- c(JL = 21, UM = 24, UT = 22)
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
panel.letter <- function(l, adj = -0.18) mtext(l, side = 3, line = 0.2, adj = adj, font = 2, cex = 1.1, col = ink)

# Table 2 (clean copy): deaths and mouse-days by paternal haplotype in windows starting at 200 d
read.t2 <- function(sex) {
  read.delim(sprintf("data/umhet3/Table2/Vita1a_deathsIn15Dwindows_%s.txt", sex), check.names = FALSE)
}
t2.bins <- function(d, br) {
  start <- as.numeric(sub("-.*", "", d[["T-age"]]))
  do.call(rbind, lapply(c("H", "D"), function(k) {
    g <- if (k == "H") c("CH", "BH") else c("CD", "BD")
    dd <- rowSums(d[, g]); ex <- 15 * (rowSums(d[, paste0(g, "_alive")]) - dd / 2)
    w <- findInterval(start, br); ok <- start >= min(br) & start < max(br)
    data.frame(paternal = k, start = br[-length(br)], end = br[-1],
               deaths = tapply(dd[ok], factor(w[ok], 1:(length(br) - 1)), sum),
               exposure = tapply(ex[ok], factor(w[ok], 1:(length(br) - 1)), sum))
  }))
}
# Gompertz fit by sex from 200 d (one level per genotype, one slope per paternal haplotype); returns h(t) per 1,000
# mouse-days for each paternal haplotype, the geometric mean of its two genotypes
t2.fit <- function(d) {
  start <- as.numeric(sub("-.*", "", d[["T-age"]]))
  lt <- do.call(rbind, lapply(c("CH", "CD", "BH", "BD"), function(g) {
    data.frame(geno = g, age = start + 7.5, deaths = d[, g], atrisk = d[, paste0(g, "_alive")],
               exposure = 15 * (d[, paste0(g, "_alive")] - d[, g] / 2))
  }))
  lt$paternal <- substr(lt$geno, 2, 2); lt <- lt[lt$age >= 200 & lt$atrisk >= 20 & lt$exposure > 0, ]   # as in vita1a_gompertz.R
  m <- glm(deaths ~ geno + I(age / 100):paternal + offset(log(exposure)), family = poisson, data = lt)
  b <- coef(m)
  list(MRDT = c(H = unname(log(2) / b["I(age/100):paternalH"] * 100), D = unname(log(2) / b["I(age/100):paternalD"] * 100)),
       h = function(k, t) {
         gs <- if (k == "H") c("CH", "BH") else c("CD", "BD")
         nd <- data.frame(geno = rep(gs, each = length(t)), age = rep(t, 2), paternal = k, exposure = 1000)
         exp(rowMeans(matrix(log(predict(m, nd, type = "response")), ncol = 2)))
       })
}
ratio.ci <- function(d1, e1, d0, e0) {   # rate ratio (1 over 0) with a 95% CI from the Poisson counts
  r <- (d1 / e1) / (d0 / e0); se <- sqrt(1 / d1 + 1 / d0)
  cbind(ratio = r, lo = r * exp(-1.96 * se), hi = r * exp(1.96 * se))
}
hazard.axes <- function(ylim = c(0.0625, 32)) {
  doublings <- 2^(log2(ylim[1]):log2(ylim[2]))
  plot(c(200, 1250), ylim, type = "n", log = "y", xaxs = "i", yaxs = "i", axes = FALSE,
       xlab = "Age (days)", ylab = "Deaths per 1,000 mouse-days (log2 scale)", cex.lab = 0.9)
  abline(h = doublings, v = seq(400, 1200, 200), col = grid.col, lwd = 0.75)
  axis(1, at = seq(200, 1200, 200), col = NA, col.ticks = ink2, cex.axis = 0.85)
  axis(2, at = doublings, labels = sapply(doublings, function(v) if (v < 1) format(v) else format(v)), col = NA, col.ticks = ink2, cex.axis = 0.75)
  box(bty = "l", col = ink2)
}
ratio.axes <- function(ylim = c(0.25, 4), xlab = "Age window (days)") {
  plot(c(200, 1100), ylim, type = "n", log = "y", xaxs = "i", yaxs = "i", axes = FALSE, xlab = xlab, ylab = "", cex.lab = 0.9)
  ticks <- 2^(log2(ylim[1]):log2(ylim[2]))
  abline(h = ticks, col = grid.col, lwd = 0.75); abline(h = 1, col = ink2, lwd = 1)
  axis(1, at = c(200, 500, 680, 800, 920, 1100), col = NA, col.ticks = ink2, cex.axis = 0.8)
  axis(2, at = ticks, labels = format(ticks), col = NA, col.ticks = ink2, cex.axis = 0.8)
  box(bty = "l", col = ink2)
}
br.ratio <- c(200, 500, 680, 800, 920, 1100)

### Figure 8: genotype calls on proximal Chr 1
bysite <- read.delim("output/UMHET3_markers_chr1_by_site.txt")
t31 <- read.delim("output/UMHET3_31Mb_father_by_mother.txt")
openSVG("output/Fig8_UMHET3_Chr1_genotype_calls.svg", width = 7.5, height = 3.6)
layout(matrix(1:2, 1), widths = c(2.1, 1)); par(mar = c(4, 4.4, 2.2, 0.8))
plot(c(0, 45), c(0, 1), type = "n", xaxs = "i", yaxs = "i", axes = FALSE, xlab = "Chr 1 position (Mb)",
     ylab = "Paternal calls that are H (fraction)", cex.lab = 0.9)
rect(3.0, 0, 8.0, 1, col = "#f1efe9", border = NA); rect(16.0, 0, 31.1, 1, col = "#f1efe9", border = NA)
text(5.5, 0.97, "Vita1a", cex = 0.75, col = ink2); text(23.5, 0.97, "Vita1b", cex = 0.75, col = ink2)
abline(h = seq(0.2, 0.8, 0.2), col = grid.col, lwd = 0.75); abline(h = 0.5, col = ink2, lwd = 1, lty = 2)
axis(1, at = seq(0, 45, 5), col = NA, col.ticks = ink2, cex.axis = 0.8)
axis(2, at = seq(0, 1, 0.2), col = NA, col.ticks = ink2, cex.axis = 0.8); box(bty = "l", col = ink2)
mat.only <- unique(bysite$Mb[bysite$Mb < 45 & bysite$matC + bysite$matB > 0 & bysite$patH + bysite$patD == 0])
segments(mat.only, 0, mat.only, 0.04, col = ink2, lwd = 1.2)
text(16, 0.07, "ticks: markers that call only the mother", cex = 0.65, col = ink2, adj = c(0.5, 0))
for (s in c("JL", "UM", "UT")) {
  p <- bysite[bysite$site == s & bysite$Mb < 45 & bysite$patH + bysite$patD >= 30, ]
  dx <- c(JL = -0.35, UM = 0, UT = 0.35)[s]
  points(p$Mb + dx, p$patH.frac, pch = pch.site[s], bg = paste0(col.site[s], "CC"), col = "white", lwd = 0.6,
         cex = 0.6 + 0.025 * sqrt(p$patH + p$patD))
}
legend("bottomright", legend = c("JL", "UM", "UT"), pch = pch.site, pt.bg = col.site, col = "white", pt.cex = 1.2,
       bty = "n", cex = 0.75, text.col = ink, inset = c(0.01, 0.08), title = "Site", title.col = ink2)
panel.letter("a", adj = -0.12)
par(mar = c(4, 3.6, 2.2, 0.6))
plot(c(0.5, 3.5), c(0, 1), type = "n", xaxs = "i", yaxs = "i", axes = FALSE, xlab = "Site",
     ylab = "Paternal calls that are H at 31.06 Mb", cex.lab = 0.85)
abline(h = seq(0.2, 0.8, 0.2), col = grid.col, lwd = 0.75); abline(h = 0.5, col = ink2, lwd = 1, lty = 2)
axis(1, at = 1:3, labels = c("JL", "UM", "UT"), col = NA, col.ticks = ink2, cex.axis = 0.8)
axis(2, at = seq(0, 1, 0.2), col = NA, col.ticks = ink2, cex.axis = 0.8); box(bty = "l", col = ink2)
for (i in 1:3) for (mo in c("B", "C")) {
  r <- t31[t31$site == c("JL", "UM", "UT")[i] & t31$mother == mo, ]; x <- i + ifelse(mo == "B", -0.2, 0.2)
  points(x, r$fracH, pch = 21, bg = col.hap[mo], col = "white", cex = 1.6, lwd = 0.8)
  text(x, r$fracH + ifelse(mo == "B" & i == 1, 0.07, -0.07), r$father.H + r$father.D, cex = 0.6, col = ink2)
}
legend("bottomleft", legend = c("Mother B (C57BL/6J)", "Mother C (BALB/cByJ)"), pch = 21, pt.bg = col.hap[c("B", "C")],
       col = "white", pt.cex = 1.3, bty = "n", cex = 0.68, text.col = ink, inset = c(0.0, 0.01))
panel.letter("b", adj = -0.3)
dev.off()

### Figure 9: Vita1a by sex
site.bins <- read.delim("output/UMHET3_Vita1a_binned_by_site.txt")
openSVG("output/Fig9_UMHET3_Vita1a_by_sex.svg", width = 7.5, height = 6.6)
par(mfrow = c(2, 2), mar = c(4, 4.4, 1.6, 0.8))
lab.sex <- c(female = "females", male = "males"); fits <- list()
for (sx in c("female", "male")) {
  d <- read.t2(sx); f <- t2.fit(d); fits[[sx]] <- f; bn <- t2.bins(d, seq(200, 1280, 60))
  hazard.axes()
  leg <- c()
  for (k in c("H", "D")) {
    p <- bn[bn$paternal == k & bn$deaths > 0 & bn$exposure > 15 * 20, ]
    points((p$start + p$end) / 2, 1000 * p$deaths / p$exposure, pch = 21, bg = paste0(col.hap[k], "B3"), col = "white",
           lwd = 0.8, cex = 0.4 + 0.15 * sqrt(p$deaths))
    t <- seq(230, max((p$start + p$end) / 2), 5); lines(t, f$h(k, t), col = col.hap[k], lwd = 2)
    n <- if (k == "H") d$CH_alive[1] + d$BH_alive[1] else d$CD_alive[1] + d$BD_alive[1]
    leg <- c(leg, sprintf("Paternal %s, n = %s: MRDT %.0f d", k, format(n, big.mark = ","), f$MRDT[k]))
  }
  legend("topleft", legend = leg, col = col.hap[c("H", "D")], lwd = 2, pch = 21, pt.bg = col.hap[c("H", "D")], pt.cex = 1,
         bty = "n", text.col = ink, cex = 0.75, inset = c(0.01, 0.01))
  text(1235, 0.08, paste("UM-HET3", lab.sex[sx], "(Table 2, all sites)"), adj = c(1, 0), cex = 0.75, col = ink2)
  panel.letter(c(female = "a", male = "b")[sx])
}
for (sx in c("female", "male")) {
  ratio.axes(c(0.25, 4)); title(ylab = "Mortality ratio, paternal D / H (log2 scale)", cex.lab = 0.85, line = 2.6)
  b2 <- t2.bins(read.t2(sx), br.ratio); h <- b2[b2$paternal == "H", ]; dd <- b2[b2$paternal == "D", ]
  r <- ratio.ci(dd$deaths, dd$exposure, h$deaths, h$exposure); mid <- (h$start + h$end) / 2
  lines(mid, r[, "ratio"], col = "#9a9a9a", lwd = 2); points(mid, r[, "ratio"], pch = 15, col = "#9a9a9a", cex = 0.8)
  for (s in c("JL", "UM+UT")) {
    b <- site.bins[site.bins$sites == s & site.bins$sex == substr(toupper(sx), 1, 1), ]
    h <- b[b$paternal == "H", ]; dd <- b[b$paternal == "D", ]
    r <- ratio.ci(dd$deaths, dd$exposure, h$deaths, h$exposure); x <- mid + ifelse(s == "JL", -12, 12)
    k <- if (s == "JL") "JL" else "UM"
    segments(x, pmax(r[, "lo"], 0.25), x, pmin(r[, "hi"], 4), col = col.site[k], lwd = 1)
    points(x, r[, "ratio"], pch = pch.site[k], bg = col.site[k], col = "white", cex = 1.2, lwd = 0.6)
  }
  legend("topleft", legend = c("Table 2, all sites", "JL, raw marker calls", "UM + UT, raw marker calls"),
         pch = c(15, 21, 24), col = c("#9a9a9a", "white", "white"), pt.bg = c(NA, col.site["JL"], col.site["UM"]),
         lwd = c(2, NA, NA), pt.cex = c(0.8, 1.2, 1.2), bty = "n", cex = 0.72, text.col = ink, inset = c(0.01, 0.01))
  text(1090, 0.27, paste("UM-HET3", lab.sex[sx]), adj = c(1, 0), cex = 0.75, col = ink2)
  panel.letter(c(female = "c", male = "d")[sx])
}
dev.off()

### Figure 10: BXD chow females against UM-HET3 females
bxd <- read.delim("output/MRDT_secondary_binned_60d.txt"); bxd <- bxd[bxd$test == "H1" & bxd$diet == "CD", ]
tests <- read.delim("output/MRDT_secondary_tests.txt"); s4 <- tests[tests$test == "S4 Chr1 D vs B, CD only" & tests$from == 200, ]
lev <- read.delim("output/MRDT_secondary_levels.txt"); lev <- lev[lev$test == "S4 Chr1 D vs B, CD only" & lev$from == 200, ]
openSVG("output/Fig10_BXD_vs_UMHET3_females.svg", width = 7.5, height = 3.9)
par(mfrow = c(1, 2), mar = c(4, 4.4, 1.6, 0.8))
hazard.axes(c(0.0625, 256))
for (k in c("B", "D")) {
  p <- bxd[bxd$class == k & bxd$deaths > 0 & bxd$atrisk >= 10, ]
  points(p$mid, 1000 * p$rate, pch = 21, bg = paste0(col.hap[k], "B3"), col = "white", lwd = 0.8, cex = 0.4 + 0.15 * sqrt(p$deaths))
  mrdt <- if (k == "B") s4$MRDT1 else s4$MRDT2; h600 <- lev$h600.per1000[lev$class == k]
  t <- seq(230, max(p$mid), 5); lines(t, h600 * 2^((t - 600) / mrdt), col = col.hap[k], lwd = 2)
}
f <- fits[["female"]]; fe <- read.t2("female"); bn <- t2.bins(fe, seq(200, 1280, 60))
for (k in c("H", "D")) {
  p <- bn[bn$paternal == k & bn$deaths > 0 & bn$exposure > 15 * 20, ]
  points((p$start + p$end) / 2, 1000 * p$deaths / p$exposure, pch = 24, bg = "white", col = col.hap[k], lwd = 1.2,
         cex = 0.4 + 0.15 * sqrt(p$deaths))
  t <- seq(230, max((p$start + p$end) / 2), 5); lines(t, f$h(k, t), col = col.hap[k], lwd = 2, lty = 2)
}
legend("topleft", bty = "n", cex = 0.66, text.col = ink, inset = c(0.01, 0.01),
       legend = c(sprintf("BXD chow, B strains, n = %d: MRDT %.0f d", s4$n1, s4$MRDT1),
                  sprintf("BXD chow, D strains, n = %d: MRDT %.0f d", s4$n2, s4$MRDT2),
                  sprintf("UM-HET3, paternal H, n = %s: MRDT %.0f d", format(fe$CH_alive[1] + fe$BH_alive[1], big.mark = ","), f$MRDT["H"]),
                  sprintf("UM-HET3, paternal D, n = %d: MRDT %.0f d", fe$CD_alive[1] + fe$BD_alive[1], f$MRDT["D"])),
       col = col.hap[c("B", "D", "H", "D")], pch = c(21, 21, 24, 24), pt.bg = c(col.hap[c("B", "D")], "white", "white"),
       lwd = 2, lty = c(1, 1, 2, 2), pt.cex = 1)
text(1235, 0.08, "Females", adj = c(1, 0), cex = 0.75, col = ink2)
panel.letter("a")
ratio.axes(c(0.25, 4)); title(ylab = "Mortality ratio, D / other haplotype (log2)", cex.lab = 0.85, line = 2.6)
mid <- (head(br.ratio, -1) + br.ratio[-1]) / 2
w <- findInterval(bxd$start, br.ratio); ok <- bxd$start >= 200 & bxd$start < 1100
agg <- function(k, v) tapply(bxd[ok & bxd$class == k, v], w[ok & bxd$class == k], sum)
r <- ratio.ci(agg("D", "deaths"), agg("D", "exposure"), agg("B", "deaths"), agg("B", "exposure"))
segments(mid - 10, r[, "lo"], mid - 10, pmin(r[, "hi"], 4), col = ink, lwd = 1)
points(mid - 10, r[, "ratio"], pch = 21, bg = ink, col = "white", cex = 1.2, lwd = 0.6)
b2 <- t2.bins(read.t2("female"), br.ratio); h <- b2[b2$paternal == "H", ]; dd <- b2[b2$paternal == "D", ]
r <- ratio.ci(dd$deaths, dd$exposure, h$deaths, h$exposure)
segments(mid + 10, r[, "lo"], mid + 10, r[, "hi"], col = "#8a8a8a", lwd = 1)
points(mid + 10, r[, "ratio"], pch = 24, bg = "white", col = "#6e6e6e", cex = 1.2, lwd = 1.2)
legend("topleft", legend = c("BXD chow: D strains / B strains", "UM-HET3: paternal D / H (Table 2)"), pch = c(21, 24),
       pt.bg = c(ink, "white"), col = c("white", "#6e6e6e"), pt.cex = 1.2, bty = "n", cex = 0.72, text.col = ink,
       inset = c(0.01, 0.01))
text(1090, 0.27, "Females", adj = c(1, 0), cex = 0.75, col = ink2)
panel.letter("b")
dev.off()
cat("Wrote Figs 8-10 to output/\n")
