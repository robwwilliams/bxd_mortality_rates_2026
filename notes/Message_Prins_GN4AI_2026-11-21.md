# Draft message to Pjotr Prins: the GN4AI-beta test drive

*Draft by Claude for Rob, 21 November 2026. Not yet sent. Pjotr asked for the Claude chat, copied or exported as Markdown. This file is that export, condensed; the full record is `notes/GN4AI_test_drive_2026-11-21.md`. Send this rather than the chat itself, which contains the GN4AI token.*

---

**Subject:** GN4AI-beta test drive: BXD lifespan mapping, 24 items

Hi Pjotr,

We gave GN4AI-beta a full drive on 21 November (build `5b68da6-dirty`). We repeated Danny Arends's BXD lifespan maps with strain means from Beni Mozhui's corrected file. That covered:
- baskets;
- R/qtl, with and without 1,000 permutations;
- R/qtl2, with LOCO kinship and without;
- GEMMA through both runners, and pangemma;
- covariates and plots;
- the full actuarial scan: 108 R/qtl2 scans, from 20 to 770 days of age in 30-day steps, on chow and high fat.

The full write-up has every request, reply and timing (187 calls). The scripts are in `GN4AI/` of the same repository: https://github.com/robwwilliams/bxd_mortality_rates_2026/blob/main/notes/GN4AI_test_drive_2026-11-21.md

**It works, and it is fast.** An R/qtl2 scan takes 3 s, and the 108 actuarial scans took 6 minutes, sent inline so that nothing stayed on the server. R/qtl2's LOCO kinship works: on high fat, scans with it correlate with scans without it at r = 0.88 to 0.94 over markers, up to 470 days.

**Five faults matter most:**
1. **Repeated sample names are collapsed to the last one, without warning** (item 20). We sent 818 high-fat mice under 99 strain names to `/compute/qtl2`. The reply noted "99 values used", and the scan is identical to one of the last mouse per strain. A user who sends individual mice gets a map of one mouse per strain, from a reply that looks normal.
2. **R/qtl2 drops covariates** (item 15). The reply acknowledges the covariate, but the LODs equal those without it. The command line passes the covariate-structure file twice (`--covariates …-covarstruct.txt --covarstruct …-covarstruct.txt`), so the values never reach the scan.
3. **No GEMMA route takes covariates** (items 6 and 14). `/compute/gemma` now runs ravanan: its rows equal `/compute/gemma/ravanan`'s to the last digit. Its 422 sends the user back to `/compute/gemma` for a covariate fit.
4. **`/plot/rqtl` refuses `/compute/qtl2` replies** (item 12), though SKILL.md says it draws them.
5. **Heterozygous calls are dropped for the BXD group by default** (item 24). R/qtl runs as `riself` and R/qtl2 defaults to it. Rob: "GN2 web service handles the BXDs and uses the heterozygous calls." RI intercross designs, such as our BXD × BXD F1s, need them (Zou et al. 2005, *Genetics* 170:1299).

**Two requests, in the order we need them.** R/qtl2's `scan1()` already does both (Karl Broman's documentation), so GN4AI only has to pass them through:
- **Individual mice, with cofactors and kinship** (item 18). This is Rob's preferred design: "I actually prefer to use ALL of the data and map at the individual level with full cofactors. The kinship handles the variable number of individuals per genotype well." It needs repeated strain names, per-mouse covariates (diet, vivarium, birth year) and `intcovar` for gene × diet.
- **The direction of each effect** (item 21). R/qtl2 replies give the LOD only. The B − D effect per marker (`scan1coef`), or its sign, would let a map show which allele raises the trait.

**Strain means: please keep equal weights.** Rob: "The mean survivorship data MUST be mapped with kinship to be accurate. There is strong kinship in the BXD family." And: "It is a really bad idea to weight each strain by the number of mice... Much better would be to forget about any weighting, provided a strain has 3 or more per group. But even better is to simply map the individuals with a full kinship correction." GN4AI's R/qtl2 already does equal weights with LOCO kinship, so weights for strain means (item 19) are low priority.

**pangemma agrees with GEMMA** (item 23). On chow its rows are identical to gemma-gn2's; on high fat they differ by at most 0.001 in −log10 *p*. Each run took 15 s.

**The other items:**
- **In SKILL.md:**
  - the sparse clone fails (item 1);
  - "There are no write endpoints" is wrong (2);
  - baskets can be mapped by every engine, not just `/compute/qtl2` (3);
  - permutation timings (4);
  - the inline route deserves a mention beside baskets (22).
- **In the replies:**
  - PATCH reports 186 values for a column of 93 (5);
  - R/qtl rows sit in `.data.markers` (7);
  - `next` links hold unfilled templates (8);
  - server paths appear in notes (9);
  - the R/qtl scan, set up as a `riself` cross, drops heterozygous calls without saying so (10);
  - a duplicate basket gets 422 rather than 409 (11);
  - R/qtl2 calls its LODs −log10 *p* (13).
- **In the data, for Arthur and Suheeta as much as for you:**
  - the lifespan traits 18441, 18435 and 24754 are older than the curated file (16);
  - their stored LODs cannot be reproduced from their current values (17).

Best,
Opus 5.5 Extra (prompted by Rob)
