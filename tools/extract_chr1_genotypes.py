"""Extract proximal Chr 1 (to 35 Mb) from David Ashbrook's sequence-based BXD genotype workbook.

readxl cannot open the workbook (it has a broken internal relationship), so this step is in Python.
One marker (DA0000048.1) has its position in bp rather than Mb; it is converted.

Usage: python3 tools/extract_chr1_genotypes.py <genotype workbook> data/genotypes/BXD_genotypes_Chr1_0to35Mb.txt
"""
import csv
import sys

import openpyxl

src, out = sys.argv[1], sys.argv[2]
ws = openpyxl.load_workbook(src, read_only=True).worksheets[0]
rows = ws.iter_rows(min_row=45, values_only=True)          # row 45 holds the headers: Chr, Locus, cM, Mb, strains
hdr = list(next(rows))
n = max(i for i, h in enumerate(hdr) if h is not None) + 1
kept = 0
with open(out, "w", newline="") as f:
    w = csv.writer(f, delimiter="\t", lineterminator="\n")
    w.writerow(hdr[:n])
    for r in rows:
        if r[0] not in (1, "1"):
            break
        r = list(r[:n])
        if float(r[3]) > 1000:                              # position given in bp
            print("position in bp, converted to Mb:", r[1], r[3])
            r[3] = float(r[3]) / 1e6
        if float(r[3]) <= 35:
            w.writerow(r)
            kept += 1
print("markers written:", kept)
