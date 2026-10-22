"""QC of the GeneNetwork export of BDL_10002 (natural lifespan, BXD-Longevity).

Usage:
    python qc/qc_bdl10002.py BDL_10002.xlsx ROY2018_DATA_DIR OUT.csv

ROY2018_DATA_DIR is the data/ folder of genenetwork/bxd_gxelongevity_2020
(the November 2018 freeze used in Roy et al. 2021). Writes one row per flag.
"""
import itertools
import sys

import numpy as np
import pandas as pd

xlsx, roy_dir, out = sys.argv[1:4]

d = pd.read_excel(xlsx, header=10)  # first 10 rows are GeneNetwork metadata
d["value"] = pd.to_numeric(d.Value, errors="coerce")       # 'x' = harvested
d["longevity"] = pd.to_numeric(d.Longevity, errors="coerce")
d["prefix"] = d.Name.str.extract(r"^([A-Za-z]+)")[0]
d["strain_key"] = d.Strain.str.replace(r"^BXD0*", "BXD", regex=True)
nat = d[d.value.notna()].copy()

flags = []


def flag(rows, code, detail):
    for _, r in rows.iterrows():
        flags.append(dict(code=code, Name=r.Name, Strain=r.Strain, Sex=r.Sex, Tx=r.Tx,
                          Value=r.Value, EarTag=r.EarTag, detail=detail(r) if callable(detail) else detail))


# A1. One ear tag, one strain, listed both as a natural death and as harvested
dup = d[d.EarTag.duplicated(keep=False)]
for tag, g in dup.groupby("EarTag"):
    if g.strain_key.nunique() == 1 and set(g.prefix) >= {"H"}:
        flag(g[g.prefix != "H"], "A1_natural_and_harvested",
             f"same strain and tag also listed as harvested ({','.join(g.Name)}), age {g.Age.iloc[0]} d")
    elif g.strain_key.nunique() > 1:
        flag(g, "A2_tag_two_strains", f"tag {tag} used by {', '.join(g.Name + ' ' + g.Strain)}")

# A4. Value disagrees with Age or Longevity in the same row
m = nat[(nat.value != nat.Age) | (nat.longevity.notna() & (nat.value != nat.longevity))]
flag(m, "A4_value_vs_age", lambda r: f"Value {r.Value}, Age {r.Age}, Longevity {r.Longevity}")

# A5. Strain spelled two ways once case is ignored
for key, counts in d.groupby(d.Strain.str.lower()).Strain:
    if counts.nunique() > 1:
        rare = counts.value_counts().idxmin()
        flag(d[d.Strain == rare], "A5_strain_spelling",
             f"'{rare}' vs '{counts.value_counts().idxmax()}'")

# A6. RRID placeholders, and one RRID used for two strain names
flag(d[d.RRID.astype(str).str.contains("GET")], "A6_rrid", lambda r: f"RRID {r.RRID}")
for s, g in d.dropna(subset=["RRID"]).groupby("Strain"):
    counts = g.RRID.value_counts()
    if len(counts) > 1:  # flag rows that carry the minority RRID for their strain
        flag(g[g.RRID != counts.index[0]], "A6_rrid",
             lambda r, c=counts: f"RRID {r.RRID}; most {r.Strain} rows have {c.index[0]}")

# B. Comparison with the November 2018 freeze (Roy et al. 2021)
roy = pd.read_csv(f"{roy_dir}/AgingBXD_Longevitydata_Nov2018.natural.deaths.txt", sep="\t")
alive = pd.read_csv(f"{roy_dir}/AgingBXD_Longevitydata_Nov2018.alive.txt", sep="\t")
for t in (roy, alive):
    t["strain_key"] = t.StrainNameCurrent.str.replace(r"^BXD0*", "BXD", regex=True)
mr = nat.merge(roy, left_on=["EarTag", "strain_key"], right_on=["EarTagNumberCurrent", "strain_key"],
               suffixes=("", "_2018"))
flag(mr[mr.value != mr.AgeAtDeath], "B1_age_differs_from_2018",
     lambda r: f"2018 AgeAtDeath {r.AgeAtDeath} (DOB {r.DateOfBirth}, DOD {r.DateOfDeath}, {r.CauseOfDeath})")
ma = nat.merge(alive, left_on=["EarTag", "strain_key"], right_on=["EarTagNumberCurrent", "strain_key"],
               suffixes=("", "_2018"))
flag(ma[ma.value < ma.AgeIfStllAlive], "A3_died_before_known_alive",
     lambda r: f"recorded alive at {r.AgeIfStllAlive} d on 15 Nov 2018")

# C1. Very early deaths
flag(nat[nat.value < 200], "C1_death_before_200d", lambda r: f"{int(r.value)} d")

# C2. Three or more animals of one strain and diet dying at the same age (same day for littermates)
for (s, tx, v), g in nat.groupby(["Strain", "Tx", "value"]):
    if len(g) >= 3:
        flag(g, "C2_same_day_cluster", f"{len(g)} {s} {tx} deaths at {int(v)} d: {','.join(g.Name)}")

# C3. Robust outliers within strain x diet x sex (n >= 6)
grp = nat.groupby(["Strain", "Tx", "Sex"]).value
nat["n"] = grp.transform("size")
nat["med"] = grp.transform("median")
nat["mad"] = grp.transform(lambda s: 1.4826 * (s - s.median()).abs().median())
nat["z"] = (nat.value - nat.med) / nat.mad.replace(0, np.nan)
flag(nat[(nat.n >= 6) & (nat.z.abs() > 3.5)], "C3_within_strain_outlier",
     lambda r: f"{int(r.value)} d vs median {r.med:.0f} (n={r.n}, robust z={r.z:.1f})")

# D1. Value present but Longevity column blank
flag(nat[nat.longevity.isna()], "D1_longevity_blank", "Value filled, Longevity blank")

f = pd.DataFrame(flags).sort_values(["code", "Strain", "Name"])
f.to_csv(out, index=False)
print(f.code.value_counts().sort_index().to_string())

# Summary statistics quoted in the QC report
near, far = [0, 0], [0, 0]
for _, g in nat.groupby(["Strain", "Tx"]):
    for (t1, v1), (t2, v2) in itertools.combinations(zip(g.EarTag, g.value), 2):
        b = near if abs(t1 - t2) <= 5 else far
        b[0] += 1
        b[1] += v1 == v2
print(f"rows {len(d)}, natural deaths {len(nat)}, harvested {(d.Value == 'x').sum()}")
print(f"same-age pairs: tags <=5 apart {near[1]}/{near[0]}, farther apart {far[1]}/{far[0]}")
print("alive in 2018 but absent from export:",
      alive.merge(d, left_on=["EarTagNumberCurrent", "strain_key"], right_on=["EarTag", "strain_key"],
                  how="left").pipe(lambda x: x[x.Name.isna()])[["StrainNameCurrent", "EarTagNumberCurrent"]]
      .values.tolist())
