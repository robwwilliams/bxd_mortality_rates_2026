"""
digitize_km.py

Reads the Kaplan-Meier survival curves of two lifespan studies from de Cabo's laboratory out of the published PDFs,
for N5 of notes/PLAN_NAM_rectangularization.md (exploratory; Rob's go-ahead of 27 October 2026).

  Martin-Montalvo et al. 2013, Nat Commun 4:2192, Fig. 1a-b (metformin; male C57BL/6, n = 83, 64, 88, 90)
  Mitchell et al. 2018, Cell Metab 27:667, Fig. 1A-B (nicotinamide; male C57BL/6J, n = 100 per arm)

How each panel is read:
  Fig. 1a (metformin 0.1%)  The vector figure carries a hidden marker at every week on each curve: small triangles on
                            the metformin curve and small circles on the control curve. Their positions are the
                            survival at each week, read exactly.
  Fig. 1b (metformin 1%)    No markers. The panel is rendered at 600 dpi and read column by column: in each column of
                            pixels (one age), the dark pixels of each curve give its survival. The metformin curve is
                            the lower of the two wherever they differ. Where the dashed control curve has a gap, its
                            survival is interpolated between the neighboring columns.
  Fig. 1A-B (nicotinamide)  An embedded image. Read column by column by color: black (vehicle), blue (low NAM) and red
                            (high NAM). Where a curve is hidden under another, its survival is interpolated between the
                            columns where it is visible.
Axes are calibrated from the tick marks (vector coordinates for Martin-Montalvo, pixel positions for Mitchell). Every
curve is forced to be non-increasing and to start at 100%.

Run from the repository root:  .venv/bin/python tools/digitize_km.py
Writes data/digitized/*.txt (age in weeks and survival in percent, by arm) and data/digitized/*_check.png (the digitized
curves drawn over the figure, to check by eye)
"""

import io
import os
import fitz
import numpy as np
from PIL import Image, ImageDraw

OUT = "data/digitized"
MM = "papers/Martin-Montalvo_deCabo_MetforminLifespanMice_NatComm_2013.pdf"
MI = "papers/Mitchell_deCabo_NicotinamideHealthspanMice_CellMeta_2018.pdf"
os.makedirs(OUT, exist_ok=True)


def write(name, weeks, curves, note):
    with open(os.path.join(OUT, name), "w") as f:
        f.write("# " + note + "\n")
        f.write("week\t" + "\t".join(curves) + "\n")
        for i, w in enumerate(weeks):
            f.write("%.3f\t" % w + "\t".join("%.3f" % curves[k][i] for k in curves) + "\n")


def tidy(s, floor):
    """Interpolate gaps, force 100% at the start and a non-increasing curve. Readings below floor, which is under the
    smallest possible step (one mouse of the arm), are the top edge of a line lying on the x axis, so they are 0."""
    s = np.array(s, dtype=float)
    s[s < floor] = 0.0
    ok = ~np.isnan(s)
    first, last = np.argmax(ok), len(s) - 1 - np.argmax(ok[::-1])
    s[:first] = 100.0
    idx = np.arange(len(s))
    inner = idx[first:last + 1]
    s[first:last + 1] = np.interp(inner, idx[ok], s[ok])
    s[last + 1:] = 0.0 if s[last] < 3 else np.nan          # a curve that ends near 0 has reached 0 on the axis
    return np.minimum.accumulate(np.clip(s, 0, 100))


def check_png(img, curves, to_px, name):
    im = img.convert("RGB").copy()
    g = ImageDraw.Draw(im)
    pal = [(0, 200, 0), (255, 140, 0), (200, 0, 200)]
    for (k, (w, s)), c in zip(curves.items(), pal):
        pts = [to_px(a, b) for a, b in zip(w, s) if not np.isnan(b)]
        g.line(pts, fill=c, width=2)
    im.save(os.path.join(OUT, name))


