# Draft message to Beni Mozhui: her BXD diet Gompertz analysis

*Draft by Claude for Rob, 21 November 2026. Not yet sent. The comparison behind it is `notes/Mozhui_comparison_results.md`.*

---

**Subject:** Your BXD diet Gompertz analysis: same slope result, and a note on *a*

Hi Beni,

Thanks for your Gompertz analysis of the BXD diets. We reached the same main conclusion: within strains, high fat steepens the rise of mortality, and pooling strains hides it. Our first, pooled fit missed this, and you are right to stress that strain has to be in the model.

I refit your model with our own likelihood on our copy of the data, the same 1,044 chow and 890 high-fat mice. It gives your numbers exactly: MRDT 119.5 days on chow and 104.0 on high fat, likelihood ratio 12.9. Four points:

1. **Our slope change is larger.** We give each strain × diet its own level, instead of one high-fat multiplier for all strains. That gives MRDTs of 114 and 90 days, a ratio of 0.78, against 0.87 in your model. Strains differ in how much high fat raises their mortality (C57BL/6J 2.2-fold, DBA/2J 1.0-fold; P = 0.0002). We think one multiplier leaves that variation in the data as a hidden mixture, which flattens the curve. Both ratios exclude 1 in a delete-one-strain jackknife: 95% CI 0.70–0.88 for ours, 0.77–0.99 for yours.

2. **"Diet changes *b*, not *a*" depends on measuring *a* at birth.** Your two curves nearly meet at birth (high fat 1.05-fold chow) and then fan out. At 600 days, your fit has high fat at 1.76-fold chow (P = 10⁻²⁸). Measured there, the lost median lifespan of a typical strain splits into −89 days for the level and +18 for the slope, instead of −7 and −64. The curves are the same either way, so we would say high fat does both: mortality about 1.8-fold higher at 600 days, with the multiple growing with age.

3. **Nicotinamide.** All NAM mice were housed at TSRB, but only 63 of the 243 high-fat controls in your NAM comparison were, and the model has no term for vivarium. The NAM mice were also born about three years after their high-fat controls. With controls born in the same years, we see no difference (hazard ratio 1.04, 95% CI 0.51–2.12).

4. **Your data file has corrected ages for four NAM mice.** We had flagged them as weighed after their recorded death: 3527 (730 days in your file, 638 in ours), 4558 (229 against 155), 4590 (786 against 421) and 5026 (620 against 483). Each of your ages falls after the mouse's last weighing. With your ages, our nicotinamide results barely move: the mean lifespan difference, NAM − high fat, goes from +26 to +28 days (95% CI −93 to 149). Suheeta and Casey made these corrections after our QC, and we will use them. Two other flagged NAM mice, 2887 and 3031, are the same in both files. Your file also leaves out the NAM mice of C57BL/6J and DBA/2J, which explains why your NAM counts differ from ours.

The comparison and its code: https://github.com/robwwilliams/bxd_mortality_rates_2026/blob/main/notes/Mozhui_comparison_results.md

P.S. We used your corrected file for a test drive of GeneNetwork's new interface for AI agents, GN4AI-beta. It repeated Danny's strain-means maps and his full actuarial scan, 20 to 770 days: https://github.com/robwwilliams/bxd_mortality_rates_2026/blob/main/notes/GN4AI_test_drive_2026-11-21.md

Best,
Opus 5.5 Extra (prompted by Rob)
