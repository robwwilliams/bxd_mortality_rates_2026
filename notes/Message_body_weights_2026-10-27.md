# Draft message to Suheeta Roy and Casey: body weights near death

*Draft by Claude for Rob, 27 October 2026. Rob sent it to Suheeta on 27 October 2026. A follow-up, not yet sent, is at the end.*

---

Dear Suheeta and Casey,

We are using the body weights of the aging colony to measure how long each mouse spends in decline before it dies. The details are in Part 4 of our report on GitHub. Two things would help us a great deal.

## 1. Odd weighings (mainly for Suheeta)

A program flagged 218 weighings in 159 mice that look wrong. `qc/BodyWeight_QC.md` lists the rules and the cases to look at first. `qc/BodyWeight_flags.txt` has every flagged weighing, with each mouse's whole series of weights. Nothing has been changed or dropped.

The most important are 34 mice weighed after their recorded age at death. For example:
- **BXD 3276 (BXD218, chow)** died at 631 days in your mapping file and in GeneNetwork, yet has 10 weighings out to 1,263 days.
- **F1 3662 (BXD172 × BXD197, chow)** died at 506 days, yet has weighings out to 982 days.

If an age at death is wrong, our lifespan analyses carry the error too.

For each flagged mouse, could you tell us one of three things?
1. The record is right, perhaps with an extenuating circumstance such as a tumor, a cage flood or a fight.
2. The record is wrong, and here is the correct value.
3. We cannot tell.

## 2. How the last weighings were taken (mainly for Casey)

Weighings come about every 64 days, and the last one is a median of 30 days before death. To fill that gap, we need to know how the weighings near death were taken.

1. **Day-of-death weighings.** 309 mice have a weight within 3 days of death, 233 of them euthanized.
   - Were these mice weighed alive, just before euthanasia?
   - Were mice found dead also weighed? If so, roughly how long after death might they have been found?
2. **Extra weighings.** Were frail mice weighed more often near the end, for example on a watch list? If so, were those weights recorded anywhere?
3. **Euthanasia criteria.** Which criteria led to euthanasia, and did they change over the years? For example: a percentage of weight lost, body condition, hunched posture, a mass of 2 cm.
4. **How mice were weighed.** What scale and precision, and at what time of day? Were the regular weighings done for a whole room on one day?
5. **Events.** Were there events that would shift a whole cage or room, such as a flood, a failed water bottle, or the move from Nash to TSRB?

For the weight at death, I suspect the answer is to extrapolate from the last two weights. We tried it on the 309 mice weighed near death, predicting that weight from the weighings before it. Extrapolation is a little better than carrying the last weight forward, but both guess too heavy:

| Rule | Typical bias | Typical size of the error |
|---|---|---|
| Carry the last weight forward | 9.0% of peak too heavy | 13.2% of peak |
| Extrapolate from the last two weights | 6.6% of peak too heavy | 13.5% of peak |

In more than half of the mice, weight fell faster in the last interval than the trend before it. A quarter, though, weighed more at death than at the weighing before.

**A small study we could do.** Weigh mice at euthanasia, and again 12 and 24 hours later, kept as found-dead mice would be. This would tell us how much weight a dead mouse loses before it is found.

With thanks,
Rob

---

## Follow-up (draft, not yet sent): the NAM mice, and the pathology

*Draft by Claude for Rob, 27 October 2026.*

Dear Suheeta,

Three more things, now that we have looked at the NAM mice and the necropsy notes.

**1. NAM records.** The same checks found 52 odd weighings in 33 NAM mice, listed in `qc/BodyWeight_QC.md` on GitHub. The ones that matter most change an age at death:
- **NAM 4558 (BXD15):** death at 155 days, but set up at 190 days;
- **NAM 4590 (BXD32):** death at 421 days, but weighed five more times, to 709 days;
- **NAM 2887 (BXD40), 3031 (BXD62), 3527 (BXD172) and 5026 (BXD62):** weighed after the recorded death.

**2. The first weeks on the NAM diet.** Many NAM mice were weighed weekly at first, and some lost a lot of weight before recovering. For example, BXD40 mouse 2888 went from 28.0 g to 15.2 g in three weeks, then back to 31.9 g. Did the mice refuse the diet at first? Was anything changed, such as the way the diet was given?

**3. Pathology.**
- **The diagnoses behind Table 1 of our 2021 paper.** Do you have the list of the 155 necropsied mice with each one's diagnosis? With it, we can test whether mice dying of lymphoma or with large masses hide their wasting on the scale.
- **The bodies in formalin.** The notes mention formalin for about 390 mice of the aging colony. Are those bodies kept? Weighing the spleen, liver and uterus, or the tumor-free carcass, would measure directly how much weight a tumor hides.

With thanks,
Rob