# ---- Martin-Montalvo Fig. 1a: the weekly markers ---------------------------------------------------------------------
doc = fitz.open(MM)
page = doc[2]
X0, X160, Y0, Y100 = 175.79, 290.61, 158.29, 58.31             # tick marks of panel a (points)
wk = lambda x: (x - X0) / (X160 - X0) * 160
sv = lambda y: (Y0 - y) / (Y0 - Y100) * 100
marks = {"triangle": {}, "circle": {}}
for d in page.get_drawings():
    r = d["rect"]
    if d["type"] != "fs" or not (175 <= r.x0 <= 292 and 55 <= r.y0 <= 160) or r.width > 0.2:
        continue
    kind = "triangle" if "".join(i[0] for i in d["items"]) == "lll" else "circle"
    w, s = wk((r.x0 + r.x1) / 2), sv((r.y0 + r.y1) / 2)
    if abs(w - 16.41) < 0.05:                                    # the markers on the legend lines
        continue
    marks[kind][int(round(w))] = s
weeks = np.arange(0, 161)
sd = tidy([marks["circle"].get(w, np.nan) if w > 0 else 100 for w in weeks], 0.5)
met = tidy([marks["triangle"].get(w, np.nan) if w > 0 else 100 for w in weeks], 0.5)
print("Fig. 1a: markers read, circles %d, triangles %d" % (len(marks["circle"]), len(marks["triangle"])))
write("MartinMontalvo2013_Fig1a.txt", weeks, {"SD": sd, "Met0.1": met},
      "Martin-Montalvo et al. 2013 Fig. 1a, from the weekly markers in the vector figure; survival (%) at each week")
mat = page.get_pixmap(dpi=300, clip=fitz.Rect(150, 40, 300, 175))
img = Image.open(io.BytesIO(mat.tobytes("png")))
sc = 300 / 72
check_png(img, {"SD": (weeks, sd), "Met0.1": (weeks, met)},
          lambda a, b: ((X0 + a / 160 * (X160 - X0) - 150) * sc, (Y0 - b / 100 * (Y0 - Y100) - 40) * sc), "MartinMontalvo2013_Fig1a_check.png")

# ---- Martin-Montalvo Fig. 1b: column by column at 600 dpi --------------------------------------------------------------
X0, X160, Y0, Y100 = 326.53, 441.82, 158.43, 58.08
dpi = 600; sc = dpi / 72; clip = fitz.Rect(320, 50, 446, 162)
img = Image.open(io.BytesIO(page.get_pixmap(dpi=dpi, clip=clip).tobytes("png"))).convert("L")
a = np.asarray(img).astype(int)
px = lambda x, y: (int(round((x - clip.x0) * sc)), int(round((y - clip.y0) * sc)))
dark = a < 128
for (x0, y0, x1, y1) in [(326, 131, 377, 156), (357, 59.2, 369, 76)]:        # legend lines and text; arrow
    (c0, r0), (c1, r1) = px(x0, y0), px(x1, y1)
    dark[r0:r1, c0:c1] = False
(c_axis, r_top), (c_end, r_axis) = px(X0, Y100), px(X160, Y0)
dark[:, :c_axis + 6] = False                                                    # y axis
dark[r_axis - 5:, :] = False                                                    # x axis (survival below 0.6%)
cols = np.arange(c_axis + 6, c_end + 1)
s_hi, s_lo = [], []
to_s = lambda r: (Y0 - (r / sc + clip.y0)) / (Y0 - Y100) * 100
prev_hi = prev_lo = 100.0
for c in cols:
    rows = np.where(dark[:, c])[0]
    runs = np.split(rows, np.where(np.diff(rows) > 3)[0] + 1) if len(rows) else []
    vals = [to_s((r[0] + r[-1]) / 2) for r in runs if len(r)]
    fits = lambda v, prev: v <= prev + 2                       # a survival curve never rises
    if len(vals) >= 2 and fits(min(vals), prev_lo):
        hi, lo = max(vals), min(vals)
    elif len(vals) >= 2:                                        # the metformin curve is already lower: all runs are control
        hi, lo = np.mean(vals), np.nan
    elif len(vals) == 1:
        v = vals[0]
        if fits(v, prev_hi) and fits(v, prev_lo) and abs(prev_hi - prev_lo) <= 2:
            hi, lo = v, v
        elif fits(v, prev_hi) and (not fits(v, prev_lo) or abs(v - prev_hi) < abs(v - prev_lo)):
            hi, lo = v, np.nan
        elif fits(v, prev_lo):
            hi, lo = np.nan, v
        else:
            hi = lo = np.nan
    else:
        hi = lo = np.nan
    s_hi.append(hi); s_lo.append(lo)
    prev_hi = hi if not np.isnan(hi) else prev_hi
    prev_lo = lo if not np.isnan(lo) else prev_lo
