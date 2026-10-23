#
# gompertz.R
#
# copyright (c) 2026 - Rob Williams
#
# Functions to fit the Gompertz (and Gompertz-Makeham) mortality law to ages at death by maximum likelihood.
# Each animal is at risk only from the age it entered the study (left truncation), so ages at set up are used.
#
#   hazard:   h(t) = a * exp(b * t) + c        (c = 0 for plain Gompertz; t in days)
#   MRDT:     log(2) / b                       (mortality rate doubling time, days)
#   base 2:   h(t) = R0 * 2^(t / MRDT) + c     (the same law; R0 = a, and mortality doubles every MRDT days)
#
# Parameters are fitted on the log scale, p = c(log(a), log(b)[, log(c)]), so a, b and c stay positive.
#

# Cumulative hazard from 0 to t
gompertz.H <- function(t, a, b, c = 0) {
  (a / b) * expm1(b * t) + c * t       # expm1 keeps H accurate when b * t is tiny
}

# Negative log-likelihood of ages at death (all deaths observed), left truncated at entry
gompertz.nll <- function(p, age, entry, makeham = FALSE) {
  a <- exp(p[1]); b <- exp(p[2]); c <- if (makeham) exp(p[3]) else 0
  h <- a * exp(b * age) + c
  -sum(log(h) - (gompertz.H(age, a, b, c) - gompertz.H(entry, a, b, c)))
}

# Gradient of gompertz.nll with respect to p (analytic, so BFGS never relies on finite differences)
gompertz.gr <- function(p, age, entry, makeham = FALSE) {
  a <- exp(p[1]); b <- exp(p[2]); c <- if (makeham) exp(p[3]) else 0
  et <- exp(b * age); ee <- exp(b * entry)
  h <- a * et + c
  dH.db <- function(t) a * (t * exp(b * t) / b - expm1(b * t) / b^2)   # derivative of H(t) with respect to b
  g.loga <- a * sum(et / h - (expm1(b * age) - expm1(b * entry)) / b)
  g.logb <- b * sum(a * age * et / h - (dH.db(age) - dH.db(entry)))
  g <- c(g.loga, g.logb)
  if (makeham) g <- c(g, c * sum(1 / h - (age - entry)))
  return(-g)
}

# Occurrence / exposure mortality rates in fixed age intervals (deaths per animal-day at risk)
gompertz.binned <- function(age, entry, width = 30, from = 0, to = max(age)) {
  breaks <- seq(from, to + width, width)
  res <- c()
  for (i in 1:(length(breaks) - 1)) {
    lo <- breaks[i]; hi <- breaks[i + 1]
    exposure <- sum(pmax(0, pmin(age, hi) - pmax(entry, lo)))
    deaths <- sum(age >= lo & age < hi & entry <= age)
    atrisk <- sum(entry <= lo & age >= lo)
    res <- rbind(res, c(start = lo, mid = (lo + hi) / 2, atrisk = atrisk, deaths = deaths, exposure = exposure,
                        rate = ifelse(exposure > 0, deaths / exposure, NA)))
  }
  return(as.data.frame(res))
}

# Classic estimate (de Magalhaes et al. 2005, 2018): weighted regression of log(rate) on age, weighted by deaths
gompertz.regression <- function(binned, from = 0) {
  use <- binned[binned[, "deaths"] > 0 & binned[, "mid"] >= from, ]
  fit <- lm(log(rate) ~ mid, data = use, weights = deaths)
  b <- unname(coef(fit)["mid"]); se <- summary(fit)$coefficients["mid", "Std. Error"]
  return(c(a = unname(exp(coef(fit)[1])), b = b, b.se = se, MRDT = log(2) / b,
           MRDT.lo = log(2) / (b + 1.96 * se), MRDT.hi = log(2) / (b - 1.96 * se), r2 = summary(fit)$r.squared))
}

# Starting values for the optimizer from the classic regression
gompertz.start <- function(age, entry) {
  reg <- gompertz.regression(gompertz.binned(age, entry), from = 200)
  return(unname(c(log(reg["a"]), log(max(reg["b"], 1e-4)))))
}

# Fit one group. Returns a, b, (c), MRDT with Wald 95% CI on the log(b) scale, log-likelihood and vcov
gompertz.fit <- function(age, entry = rep(0, length(age)), makeham = FALSE, start = NULL) {
  if (is.null(start)) start <- gompertz.start(age, entry)
  if (makeham) start <- c(start, log(1e-6))
  opt <- optim(start, gompertz.nll, gompertz.gr, age = age, entry = entry, makeham = makeham,
               method = "BFGS", hessian = TRUE, control = list(maxit = 5000, reltol = 1e-12))
  vc <- solve(opt$hessian)
  se.logb <- sqrt(vc[2, 2])
  b <- exp(opt$par[2])
  return(list(par = opt$par, vcov = vc, logLik = -opt$value, n = length(age), convergence = opt$convergence,
              a = exp(opt$par[1]), b = b, c = if (makeham) exp(opt$par[3]) else 0,
              MRDT = log(2) / b, MRDT.lo = log(2) / exp(opt$par[2] + 1.96 * se.logb),
              MRDT.hi = log(2) / exp(opt$par[2] - 1.96 * se.logb)))
}

