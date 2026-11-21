#
# danny_model_check.R
#
# copyright (c) 2026 - Rob Williams
#
# Reproduces Danny Arends's actuarial strain-means maps (his Fig. 2, top two rows; QTL_Lifespan_05Nov2026.xlsx, sheets CD
# and HF) with the model in his code: lifespan.R of github.com/DannyArends/BxDLifeSpan, commit 363f3fc (9 November 2026),
# read on 21 November 2026 when Rob asked for a fork of his map code. Exploratory.
#   At each T-age, strains with at least 3 mice alive at T (age >= T); strain means of age at death rounded to whole days;
#   lm(strain mean ~ set-up class + genotype, weights = mice per strain), where the set-up class is the strain's mean
#   set-up age (rounded) cut into 180-day classes, and the genotype is coded B -1, H 0, D +1. Signed -log10 P of the
#   genotype term. No kinship.
#   The same regression without the set-up class is GN4AI/actuarial_compare.R's local check, which matches his maps only
#   to 620 days on high fat.
#
# Inputs not in git, in data/local/: Danny's workbook in Arends_Data_05Nov2026/ and the BXD.8 genotypes (sheet "BXD Geno
# v8 in GN with U" of BXD_final_Genotypes_DGA_RWW_21Dec2025_based_on_v050423.xlsx).
# Run from the repository root:  Rscript GN4AI/danny_model_check.R   (every 10th marker; about 3 minutes)
# Writes output/GN4AI/actuarial/danny_model_check.txt
#

library(readxl)

Tages <- seq(20, 770, by = 30)
geno <- as.data.frame(suppressMessages(suppressWarnings(read_excel("data/local/BXD_final_Genotypes_DGA_RWW_21Dec2025_based_on_v050423.xlsx",
                                                                  sheet = "BXD Geno v8 in GN with U", skip = 23))))
d <- read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM")[, 1:7]
colnames(d) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
d <- d[!is.na(d[, "EarTag"]), ]

sink("output/GN4AI/actuarial/danny_model_check.txt", split = TRUE)
cat("Danny's strain-means maps against his model refitted on Beni Mozhui's file (every 10th marker, autosomes and X)\n")
for (diet in c("CD", "HF")) {
  x <- as.data.frame(suppressMessages(read_excel("data/local/Arends_Data_05Nov2026/QTL_Lifespan_05Nov2026.xlsx", sheet = diet, col_names = FALSE)))
  k <- seq(2, nrow(x), by = 10); markers <- x[k, 1]; danny <- suppressWarnings(sapply(x[k, 6:31], as.numeric))
  G <- geno[match(markers, geno[, "Locus"]), ]
  cat("\n=====", diet, "\n")
  for (j in seq_along(Tages)) {
    a <- d[d[, "Diet"] == diet & d[, "Age"] >= Tages[j], ]
    n <- table(a[, "Strain"]); n <- n[n >= 3]; s <- names(n)[grep("BXD", names(n))]
    y <- round(sapply(s, function(z) mean(a[a[, "Strain"] == z, "Age"])), 0); w <- as.numeric(n[s])
    setup <- as.factor(cut(round(sapply(s, function(z) mean(a[a[, "Strain"] == z, "SetupAge"])), 0), seq(0, 1000, 180)))
    fit <- function(with.setup) sapply(seq_len(nrow(G)), function(i) {
      g <- as.numeric(factor(as.character(unlist(G[i, s])), levels = c("B", "H", "D"))) - 2
      f <- if (with.setup) lm(y ~ setup + g, weights = w) else lm(y ~ g, weights = w)
      if (is.na(coef(f)["g"])) return(NA)
      sign(coef(f)["g"]) * -log10(anova(f)[["Pr(>F)"]][if (with.setup) 2 else 1])
    })
    p1 <- fit(TRUE); p0 <- fit(FALSE)
    cat(sprintf("T%-4d %2d strains, set-up classes %-28s with set-up class: r = %.4f, largest difference %.4f; without: r = %.3f\n", Tages[j], length(s),
                paste(names(table(droplevels(setup))), table(droplevels(setup)), sep = ":", collapse = " "),
                cor(p1, danny[, j], use = "complete"), max(abs(p1 - danny[, j]), na.rm = TRUE), cor(p0, danny[, j], use = "complete")))
  }
}
sink()
