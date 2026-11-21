# GN4AI-beta test drive: BXD lifespan strain means

**Exploratory, 21 November 2026.** Opus 5.5 Extra (Claude, Anthropic) ran it at Rob Williams's request, after Pjotr Prins asked Rob to test GN4AI-beta before its release this week. Rob: "What we might try to do using Beni's updated and corrected file is some mapping that Danny has already done."
- **Code:** [`GN4AI/strain_means.R`](../GN4AI/strain_means.R) builds the strain means, [`GN4AI/test_drive.sh`](../GN4AI/test_drive.sh) sends and maps them, and [`GN4AI/compare_Danny.R`](../GN4AI/compare_Danny.R) sets the scans beside Danny's.
- **Outputs:** [`output/GN4AI/`](../output/GN4AI/), including every call's timing (`timings.txt`), every scan (`*.tsv.gz`) and GeneNetwork's own plots (`*.svg`).
- **Service:** https://vesuvio.pu.ac.ke/gn4, build `5b68da6-dirty` of 21 November 2026. SKILL.md was read from the docs repository at commit `a621bb3` (19 November); Rob's copy of 11 November predates baskets and the ravanan runner.

## In brief

- **It works.** 37 timed calls, all answered: baskets, R/qtl, GEMMA through both runners, permutations and plots. The only refusal was the intended one, a basket name already in use.
- **We repeated Danny Arends's strain-means maps (his Fig. 2, top two rows).** The strain means are at T-age 20, so every mouse counts, and they come from Beni Mozhui's corrected file.
- **High fat: GeneNetwork finds Danny's two peaks,** on proximal Chr 1 at 23.5 Mb, in the Vita1a–Vita1b interval, and on Chr 2 at 157.5 Mb. Both clear R/qtl's significance threshold from 1,000 permutations.
- **Chow: nothing is significant, in GeneNetwork or in Danny's maps.** The top marker differs: Chr 10 in GeneNetwork, Chr 2 in Danny's.
- **The two differ because Danny weights each strain mean by its number of mice.** GeneNetwork cannot weight. A local check reproduces both maps (r = 0.98 to 0.999).
- **Beni's corrected NAM ages change three strain means, by 8 to 24 days, but not the map.** The largest change in LOD is 0.11, and nothing is significant either way.
- **Speed.** One scan takes 8 s. GEMMA takes 10–22 s the first time and 4 s when cached. 1,000 permutations take from 22 s to nearly 8 minutes.
- **GeneNetwork's published lifespan traits are older than the curated file.** They have fewer strains, and some strain means differ: BXD86 on high fat is 610 days in GeneNetwork against 724 in the file.

## What we sent

Strain means of age at death, following Danny's rule: at a T-age, each strain with at least 3 mice alive beyond it, set-up age ignored, parents and F1s left out. This rule gives his strain counts (`qc/Mapping_files_QC.md`). Each column went to GeneNetwork as a basket, a private column of values that the compute calls can map by name.

| Basket | Diet | Ages from | Strains | Mice |
|---|---|---|---|---|
| `lifespan_CD_T20` | chow | Beni's file (the same as Danny's on chow) | 93 | 897 |
| `lifespan_HF_T20` | high fat | Beni's file (the same as Danny's on high fat) | 87 | 800 |
| `lifespan_NAM_T20_Beni` | NAM | Beni's file: four corrected ages | 21 | 135 |
| `lifespan_NAM_T20_Danny` | NAM | Danny's file: one corrected age | 21 | 135 |

All 93, 87 and 21 strain means aligned onto GeneNetwork's BXD.8 genotypes by name.

## Timings

Wall-clock times from Rob's Mac, every call in `output/GN4AI/timings.txt`.

| Step | Seconds | Reply |
|---|---|---|
| Store or revise a basket | 0.2 | 1 kB |
| Fetch a trait's values | 0.2 | 4–12 kB |
| R/qtl scan, 21,056 markers | 7.5–7.9 | 1.1 MB |
| R/qtl with 1,000 permutations | 221 (chow, 93 strains), 463 (high fat, 87), 21–22 (NAM, 21) | 1.1 MB |
| GEMMA through ravanan, first run | 21.6 (chow), 15.3 (high fat), 15.4 and 9.8 (NAM) | 2.1 MB |
| GEMMA, repeated (cached) | 4.3 | 2.1 MB |
| `/compute/gemma` (the wrapper runner) | 4.2–4.4 | 2.1 MB |
| A plot | 0.8–1.5 (one of 4.9) | 0.26 MB |

