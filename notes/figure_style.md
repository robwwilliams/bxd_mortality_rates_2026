# Figure and legend style: Nature Portfolio

We plan to submit to a Nature-series journal. Figures and legends follow Arends et al. 2026 (*Nature* 654:437; in `papers/`) and Nature's figure guidelines. Check the target journal's current guide before submission.

## Figures

- **Width at final size:** 89 mm (single column), 120–136 mm (1.5 columns) or 183 mm (double column). Maximum height about 247 mm.
- **Text:**
  - 5–7 pt at final size, in Arial (or Helvetica).
  - Panel letters are 8 pt, bold, lowercase, with no period: **a**, **b**.
  - Axis labels are in sentence case, with units in parentheses: "Age (days)".
  - Panels carry no titles.
- **Files:** vector, with editable text. Our SVGs come from `svglite`, with every label one text element; the PNGs are previews only. RGB color; line weights of at least 0.25 pt.
- **Colors:**
  - chow (CD) is brown `#a86a28`; high fat (HF, the "blue diet") is blue `#2a78d6`. The pair passes the contrast and color-blind checks.
  - **Haplotypes follow Arends et al. 2026 (Fig. 2f):** B ("black") dark purple `#7d4598`; D ("dilute") orange `#ed8f22`. Their tan D (Fig. 3f, `#a97b4f`) is too close to the chow brown, so it is not used.
  - **F1 hybrids** are green `#008300`, and **inbred parents** pink `#e87ba4`. The four group colors pass the color-blind checks as a set. Orange and pink fall below 3:1 contrast, so every series is named in its key.
  - Use the same colors in every figure.
- **Arends-style conventions:**
  - T-age notation (T365) for survivorships.
  - Mean lines with s.e.m. as shaded bands at 50% opacity, drawn under the lines.
  - Kaplan–Meier curves labeled directly.
  - Numbers of mice shown where they matter.
- **Before submission:** the current SVGs are 7 inches (178 mm) wide with text at about 9 pt. When the final figures are assembled, rebuild the panels at 89 or 183 mm with 6–7 pt text, and combine them into multi-panel figures as in Arends et al. Fig. 1.

## Legends

- **Spelling:** British (Oxford), as in *Nature*: colour, grey, analysed, labelled, modelled, towards, but -ize endings (randomized). Everything else, including notes, code comments and messages to Rob, is American.
- **Opening:** a bold title stating the finding: "**Fig. 1 | A high-fat diet raises mortality at every age without changing the mortality rate doubling time.**" Extended Data figures use "Extended Data Fig. 1 |".
- **Panels:** one description per panel, with bold panel letters: "**a**, ...", "**b**, ..."; "**a**,**b**, ..." for a pair.
- **Italic:** statistical symbols (*n*, *P*, *r*, *t*, *χ*², *I*²), axis letters (*x* axis), and gene symbols.
- **Every mark defined:** for example, "Lines indicate mean and shaded bands represent s.e.m.", "Points indicate estimates and bars indicate 95% CI".
- **Statistics:**
  - n per group, with thousands separators (n = 1,044);
  - the test, named;
  - exact P values with a capital P (P = 0.035);
  - whether P values are corrected for multiple tests.
- **Wording:** "days" spelled out; "s.e.m."; "95% CI"; "d.f.".
- **Length:** Rob prefers longer legends that carry the statistics (26 October 2026): the test, *n*, d.f., exact *P*, whether *P* is corrected, and which analyses are exploratory. Reviewers look for these details in the legends.
- **The current legends,** written in this style, are in `output/Figure_legends.md`.
