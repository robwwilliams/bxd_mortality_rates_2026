#
# vita1_site_check.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory: do the Vita1a and Vita1b effects on the level and slope of mortality hold where the paternal calls are
# clean? chr1_marker_check.R finds that the paternal calls at 1_3010274 and 1_31062737 are biased toward H at UM and UT
# but not at JL. Here each mouse's paternal haplotype is taken from the raw marker calls of the cross file, and
# individual ages at death are fitted by maximum likelihood (Gompertz/gompertz.R), separately by sex and site.
#   Vita1a, father: the calls at 1_3010272, 1_3010274 and 1_4344820 (3.0-4.3 Mb), kept when they agree.
#   Vita1b, father: 1_31062737 and 1_31062758 (31.06 Mb, the nearest paternal markers to the 24.0 Mb peak);
#           mother: 1_24042124 (24.0 Mb).
# Mice that died at 200 d or later, each at risk from 200 d. All drug groups pooled (genotype is independent of drug).
# Each site x cohort has its own level (the miscalls cluster by cohort, and cohorts differ in lifespan); each genotype
# class has one slope per sex. Mortality ratios are geometric means over the cohorts, weighted by their mice.
#
# Run: Rscript UMHET3/vita1_site_check.R <S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr>
# Writes output/UMHET3_Vita1_site_check.txt
#

source("Gompertz/gompertz.R")

x <- read.csv(commandArgs(trailingOnly = TRUE)[1], header = FALSE, colClasses = "character", row.names = 1)
g <- x[-(1:10), -(1:2)]
mice <- data.frame(sex = ifelse(unlist(x["sex", -(1:2)]) == "0", "F", "M"),
                   site = c("1.0" = "JL", "2.0" = "UM", "3.0" = "UT")[unlist(x["site", -(1:2)])],
                   age = as.numeric(unlist(x["longevity", -(1:2)])))
mice$cohort <- paste(mice$site, unlist(x["cohort", -(1:2)]))
pat <- function(mk) { v <- unlist(g[mk, ]); ifelse(v %in% c("7", "1", "2"), "H", ifelse(v %in% c("8", "3", "4"), "D", NA)) }
mat <- function(mk) { v <- unlist(g[mk, ]); ifelse(v %in% c("5", "1", "3"), "C", ifelse(v %in% c("6", "2", "4"), "B", NA)) }
agree <- function(...) {   # the call shared by all markers that called the mouse; NA if none called it or they disagree
  v <- cbind(...)
  apply(v, 1, function(z) { z <- z[!is.na(z)]; if (length(z) > 0 && all(z == z[1])) z[1] else NA })
}
mice$vita1a.pat <- agree(pat("1_3010272"), pat("1_3010274"), pat("1_4344820"))
mice$vita1b.pat <- agree(pat("1_31062737"), pat("1_31062758"))
mice$vita1b.mat <- mat("1_24042124")
mice$vita1b.BD <- ifelse(is.na(mice$vita1b.pat) | is.na(mice$vita1b.mat), NA,
                         ifelse(mice$vita1b.mat == "B" & mice$vita1b.pat == "D", "BD", "other"))

out <- c()
fit <- function(d, class, levels, label) {
  d <- d[!is.na(d[, class]) & !is.na(d$age) & d$age >= 200, ]
  for (sx in c("F", "M")) {
    s <- d[d$sex == sx, ]
    both <- names(which(tapply(s[, class], s$cohort, function(z) all(levels %in% z))))   # cohorts with both classes
    s <- s[s$cohort %in% both, ]; cl <- factor(s[, class], levels = levels)
    cmp <- gompertz.classes.compare(s$age, rep(200, nrow(s)), s$cohort, cl)
    f1 <- cmp$fits[[1]]; f2 <- cmp$fits[[2]]; w <- as.numeric(table(s$cohort)[both])
    ratio <- function(t) exp(weighted.mean(log(f2$a[both] * exp(f2$b * t) / (f1$a[both] * exp(f1$b * t))), w))
    out <<- rbind(out, data.frame(test = label, sex = sx, cohorts = length(both), n1 = f1$n, n2 = f2$n,
                                  frac.class2 = round(f2$n / (f1$n + f2$n), 3),
                                  MRDT1 = round(f1$MRDT), MRDT2 = round(f2$MRDT),
                                  ratio600 = round(ratio(600), 2), ratio860 = round(ratio(860), 2),
                                  chisq.slope = round(unname(cmp$lrt["chisq"]), 2), p.slope = signif(unname(cmp$lrt["p"]), 2)))
  }
}
for (st in list("JL", c("UM", "UT"), c("JL", "UM", "UT"))) {
  d <- mice[mice$site %in% st, ]; nm <- paste(st, collapse = "+")
  fit(d, "vita1a.pat", c("H", "D"), paste(nm, "Vita1a paternal D / H"))
  fit(d, "vita1b.BD", c("other", "BD"), paste(nm, "Vita1b BD / other"))
}
# Both sexes together: the sum of the two 1-df likelihood-ratio statistics, on 2 df
comb <- aggregate(chisq.slope ~ test, out, sum); comb$p.2df <- signif(pchisq(comb$chisq.slope, 2, lower.tail = FALSE), 2)
print(out, row.names = FALSE); cat("\nSlope change in either sex (2 df):\n"); print(comb, row.names = FALSE)
write.table(out, "output/UMHET3_Vita1_site_check.txt", sep = "\t", quote = FALSE, row.names = FALSE)

# Deaths and mouse-days by age window, Vita1a paternal haplotype, for the figures (Fig. 9)
br <- c(200, 500, 680, 800, 920, 1100)
binned <- c()
for (st in list("JL", c("UM", "UT"))) for (sx in c("F", "M")) for (k in c("H", "D")) {
  a <- mice$age[mice$site %in% st & mice$sex == sx & mice$vita1a.pat %in% k & !is.na(mice$age) & mice$age >= 200]
  binned <- rbind(binned, data.frame(sites = paste(st, collapse = "+"), sex = sx, paternal = k, start = head(br, -1), end = br[-1],
                                     deaths = sapply(1:(length(br) - 1), function(i) sum(a >= br[i] & a < br[i + 1])),
                                     exposure = sapply(1:(length(br) - 1), function(i) sum(pmin(pmax(a - br[i], 0), br[i + 1] - br[i])))))
}
write.table(binned, "output/UMHET3_Vita1a_binned_by_site.txt", sep = "\t", quote = FALSE, row.names = FALSE)
