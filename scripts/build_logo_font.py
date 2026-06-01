import re
from fontTools.svgLib.path import parse_path
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.transformPen import TransformPen
from fontTools.misc.transform import Transform
from fontTools.fontBuilder import FontBuilder

CP = 0xE800
UPM, ASC, DESC = 1000, 800, -200
Hvb = 341.292002
HEIGHT = 620.0          # altura del logo en unidades de em
S = HEIGHT/Hvb
OFFX = 10               # margen lateral izq (movido a la izquierda)
OFFY = -10              # desplazamiento vertical (baseline)

d = re.search(r'd="([^"]*)"', open('/tmp/logo.svg').read(), re.S).group(1)

# path(internal) -> viewBox -> font(y-up)
total = (Transform()
         .translate(OFFX, S*Hvb+OFFY)
         .scale(S, -S)
         .translate(-20.5, 361.0)
         .scale(0.1, -0.1))

ttpen = TTGlyphPen(None)
tpen = TransformPen(Cu2QuPen(ttpen, max_err=0.5, reverse_direction=True), total)
parse_path(d, tpen)
glyph = ttpen.glyph()

notdef = TTGlyphPen(None).glyph()
adv = round(OFFX*2 + S*443.654616)

fb = FontBuilder(UPM, isTTF=True)
fb.setupGlyphOrder(['.notdef', 'bolado'])
fb.setupCharacterMap({CP: 'bolado'})
fb.setupGlyf({'.notdef': notdef, 'bolado': glyph})
fb.setupHorizontalMetrics({'.notdef': (600, 0), 'bolado': (adv, 0)})
fb.setupHorizontalHeader(ascent=ASC, descent=DESC)
fb.setupNameTable({'familyName':'Bolado Logo','styleName':'Regular',
                   'fullName':'Bolado Logo','psName':'BoladoLogo-Regular',
                   'version':'1.0'})
fb.setupOS2(sTypoAscender=ASC, sTypoDescender=DESC, usWinAscent=ASC, usWinDescent=-DESC)
fb.setupPost()
fb.save('/tmp/BoladoLogo.ttf')
print("fuente creada. advance=", adv, " glyph bbox=", glyph.xMin if hasattr(glyph,'xMin') else '?')

# === preview ===
from PIL import Image, ImageFont, ImageDraw
f = ImageFont.truetype('/tmp/BoladoLogo.ttf', 72)
asc, desc = f.getmetrics()
img = Image.new('RGB', (160, 110), (20,20,20)); dr = ImageDraw.Draw(img)
top = 18
dr.text((40, top), chr(CP), font=f, fill=(240,240,240))
base = top + asc
dr.line([(0,base),(160,base)], fill=(80,40,40))   # baseline (roja tenue)
img.save('/tmp/glyph_preview.png')
print("preview /tmp/glyph_preview.png (linea = baseline)")
