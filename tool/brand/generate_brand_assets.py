#!/usr/bin/env python3
"""Regenerate every TracGo brand asset from refference-image/Logo1.png.

    python3 tool/brand/generate_brand_assets.py

Outputs (all overwritten in place):

    assets/images/tracgo_logo.svg              full-colour pin, in-app
    assets/images/tracgo_logo_mono.svg         one-colour pin, for dark surfaces
    android/.../mipmap-*/ic_launcher.png       legacy launcher icons
    android/.../drawable/ic_launcher_foreground.xml    adaptive icon foreground
    android/.../drawable/ic_launcher_monochrome.xml    themed-icon shape
    android/.../drawable/tracgo_splash_logo.xml        cold-start mark
    android/.../drawable/tracgo_splash_logo_mono.xml   cold-start mark, dark mode
    ios/.../AppIcon.appiconset/*.png           every size listed in Contents.json
    ios/.../LaunchImage.imageset/*.png         cold-start mark, @1x/@2x/@3x

Requirements (macOS): `brew install potrace resvg`, `pip3 install pillow`, and Node for
`npx svg2vectordrawable`. Intermediates land in build/brand/ and are disposable.

Why it works the way it does
----------------------------
The source is a soft-shaded raster with a white sticker halo and a wordmark. Three things
have to happen before it can be traced into something shippable:

1. Isolate the symbol. The halo is flood-filled away from the border, which also
   distinguishes it from the white *inside* the art (lane dashes, the pin's counter) that
   must stay. The wordmark is dropped by connected component.
2. Flatten to a fixed palette. Tracing the shaded original produced 120 KB and ~200
   near-duplicate fills, one per band of every gradient.
3. Trace one 1-bit mask per palette colour with potrace, rather than colour-tracing with
   vtracer, which re-clusters and emits its own averaged shades regardless of the input.
"""

from __future__ import annotations

import re
import subprocess
import sys
from collections import deque
from pathlib import Path

try:
    from PIL import Image, ImageFilter
except ImportError:  # pragma: no cover - environment guard
    sys.exit("Pillow is required: pip3 install pillow")

REPO = Path(__file__).resolve().parents[2]
SOURCE = REPO / "refference-image/Logo1.png"
WORK = REPO / "build/brand"

COLOR_SVG = REPO / "assets/images/tracgo_logo.svg"
MONO_SVG = REPO / "assets/images/tracgo_logo_mono.svg"
ANDROID_RES = REPO / "android/app/src/main/res"
IOS_APPICON = REPO / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
IOS_LAUNCH = REPO / "ios/Runner/Assets.xcassets/LaunchImage.imageset"

# Point size of the launch mark. The storyboard centres the image at its natural size —
# pixels divided by scale — so emitting 120/240/360 renders a 120pt mark on every device.
# Matches the 108pt logo the Sign In screen opens with closely enough that the handoff
# from launch screen to first frame does not visibly jump.
IOS_LAUNCH_MARK_PT = 120

# Hand-picked, not median-cut. Median cut allocates slots by area, which spent five of
# twelve on indistinguishable navies and dropped the traffic light and signal arcs
# entirely — they are tiny in area and carry the meaning of the mark.
PALETTE = [
    "#110F3F",  # road navy
    "#2A2856",  # road navy, lit edge
    "#6FA44A",  # swoosh green
    "#52823A",  # swoosh green, shadowed edge
    "#FFFFFF",  # counter, lane dashes
    "#CFD0D1",  # car body
    "#9A9A9A",  # car shading
    "#F0B428",  # traffic-light housing
    "#CE3A2C",  # stop lens
    "#55B4A4",  # signal arcs
]

# What the mono cut keeps as solid colour; everything else becomes the road void.
MONO_KEEP = {"#6FA44A", "#52823A", "#FFFFFF", "#55B4A4"}

ANDROID_LEGACY_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

TRANSFORM_RE = re.compile(r'<g transform="([^"]+)"')
PATH_RE = re.compile(r'<path d="([^"]+)"')


def rgb(hex_color: str) -> tuple[int, int, int]:
    return (int(hex_color[1:3], 16), int(hex_color[3:5], 16), int(hex_color[5:7], 16))


def require(tool: str) -> None:
    if subprocess.run(["which", tool], capture_output=True).returncode != 0:
        sys.exit(f"missing required tool: {tool}")


# --------------------------------------------------------------------------------------
# 1. Isolate the symbol
# --------------------------------------------------------------------------------------