# Two groups (grp = 1/2) with a shared slope b and separate a: p = c(log(a1), log(a2), log(b))
gompertz.nll.sharedb <- function(p, age, entry, grp) {
  gompertz.nll(c(p[1], p[3]), age[grp == 1], entry[grp == 1]) + gompertz.nll(c(p[2], p[3]), age[grp == 2], entry[grp == 2])
}
gompertz.gr.sharedb <- function(p, age, entry, grp) {
  g1 <- gompertz.gr(c(p[1], p[3]), age[grp == 1], entry[grp == 1]); g2 <- gompertz.gr(c(p[2], p[3]), age[grp == 2], entry[grp == 2])
  c(g1[1], g2[1], g1[2] + g2[2])
}

# Two groups with a shared a and separate b: p = c(log(a), log(b1), log(b2))
gompertz.nll.shareda <- function(p, age, entry, grp) {
  gompertz.nll(c(p[1], p[2]), age[grp == 1], entry[grp == 1]) + gompertz.nll(c(p[1], p[3]), age[grp == 2], entry[grp == 2])
}
gompertz.gr.shareda <- function(p, age, entry, grp) {
  g1 <- gompertz.gr(c(p[1], p[2]), age[grp == 1], entry[grp == 1]); g2 <- gompertz.gr(c(p[1], p[3]), age[grp == 2], entry[grp == 2])
  c(g1[1] + g2[1], g1[2], g2[2])
}

# Likelihood ratio tests between two groups: is the slope (MRDT) different? is the intercept (R0) different?
gompertz.compare <- function(age, entry, group) {
  lv <- levels(factor(group)); g <- as.numeric(factor(group, levels = lv))
  f1 <- gompertz.fit(age[g == 1], entry[g == 1]); f2 <- gompertz.fit(age[g == 2], entry[g == 2])
  ll.sep <- f1$logLik + f2$logLik
  sb <- optim(c(f1$par[1], f2$par[1], mean(c(f1$par[2], f2$par[2]))), gompertz.nll.sharedb, gompertz.gr.sharedb,
              age = age, entry = entry, grp = g,  # not 'g =': it would match optim's 'gr'
              method = "BFGS", hessian = TRUE, control = list(maxit = 5000, reltol = 1e-12))
  sa <- optim(c(mean(c(f1$par[1], f2$par[1])), f1$par[2], f2$par[2]), gompertz.nll.shareda, gompertz.gr.shareda,
              age = age, entry = entry, grp = g,
              method = "BFGS", control = list(maxit = 5000, reltol = 1e-12))
  one <- gompertz.fit(age, entry)
  if (-sb$value > ll.sep + 1e-6 || -sa$value > ll.sep + 1e-6) warning("constrained fit beats the separate fits: optimizer failure")
  lrt <- function(ll0, df, ll1 = ll.sep) { x2 <- 2 * (ll1 - ll0); c(chisq = x2, df = df, p = pchisq(x2, df, lower.tail = FALSE)) }
  se.loghr <- sqrt(c(-1, 1, 0) %*% solve(sb$hessian) %*% c(-1, 1, 0))
  return(list(fits = setNames(list(f1, f2), lv),
              slope = lrt(-sb$value, 1),        # H0: same b (same MRDT), separate a
              intercept = lrt(-sa$value, 1),    # H0: same a (same R0), separate b
              any = lrt(one$logLik, 2),         # H0: one curve for both groups
              R0 = lrt(one$logLik, 1, -sb$value),  # H0: same a, given the shared slope
              sharedb = c(a1 = exp(sb$par[1]), a2 = exp(sb$par[2]), b = exp(sb$par[3]), MRDT = log(2) / exp(sb$par[3]),
                          HR = exp(sb$par[2] - sb$par[1]), HR.lo = exp(sb$par[2] - sb$par[1] - 1.96 * se.loghr),
                          HR.hi = exp(sb$par[2] - sb$par[1] + 1.96 * se.loghr))))
}

# Nonparametric bootstrap of the per-group fits (animals resampled within group)
gompertz.bootstrap <- function(age, entry, group, B = 1000, seed = 1) {
  set.seed(seed)
  lv <- levels(factor(group))
  res <- c()
  for (i in 1:B) {
    row <- c()
    for (l in lv) {
      idx <- which(group == l)
      s <- idx[sample.int(length(idx), replace = TRUE)]
      f <- gompertz.fit(age[s], entry[s])
      row <- c(row, f$par[1], f$par[2], f$MRDT)
    }
    res <- rbind(res, row)
  }
  colnames(res) <- paste0(rep(c("loga.", "logb.", "MRDT."), length(lv)), rep(lv, each = 3))
  return(as.data.frame(res))
}
