#
# NAM_by_Vita1.R - Does nicotinamide on high fat act differently by Vita1a and Vita1b genotype?
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026, after the grant's pilot result was seen
# (Mozhui, Roy and Bajwa R01 resubmission, June 2026: "NAM rescues the effect of HFD only in mice with the B allele, and
# this GxE interaction is particularly strong at Vita1b"). Rob: "The other unused resource is our 18X NAM cases aged on high
# fat. We have NOT included those in the analysis but they show a strong interaction on Chr 1 at Vita1a and Vita1b."
#   - Mice: BXD females on high fat (HF) and on high fat + 1% NAM, from the mapping file, with the four NAM ages at death
#     corrected in Beni Mozhui's file (as NAM_rectangularization.R does with "mozhui"). Chow (CD) mice for reference.
#   - Design as Part 5: TSRB only (vivarium 3, where all NAM mice lived); strains with at least 3 mice in each arm. The
#     unit is the strain: d = mean age at death on NAM minus on HF, per strain.
#   - Genotypes: each strain's call at Vita1a (rsm10000000010, 5.02 Mb) and Vita1b (rsm10000000521, 23.52 Mb), from the
#     BXD genotype file used for mapping (robwwilliams/BxDLifeSpan, data/BXD_current_rev050423.geno).
#   - Test: the mean d of D strains minus that of B strains; P from all relabelings of genotypes among the strains (exact
#     when there are few strains, else 100,000 draws, seed 20261124); Welch t alongside. A crossover (NAM helps B, harms D)
#     would leave the average NAM effect near zero, as Part 5 found.
#   - Caution (Part 5): NAM mice were born about three years after most of their high-fat controls, and at TSRB mortality
#     rose with year of birth. A genotype x arm interaction is less exposed to that than a main effect, but not immune if
#     the controls of B and D strains were born in different years.
# Writes output/NAM_by_Vita1.txt
#   Rscript Gompertz/NAM_by_Vita1.R
#

