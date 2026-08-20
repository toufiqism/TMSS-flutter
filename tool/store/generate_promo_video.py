#!/usr/bin/env python3
"""Render the TracGo promo video: 1920x1080, ~28s, no audio track needed.

    python3 tool/store/generate_promo_video.py [out.mp4]

Default output: docs/play/graphics/tracgo-promo-1080p.mp4

Frames are generated with Pillow and piped straight into ffmpeg as raw RGB, so no
intermediate PNGs are written — 850-odd 1920x1080 frames would otherwise be a couple of
gigabytes of scratch files.

Source material is `docs/play/graphics/screenshots/raw/*.png`, the same synthetic
captures the store screenshots are built from (see `docs/play/graphics/README.md`): the
app talking to `tool/store/mock_api_server.py`, so every name and address on screen is
invented.

Requirements: `brew install ffmpeg`, `pip3 install pillow`.
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
FONTS = REPO / "assets/fonts"
RAW = REPO / "docs/play/graphics/screenshots/raw"
LOGO = REPO / "assets/images/tracgo_logo.svg"
WORK = REPO / "build/store"
DEFAULT_OUT = REPO / "docs/play/graphics/tracgo-promo-1080p.mp4"

W, H = 1920, 1080
FPS = 30

INK = (0x12, 0x12, 0x2B)
LIME = (0x7A, 0xB6, 0x48)
WHITE = (0xFF, 0xFF, 0xFF)
MUTED = (0xC5, 0xCB, 0xC2)
DIM = (0x8D, 0x94, 0x8B)

SCENE_SECONDS = 4.4
FADE_SECONDS = 0.55
INTRO_SECONDS = 2.8
OUTRO_SECONDS = 3.2

# Phone viewport on the right-hand side of the frame.
PHONE_H = 900
PHONE_W = round(PHONE_H * 1344 / 2992)
PHONE_X = 1230
PHONE_Y = (H - PHONE_H) // 2
PHONE_RADIUS = 34
PUSH_IN = 0.045          # how far the capture scales up over a scene

SCENES = [
    ("01-dashboard.png", "Every requisition\nat a glance",
     "Pending, approved, assigned and rejected — counted for you, with your latest trips underneath."),
    ("02-new-passenger.png", "Raise a trip request\nin seconds",
     "Pick the time, the route and who is travelling. The form is three short steps."),
    ("03-detail-assigned.png", "Know your vehicle\nand driver",
     "The moment transport assigns a trip, the plate and the driver's number are in your pocket."),
    ("04-list.png", "Follow every request\nto the trip",
     "Search your own history, filter by date, and cancel anything still pending."),
    ("05-logistics.png", "Cargo runs, not just\npassengers",
     "Cover van or open truck, loading capacity and goods weight — same flow, same approvals."),
    ("06-login.png", "Sign in with your\nwork account",
     "Accounts are issued by your organisation. There is no sign-up and no public access."),
]


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / name), size)


def logo(height: int) -> Image.Image:
    WORK.mkdir(parents=True, exist_ok=True)
    png = WORK / f"promo-logo-{height}.png"
    if not png.exists():
        subprocess.run(["resvg", str(LOGO), str(png), "--width",
                        str(round(height * 303 / 385)), "--height", str(height)],
                       check=True, capture_output=True)
    return Image.open(png).convert("RGBA")


def background() -> Image.Image:
    """Ink page with a lime bloom behind the phone — the feature graphic's treatment."""
    layer = Image.new("RGB", (W, H), INK)
    draw = ImageDraw.Draw(layer)
    cx, cy, radius = PHONE_X + PHONE_W // 2, H // 2, 620
    for i in range(48, 0, -1):
        r = radius * i / 48
        t = 1 - i / 48
        colour = tuple(round(INK[c] + (LIME[c] - INK[c]) * t * 0.26) for c in range(3))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=colour)
    return layer.filter(ImageFilter.GaussianBlur(90))


def wrap(draw: ImageDraw.ImageDraw, text: str, f: ImageFont.FreeTypeFont, limit: int):
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


BG = None
MARK_SMALL = None


def scene_plate(headline: str, sub: str) -> Image.Image:
    """Everything in a scene except the phone: background, wordmark, copy."""
    plate = BG.copy()
    draw = ImageDraw.Draw(plate)

    plate.paste(MARK_SMALL, (150, 96), MARK_SMALL)
    draw.text((150 + MARK_SMALL.width + 26, 108), "TracGo",
              font=font("space_grotesk_bold.ttf", 46), fill=WHITE)

    head = font("space_grotesk_bold.ttf", 78)
    y = 380
    for line in headline.split("\n"):
        draw.text((150, y), line, font=head, fill=WHITE)
        y += 92

    draw.line([(150, y + 26), (150 + 96, y + 26)], fill=LIME, width=5)
    y += 74

    body = font("plus_jakarta_sans_medium.ttf", 32)
    for line in wrap(draw, sub, body, 880):
        draw.text((150, y), line, font=body, fill=MUTED)
        y += 46
    return plate


