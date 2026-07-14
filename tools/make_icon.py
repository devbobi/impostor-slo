"""Generira končno ikono aplikacije Vsiljivec (emoji 🥸 na gradientu)."""
import os
from PIL import Image, ImageDraw, ImageFont

S = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
os.makedirs(OUT, exist_ok=True)

PURPLE = (124, 77, 255)
PINK = (255, 77, 141)
EMOJI = "🥸"
EMOJI_FONT = "C:/Windows/Fonts/seguiemj.ttf"


def vgradient(size, c1, c2):
    img = Image.new("RGB", (size, size))
    d = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        d.line([(0, y), (size, y)], fill=(
            int(c1[0] + (c2[0] - c1[0]) * t),
            int(c1[1] + (c2[1] - c1[1]) * t),
            int(c1[2] + (c2[2] - c1[2]) * t),
        ))
    return img


def emoji_layer(char, px):
    font = ImageFont.truetype(EMOJI_FONT, px)
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    bbox = d.textbbox((0, 0), char, font=font, embedded_color=True)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (S - w) // 2 - bbox[0]
    y = (S - h) // 2 - bbox[1]
    d.text((x, y), char, font=font, embedded_color=True)
    return layer


bg = vgradient(S, PURPLE, PINK)

# 1) Polna ikona (legacy / okrogla): gradient + emoji
full = bg.convert("RGBA")
full.alpha_composite(emoji_layer(EMOJI, 660))
full.convert("RGB").save(os.path.join(OUT, "icon.png"))

# 2) Ozadje za adaptive ikono (poln gradient)
bg.save(os.path.join(OUT, "icon_background.png"))

# 3) Ospredje za adaptive ikono (samo emoji, manjše zaradi varne cone)
fg = emoji_layer(EMOJI, 560)
fg.save(os.path.join(OUT, "icon_foreground.png"))

print("OK ->", os.path.abspath(OUT))
