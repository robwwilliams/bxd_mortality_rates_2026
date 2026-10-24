#
# Chr1_haplotypes.R
#
# copyright (c) 2026 - Rob Williams
#
# Classify BXD strains by haplotype across proximal Chr 1 (Vita1a and Vita1b, 0 to 30 Mb) from the sequence-based
# genotypes of David Ashbrook (2018, updated 2019). The first marker is at 3.0 Mb.
#
# Cleaning, in order:
#   1. Markers whose B frequency across strains departs by more than 0.10 from the median of their 20 neighbors are
#      dropped: at these, many D strains read B (or many B strains read D), which no recombination can produce.
#   2. Runs of fewer than 3 markers, or spanning less than 0.5 Mb, are treated as genotyping noise and take the
#      genotype of the longer neighboring run.
#   3. An unknown (U) flanked by the same genotype takes that genotype; a U between two different genotypes stays U.
#
# Classes:
#   B            B across the whole region
#   D            D across the whole region
#   Recombinant  both B and D blocks (listed in Segments)
#   Het          a heterozygous block that survives step 2
#
# Run from the repository root:
#   Rscript Genotypes/Chr1_haplotypes.R data/genotypes/BXD_genotypes_Chr1_0to35Mb.txt output/Chr1_haplotypes.txt
#

args <- commandArgs(trailingOnly = TRUE)
geno <- read.delim(args[1], check.names = FALSE, colClasses = "character")
geno <- geno[geno[, "Chr"] == "1" & as.numeric(geno[, "Mb"]) <= 30, ]
geno <- geno[order(as.numeric(geno[, "Mb"])), ]
strains <- colnames(geno)[-(1:4)]
strains <- strains[strains != ""]

# Step 1: drop markers whose B frequency is out of line with their neighbors
fB <- apply(geno[, strains], 1, function(g) sum(g == "B") / sum(g %in% c("B", "D")))
nbmed <- sapply(seq_along(fB), function(i) median(fB[setdiff(max(1, i - 10):min(length(fB), i + 10), i)]))
bad <- abs(fB - nbmed) > 0.10
cat("Markers dropped as out of line with their neighbors:\n")
print(data.frame(geno[bad, 2:4], B.freq = round(fB[bad], 2), neighbors = round(nbmed[bad], 2)))
geno <- geno[!bad, ]

# 'BXD073b_RwwJ_0440' -> 'BXD73b', 'BXD29 (BXD29_Ty)' -> 'BXD29'
short <- sub("^BXD0*", "BXD", sub("[_ ].*$", "", strains))

min.run <- 3                               # markers
min.span <- 0.5                            # Mb

# Step 2: runs shorter than min.run markers or min.span Mb take the genotype of the longer neighboring run, shortest first
smooth <- function(g, mb) {
  repeat {
    r <- rle(g)
    ends <- cumsum(r$lengths); starts <- c(1, head(ends, -1) + 1)
    noise <- r$lengths < min.run | (mb[ends] - mb[starts]) < min.span
    if (length(r$values) == 1 || !any(noise)) return(g)
    i <- which(noise)[which.min(r$lengths[noise])]
    nb <- c(if (i > 1) i - 1, if (i < length(r$values)) i + 1)
    r$values[i] <- r$values[nb[which.max(r$lengths[nb])]]
    g <- inverse.rle(r)
  }
}

hap <- c()
mb <- as.numeric(geno[, "Mb"])
for (i in seq_along(strains)) {
  g <- geno[, strains[i]]
  typed <- g %in% c("B", "D", "H")
  gs <- smooth(g[typed], mb[typed])
  runs <- rle(gs)
  ends <- cumsum(runs$lengths); starts <- c(1, head(ends, -1) + 1)
  segments <- if (length(runs$values) > 1) paste0(runs$values, " ", sprintf("%.1f", mb[typed][starts]), "-",
                                                  sprintf("%.1f", mb[typed][ends]), " Mb", collapse = "; ") else ""
  cls <- if (any(runs$values == "H")) "Het" else if (length(runs$values) == 1) runs$values else "Recombinant"
  g <- replace(g, which(typed), gs)
  # Step 3: impute U flanked by the same genotype
  k <- which(g != "U")
  for (j in which(g == "U")) {
    left <- k[k < j]; right <- k[k > j]
    if (length(left) && length(right) && g[max(left)] == g[min(right)]) g[j] <- g[max(left)]
  }
  hap <- rbind(hap, data.frame(Strain = short[i], Column = strains[i], Chr1.0to30Mb = cls,
                               Vita1a.4.5Mb = g[which.min(abs(mb - 4.5))], Vita1b.24Mb = g[which.min(abs(mb - 24))],
                               n.B = sum(g == "B"), n.D = sum(g == "D"), n.H = sum(g == "H"), n.U = sum(g == "U"),
                               Segments = segments))
}
cat("Markers from", min(mb), "to", max(mb), "Mb:", nrow(geno), "\n")
print(table(hap[, "Chr1.0to30Mb"]))
write.table(hap, args[2], sep = "\t", quote = FALSE, row.names = FALSE)