## Results

| Basket | Engine | Strongest marker | Chr, Mb | Score | R/qtl thresholds, 1,000 permutations |
|---|---|---|---|---|---|
| chow | R/qtl | rsm10000007009 | 10, 66.6 | LOD 2.17 | significant 3.70, suggestive 2.76 |
| chow | GEMMA | rsm10000007009 | 10, 66.6 | −log10 *p* 2.67 | |
| high fat | R/qtl | rsm10000001145 | 2, 157.5 | LOD 4.47 | significant 3.75, suggestive 2.79 |
| high fat | R/qtl, next peak | rsm10000000521 | 1, 23.5 | LOD 4.44 | |
| high fat | GEMMA | rsm10000000521 | 1, 23.5 | −log10 *p* 5.08 (Chr 2: 4.69) | |
| NAM, Beni's ages | R/qtl | rsm10000001229 | 2, 45.6 | LOD 2.33 | significant 3.50, suggestive 2.69 |
| NAM, Danny's ages | R/qtl | rsm10000001229 | 2, 45.6 | LOD 2.38 | significant 3.53, suggestive 2.70 |
| NAM, Beni's / Danny's ages | GEMMA | rsm10000013988 | 19, 12.5 | −log10 *p* 3.70 / 3.77 | |

- **R/qtl reports LOD and GEMMA reports −log10 *p*.** The two scales differ, so 5.08 and 4.44 at the same marker do not disagree.
- **On chow, kinship explains almost none of the variance in the strain means.** GEMMA's PVE is 0 to 0.08, depending on the chromosome left out, so GEMMA comes close to a plain regression and tracks R/qtl at r = 0.99 over markers.
- **On high fat, kinship explains more,** with PVE up to 0.60. GEMMA then departs further from R/qtl (r = 0.90), as on Chr 15.

### Chow and high fat beside Danny's maps

