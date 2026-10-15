#!/usr/bin/env python3
"""Generate original AnatoMorph launcher artwork (MIT), not anatomy media."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
base=Image.new('RGB',(1024,1024),'#287D72')
draw=ImageDraw.Draw(base)
draw.ellipse((433,180,591,338),fill='#F8FAF7')
draw.rounded_rectangle((459,370,565,641),radius=36,fill='#F8FAF7')
draw.line([(298,400),(512,468),(726,400)],fill='#F8FAF7',width=69)
draw.line([(512,596),(385,821)],fill='#F8FAF7',width=74)
draw.line([(512,596),(639,821)],fill='#F8FAF7',width=74)
for pattern in ['android/app/src/main/res/mipmap-*/ic_launcher.png','ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png','macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png','web/icons/*.png','web/favicon.png']:
    for path in ROOT.glob(pattern):
        size=Image.open(path).size
        base.resize(size,Image.Resampling.LANCZOS).save(path)
base.save(ROOT/'windows/runner/resources/app_icon.ico',format='ICO',sizes=[(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)])
print('Generated platform launcher icons from original artwork.')
