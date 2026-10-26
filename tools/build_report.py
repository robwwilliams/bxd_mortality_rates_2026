"""Build a shareable report from a Markdown note: HTML, Word and PDF, with every figure as PNG and SVG, and a ZIP.

Usage: .venv/bin/python tools/build_report.py notes/Report.md <out_dir> [<name>]
  Images in the note are written ../output/<Fig>.png; the matching .svg is copied too.
  Writes <out_dir>/<name>/{<name>.html, <name>.docx, <name>.pdf, figures/} and <out_dir>/<name>.zip.
The PDF comes from tools/html2pdf.swift (macOS WebKit). Needs: markdown, htmldocx, python-docx (see CLAUDE.md).
"""
import os
import re
import shutil
import subprocess
import sys
import zipfile

import docx
import markdown
from docx.shared import Inches, Pt
from htmldocx import HtmlToDocx

src, out_dir = sys.argv[1], sys.argv[2]
name = sys.argv[3] if len(sys.argv) > 3 else os.path.splitext(os.path.basename(src))[0]
root = os.path.join(out_dir, name)
figdir = os.path.join(root, "figures")
os.makedirs(figdir, exist_ok=True)

text = open(src, encoding="utf-8").read()
# Python-Markdown nests lists by 4 spaces; the notes use 2 (as GitHub does)
text = re.sub(r"(?m)^( +)(?=([-*]|\d+\.) )", lambda m: m.group(1) * 2, text)
# and it starts a list only after a blank line, which GitHub does not require
item = re.compile(r"^\s*([-*]|\d+\.) ")
lines = text.split("\n")
text = "\n".join(l if i == 0 or not item.match(l) or not lines[i - 1].strip() or item.match(lines[i - 1])
                 or lines[i - 1].startswith(" ") else "\n" + l for i, l in enumerate(lines))
# Figures: copy PNG and SVG, and point the images at figures/
for png in re.findall(r"!\[[^\]]*\]\(([^)]+\.png)\)", text):
    path = os.path.normpath(os.path.join(os.path.dirname(src), png))
    for f in (path, path[:-4] + ".svg"):
        if os.path.exists(f):
            shutil.copy(f, figdir)
    text = text.replace(png, "figures/" + os.path.basename(png))

body = markdown.markdown(text, extensions=["tables", "sane_lists", "fenced_code"])
css = """
body { font-family: Arial, Helvetica, sans-serif; font-size: 10.5pt; line-height: 1.4; color: #111; max-width: 7in; margin: auto; }
h1 { font-size: 17pt; margin-top: 0.4em; } h2 { font-size: 13pt; margin-top: 1.2em; } h3 { font-size: 11pt; }
table { border-collapse: collapse; margin: 0.6em 0; font-size: 9.5pt; page-break-inside: avoid; }
th, td { border: 1px solid #bbb; padding: 3px 6px; text-align: left; vertical-align: top; }
th { background: #f1efe9; }
img { width: 100%; margin-top: 0.8em; page-break-inside: avoid; }
p:has(img) { page-break-inside: avoid; page-break-after: avoid; }
hr { border: 0; page-break-after: always; }
code { font-size: 9pt; }
"""
html = f'<!doctype html><html><head><meta charset="utf-8"><title>{name}</title><style>{css}</style></head><body>{body}</body></html>'
html_path = os.path.join(root, name + ".html")
open(html_path, "w", encoding="utf-8").write(html)

# Word: the same HTML, images scaled to the text width
d = docx.Document()
st = d.styles["Normal"]; st.font.name = "Arial"; st.font.size = Pt(10.5)
for s in d.sections:
    s.left_margin = s.right_margin = Inches(1)
cwd = os.getcwd(); os.chdir(root)          # htmldocx reads images relative to the working directory
conv = HtmlToDocx(); conv.table_style = "Table Grid"
conv.add_html_to_document(body.replace("<hr />", ""), d)
os.chdir(cwd)
for shape in d.inline_shapes:
    ratio = shape.height / shape.width
    shape.width = Inches(6.5); shape.height = int(Inches(6.5) * ratio)
d.save(os.path.join(root, name + ".docx"))

# PDF from the HTML
pdf = os.path.join(root, name + ".pdf")
subprocess.run(["swift", os.path.join(cwd, "tools", "html2pdf.swift"), os.path.abspath(html_path), os.path.abspath(pdf)],
               check=True, stderr=subprocess.DEVNULL)

with zipfile.ZipFile(os.path.join(out_dir, name + ".zip"), "w", zipfile.ZIP_DEFLATED) as z:
    for dirpath, _, files in os.walk(root):
        for f in sorted(files):
            p = os.path.join(dirpath, f)
            z.write(p, os.path.relpath(p, out_dir))
print("wrote", root, "and", os.path.join(out_dir, name + ".zip"))