weeks_b = ((cols / sc + clip.x0) - X0) / (X160 - X0) * 160
sd_b, met_b = tidy(s_hi, 0.8), tidy(s_lo, 0.8)                  # one mouse is 1.1% of either arm
write("MartinMontalvo2013_Fig1b.txt", weeks_b, {"SD": sd_b, "Met1": met_b},
      "Martin-Montalvo et al. 2013 Fig. 1b, read column by column from a 600-dpi rendering; survival (%) by age in weeks")
check_png(img, {"SD": (weeks_b, sd_b), "Met1": (weeks_b, met_b)},
          lambda w, s: ((X0 + w / 160 * (X160 - X0) - clip.x0) * sc, (Y0 - s / 100 * (Y0 - Y100) - clip.y0) * sc), "MartinMontalvo2013_Fig1b_check.png")
print("Fig. 1b: %d columns; control gaps %d, metformin gaps %d" % (len(cols), int(np.isnan(s_hi).sum()), int(np.isnan(s_lo).sum())))

# ---- Mitchell Fig. 1A-B: column by column, by color ---------------------------------------------------------------------
doc = fitz.open(MI)
xref = [im[0] for im in doc[2].get_images(full=True)][0]
fig = Image.open(io.BytesIO(doc.extract_image(xref)["image"])).convert("RGB")
a = np.asarray(fig).astype(int)
R, G, B = a[:, :, 0], a[:, :, 1], a[:, :, 2]
colors = {"black": (R < 90) & (G < 90) & (B < 90),
          "blue": (B > 150) & (R < 110) & (G < 110),
          "red": (R > 150) & (G < 100) & (B < 100)}
XW50, XW170 = 132.5, 568.5                                       # tick marks at 50 and 170 weeks (pixels)
panels = {"A": {"y100": 172.0, "y0": 464.5, "arms": {"black": "SD", "blue": "SDL", "red": "SDH"}, "label": (470, 175, 575, 215)},
          "B": {"y100": 629.5, "y0": 922.0, "arms": {"black": "HFD", "blue": "HFDL", "red": "HFDH"}, "label": (440, 630, 575, 675)}}
cols = np.arange(137, 569)
weeks_m = 50 + (cols - XW50) / (XW170 - XW50) * 120
for p, P in panels.items():
    r0, r1 = int(P["y100"]) - 4, int(P["y0"]) - 3                # plot rows, above the x axis
    curves = {}
    for col, arm in P["arms"].items():
        m = colors[col].copy()
        x0, y0, x1, y1 = P["label"]
        m[y0:y1, x0:x1] = False                                  # the panel label (SD or HFD)
        s = []
        for c in cols:
            rows = np.where(m[r0:r1, c])[0] + r0
            s.append(np.nan if len(rows) < 2 else (P["y0"] - np.median(rows)) / (P["y0"] - P["y100"]) * 100)
        curves[arm] = tidy(s, 0.5)                              # one mouse is 1% of an arm
        print("Fig. 1%s %-4s: hidden in %d of %d columns" % (p, arm, int(np.isnan(s).sum()), len(cols)))
    write("Mitchell2018_Fig1%s.txt" % p, weeks_m, curves,
          "Mitchell et al. 2018 Fig. 1%s, read column by column by color from the embedded image; survival (%%) by age in weeks" % p)
    crop = fig.crop((100, int(P["y100"]) - 40, 590, int(P["y0"]) + 20))
    check_png(crop, {k: (weeks_m, v) for k, v in curves.items()},
              lambda w, s, P=P: (XW50 + (w - 50) / 120 * (XW170 - XW50) - 100, P["y0"] - s / 100 * (P["y0"] - P["y100"]) - (int(P["y100"]) - 40)),
              "Mitchell2018_Fig1%s_check.png" % p)
