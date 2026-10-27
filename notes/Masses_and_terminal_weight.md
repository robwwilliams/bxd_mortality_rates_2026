# Do tumors hide terminal weight loss? Notes and results

**Exploratory, 27 October 2026,** written after the Part 4 results were seen.
- **Code:** `BodyWeight/masses_notes.R`.
- **Output:** `output/Masses_notes.txt` (every mouse with a mass or a necropsy note, with its note) and `output/Masses_notes.log`.

Rob's question:

> "Fascinating that some mice resist weight loss but not death. Solid tumors? What types of murine cancers associated with tumor weights of 2 to 6 g? We may have some data for Roy et al. 2021 in which we did a bit of pathology."

The observation behind it: 25–34% of our mice were still within 10% of their peak weight in their last month.

## In brief

- **A large mass can hide wasting.** We have vivid cases. BXD184 mouse 3057 died at 150% of its peak weight. At necropsy its abdomen was full of milky fluid, with a large mass in the mesentery and masses in the liver.
- **But masses do not explain most mice that die without losing weight.**
  - Among mice weighed within a week of death, those with a recorded mass were no closer to their peak than mice with no such note. Within strain, the difference was −0.05 of peak (95% CI −0.14 to +0.04).
  - Of the 96 mice at 95% of peak or more at death, 31 (32%) had a mass recorded, against 26% of the 326 below it.
- **The masses most likely to weigh 2–6 g in old B6, D2 and BXD females:**
  - **Blood-cell cancers:** lymphoma and histiocytic sarcoma, which swell the spleen, liver and mesenteric lymph nodes, and the uterus in the case of histiocytic sarcoma;
  - **fluid:** ascites, blood in the abdomen, fluid in the chest, cysts;
  - **other masses:** liver tumors, uterine masses and ovarian tumors or cysts.
- **Roy et al. 2021 has the pathology we need, but only as totals.** A veterinary pathologist necropsied 155 BXD females. The per-mouse diagnoses would let us test Rob's idea properly.

## What the literature says (a short lesson)