def isolate_symbol() -> Image.Image:
    im = Image.open(SOURCE).convert("RGBA")
    w, h = im.size
    px = im.load()

    def is_background(p) -> bool:
        r, g, b, a = p
        return a < 128 or (r > 225 and g > 225 and b > 225)

    exterior = bytearray(w * h)
    queue: deque[tuple[int, int]] = deque()

    def seed(x: int, y: int) -> None:
        if not exterior[y * w + x] and is_background(px[x, y]):
            exterior[y * w + x] = 1
            queue.append((x, y))

    for x in range(w):
        seed(x, 0)
        seed(x, h - 1)
    for y in range(h):
        seed(0, y)
        seed(w - 1, y)

    while queue:
        x, y = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not exterior[ny * w + nx]:
                if is_background(px[nx, ny]):
                    exterior[ny * w + nx] = 1
                    queue.append((nx, ny))

    keep = [not exterior[i] for i in range(w * h)]

    # Label what survived so the wordmark can be dropped. It cannot be cut by row: the
    # pin's tip reaches y=402 while the letters start at y=378. They are told apart by
    # where they *begin* — every letter starts in the bottom quarter, and the only other
    # small components (the signal arcs) sit at the very top.
    seen = [False] * (w * h)
    components: list[tuple[list[int], tuple[int, int, int, int]]] = []
    for start in range(w * h):
        if not keep[start] or seen[start]:
            continue
        seen[start] = True
        stack = [start]
        pixels: list[int] = []
        minx, miny, maxx, maxy = w, h, 0, 0
        while stack:
            i = stack.pop()
            pixels.append(i)
            x, y = i % w, i // w
            minx, maxx = min(minx, x), max(maxx, x)
            miny, maxy = min(miny, y), max(maxy, y)
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        j = ny * w + nx
                        if keep[j] and not seen[j]:
                            seen[j] = True
                            stack.append(j)
        components.append((pixels, (minx, miny, maxx, maxy)))

    components.sort(key=lambda c: len(c[0]), reverse=True)

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    op = out.load()
    minx, miny, maxx, maxy = w, h, 0, 0
    for index, (pixels, bbox) in enumerate(components):
        is_pin = index == 0  # the pin is by far the largest component
        if not is_pin:
            if bbox[1] > 0.75 * h:  # wordmark
                continue
            if len(pixels) < 12:  # antialiasing speck
                continue
        for i in pixels:
            x, y = i % w, i // w
            r, g, b, _ = px[x, y]
            op[x, y] = (r, g, b, 255)
        minx, miny = min(minx, bbox[0]), min(miny, bbox[1])
        maxx, maxy = max(maxx, bbox[2]), max(maxy, bbox[3])

    symbol = out.crop((minx, miny, maxx + 1, maxy + 1))
    symbol.save(WORK / "symbol.png")
    print(f"  symbol isolated: {symbol.size[0]}x{symbol.size[1]}")
    return symbol


# --------------------------------------------------------------------------------------
# 2. Flatten to the palette
# --------------------------------------------------------------------------------------


def flatten(symbol: Image.Image) -> Image.Image:
    palette = [rgb(c) for c in PALETTE]
    w, h = symbol.size
    px = symbol.load()
    flat = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    fp = flat.load()
    cache: dict[tuple[int, int, int], tuple[int, int, int]] = {}

    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 128:
                continue
            key = (r, g, b)
            mapped = cache.get(key)
            if mapped is None:
                # Weighted toward luminance; plain Euclidean RGB pulled the amber housing
                # toward grey.
                mapped = min(
                    palette,
                    key=lambda p: 2 * (r - p[0]) ** 2 + 4 * (g - p[1]) ** 2 + 3 * (b - p[2]) ** 2,
                )
                cache[key] = mapped
            fp[x, y] = (*mapped, 255)

    flat.save(WORK / "symbol_flat.png")
    print(f"  flattened to {len(PALETTE)} colours")
    return flat


# --------------------------------------------------------------------------------------
# 3. Trace
# --------------------------------------------------------------------------------------


def trace_mask(mask: Image.Image, name: str, turd_size: int = 4) -> tuple[str, str]:
    pbm = WORK / f"mask_{name}.pbm"
    svg = WORK / f"mask_{name}.svg"
    mask.save(pbm)
    subprocess.run(
        ["potrace", str(pbm), "-s", "-o", str(svg), "--flat",
         "-a", "1.0", "-O", "0.2", "-t", str(turd_size)],
        check=True,
        capture_output=True,
    )
    text = svg.read_text()
    transform = TRANSFORM_RE.search(text)
    paths = PATH_RE.findall(text)
    if not transform or not paths:
        return "", ""
    return transform.group(1), " ".join(paths)


