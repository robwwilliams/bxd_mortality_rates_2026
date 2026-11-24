#
# NAM_by_Vita1_mouse_level.R - A replication of the mouse-level analysis of nicotinamide by Vita1 genotype in the R01
# resubmission of Mozhui, Roy and Bajwa (June 2026, Pilot Data, Figs 5 and 6), from its description
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026. Rob: "Yes, Beni did a mouse level analysis.
# See if you can replicate her work. I suspect it will be on her GitHub too." Her code is not on GitHub (squirrelB holds
# only BXD-Diet-Gompertz), so this follows the grant's text and legends:
#   Fig 5: "Strong GxD effects of Vita1a and Vita1b on NAM addition to the HFD (mean ± s.e.). The B genotype has a positive
#          effect, whereas the D genotype has a negative effect."
#   Fig 6: "Effect of diet on lifespan stratified by genotype at Vita1b. Tukey HSD post hoc comparisons."
#   - Data: her file, data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv (BXD females on CD, HF and HF + 1% NAM).
#   - Genotypes: each mouse's strain call at Vita1a (rsm10000000010, 5.02 Mb) and Vita1b (rsm10000000521, 23.52 Mb). Her
#     markers are not stated; these are the BXD peaks.
#   - Mouse-level: two-way ANOVA, age at death ~ diet x genotype (HF and NAM), and Tukey HSD of diet within each Vita1b
#     genotype (CD, HF, NAM); all vivaria (as the grant reads) and TSRB alone.
#   - Beside it: the same interaction with a random intercept per strain, and with genotypes permuted among strains (the
#     strain as the unit).
# Writes output/NAM_by_Vita1_mouse_level.txt
#   Rscript Gompertz/NAM_by_Vita1_mouse_level.R
#

library(lme4)
set.seed(20261124)
d <- read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM")[, 1:7]
colnames(d) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
d <- d[!is.na(d$EarTag) & d$Diet %in% c("CD", "HF", "NAM") & !is.na(as.numeric(d$Age)), ]; d$Age <- as.numeric(d$Age)
g <- read.table("../BxDLifeSpan/data/BXD_current_rev050423.geno", sep = "\t", skip = 23, header = TRUE, na.strings = c("U", "", "NA"), check.names = FALSE)
rownames(g) <- g$Locus
loci <- c(Vita1a = "rsm10000000010", Vita1b = "rsm10000000521")

sink("output/NAM_by_Vita1_mouse_level.txt", split = TRUE)
cat("Replication of the grant's mouse-level analysis of NAM by Vita1 genotype (Figs 5 and 6), from Beni Mozhui's data file\n")
for(where in c("all vivaria", "TSRB")){
  x <- d[d$Strain %in% colnames(g), ]; if(where == "TSRB") x <- x[x$Vivarium == 3, ]
  cat(sprintf("\n==== %s: %s\n", where, paste(sprintf("%s %d mice", names(table(x$Diet)), table(x$Diet)), collapse = ", ")))
  for(l in names(loci)){
    x$G <- as.character(unlist(g[loci[l], x$Strain])); y <- x[x$G %in% c("B", "D"), ]
    cat(sprintf("\n%s: mean age at death ± s.e. (mice)\n", l))
    for(arm in c("CD", "HF", "NAM")) cat(sprintf("  %-3s  B %4.0f ± %2.0f (%3d)   D %4.0f ± %2.0f (%3d)\n", arm,
      mean(y$Age[y$Diet == arm & y$G == "B"]), sd(y$Age[y$Diet == arm & y$G == "B"]) / sqrt(sum(y$Diet == arm & y$G == "B")), sum(y$Diet == arm & y$G == "B"),
      mean(y$Age[y$Diet == arm & y$G == "D"]), sd(y$Age[y$Diet == arm & y$G == "D"]) / sqrt(sum(y$Diet == arm & y$G == "D")), sum(y$Diet == arm & y$G == "D")))
    z <- y[y$Diet %in% c("HF", "NAM"), ]
    a <- anova(lm(Age ~ Diet * G, z))
    f1 <- lmer(Age ~ Diet * G + (1 | Strain), z, REML = FALSE); f0 <- lmer(Age ~ Diet + G + (1 | Strain), z, REML = FALSE)
    st <- unique(z$Strain); gs <- setNames(as.character(unlist(g[loci[l], st])), st)
    lrt <- function(gm){ z$G <- gm[z$Strain]; 2 * (logLik(lmer(Age ~ Diet * G + (1 | Strain), z, REML = FALSE)) - logLik(lmer(Age ~ Diet + G + (1 | Strain), z, REML = FALSE))) }
    obs <- 2 * (logLik(f1) - logLik(f0)); null <- replicate(2000, suppressMessages(lrt(setNames(sample(gs), st))))
    cat(sprintf("  Diet x genotype (HF, NAM): mouse-level ANOVA F = %.2f, P = %.2g | with a random strain intercept P = %.3f | strain permutation P = %.3f (%d strains)\n",
                a["Diet:G", "F value"], a["Diet:G", "Pr(>F)"], pchisq(obs, 1, lower.tail = FALSE), mean(null >= obs), length(st)))
    if(l == "Vita1b"){
      cat("  Tukey HSD of diet within each Vita1b genotype (mouse-level, as Fig 6):\n")
      for(gg in c("B", "D")){ tk <- TukeyHSD(aov(Age ~ Diet, y[y$G == gg, ]))$Diet
        cat(sprintf("    %s: %s\n", gg, paste(sprintf("%s %+.0f days (P = %.2g)", rownames(tk), tk[, "diff"], tk[, "p adj"]), collapse = "; "))) }
    }
  }
}
sink()

### All vivaria with vivarium as a covariate (NAM mice are all at TSRB; the HF mice of the other vivaria then inform the
### genotype effect on HF only after vivarium is allowed for). Vita1b, 2,000 strain permutations.
x <- d[d$Strain %in% colnames(g) & d$Diet %in% c("HF", "NAM"), ]; x$G <- as.character(unlist(g[loci["Vita1b"], x$Strain])); z <- x[x$G %in% c("B", "D"), ]
z$Viv <- factor(z$Vivarium); st <- unique(z$Strain); gs <- setNames(as.character(unlist(g[loci["Vita1b"], st])), st)
lrt <- function(gm){ z$G <- gm[z$Strain]; 2 * (logLik(lmer(Age ~ Diet * G + Viv + (1 | Strain), z, REML = FALSE)) - logLik(lmer(Age ~ Diet + G + Viv + (1 | Strain), z, REML = FALSE))) }
obs <- lrt(gs); null <- replicate(2000, suppressMessages(lrt(setNames(sample(gs), st))))
f1 <- lmer(Age ~ Diet * G + Viv + (1 | Strain), z, REML = FALSE)
sink("output/NAM_by_Vita1_mouse_level.txt", append = TRUE, split = TRUE)
cat(sprintf("\n==== All vivaria, vivarium as a covariate, Vita1b: genotype x NAM %+.0f days; random strain intercept P = %.3f; strain permutation P = %.3f (%d strains)\n",
            fixef(f1)["DietNAM:GD"], pchisq(obs, 1, lower.tail = FALSE), mean(null >= obs), length(st)))
sink()
