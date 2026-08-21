#!/usr/bin/env python3
"""Compose App Store phone screenshots from raw iOS Simulator captures.

    python3 tool/store/generate_ios_store_screenshots.py

Reads  docs/appstore/graphics/screenshots/raw/*.png       (1320x2868 iPhone 17 Pro Max)
Writes docs/appstore/graphics/screenshots/6.9-inch/*.png  (1320x2868, ready to upload)
       docs/appstore/graphics/screenshots/6.5-inch/*.png  (1284x2778, ready to upload)

Why compose at all, when the raw capture is already the right size
------------------------------------------------------------------
Play rejects the Android raws outright — a 1344x2992 capture is more extreme than its
2:1 limit — so there the framing pass is mandatory. The App Store has no such rule: it
wants one of a fixed set of exact sizes, and the 6.9" simulator already produces one of
them. The framing here is therefore a listing decision rather than a technical one. A
bare screenshot makes the viewer work out what they are looking at; a caption above the
device says it in four words while they are still deciding whether to install.

One directory per upload slot. App Store Connect enforces the selected tab's sizes and
refuses the whole batch on the first mismatch, so dropping a 1320x2868 file on the 6.5"
tab fails with "The dimensions of one or more screenshots are wrong" — which is a wrong
*tab*, not a wrong capture. Both sets are produced so either tab works; 6.9" alone
satisfies a submission, and Apple scales it down for every smaller device.

The captures come from a debug build pointed at `tool/store/mock_api_server.py`, so
every name, address and plate in them is synthetic — see that file. Regenerate the raws
with `tool/store/capture_ios_screenshots.sh` if the UI changes.
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
RAW = REPO / "docs/appstore/graphics/screenshots/raw"
OUT = REPO / "docs/appstore/graphics/screenshots"

# One directory per App Store Connect upload slot, because the slots do not share a size
# and ASC rejects the whole upload on the first file that does not match the tab it was
# dropped on. 6.9" alone is enough for a new submission — Apple scales it down for every
# smaller device — but the 6.5" tab is still offered, still enforces its own sizes, and
# is the one it is easy to click by mistake.
#
# 1320x2868 is the iPhone 17/16 Pro Max viewport, so that set is composed at the raw's
# own resolution. 1284x2778 is the iPhone 12-14 Pro Max; nothing is recaptured for it,
# the device shot is just scaled into a shorter canvas, which is safe because the aspect
# ratios differ by 0.4%.
TARGETS = [
    ("6.9-inch", (1320, 2868)),
    ("6.5-inch", (1284, 2778)),
]

# Sizes ASC accepts per slot, portrait, so a raw captured on the wrong simulator is
# caught here rather than at upload.
ACCEPTED = {
    "6.9-inch": {(1320, 2868), (1290, 2796)},
    "6.5-inch": {(1284, 2778), (1242, 2688)},
}

MARGIN = 82
DEVICE_BLEED = 64              # how far the device runs off the bottom edge
DEVICE_GAP = 52                # breathing room between caption and device
CORNER = 56                    # iPhone 17 Pro Max corner radius, roughly, at 3x
SAFE_AREA_TOP = 186           # 62pt at 3x — see _without_empty_status_bar

INK = (0x12, 0x12, 0x2B)
BODY = (0x4A, 0x51, 0x48)
PAGE = (0xF1, 0xF3, 0xEC)
LIME = (0x7A, 0xB6, 0x48)

# Same order and copy as the Play set: the listing text was written once and reviewed
# once, and two stores disagreeing about what the app does helps nobody.
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


def _without_empty_status_bar(image: Image.Image) -> Image.Image:
    """Trim the dead band at the top of the capture, if that is what it is.

    `integration_test`'s `takeScreenshot` reads back the *Flutter* surface, and the iOS
    status bar is not part of it. What the capture holds instead is the app's safe-area
    inset — 62pt, so 186px at 3x — in a flat colour, which framed reads as an unexplained
    empty strip inside the phone rather than as the place the clock lives.

    Cropping is conditional on the band actually being flat, so a raw that *does* carry a
    status bar — anything captured with `xcrun simctl io <udid> screenshot` — keeps it
    instead of losing its top 186 rows.
    """
    if image.height <= SAFE_AREA_TOP:
        return image
    band = image.crop((0, 0, image.width, SAFE_AREA_TOP))
    colours = band.getcolors(maxcolors=2)
    if colours is None or len(colours) > 1:
        return image
    return image.crop((0, SAFE_AREA_TOP, image.width, image.height))


def compose(raw_name: str, headline: str, sub: str,
            canvas_size: tuple[int, int], out_dir: Path) -> Path:
    source = RAW / raw_name
    if not source.exists():
        sys.exit(f"missing capture: {source}\n"
                 f"run tool/store/capture_ios_screenshots.sh first")

    with Image.open(source) as raw:
        raw_copy = _without_empty_status_bar(raw.convert("RGB").copy())

    canvas = Image.new("RGB", canvas_size, PAGE)
    draw = ImageDraw.Draw(canvas)
    limit = canvas_size[0] - MARGIN * 2

    head_font = font("space_grotesk_bold.ttf", 60)
    sub_font = font("plus_jakarta_sans_medium.ttf", 33)

    # Below the notch, not level with it: a caption starting at the very top of a 6.9"
    # canvas sits where the Dynamic Island would be on the device the viewer is holding.
    y = 132
    for line in wrap(draw, headline, head_font, limit):
        draw.text((MARGIN, y), line, font=head_font, fill=INK)
        y += 72
    draw.line([(MARGIN, y + 18), (MARGIN + 92, y + 18)], fill=LIME, width=5)
    y += 46
    for line in wrap(draw, sub, sub_font, limit):
        draw.text((MARGIN, y), line, font=sub_font, fill=BODY)
        y += 45

    # The device fills whatever the caption leaves, rather than a fixed height: a
    # three-line caption would otherwise collide with it, and a one-line caption would
    # leave a band of dead page above the phone.
    top = y + DEVICE_GAP
    height = canvas_size[1] - top + DEVICE_BLEED
    width = round(raw_copy.width * height / raw_copy.height)
    if width > canvas_size[0] - MARGIN * 2:
        width = canvas_size[0] - MARGIN * 2
        height = round(raw_copy.height * width / raw_copy.width)
    device = raw_copy.resize((width, height), Image.LANCZOS)

    x = (canvas_size[0] - device.width) // 2

    glow = shadow(device.size, CORNER, 34, 40)
    canvas.paste(glow, (x - 40, top - 40 + 18), glow)
    frame = rounded(device, CORNER)
    canvas.paste(frame, (x, top), frame)

    path = out_dir / raw_name
    canvas.save(path, "PNG")
    return path


def main() -> None:
    if not RAW.is_dir() or not any(RAW.glob("*.png")):
        sys.exit(f"no raw captures in {RAW.relative_to(REPO)}\n"
                 f"run tool/store/capture_ios_screenshots.sh first")

    rejected = 0
    for label, canvas_size in TARGETS:
        out_dir = OUT / label
        out_dir.mkdir(parents=True, exist_ok=True)
        print(f"{label}  ({canvas_size[0]}x{canvas_size[1]})")
        for name, headline, sub in FRAMES:
            path = compose(name, headline, sub, canvas_size, out_dir)
            with Image.open(path) as img:
                size = img.size
            ok = size in ACCEPTED[label]
            rejected += 0 if ok else 1
            print(f"  {path.relative_to(REPO)}  {size[0]}x{size[1]}  "
                  f"{'OK' if ok else 'REJECTED BY ASC'}  "
                  f"{path.stat().st_size / 1024:.0f} KB")
        print()

    if rejected:
        sys.exit(f"{rejected} file(s) are not a size App Store Connect accepts.")


if __name__ == "__main__":
    main()
