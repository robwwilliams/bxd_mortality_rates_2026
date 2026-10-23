"""Annotated copy of the BDL_10002 export for curation.

Usage:
    python qc/annotate_bdl10002.py data/original/BDL_10002.xlsx ROY2018_DATA_DIR OUT.xlsx

ROY2018_DATA_DIR is the data/ folder of genenetwork/bxd_gxelongevity_2020. The output
keeps every original row in its original order and every original cell unchanged. It
inserts seven columns at the far left: QC priority, QC codes, QC note, proposed Value,
proposed Longevity, and two blank columns for the curator's decision and note. A second
sheet, "QC legend", defines the codes and counts them.
"""
import itertools
import sys
from collections import defaultdict

import numpy as np
import openpyxl
import pandas as pd
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.worksheet.datavalidation import DataValidation

src, roy_dir, out = sys.argv[1:4]
HEADER_ROW = 11  # GeneNetwork puts 10 rows of metadata above the column headers

d = pd.read_excel(src, header=HEADER_ROW - 1)
d["row"] = d.index + HEADER_ROW + 1  # worksheet row of each animal
d["value"] = pd.to_numeric(d.Value, errors="coerce")
d["prefix"] = d.Name.str.extract(r"^([A-Za-z]+)")[0]
d["strain_key"] = d.Strain.str.replace(r"^BXD0*", "BXD", regex=True)

xl = f"{roy_dir}/AgingBXD_Longevitydata_Nov2018.xlsx"
roy_nat = pd.read_csv(f"{roy_dir}/AgingBXD_Longevitydata_Nov2018.natural.deaths.txt", sep="\t")
for c in ("DateOfBirth", "DateOfDeath"):
    roy_nat[c] = pd.to_datetime(roy_nat[c], format="%m.%d.%Y")
roy_alive = pd.read_csv(f"{roy_dir}/AgingBXD_Longevitydata_Nov2018.alive.txt", sep="\t")
roy_excl = pd.read_excel(xl, sheet_name="OthersLowOutliers")
for t in (roy_nat, roy_alive, roy_excl):
    t["strain_key"] = t.StrainNameCurrent.astype(str).str.replace(r"^BXD0*", "BXD", regex=True)
key = ["EarTag", "strain_key"]
rkey = ["EarTagNumberCurrent", "strain_key"]

flags = defaultdict(list)  # Name -> list of (priority, code, note)
proposed_value, proposed_longevity = {}, {}


def add(name, priority, code, note):
    flags[name].append((priority, code, note))


def day(x):
    return pd.Timestamp(x).strftime("%-d %b %Y")


# EXCLUDED_2018 and DUPLICATE: animals the 2018 curation set aside as Other or LowOutlier
ex = d.merge(roy_excl, left_on=key, right_on=rkey, suffixes=("", "_2018"))
same_day = roy_excl.groupby("DateOfDeath").size()
dup_tags = set(ex[ex.prefix == "H"].EarTag) & set(ex[ex.prefix == "L"].EarTag)
for r in ex.itertuples():
    n = same_day[r.DateOfDeath]
    when = f"died {day(r.DateOfDeath)}" + (f", one of {n} 2018 exclusions that died that day" if n > 1 else "")
    if r.prefix == "H":
        if r.EarTag in dup_tags:
            add(r.Name, 2, "DUPLICATE",
                f"Same animal as natural-death row L{r.EarTag:04d}. Keep this harvested row; delete the L row.")
        continue
    if r.EarTag in dup_tags:
        add(r.Name, 1, "DUPLICATE",
            f"Same animal as harvested row H{r.EarTag:04d}. Delete this row. 2018 cause: {r.CauseOfDeath}, {when}.")
        proposed_value[r.Name] = "delete row"
    else:
        add(r.Name, 1, "EXCLUDED_2018",
            f"Excluded from natural lifespan in Nov 2018 as \"{r.CauseOfDeath}\" ({when}). Set Value and Longevity to x.")
        proposed_value[r.Name] = proposed_longevity[r.Name] = "x"
excluded = set(ex.Name)

# VALUE_WRONG: Value disagrees with Age (only L0852)
nat = d[d.value.notna()].copy()
for r in nat[nat.value != nat.Age].itertuples():
    add(r.Name, 1, "VALUE_WRONG",
        f"Value {r.Value} but Age and Longevity are {r.Age}; the Nov 2018 record also gives {r.Age} d.")
    proposed_value[r.Name] = r.Age

# LONGEVITY_BLANK: Value and Longevity should be identical
for r in d[d.Longevity.isna()].itertuples():
    add(r.Name, 1, "LONGEVITY_BLANK", f"Longevity is blank; it should equal Value ({r.Value}).")
    proposed_longevity.setdefault(r.Name, r.Value)