**Tumor weight masks wasting.** Cancer-cachexia studies weigh the carcass without the tumor for exactly this reason.
- In mice carrying the C26 colon tumor, a 2.7 g tumor sat in a body whose carcass was 12 g lighter than in controls (Tanaka et al. 1990, *Cancer Res* 50:2290, PMID 2317817).
- In female mice with ovarian cancer and ascites, total weight was higher than in controls, while the carcass had lost 12% and the thigh muscle 38% (Pin et al. 2018, *J Cachexia Sarcopenia Muscle* 9:685, [doi:10.1002/jcsm.12311](https://doi.org/10.1002/jcsm.12311)).
- A chow-fed BXD female weighs about 30 g, so a 3 g mass hides a 10% loss.

**Which lesions reach several grams in old B6 and D2 females.** Pathology papers report how often lesions occur, almost never their weight in grams, so the masses below are rough.

| Lesion | Where | How common | Source |
|---|---|---|---|
| Lymphoma | spleen, mesenteric lymph nodes, liver | the commonest cause of death in old B6; with histiocytic sarcoma, about 35% of necropsied BXD females on both diets | Blackwell et al. 1995; Brayton et al. 2012; Roy et al. 2021 |
| Histiocytic sarcoma | uterus, liver, spleen | common in B6 females; can replace the whole uterus | Pettan-Brewer & Treuting 2011 |
| Liver tumors | liver | carcinomas (liver and skin) in 15 of 76 necropsied chow BXDs, against 4 of 79 on high fat | Roy et al. 2021 |
| Hemangiosarcoma | spleen, liver; bleeds into the abdomen | among the sarcomas of 11 chow and 6 high-fat BXDs | Roy et al. 2021 |
| Uterine smooth-muscle tumors | uterus | a DBA/2 lesion, carried into B6D2F1 mice | Harbison et al. 2016 |
| Fluid | abdomen, chest, cysts | with tumors, or with heart failure, which was in 15 of 79 necropsied BXDs on high fat and 1 on chow | Roy et al. 2021 |

- **The opposite case is pituitary tumors.** They are common in old B6 females but weigh milligrams, so a mouse dying of one should look thin.
- **No study we found compares terminal weight loss by cause of death in mice.** Our data could be the first.

**References**, all checked against PubMed:
- Roy S, … Williams RW 2021. *Nat Metab* 3:1217 ([doi:10.1038/s42255-021-00449-w](https://doi.org/10.1038/s42255-021-00449-w)). Table 1 and Methods: 155 necropsies; most bodies were fixed whole in formalin within 24 h of death.
- Brayton CF, Treuting PM, Ward JM 2012. *Vet Pathol* 49:85 ([doi:10.1177/0300985811430696](https://doi.org/10.1177/0300985811430696)).
- Blackwell BN, Bucci TJ, Hart RW, Turturro A 1995. *Toxicol Pathol* 23:570 ([doi:10.1177/019262339502300503](https://doi.org/10.1177/019262339502300503)).
- Pettan-Brewer C, Treuting PM 2011. *Pathobiol Aging Age Relat Dis* 1:7202 ([doi:10.3402/pba.v1i0.7202](https://doi.org/10.3402/pba.v1i0.7202)).
- Harbison CE, Lipman RD, Bronson RT 2016. *Vet Pathol* 53:468 ([doi:10.1177/0300985815612152](https://doi.org/10.1177/0300985815612152)).
- Snyder JM, Ward JM, Treuting PM 2016. *Vet Pathol* 53:233 ([doi:10.1177/0300985815610391](https://doi.org/10.1177/0300985815610391)), on cause-of-death analysis in aging studies.
- Lipman R, Galecki A, Burke DT, Miller RA 2004. *J Gerontol A* 59:977 ([doi:10.1093/gerona/59.10.b977](https://doi.org/10.1093/gerona/59.10.b977)). Loci on Chr 1 and Chr 4 changed lymphoma risk in a four-way cross like UM-HET3. Whether the Chr 1 locus is proximal is not yet checked.

## What our own records show

**The only pathology in our files is free text,** in the columns `NotesByRoy` and `NotesByIngels` of the BXD workbook.
- 85 mice of the Part 4 sample have notes from a necropsy, nearly all born in 2018–2019.
- 63 of the 85 had an internal mass, an enlarged organ or fluid.
- The organs named most often are the liver (30 mice) and spleen (27), then the ovary (15), the uterus (10), blood in a body cavity (19) and fluid (18).
- That pattern fits lymphoma and histiocytic sarcoma, with bleeding tumors and ovarian cysts.

**Last weight as a fraction of peak, in mice weighed within 7 days of death:**

| Note | Status | Mice | Median | At 95% of peak or more |
|---|---|---|---|---|
| a mass, swelling or fluid | euthanized | 87 | 0.83 | 31% |
| nothing of the kind | euthanized | 93 | 0.83 | 34% |
| thin, no mass | euthanized | 15 | 0.59 | 0% |
| a mass, swelling or fluid | natural death | 30 | 0.77 | 13% |
| nothing of the kind | natural death | 181 | 0.72 | 18% |
| thin, no mass | natural death | 16 | 0.67 | 6% |

- **The mass groups look like the rest.** Within strain, adjusted for diet, status and the days from the last weighing to death, mice with a mass ended 0.05 of peak *lower* (95% CI −0.14 to +0.04, *P* = 0.28).
- **Necropsied mice with a mass:** 17 of the 45 weighed within a week of death were still at 95% of peak or more.
- **Caution:** "nothing of the kind" means nothing written down. Most mice were never necropsied, so many internal tumors went unrecorded. That blurs the contrast.

**So the answer, for now:**
- A big tumor or a belly full of fluid can hold a dying mouse at its peak weight, and we have mice that did exactly that.
- As recorded, though, masses explain only a minority of the mice that die without losing weight.
- The rest may have had unrecorded internal tumors, or died of something quick, such as heart failure, a bleed or an infection, before wasting could start.

## What would settle it

1. **The per-mouse diagnoses behind Roy et al. 2021 Table 1** (155 mice). With them we can compare the last months of weight between lymphoma deaths, other cancers, heart deaths and the rest. Who holds that list, Suheeta or the pathologist?
2. **The bodies in formalin.**
   - "Formalin" appears in the notes of 365 mice of the Part 4 sample.
   - If those bodies still exist, weighing the tumor-free carcass, or simply the spleen, liver and uterus, would measure the masking directly.
   - It would fit the small post-mortem study Rob proposed for the last gap.
3. **Organ weights at necropsy from now on.** Weighing the spleen, liver and uterus, and any mass, would take a few minutes per mouse.