def build_color_svg(flat: Image.Image) -> None:
    w, h = flat.size
    px = flat.load()

    silhouette = Image.new("1", (w, h), 1)
    sp = silhouette.load()
    layers = []

    for hex_color in PALETTE:
        target = rgb(hex_color)
        mask = Image.new("1", (w, h), 1)
        mp = mask.load()
        count = 0
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[x, y]
                if a < 128:
                    continue
                sp[x, y] = 0
                if (r, g, b) == target:
                    mp[x, y] = 0
                    count += 1
        if count == 0:
            continue
        transform, d = trace_mask(mask, hex_color[1:])
        if d:
            layers.append((hex_color, count, d))

    sil_transform, sil_d = trace_mask(silhouette, "silhouette")
    layers.sort(key=lambda layer: layer[1], reverse=True)

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">',
        f'<g transform="{sil_transform}" fill-rule="evenodd">',
        # The colour masks are mutually exclusive, so a hairline of background can show
        # along a seam where two meet. A silhouette underneath in the dominant navy plus
        # a same-colour hairline stroke on each layer closes those seams.
        f'<path fill="{PALETTE[0]}" stroke="{PALETTE[0]}" stroke-width="1" d="{sil_d}"/>',
    ]
    for hex_color, _count, d in layers:
        parts.append(
            f'<path fill="{hex_color}" stroke="{hex_color}" stroke-width="1" d="{d}"/>'
        )
    parts.append("</g></svg>")

    COLOR_SVG.write_text("\n".join(parts) + "\n")
    print(f"  {COLOR_SVG.relative_to(REPO)}: {COLOR_SVG.stat().st_size} bytes")


def build_mono_svg(flat: Image.Image) -> None:
    w, h = flat.size
    px = flat.load()
    keep = {rgb(c) for c in MONO_KEEP}

    # Filling only the swoosh and counter breaks the mark: the road runs to the pin's
    # right edge, so knocking it out severs the outline into floating blobs. Keep the
    # whole pin and void only the road's *interior* — the erosion leaves a white rim, so
    # the teardrop stays closed and the S-curve still reads as a road through it.
    silhouette = Image.new("L", (w, h), 0)
    road = Image.new("L", (w, h), 0)
    sp, rp = silhouette.load(), road.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 128:
                continue
            sp[x, y] = 255
            if (r, g, b) not in keep:
                rp[x, y] = 255

    # Lane dashes, the car and the traffic light are islands inside the road. Left alone
    # they stay solid and pock the void with unreadable bumps, so fill every hole the
    # road encloses: anything a border flood cannot reach is interior.
    outside = bytearray(w * h)
    queue: deque[tuple[int, int]] = deque()

    def seed(x: int, y: int) -> None:
        if not rp[x, y] and not outside[y * w + x]:
            outside[y * w + x] = 1
            queue.append((x, y))

    for x in range(w):
        seed(x, 0)
        seed(x, h - 1)
    for y in range(h):
        seed(0, y)
        seed(w - 1, y)
    while queue:
        x, y = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not outside[ny * w + nx] and not rp[nx, ny]:
                outside[ny * w + nx] = 1
                queue.append((nx, ny))
    for y in range(h):
        for x in range(w):
            if not rp[x, y] and not outside[y * w + x]:
                rp[x, y] = 255

    # Square erosion. 21 px at this source width leaves a rim just under 3% of the mark's
    # width, which survives down to icon sizes.
    eroded = road.filter(ImageFilter.MinFilter(21))
    ep = eroded.load()

    mask = Image.new("1", (w, h), 1)
    mp = mask.load()
    for y in range(h):
        for x in range(w):
            if sp[x, y] and not ep[x, y]:
                mp[x, y] = 0

    transform, d = trace_mask(mask, "mono", turd_size=8)
    MONO_SVG.write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">\n'
        f'<g transform="{transform}" fill-rule="evenodd">\n'
        f'<path fill="#FFFFFF" d="{d}"/>\n'
        f"</g></svg>\n"
    )
    print(f"  {MONO_SVG.relative_to(REPO)}: {MONO_SVG.stat().st_size} bytes")


# --------------------------------------------------------------------------------------
# 4. Platform assets
# --------------------------------------------------------------------------------------


