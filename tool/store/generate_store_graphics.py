#!/usr/bin/env python3
"""Generate the two static Play Store graphics from the brand SVG.

    python3 tool/store/generate_store_graphics.py

Outputs (overwritten in place):

    docs/play/graphics/play-icon-512.png       512x512, opaque, square corners
    docs/play/graphics/play-feature-1024x500.png
    docs/play/graphics/youtube-thumbnail-1280x720.png

Requirements: `brew install resvg`, `pip3 install pillow`.

Why a script and not two exports
--------------------------------
Play rejects a 512 icon that carries an alpha channel or pre-rounded corners, and it
rejects a feature graphic that is not exactly 1024x500. Both are trivially wrong when
hand-exported and trivially right when the sizes are literals in a file. The icon
background is `#FFFFFF` because that is what `values/colors.xml` gives the adaptive
launcher icon — the store tile and the home screen should not disagree.

The logo is rasterised by resvg rather than drawn here: it is the same
`assets/images/tracgo_logo.svg` the app renders through flutter_svg, so the store art
cannot drift from the in-app mark.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError:  # pragma: no cover - environment guard
    sys.exit("Pillow is required: pip3 install pillow")

REPO = Path(__file__).resolve().parents[2]
LOGO = REPO / "assets/images/tracgo_logo.svg"
FONTS = REPO / "assets/fonts"
OUT = REPO / "docs/play/graphics"
WORK = REPO / "build/store"

INK = (0x12, 0x12, 0x2B)
LIME = (0x7A, 0xB6, 0x48)
WHITE = (0xFF, 0xFF, 0xFF)
MUTED = (0xC5, 0xCB, 0xC2)

# The mark is 303x385 in user units; every size below is derived from that ratio so the
# pin is never stretched.
LOGO_RATIO = 385 / 303


def rasterise(height: int) -> Image.Image:
    """Render the brand SVG to RGBA at `height` pixels tall."""
    WORK.mkdir(parents=True, exist_ok=True)
    png = WORK / f"logo-{height}.png"
    width = round(height / LOGO_RATIO)
    subprocess.run(
        ["resvg", str(LOGO), str(png), "--width", str(width), "--height", str(height)],
        check=True,
        capture_output=True,
    )
    return Image.open(png).convert("RGBA")


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / name), size)


def build_icon() -> Path:
    """512x512 store icon: the mark on the launcher's own white, no alpha, no rounding.

    Play masks this tile into whatever shape the surface uses, so the art is held to
    ~70% of the canvas — a full-bleed mark loses its corners to the mask.
    """
    canvas = Image.new("RGB", (512, 512), WHITE)
    mark = rasterise(360)
    canvas.paste(mark, ((512 - mark.width) // 2, (512 - mark.height) // 2), mark)
    path = OUT / "play-icon-512.png"
    canvas.save(path, "PNG")
    return path


def _glow(size: tuple[int, int], centre: tuple[int, int], radius: int) -> Image.Image:
    """A soft lime radial bloom, drawn as stacked ellipses and blurred flat."""
    layer = Image.new("RGB", size, INK)
    draw = ImageDraw.Draw(layer)
    steps = 48
    for i in range(steps, 0, -1):
        r = radius * i / steps
        t = 1 - i / steps
        colour = tuple(round(INK[c] + (LIME[c] - INK[c]) * t * 0.30) for c in range(3))
        draw.ellipse(
            [centre[0] - r, centre[1] - r, centre[0] + r, centre[1] + r], fill=colour
        )
    return layer.filter(ImageFilter.GaussianBlur(60))


def build_feature() -> Path:
    """1024x500 feature graphic.

    Play crops this asset differently across surfaces, so everything that has to be read
    is held inside a 100 px safe margin. The tagline is measured and shrunk until it fits
    rather than trusted to: a font metric changes, the text silently runs off the edge,
    and the crop eats the last word.
    """
    w, h = 1024, 500
    margin = 100
    canvas = _glow((w, h), (280, 250), 320)

    mark = rasterise(300)
    mark_x = 150
    canvas.paste(mark, (mark_x, (h - mark.height) // 2), mark)

    draw = ImageDraw.Draw(canvas)
    text_x = mark_x + mark.width + 60
    limit = w - margin - text_x

    wordmark = font("space_grotesk_bold.ttf", 92)
    draw.text((text_x, 150), "TracGo", font=wordmark, fill=WHITE)

    rule_y = 268
    draw.line([(text_x, rule_y), (text_x + 88, rule_y)], fill=LIME, width=5)

    lines = ["Request and track company vehicles",
             "Raise, follow and manage trip requisitions"]
    size = 30
    while size > 18:
        tagline = font("plus_jakarta_sans_medium.ttf", size)
        if max(draw.textlength(line, font=tagline) for line in lines) <= limit:
            break
        size -= 1
    else:  # pragma: no cover - only reachable if the strings grow a lot
        sys.exit("feature graphic tagline cannot be made to fit the safe area")

    y = 300
    for line in lines:
        draw.text((text_x, y), line, font=tagline, fill=MUTED)
        y += size + 12

    widest = max(draw.textlength(line, font=tagline) for line in lines)
    overrun = text_x + max(widest, draw.textlength("TracGo", font=wordmark)) - (w - margin)
    if overrun > 0:  # pragma: no cover - guarded by the fitting loop above
        sys.exit(f"feature graphic text overruns the safe area by {overrun:.0f} px")

    path = OUT / "play-feature-1024x500.png"
    canvas.save(path, "PNG")
    return path


def build_thumbnail() -> Path:
    """1280x720 thumbnail for the promo video on YouTube.

    Same treatment as the feature graphic at a different ratio rather than a crop of it:
    YouTube shows this as small as 210 px wide in a sidebar, so the wordmark is
    proportionally larger and the second line of the tagline is dropped.
    """
    w, h = 1280, 720
    canvas = _glow((w, h), (400, 360), 420)

    mark = rasterise(360)
    canvas.paste(mark, (210, (h - mark.height) // 2), mark)

    draw = ImageDraw.Draw(canvas)
    text_x = 560
    draw.text((text_x, 250), "TracGo", font=font("space_grotesk_bold.ttf", 110), fill=WHITE)
    draw.line([(text_x, 392), (text_x + 104, 392)], fill=LIME, width=6)
    draw.text((text_x, 428), "Company vehicle requisitions",
              font=font("plus_jakarta_sans_medium.ttf", 36), fill=MUTED)

    path = OUT / "youtube-thumbnail-1280x720.png"
    canvas.save(path, "PNG")
    return path


def main() -> None:
    if not LOGO.exists():
        sys.exit(f"missing {LOGO}")
    OUT.mkdir(parents=True, exist_ok=True)
    for path in (build_icon(), build_feature(), build_thumbnail()):
        with Image.open(path) as img:
            print(f"{path.relative_to(REPO)}  {img.size[0]}x{img.size[1]}  {img.mode}  "
                  f"{path.stat().st_size / 1024:.0f} KB")


if __name__ == "__main__":
    main()