# STRAIN_NAME: one strain spelled two ways when case is ignored
for _, g in d.groupby(d.Strain.str.lower()):
    if g.Strain.nunique() > 1:
        counts = g.Strain.value_counts()
        for r in g[g.Strain == counts.idxmin()].itertuples():
            add(r.Name, 1, "STRAIN_NAME", f"Strain should be {counts.idxmax()} (as for {counts.max()} other animals).")

# TAG_SHARED: one ear tag, two strains
for tag, g in d[d.EarTag.duplicated(keep=False)].groupby("EarTag"):
    if g.strain_key.nunique() > 1:
        for r in g.itertuples():
            other = g[g.Name != r.Name].iloc[0]
            add(r.Name, 2, "TAG_SHARED",
                f"Ear tag {tag} is also {other.Name} ({other.Strain}, {other.Sex}, {other.Tx}). Check colony records.")

# ALIVE_LATER: died before an age at which it was recorded alive (15 Nov 2018)
m = nat.merge(roy_alive, left_on=key, right_on=rkey, suffixes=("", "_2018"))
for r in m[m.value < m.AgeIfStllAlive].itertuples():
    add(r.Name, 2, "ALIVE_LATER",
        f"Recorded alive at {r.AgeIfStllAlive} d on 15 Nov 2018, but Value is {r.Value}. Check dates.")

# AGE_DIFFERS_2018: age at death differs from the Nov 2018 natural-death record
m = nat.merge(roy_nat, left_on=key, right_on=rkey, suffixes=("", "_2018"))
accepted_2018 = set(m.Name)
for r in m[m.value != m.AgeAtDeath].itertuples():
    if r.Name in flags and any(c == "VALUE_WRONG" for _, c, _ in flags[r.Name]):
        continue
    add(r.Name, 2, "AGE_DIFFERS_2018",
        f"Nov 2018 record: {r.AgeAtDeath} d (born {day(r.DateOfBirth)}, died {day(r.DateOfDeath)}). Check dates.")

# The remaining checks use natural deaths after removing the 2018 exclusions
keep = nat[~nat.Name.isin(excluded)].copy()

# EARLY_DEATH: natural death before 200 d
for r in keep[keep.value < 200].itertuples():
    if r.Name in accepted_2018:
        add(r.Name, 3, "EARLY_DEATH", f"Died at {int(r.value)} d; accepted as a natural death in Nov 2018.")
    else:
        add(r.Name, 2, "EARLY_DEATH",
            f"Died at {int(r.value)} d; added since 2018. Check cause of death against the 2018 rules.")

# SAME_DAY: cage-mates (same strain and diet, ear tags within 5) with the same age at death
groups = []
for _, g in keep.groupby(["Strain", "Tx", "value"]):
    if len(g) < 2:
        continue
    tags = sorted(g.EarTag)
    cluster = [tags[0]]
    for t in tags[1:]:
        if t - cluster[-1] <= 5:
            cluster.append(t)
        else:
            groups.append((g, cluster))
            cluster = [t]
    groups.append((g, cluster))
for g, cluster in groups:
    if len(cluster) < 2:
        continue
    members = g[g.EarTag.isin(cluster)]
    new = [n for n in members.Name if n not in accepted_2018]
    priority = 2 if len(cluster) >= 3 and new else 3
    for r in members.itertuples():
        others = ", ".join(n for n in members.Name if n != r.Name)
        status = "all accepted as natural in 2018" if not new else "check cause of death"
        add(r.Name, priority, "SAME_DAY", f"Died at {int(r.value)} d, same day as cage-mate(s) {others}; {status}.")

# OUTLIER: more than 3.5 robust SD from the strain x diet x sex median (groups of 6 or more)
grp = keep.groupby(["Strain", "Tx", "Sex"]).value
keep["n"] = grp.transform("size")
keep["med"] = grp.transform("median")
keep["mad"] = grp.transform(lambda s: 1.4826 * (s - s.median()).abs().median())
keep["z"] = (keep.value - keep.med) / keep.mad.replace(0, np.nan)
mixups = {"L0101": "neighboring tags L0097-L0100 are BXD12; possible strain mix-up",
          "L0102": "neighboring tags L0097-L0100 are BXD12; possible strain mix-up",
          "L0481": "whole cage L0481-L0484 lived 1,088-1,229 d; possible strain mix-up",
          "L0482": "whole cage L0481-L0484 lived 1,088-1,229 d; possible strain mix-up",
          "L0483": "whole cage L0481-L0484 lived 1,088-1,229 d; possible strain mix-up",
          "L0484": "whole cage L0481-L0484 lived 1,088-1,229 d; possible strain mix-up"}