def phone_layer(capture: Image.Image, progress: float) -> Image.Image:
    """The capture inside a rounded viewport, pushing in slowly as the scene runs.

    A vertical pan was the first attempt and looked like a mistake: by mid-scene it had
    scrolled the app bar out of the viewport, so every screen lost its own title. The
    push-in is centred, so at the start of a scene the screen is whole and even at the
    end it has only lost ~2% off each edge.
    """
    zoom = 1.0 + PUSH_IN * min(max(progress, 0.0), 1.0)
    scaled_h = round(PHONE_H * zoom)
    scaled_w = round(PHONE_W * zoom)
    frame = capture.resize((scaled_w, scaled_h), Image.LANCZOS)

    offset_x = (scaled_w - PHONE_W) // 2
    offset_y = (scaled_h - PHONE_H) // 2
    view = frame.crop((offset_x, offset_y, offset_x + PHONE_W, offset_y + PHONE_H))

    mask = Image.new("L", view.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, view.width - 1, view.height - 1],
                                           radius=PHONE_RADIUS, fill=255)
    out = view.convert("RGBA")
    out.putalpha(mask)
    return out


def phone_shadow() -> Image.Image:
    spread = 60
    layer = Image.new("RGBA", (PHONE_W + spread * 2, PHONE_H + spread * 2), (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle(
        [spread, spread, spread + PHONE_W, spread + PHONE_H],
        radius=PHONE_RADIUS, fill=(0, 0, 0, 110))
    return layer.filter(ImageFilter.GaussianBlur(46))


def card(title: str, sub: str, mark_height: int) -> Image.Image:
    """Intro and outro: centred mark, wordmark, one line of copy."""
    plate = BG.copy()
    draw = ImageDraw.Draw(plate)
    mark = logo(mark_height)

    title_font = font("space_grotesk_bold.ttf", 96)
    sub_font = font("plus_jakarta_sans_medium.ttf", 34)
    title_w = draw.textlength(title, font=title_font)

    block_h = mark.height + 42 + 110 + 60
    top = (H - block_h) // 2
    plate.paste(mark, ((W - mark.width) // 2, top), mark)
    draw.text(((W - title_w) // 2, top + mark.height + 42), title, font=title_font, fill=WHITE)

    y = top + mark.height + 42 + 118
    for line in wrap(draw, sub, sub_font, 1100):
        line_w = draw.textlength(line, font=sub_font)
        draw.text(((W - line_w) // 2, y), line, font=sub_font, fill=MUTED)
        y += 48
    return plate


def build_timeline():
    """(renderer, duration) segments; each renderer takes progress 0..1."""
    intro = card("TracGo", "Company vehicle requisitions, from request to trip.", 240)
    # No store-availability claim here on purpose: iOS is built but not published, and a
    # promo that says "available on" a store the app is not on is a rejection risk.
    outro = card("TracGo", "B-Trac Solutions Limited · Issued to employees by your organisation", 200)

    shadow = phone_shadow()
    segments = [(lambda p, img=intro: img, INTRO_SECONDS)]

    for name, headline, sub in SCENES:
        plate = scene_plate(headline, sub)
        capture = Image.open(RAW / name).convert("RGB")

        def render(p, plate=plate, capture=capture, shadow=shadow):
            frame = plate.copy()
            frame.paste(shadow, (PHONE_X - 60, PHONE_Y - 60 + 20), shadow)
            phone = phone_layer(capture, p)
            frame.paste(phone, (PHONE_X, PHONE_Y), phone)
            return frame

        segments.append((render, SCENE_SECONDS))

    segments.append((lambda p, img=outro: img, OUTRO_SECONDS))
    return segments


def frames(segments):
    """Yield every frame, cross-fading FADE_SECONDS between consecutive segments."""
    fade_frames = round(FADE_SECONDS * FPS)
    for index, (render, seconds) in enumerate(segments):
        count = round(seconds * FPS)
        for i in range(count):
            p = i / max(count - 1, 1)
            frame = render(p)
            # Fade in over the tail of the previous segment.
            if index > 0 and i < fade_frames:
                previous = segments[index - 1][0](1.0)
                frame = Image.blend(previous, frame, i / fade_frames)
            yield frame


def main() -> None:
    global BG, MARK_SMALL
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_OUT
    missing = [name for name, _, _ in SCENES if not (RAW / name).exists()]
    if missing:
        sys.exit(f"missing captures in {RAW}: {', '.join(missing)}")

    BG = background()
    MARK_SMALL = logo(58)

    segments = build_timeline()
    total = sum(round(seconds * FPS) for _, seconds in segments)
    out.parent.mkdir(parents=True, exist_ok=True)

    command = [
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
        # A silent stereo track: some uploaders and players behave oddly with a
        # video-only MP4, and an empty AAC stream costs a few kilobytes.
        "-f", "lavfi", "-i", "anullsrc=channel_layout=stereo:sample_rate=48000",
        "-shortest",
        "-c:v", "libx264", "-preset", "slow", "-crf", "19", "-pix_fmt", "yuv420p",
        "-movflags", "+faststart", "-c:a", "aac", "-b:a", "128k",
        str(out),
    ]
    process = subprocess.Popen(command, stdin=subprocess.PIPE)
    written = 0
    for frame in frames(segments):
        process.stdin.write(frame.tobytes())
        written += 1
        if written % (FPS * 5) == 0:
            print(f"  {written}/{total} frames", flush=True)
    process.stdin.close()
    if process.wait() != 0:
        sys.exit("ffmpeg failed")

    size_mb = out.stat().st_size / (1024 * 1024)
    print(f"{out.relative_to(REPO)}  {W}x{H}  {written / FPS:.1f}s  {size_mb:.1f} MB")


if __name__ == "__main__":
    main()
