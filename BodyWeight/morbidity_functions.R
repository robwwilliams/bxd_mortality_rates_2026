#
# morbidity_functions.R
#
# copyright (c) 2026 - Rob Williams
#
# Days in terminal decline, or a graded burden, for one mouse under every definition of
# notes/PLAN_morbidity_definitions.md (approved by Rob on 27 October 2026). A definition is one setting of:
#   P  plateau        P1 highest weight >= 120 d before death; P2 running peak; P3 median of the 3 highest >= 120 d
#                     before death; P4 mean of the weighings 120-240 d before death (P1 if none)
#   O  onset          O1-O4 below 90/95/85/80% with no recovery; O5 below 90% for the first time; O6 final run of
#                     intervals losing >= 2% of plateau per month; O7 below 90% or losing >= 5% per month, no recovery;
#                     O8 change point; O9 first interval losing > 10%; O10 equal risk (78.0% chow, 86.2% high fat, F1s)
#   T  timing         T1 halfway between weighings; T2 where the straight line crosses (threshold rules only)
#   L  last gap       L1 half the days to death; L2 last weight carried to death; L3 straight line through the last two
#                     weights; L4 straight line to 76% of plateau at death
#   G  graded         G1 percent-days below plateau beyond a 5% band; G2 excess-risk days, sum of HR - 1
# The weighing setting (K1 all, K2 without flagged weighings) is applied before these functions are called.
#

theta <- c(O1 = 0.90, O2 = 0.95, O3 = 0.85, O4 = 0.80, O5 = 0.90, O7 = 0.90)
theta.equal.risk <- function(group) ifelse(group == "chow", 1 - 0.10 * log(2) / log(1.37), 1 - 0.10 * log(2) / log(1.65))
beta.risk <- function(group) ifelse(group == "chow", log(1.37) / 0.10, log(1.65) / 0.10)

# Plateau at each weighing (a vector the length of w); ip is the peak weighing, pre the weighings >= 120 d before death
plateau <- function(P, a, w, death, ip, pre) {
  n <- length(w)
  switch(P,
    P1 = rep(w[ip], n),
    P2 = cummax(w),
    P3 = rep(median(sort(w[pre], decreasing = TRUE)[1:min(3, length(pre))]), n),
    P4 = { k <- which(a >= death - 240 & a <= death - 120); rep(if (length(k)) mean(w[k]) else w[ip], n) })
}

# Weight at death on the assumed path of the last gap
weight.at.death <- function(L, a, w, death, plat.n) {
  n <- length(w)
  if (L == "L3" && n >= 2 && a[n] > a[n - 1]) return(max(0, w[n] + (w[n] - w[n - 1]) / (a[n] - a[n - 1]) * (death - a[n])))
  if (L == "L4") return(min(w[n], 0.76 * plat.n))
  w[n]
}

# Change point: plateau c, then a straight-line fall from tau. Returns tau, or NA if the fall by the last point is
# under 5% of c (the noise band)
change.point <- function(t, y) {
  if (length(t) < 2) return(NA)
  taus <- seq(t[1], t[length(t)], by = 5)
  X <- outer(t, taus, function(t, tau) pmax(0, t - tau))
  xm <- colMeans(X); ym <- mean(y)
  sxx <- colSums(sweep(X, 2, xm)^2); sxy <- colSums(sweep(X, 2, xm) * (y - ym))
  ok <- sxx > 0; if (!any(ok)) return(NA)
  slope <- ifelse(ok, sxy / sxx, 0); c0 <- ym - slope * xm
  rss <- colSums((y - (rep(c0, each = length(t)) + X * rep(slope, each = length(t))))^2)
  rss[!ok] <- sum((y - ym)^2)
  k <- which.min(rss)
  fall <- -slope[k] * (t[length(t)] - taus[k])
  if (slope[k] < 0 && fall >= 0.05 * c0[k]) taus[k] else NA
}

# Onset for a threshold rule (no recovery unless first = TRUE), from the weighings and, if needed, the last-gap path
onset.threshold <- function(a, r, ip, death, th, Tm, L, rD, first = FALSE) {
  n <- length(r); idx <- ip:n
  if (first) {
    below <- idx[r[idx] < th]
    if (length(below)) { ib <- below[1]; ia <- ib - 1 } else ia <- n
  } else ia <- max(idx[r[idx] >= th])
  if (ia < n) {
    if (Tm == "T1") return((a[ia] + a[ia + 1]) / 2)
    return(a[ia] + (r[ia] - th) / (r[ia] - r[ia + 1]) * (a[ia + 1] - a[ia]))
  }
  gap.onset(a[n], r[n], death, th, L, rD)
}

# Onset in the last gap for a mouse not in decline at its last weighing (NA = no decline before death)
gap.onset <- function(an, rn, death, th, L, rD) {
  if (death <= an) return(NA)
  if (L == "L1") return((an + death) / 2)
  if (L == "L2" || rD >= th) return(NA)
  an + (rn - th) / (rn - rD) * (death - an)
}