for r in keep[(keep.n >= 6) & (keep.z.abs() > 3.5)].itertuples():
    note = f"{int(r.value)} d vs median {r.med:.0f} d for {r.Strain} {r.Tx} {r.Sex} (n={r.n}, robust z {r.z:+.1f})"
    if r.Name in mixups:
        add(r.Name, 2, "OUTLIER", note + "; " + mixups[r.Name] + ".")
    else:
        add(r.Name, 3, "OUTLIER", note + ".")

# RRID: placeholder, or the RRID most rows of another strain carry
for r in d[d.RRID.astype(str).str.contains("GET")].itertuples():
    add(r.Name, 3, "RRID", f"RRID {r.RRID} is a placeholder; enter the JAX stock number for {r.Strain}.")
for s, g in d.dropna(subset=["RRID"]).groupby("Strain"):
    counts = g.RRID.value_counts()
    for r in g[g.RRID != counts.index[0]].itertuples():
        add(r.Name, 3, "RRID", f"RRID {r.RRID}, but most {s} rows carry {counts.index[0]}.")

# METADATA_BLANK: RRID or Epoch blank although the strain has one elsewhere
rrid = d.dropna(subset=["RRID"]).groupby("Strain").RRID.agg(lambda s: s.value_counts().index[0])
epoch = d.dropna(subset=["Epoch"]).groupby("Strain").Epoch.agg(lambda s: s.value_counts().index[0])
for r in d.itertuples():
    missing = []
    if pd.isna(r.RRID) and r.Strain in rrid:
        missing.append(f"RRID ({rrid[r.Strain]})")
    if pd.isna(r.Epoch) and r.Strain in epoch:
        missing.append(f"Epoch ({epoch[r.Strain]})")
    if missing:
        add(r.Name, 3, "METADATA_BLANK", "Blank but known for this strain: " + ", ".join(missing) + ".")

# --- write the workbook ---------------------------------------------------------------
NEW = ["QC priority", "QC codes", "QC note", "Proposed Value", "Proposed Longevity",
       "Curator decision", "Curator note"]
k = len(NEW)
wb = openpyxl.load_workbook(src)
ws = wb.active
ws.insert_cols(1, k)

font = Font(name="Calibri", size=11)
bold = Font(name="Calibri", size=11, bold=True)
qc_fill = PatternFill("solid", fgColor="DCE6F1")      # added QC columns
input_fill = PatternFill("solid", fgColor="FFFF99")   # for the curator to fill in
priority_fill = {1: PatternFill("solid", fgColor="F4B6B6"), 2: PatternFill("solid", fgColor="FCE4B6"),
                 3: PatternFill("solid", fgColor="E7E6E6")}

ws.cell(1, 1, "QC annotations added 23 October 2026. Columns A-G are new; all other cells are the "
              "original GeneNetwork export, unchanged. See sheet \"QC legend\".").font = bold
for j, h in enumerate(NEW, start=1):
    c = ws.cell(HEADER_ROW, j, h)
    c.font = bold
    c.fill = input_fill if j > 5 else qc_fill

by_row = dict(zip(d.Name, d.row))
for name, items in flags.items():
    items.sort()
    row = by_row[name]
    codes = []
    for _, code, _ in items:
        if code not in codes:
            codes.append(code)
    values = [min(p for p, _, _ in items), "; ".join(codes), " | ".join(note for _, _, note in items),
              proposed_value.get(name), proposed_longevity.get(name)]
    for j, v in enumerate(values, start=1):
        c = ws.cell(row, j, v)
        c.font = font
    ws.cell(row, 1).fill = priority_fill[values[0]]
    ws.cell(row, 1).alignment = Alignment(horizontal="center")
for row in range(HEADER_ROW + 1, ws.max_row + 1):
    for j in (6, 7):
        ws.cell(row, j).fill = input_fill
        ws.cell(row, j).font = font

dv = DataValidation(type="list", formula1='"Accept,Reject,Modify,Pending"', allow_blank=True)
dv.add(f"F{HEADER_ROW + 1}:F{ws.max_row}")
ws.add_data_validation(dv)
for col, width in zip("ABCDEFG", (11, 30, 90, 15, 18, 17, 40)):
    ws.column_dimensions[col].width = width
ws.freeze_panes = ws.cell(HEADER_ROW + 1, k + 3)  # keep QC columns, Index and Name in view
ws.auto_filter.ref = f"A{HEADER_ROW}:{openpyxl.utils.get_column_letter(ws.max_column)}{ws.max_row}"

