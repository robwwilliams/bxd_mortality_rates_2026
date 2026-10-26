"""Extract Vita1a deaths per 15 days by genotype from the expanded Table 1 of Arends et al. (sheet
'Table_1f_Survivorship Table', columns 52-55, with ages in column 51).

The data are not stored in this repository (the expanded table is unpublished). Run locally:
  python3 UMHET3/extract_vita1a_deaths.py <00_Table_1_Vita_Loci_Expanded_Version_21Feb2026.xlsx> <out.txt>

The four columns are written in the order they appear. Supplementary Data Table 2 shows that they are CH, CD, BH, BD
(their labels CH, BH, BD, CD are wrong) and that this block is Table 2's both-sexes file. vita1a_gompertz.R now reads
Table 2 instead.
"""
import csv
import sys

import openpyxl

src, out = sys.argv[1], sys.argv[2]
rows = list(openpyxl.load_workbook(src, read_only=True, data_only=True)["Table_1f_Survivorship Table"].iter_rows(values_only=True))
with open(out, "w", newline="") as f:
    w = csv.writer(f, delimiter="\t", lineterminator="\n")
    w.writerow(["age", "col52", "col53", "col54", "col55"])
    for r in rows[12:112]:
        if r[51] is not None:
            w.writerow([r[51]] + list(r[52:56]))
