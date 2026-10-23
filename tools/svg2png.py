"""Render SVG figures to PNG previews with CairoSVG.

Usage: python3 tools/svg2png.py output/*.svg   (writes a .png next to each .svg, 150 dpi)
"""
import sys

import cairosvg

for svg in sys.argv[1:]:
    png = svg[:-4] + ".png"
    cairosvg.svg2png(url=svg, write_to=png, dpi=150, scale=150 / 96, background_color="white")
    print("wrote", png)