![GN4AI scans beside Danny Arends's strain-means maps](../output/GN4AI/GN4AI_vs_Danny.png)

*Danny's maps (black) beside GN4AI's R/qtl (diet color) and GEMMA (grey, dashed), as −log10 P at every marker. R/qtl's LOD is converted with the F test of the same regression. The dotted line is R/qtl's significance threshold from 1,000 permutations.*

- **On high fat, the two agree on the peaks.** Chr 2 at 157 Mb: 5.65 in Danny's map, 5.11 in R/qtl. Chr 1 at 23 Mb: 5.24 against 5.08.
- **On chow, they rank weak peaks differently.** Danny's strongest is Chr 2 at 157 Mb (3.00), where R/qtl gives 2.62. R/qtl's strongest is Chr 10 at 67 Mb (2.74), where Danny's map gives 1.62. All of these are below R/qtl's threshold, which is 4.33 on this scale.
- **Over all markers, Danny's maps correlate with GN4AI's R/qtl at r = 0.69 on chow and 0.80 on high fat.**

**Why: a lesson in weighting.** A strain mean from 20 mice is more precise than one from 3.
- **Danny's maps give each strain mean a weight equal to its number of mice.** Locally, on every 10th marker, a regression of strain means weighted that way matches his maps at r = 0.988 on chow and 0.981 on high fat.
- **GeneNetwork gives every strain the same weight.** The same regression without weights matches GN4AI's R/qtl at r = 0.997 and 0.999.
- **So each map is right for its own model.** The chow peak moves because the strains that carry it differ in how many mice they have.
- **Weighting is the better choice for these data,** where the number of mice per strain ranges from 3 to 23. GN4AI cannot do it yet (item 14 below).

### NAM: do Beni's corrected ages change the map?

- **Three strain means change.** BXD32 rises by 24.3 days, BXD62 by 19.6 and BXD172 by 7.7. NAM 4558 (BXD15) is corrected in both files.
- **The maps barely move.** Over markers, the two R/qtl scans correlate at r = 0.998, and the largest change in LOD is 0.11, on Chr 17. GEMMA's peak goes from 3.77 to 3.70.
- **Nothing is significant either way,** with only 21 strains. The corrections matter for the record, not for this map.

### GeneNetwork's own published lifespan traits

These are traits 18441 (chow), 18435 (high fat) and 24754 (NAM), from Suheeta Roy and colleagues. They are older than the curated mapping file.

| Trait | BXD strains in GeneNetwork | In the file | Shared strains that differ by more than 1 day |
|---|---|---|---|
| 18441, chow | 92 | 115 | BXD2 (420 days in GeneNetwork, 431 in the file), BXD69 (584, 615) |
| 18435, high fat | 85 | 99 | BXD22 (615, 563), BXD48 (522, 523), BXD86 (610, 724) |
| 24754, NAM | 23 | 26 | 11 of 23, among them BXD32 (602, 626), BXD65 (590, 658) and BXD70 (586, 655) |

- **The NAM trait was probably computed before the last NAM mice died.** In 9 of the 11 strains that differ, GeneNetwork's mean is the lower.
- **Mapped through GeneNetwork's own route,** 18441 peaks on Chr 2 at 157.3 Mb with LOD 2.67, and 18435 on Chr 1 at 23.5 Mb with LOD 4.47. These are the same regions as our baskets.
- **The trait records store higher LODs** at rsm10000001144: 3.13 for 18441 and 5.08 for 18435, against 2.67 and 3.95 recomputed. They probably come from an older mapping.

## For Pjotr: what to fix or consider

**In the docs**
1. **The sparse clone in SKILL.md, section 8, fails.** `git clone --depth 1 --sparse` gives "dumb http transport does not support shallow capabilities". A full clone works: 19 MB, 72 s.
2. **Section 4 says "There are no write endpoints".** Section 3 documents baskets, matrices and genotype uploads, and they work.
3. **The basket's "Stored" note says to map it with `/compute/qtl2`.** `/compute/rqtl`, `/compute/gemma` and `/compute/gemma/ravanan` take baskets too; we used all three.
4. **SKILL.md "100 permutations take about 14 s".** We saw 1,000 take 221 s (93 strains) and 463 s (87 strains), but 22 s with 21 strains. The time may scale with the number of strains, or with load.

**In the replies**

5. **The PATCH `/baskets/{name}` reply says `"values": 186` for a column of 93.** `GET .../values` and the mapping both show 93.
6. **`/compute/gemma` looks like ravanan, not gemma-wrapper.** Its rows are identical to `/compute/gemma/ravanan`'s to the last digit, it comes back in 4 s, and its notes name ravanan (slurm-api backend) as the runner. So the check in SKILL.md, "send the same body to both and compare rows", compares ravanan with itself.
7. **R/qtl replies put the rows in `.data.markers`,** beside `.data.permutation`, while GEMMA replies put them in `.data` itself. Scripts written from SKILL.md ("rows are positional") break on the first.
8. **Compute replies' `next` holds unfilled templates:** `/gn4/groups/BXD/genotypes/%7Bversion%7D/markers/rsm10000007009/classes?trait={trait_id}` and `/gn4/groups/unlisted/genotypes/{name}/frequencies`. A basket has no trait id. SKILL.md says every `next` link is a GET that returns 200.
9. **Notes and `x-plot-summary` show server paths,** such as `/home/wrk/tmp/ai-root/...` and `/gnu/store/...`. They end up in users' chats and repositories.
10. **R/qtl drops heterozygous calls silently.** Its status log shows "Omitting 230532 genotypes with code==2", 5,513 male X heterozygotes dropped, and X converted to an autosome. That is expected for `riself`, but the reply's notes do not say it, while GEMMA keeps H as 0.5.
11. **A basket name already in use gets a 422.** A 409 would be the usual code, with a pointer to PATCH.

**In the data (for Arthur Centeno and Suheeta Roy as much as for Pjotr)**

12. **The lifespan traits 18441, 18435 and 24754 are older than the curated file** (table above).
13. **A trait record's LOD differs from a fresh scan of the same values** (above). Saying where the stored LOD came from would help.

**Feature requests**

14. **Weights for strain means:** per-strain *n* or SE, as in GeneNetwork's "replicate average, SE, N". Danny's maps need them, and without them a chow map ranks its weak peaks differently.
15. **Mapping individual mice with a strain-level kinship,** as in Danny's Fig. 2, rows 3–4: individuals on both diets, main effects and gene × diet interaction. This needs samples that repeat a strain's name, and a covariate (diet) for each mouse.

## Reproduce

```bash
Rscript GN4AI/strain_means.R
GN4AI_TOKEN_FILE=/path/to/token bash GN4AI/test_drive.sh
Rscript GN4AI/compare_Danny.R
```

The token is never stored in the repository. `compare_Danny.R` also needs two files kept in `data/local/` (not in git): Danny's `QTL_Lifespan_05Nov2026.xlsx`, from `Arends_Figures_09Nov2026.zip`, and the BXD.8 genotypes in `BXD_final_Genotypes_DGA_RWW_21Dec2025_based_on_v050423.xlsx`.