# Legend sheet
lg = wb.create_sheet("QC legend")
first, last = HEADER_ROW + 1, ws.max_row
rows = [
    ("QC annotations for the BDL_10002 export of 22 October 2026", None, None, None),
    ("Rows are in the original order and original cells are unchanged. Filter column A or B on Sheet1 to work through them.", None, None, None),
    (None, None, None, None),
    ("Priority", "Meaning", "Rows", None),
    (1, "Clear error; a correction is proposed", f'=COUNTIF(Sheet1!$A${first}:$A${last},1)', None),
    (2, "Check against colony records before mapping", f'=COUNTIF(Sheet1!$A${first}:$A${last},2)', None),
    (3, "Minor or for information: metadata, outliers, early deaths accepted in 2018", f'=COUNTIF(Sheet1!$A${first}:$A${last},3)', None),
    (None, None, None, None),
    ("Code", "Meaning", "Rows", "Word report fix"),
]
codes_def = [
    ("DUPLICATE", "Animal listed both as a natural death (L) and as harvested (H). Delete the L row; keep the H row.", "1"),
    ("EXCLUDED_2018", "Set aside in the Nov 2018 curation as \"Other\" or \"LowOutlier\", but entered here as a natural death.", "2"),
    ("VALUE_WRONG", "Value disagrees with Age, Longevity and the 2018 record.", "3"),
    ("LONGEVITY_BLANK", "Longevity is blank; it should equal Value (x for harvested).", "4"),
    ("STRAIN_NAME", "Strain spelled differently from other animals of the same strain.", "5"),
    ("TAG_SHARED", "Ear tag also used by an animal of a different strain.", "6"),
    ("ALIVE_LATER", "Died before an age at which the animal was recorded alive in Nov 2018.", "7"),
    ("AGE_DIFFERS_2018", "Age at death differs from the Nov 2018 natural-death record.", "8"),
    ("EARLY_DEATH", "Natural death before 200 d. Priority 2 if added since 2018, 3 if accepted in 2018.", "9"),
    ("SAME_DAY", "Same age at death as a cage-mate (same strain and diet, ear tags within 5). Priority 2 for groups of 3+ added since 2018.", "9"),
    ("OUTLIER", "More than 3.5 robust SD from the strain x diet x sex median (n of 6 or more, after removing 2018 exclusions).", "-"),
    ("RRID", "RRID is a placeholder, or matches a different strain.", "10"),
    ("METADATA_BLANK", "RRID or Epoch blank although other rows of this strain have it.", "-"),
]
for code, meaning, fix in codes_def:
    f = (f'=SUMPRODUCT(--ISNUMBER(SEARCH("{code};",SUBSTITUTE(Sheet1!$B${first}:$B${last}," ","")&";")))')
    rows.append((code, meaning, f, fix))
rows += [
    (None, None, None, None),
    ("Columns added to Sheet1", None, None, None),
    ("QC priority", "Highest priority among the row's flags (1 is highest).", None, None),
    ("QC codes", "All codes for the row, separated by semicolons.", None, None),
    ("QC note", "One note per code, separated by |.", None, None),
    ("Proposed Value / Longevity", "Proposed replacement, where one is proposed. \"delete row\" means remove the row.", None, None),
    ("Curator decision", "For the curator: Accept, Reject, Modify or Pending (yellow).", None, None),
    ("Curator note", "For the curator: free text (yellow).", None, None),
    (None, None, None, None),
    ("Not annotated (no row to annotate)", None, None, None),
    ("Three animals alive on 15 Nov 2018 are missing from the export: BXD199 (tag 2773), BXD16 (tag 2686) and DBA/2J-Gpnmb (tag 2591).", None, None, None),
    (None, None, None, None),
    ("Sources: November 2018 data in github.com/genenetwork/bxd_gxelongevity_2020 (data/AgingBXD_Longevitydata_Nov2018.xlsx). "
     "Script: qc/annotate_bdl10002.py in github.com/robwwilliams/bxd_mortality_rates_2026.", None, None, None),
]
for i, r in enumerate(rows, start=1):
    for j, v in enumerate(r, start=1):
        if v is not None:
            c = lg.cell(i, j, v)
            c.font = bold if (i in (1, 4, 9) or r[0] == "Columns added to Sheet1"
                              or str(r[0]).startswith("Not annotated")) else font
            c.alignment = Alignment(wrap_text=j == 2, vertical="top")
for col, width in zip("ABCD", (30, 95, 8, 16)):
    lg.column_dimensions[col].width = width
wb.save(out)

n_by_code = defaultdict(int)
for items in flags.values():
    for c in {code for _, code, _ in items}:
        n_by_code[c] += 1
print("annotated rows:", len(flags))
print("by priority:", pd.Series([min(p for p, _, _ in v) for v in flags.values()]).value_counts().sort_index().to_dict())
print("by code:", dict(sorted(n_by_code.items())))