library(readxl)
set.seed(20261124)
m <- as.data.frame(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal"))[, 1:7]
colnames(m) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
m <- m[!is.na(m$EarTag), ]
bm <- read.csv("data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv", skip = 15, check.names = FALSE, fileEncoding = "UTF-8-BOM")[, 1:7]
colnames(bm) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
bm <- bm[!is.na(bm$EarTag) & bm$Diet == "NAM", ]
i <- which(m$Diet == "NAM" & m$EarTag %in% bm$EarTag); m$Age[i] <- bm$Age[match(m$EarTag[i], bm$EarTag)]   # Beni's corrected NAM ages
m$Age <- as.numeric(m$Age)

g <- read.table("../BxDLifeSpan/data/BXD_current_rev050423.geno", sep = "\t", skip = 23, header = TRUE, na.strings = c("U", "", "NA"), check.names = FALSE)
rownames(g) <- g$Locus
loci <- c(Vita1a = "rsm10000000010", Vita1b = "rsm10000000521")

perm.test <- function(d, grp){                                                     # grp: "B" or "D" per strain
  obs <- mean(d[grp == "D"]) - mean(d[grp == "B"]); n <- length(d); k <- sum(grp == "D")
  if(choose(n, k) <= 2e5){ cmb <- combn(n, k); null <- apply(cmb, 2, function(j) mean(d[j]) - mean(d[-j])) }
  else null <- replicate(1e5, { j <- sample.int(n, k); mean(d[j]) - mean(d[-j]) })
  c(obs = obs, p = mean(abs(null) >= abs(obs) - 1e-9), welch.p = t.test(d[grp == "D"], d[grp == "B"])$p.value)
}

sink("output/NAM_by_Vita1.txt", split = TRUE)
cat("High fat + 1% NAM against high fat, by Vita1a and Vita1b genotype; BXD females at TSRB, the strain as the unit\n")
for(minN in c(3, 2)){
  x <- m[m$Diet %in% c("HF", "NAM") & m$Vivarium == 3 & !is.na(m$Age), ]
  tb <- table(x$Strain, x$Diet); ok <- rownames(tb)[tb[, "HF"] >= minN & tb[, "NAM"] >= minN]; ok <- ok[ok %in% colnames(g)]
  mean.by <- function(arm) sapply(ok, function(s) mean(x$Age[x$Strain == s & x$Diet == arm]))
  d <- mean.by("NAM") - mean.by("HF")
  cat(sprintf("\n== Strains with at least %d mice in each arm: %d strains, %d NAM and %d high-fat mice. Mean NAM - HF over strains: %+.0f days\n",
              minN, length(ok), sum(x$Diet == "NAM" & x$Strain %in% ok), sum(x$Diet == "HF" & x$Strain %in% ok), mean(d)))
  for(l in names(loci)){
    gt <- as.character(unlist(g[loci[l], ok])); keep <- gt %in% c("B", "D")
    r <- perm.test(d[keep], gt[keep])
    cat(sprintf("  %s: B strains %d, mean NAM - HF %+.0f days; D strains %d, %+.0f days; D - B %+.0f days, permutation P = %.3f (Welch P = %.3f)\n", l,
                sum(gt[keep] == "B"), mean(d[keep][gt[keep] == "B"]), sum(gt[keep] == "D"), mean(d[keep][gt[keep] == "D"]), r["obs"], r["p"], r["welch.p"]))
  }
  if(minN == 3){
    cat("  Strains (NAM - HF, days; Vita1a, Vita1b):\n")
    print(data.frame(strain = ok, d = round(d), Vita1a = unlist(g[loci["Vita1a"], ok]), Vita1b = unlist(g[loci["Vita1b"], ok]), row.names = NULL), row.names = FALSE)
  }
}
cat("\nStrain means at TSRB (equal weights over strains with at least 3 mice in the arm), by genotype, for reference:\n")
for(l in names(loci)) for(arm in c("CD", "HF", "NAM")){
  y <- m[m$Diet == arm & m$Vivarium == 3 & !is.na(m$Age), ]; n <- table(y$Strain); s <- intersect(names(n)[n >= 3], colnames(g))
  mu <- tapply(y$Age, y$Strain, mean)[s]; gt <- as.character(unlist(g[loci[l], s]))
  cat(sprintf("  %s %-3s: B %4.0f days (%d strains), D %4.0f days (%d strains)\n", l, arm, mean(mu[gt == "B"]), sum(gt == "B", na.rm = TRUE), mean(mu[gt == "D"]), sum(gt == "D", na.rm = TRUE)))
}
sink()

### Every TSRB mouse on HF or NAM: a mixed model with a random intercept per strain, so that strains with mice in only one arm
### count too. Genotype x arm by likelihood ratio, and P from relabeling genotypes among the strains (the strain as the
### unit; each strain keeps its mice and arms), 10,000 draws.
library(lme4)
x <- m[m$Diet %in% c("HF", "NAM") & m$Vivarium == 3 & !is.na(m$Age) & m$Strain %in% colnames(g), ]
sink("output/NAM_by_Vita1.txt", append = TRUE, split = TRUE)
cat(sprintf("\n== Every TSRB mouse on HF or NAM: %d mice of %d strains (%d with NAM mice)\n", nrow(x), length(unique(x$Strain)), length(unique(x$Strain[x$Diet == "NAM"]))))
for(l in names(loci)){
  st <- unique(x$Strain); gs <- as.character(unlist(g[loci[l], st])); names(gs) <- st; st <- st[gs %in% c("B", "D")]
  y <- x[x$Strain %in% st, ]
  lrt <- function(gmap){ y$G <- gmap[y$Strain]; f1 <- lmer(Age ~ Diet * G + (1 | Strain), y, REML = FALSE); f0 <- lmer(Age ~ Diet + G + (1 | Strain), y, REML = FALSE)
    c(chisq = 2 * (logLik(f1) - logLik(f0)), int = unname(fixef(f1)["DietNAM:GD"])) }
  obs <- lrt(gs[st]); null <- replicate(10000, suppressMessages(lrt(setNames(sample(gs[st]), st)))["chisq"])
  cat(sprintf("  %s: genotype x NAM = %+.0f days (NAM - HF in D strains minus in B strains); LR chi-square %.2f, P = %.3f (1 d.f.), strain permutation P = %.3f\n",
              l, obs["int"], obs["chisq"], pchisq(obs["chisq"], 1, lower.tail = FALSE), mean(null >= obs["chisq"])))
}
sink()