def padded_svg(src: Path, canvas: float, content: float, out: Path) -> Path:
    text = src.read_text()
    view = re.search(r'viewBox="0 0 ([\d.]+) ([\d.]+)"', text)
    w, h = float(view.group(1)), float(view.group(2))
    body = text[text.index("<g ") : text.rindex("</svg>")]
    scale = content / max(w, h)
    tx = (canvas - w * scale) / 2
    ty = (canvas - h * scale) / 2
    out.write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {canvas} {canvas}" '
        f'width="{canvas}" height="{canvas}">\n'
        f'<g transform="translate({tx:.3f},{ty:.3f}) scale({scale:.6f})">\n{body}\n</g></svg>\n'
    )
    return out


def render_png(svg: Path, px: int, out: Path, opaque: bool) -> None:
    subprocess.run(
        ["resvg", "--width", str(px), "--height", str(px), str(svg), str(out)],
        check=True,
        capture_output=True,
    )
    im = Image.open(out).convert("RGBA")
    if opaque:
        # iOS rejects icons with an alpha channel, and the Android set being replaced was
        # opaque too.
        flat = Image.new("RGBA", im.size, (255, 255, 255, 255))
        flat.alpha_composite(im)
        flat.convert("RGB").save(out)


def to_vector_drawable(svg: Path, out: Path, size_dp: int) -> None:
    result = subprocess.run(
        ["npx", "-y", "svg2vectordrawable", "-i", str(svg), "-o", str(out)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or not out.exists():
        sys.exit(f"svg2vectordrawable failed for {svg.name}:\n{result.stdout}\n{result.stderr}")
    xml = out.read_text()
    xml = re.sub(r'android:width="[^"]*"', f'android:width="{size_dp}dp"', xml, count=1)
    xml = re.sub(r'android:height="[^"]*"', f'android:height="{size_dp}dp"', xml, count=1)
    out.write_text(xml)


def build_platform_assets() -> None:
    legacy = padded_svg(COLOR_SVG, 100, 84, WORK / "icon_legacy.svg")
    for folder, px in ANDROID_LEGACY_SIZES.items():
        render_png(legacy, px, ANDROID_RES / folder / "ic_launcher.png", opaque=True)
    print(f"  android legacy icons: {len(ANDROID_LEGACY_SIZES)}")

    # 66/108 is the adaptive icon safe zone; anything outside it can be cropped by the
    # launcher's mask.
    to_vector_drawable(
        padded_svg(COLOR_SVG, 108, 66, WORK / "icon_foreground.svg"),
        ANDROID_RES / "drawable/ic_launcher_foreground.xml",
        108,
    )
    to_vector_drawable(
        padded_svg(MONO_SVG, 108, 66, WORK / "icon_monochrome.svg"),
        ANDROID_RES / "drawable/ic_launcher_monochrome.xml",
        108,
    )
    to_vector_drawable(
        padded_svg(COLOR_SVG, 160, 148, WORK / "splash.svg"),
        ANDROID_RES / "drawable/tracgo_splash_logo.xml",
        160,
    )
    to_vector_drawable(
        padded_svg(MONO_SVG, 160, 148, WORK / "splash_mono.svg"),
        ANDROID_RES / "drawable/tracgo_splash_logo_mono.xml",
        160,
    )
    print("  android vector drawables: 4")

    ios_svg = padded_svg(COLOR_SVG, 100, 86, WORK / "icon_ios.svg")
    count = 0
    for png in sorted(IOS_APPICON.glob("*.png")):
        render_png(ios_svg, Image.open(png).size[0], png, opaque=True)
        count += 1
    print(f"  ios app icons: {count}")

    # The launch mark is tight to its canvas — unlike the app icon, which is inset to
    # survive the rounded-rect mask — and keeps its alpha, so it sits on the colour the
    # storyboard paints rather than carrying a white square of its own.
    launch_svg = padded_svg(COLOR_SVG, 100, 100, WORK / "launch_ios.svg")
    for scale in (1, 2, 3):
        suffix = "" if scale == 1 else f"@{scale}x"
        render_png(
            launch_svg,
            IOS_LAUNCH_MARK_PT * scale,
            IOS_LAUNCH / f"LaunchImage{suffix}.png",
            opaque=False,
        )
    print("  ios launch images: 3")


def main() -> None:
    for tool in ("potrace", "resvg", "npx"):
        require(tool)
    if not SOURCE.exists():
        sys.exit(f"source artwork missing: {SOURCE}")
    WORK.mkdir(parents=True, exist_ok=True)

    print("isolating symbol")
    symbol = isolate_symbol()
    print("flattening palette")
    flat = flatten(symbol)
    print("tracing")
    build_color_svg(flat)
    build_mono_svg(flat)
    print("platform assets")
    build_platform_assets()
    print("done")


if __name__ == "__main__":
    main()