# Every definition for one mouse. a, w: ages and weights (any order); group: "chow" or "hf" (high-fat BXDs, all F1s
# and NAM mice). Returns a named vector: days in decline (0 if none), or the graded burden.
morbidity.all <- function(a, w, death, group, K = "K1") {
  o <- order(a); a <- a[o]; w <- w[o]; keep <- a <= death; a <- a[keep]; w <- w[keep]; n <- length(a)
  pre <- which(a <= death - 120)
  if (length(pre) == 0) return(NULL)
  ip <- pre[which.max(w[pre])]
  span <- function(on) if (is.na(on)) 0 else death - on
  out <- c()
  for (P in c("P1", "P2", "P3", "P4")) {
    plat <- plateau(P, a, w, death, ip, pre); r <- w / plat
    rate <- c(NA, (w[-n] - w[-1]) / plat[-1] * 30 / pmax(diff(a), 1))           # loss per month, interval ending at j
    for (L in c("L1", "L2", "L3", "L4")) {
      wD <- weight.at.death(L, a, w, death, plat[n]); rD <- wD / max(plat[n], if (P == "P2") wD else 0)
      rateD <- if (death > a[n]) (w[n] - wD) / plat[n] * 30 / (death - a[n]) else 0
      for (O in c("O1", "O2", "O3", "O4", "O5", "O7", "O10")) {
        th <- if (O == "O10") theta.equal.risk(group) else theta[[O]]
        for (Tm in c("T1", "T2")) {
          if (O == "O7") {
            st <- c(FALSE, r[-1] < th | rate[-1] >= 0.05); st[seq_len(ip)] <- FALSE
            ia <- max(which(!st))
            on <- if (ia < n) {
              if (Tm == "T2" && r[ia] >= th && r[ia + 1] < th) a[ia] + (r[ia] - th) / (r[ia] - r[ia + 1]) * (a[ia + 1] - a[ia])
              else (a[ia] + a[ia + 1]) / 2
            } else if (L %in% c("L3", "L4") && rD >= th && rateD >= 0.05 && death > a[n]) (a[n] + death) / 2   # the path's rate triggers
            else gap.onset(a[n], r[n], death, th, L, rD)
          } else on <- onset.threshold(a, r, ip, death, th, Tm, L, rD, first = O == "O5")
          out[paste(P, K, O, Tm, L, sep = ".")] <- span(on)
        }
      }
      # O6: start of the final run of intervals losing >= 2% per month
      j <- n; while (j > ip && !is.na(rate[j]) && rate[j] >= 0.02) j <- j - 1
      on <- if (j < n) a[j] else if (L == "L1") gap.onset(a[n], 1, death, 0, "L1", 0) else if (L != "L2" && rateD >= 0.02) a[n] else NA
      out[paste(P, K, "O6", L, sep = ".")] <- span(on)
      # O9: start of the first interval losing > 10% of plateau
      big <- which(seq_len(n) > ip & (c(w[1], w[-n]) - w) / plat > 0.10)
      on <- if (length(big)) a[big[1] - 1] else if (L == "L1") gap.onset(a[n], 1, death, 0, "L1", 0)
            else if (L != "L2" && (w[n] - wD) / plat[n] > 0.10 && death > a[n]) a[n] else NA
      out[paste(P, K, "O9", L, sep = ".")] <- span(on)
      # Graded measures, on a 1-day grid from the peak to death, along the weighings and then the last-gap path
      if (L != "L1") {
        tt <- seq(a[ip], death, by = 1)
        path <- if (death > a[n]) approx(c(a[ip:n], death), c(w[ip:n], wD), tt, ties = mean)$y else approx(a[ip:n], w[ip:n], tt, rule = 2, ties = mean)$y
        pl <- if (P == "P2") pmax(cummax(w)[findInterval(tt, a)], path) else rep(plat[1], length(tt))
        loss <- pmax(0, 1 - path / pl)
        out[paste(P, K, "G1", L, sep = ".")] <- 100 * sum(pmax(0, loss - 0.05))
        out[paste(P, K, "G2", L, sep = ".")] <- sum(exp(beta.risk(group) * loss) - 1)
      }
    }
  }
  # O8: change point over the weighings from the peak on; it uses no plateau
  tau <- change.point(a[ip:n], w[ip:n])
  for (L in c("L1", "L2", "L3", "L4")) {
    on <- tau
    if (is.na(on) && death > a[n]) {
      if (L == "L1") on <- (a[n] + death) / 2
      if (L %in% c("L3", "L4")) on <- change.point(c(a[ip:n], death), c(w[ip:n], weight.at.death(L, a, w, death, w[ip])))
    }
    out[paste(K, "O8", L, sep = ".")] <- span(on)
  }
  out
}
