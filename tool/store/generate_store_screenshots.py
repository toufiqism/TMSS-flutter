#!/usr/bin/env python3
"""Compose Play Store phone screenshots from raw emulator captures.

    python3 tool/store/generate_store_screenshots.py

Reads  docs/play/graphics/screenshots/raw/*.png   (1344x2992 Pixel 9 Pro XL captures)
Writes docs/play/graphics/screenshots/*.png       (1440x2560, ready to upload)

Why the raws cannot be uploaded directly
----------------------------------------
A Pixel 9 Pro XL viewport is 1344x2992 — an aspect ratio of 1:2.23. Play accepts a side
between 320 and 3840 px but rejects anything more extreme than 2:1, so the raw capture is
refused at upload. Each frame is therefore composed onto a 9:16 canvas (1440x2560, ratio
1:1.78) with the device shot inset and a caption above it, which is also what the listing
wants to look like.

The captures come from a profile build pointed at `tool/store/mock_api_server.py`, so
every name, address and plate in them is synthetic — see that file. Regenerate the raws
before this script if the UI changes.
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError:  # pragma: no cover - environment guard
    sys.exit("Pillow is required: pip3 install pillow")

REPO = Path(__file__).resolve().parents[2]
FONTS = REPO / "assets/fonts"
RAW = REPO / "docs/play/graphics/screenshots/raw"
OUT = REPO / "docs/play/graphics/screenshots"

CANVAS = (1440, 2560)          # 9:16 exactly
MARGIN = 90
DEVICE_BLEED = 70              # how far the device runs off the bottom edge
DEVICE_GAP = 56                # breathing room between caption and device
CORNER = 44

INK = (0x12, 0x12, 0x2B)
BODY = (0x4A, 0x51, 0x48)
PAGE = (0xF1, 0xF3, 0xEC)
LIME = (0x7A, 0xB6, 0x48)

# Order is the order Play shows them: the first two carry the install decision.
FRAMES = [
    ("01-dashboard.png", "Every requisition at a glance", "Counts, statuses and your latest trips"),
    ("02-new-passenger.png", "Raise a trip request in seconds", "Pick the time, the route and who is travelling"),
    ("03-detail-assigned.png", "Know your vehicle and driver", "Assignment details as soon as transport confirms"),
    ("04-list.png", "Follow every request to the trip", "Search and filter your own requisition history"),
    ("05-logistics.png", "Cargo runs, not just passengers", "Cover van or open truck, with load details"),
    ("06-login.png", "Sign in with your work account", "Accounts are issued by your organisation"),
]


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / name), size)


def rounded(image: Image.Image, radius: int) -> Image.Image:
    """Round the device capture's corners so it reads as a screen, not a rectangle."""
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, image.width - 1, image.height - 1],
                                           radius=radius, fill=255)
    out = image.convert("RGBA")
    out.putalpha(mask)
    return out


def shadow(size: tuple[int, int], radius: int, blur: int, spread: int) -> Image.Image:
    """A soft drop shadow sized to the device shot."""
    layer = Image.new("RGBA", (size[0] + spread * 2, size[1] + spread * 2), (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle(
        [spread, spread, spread + size[0], spread + size[1]],
        radius=radius, fill=(18, 18, 43, 60))
    return layer.filter(ImageFilter.GaussianBlur(blur))


def wrap(draw: ImageDraw.ImageDraw, text: str, f: ImageFont.FreeTypeFont,
         limit: int) -> list[str]:
    lines, current = [], ""
    for word in text.split():
        trial = f"{current} {word}".strip()
        if draw.textlength(trial, font=f) <= limit or not current:
            current = trial
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def compose(raw_name: str, headline: str, sub: str) -> Path:
    source = RAW / raw_name
    if not source.exists():
        sys.exit(f"missing capture: {source}")

    canvas = Image.new("RGB", CANVAS, PAGE)
    draw = ImageDraw.Draw(canvas)
    limit = CANVAS[0] - MARGIN * 2

    head_font = font("space_grotesk_bold.ttf", 62)
    sub_font = font("plus_jakarta_sans_medium.ttf", 34)

    y = 96
    for line in wrap(draw, headline, head_font, limit):
        draw.text((MARGIN, y), line, font=head_font, fill=INK)
        y += 74
    draw.line([(MARGIN, y + 18), (MARGIN + 92, y + 18)], fill=LIME, width=5)
    y += 46
    for line in wrap(draw, sub, sub_font, limit):
        draw.text((MARGIN, y), line, font=sub_font, fill=BODY)
        y += 46

    # The device fills whatever the caption leaves, rather than a fixed height: a
    # three-line caption would otherwise collide with it, and a one-line caption would
    # leave a band of dead page above the phone.
    top = y + DEVICE_GAP
    height = CANVAS[1] - top + DEVICE_BLEED
    with Image.open(source) as raw:
        width = round(raw.width * height / raw.height)
        if width > CANVAS[0] - MARGIN * 2:
            width = CANVAS[0] - MARGIN * 2
            height = round(raw.height * width / raw.width)
        device = raw.resize((width, height), Image.LANCZOS)

    x = (CANVAS[0] - device.width) // 2

    glow = shadow(device.size, CORNER, 34, 40)
    canvas.paste(glow, (x - 40, top - 40 + 18), glow)
    frame = rounded(device, CORNER)
    canvas.paste(frame, (x, top), frame)

    path = OUT / raw_name
    canvas.save(path, "PNG")
    return path


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, headline, sub in FRAMES:
        path = compose(name, headline, sub)
        with Image.open(path) as img:
            w, h = img.size
            ratio = max(w, h) / min(w, h)
            ok = 320 <= min(w, h) and max(w, h) <= 3840 and ratio <= 2.0
            print(f"{path.relative_to(REPO)}  {w}x{h}  ratio 1:{ratio:.2f}  "
                  f"{'OK' if ok else 'REJECTED BY PLAY'}  {path.stat().st_size / 1024:.0f} KB")


if __name__ == "__main__":
    main()
