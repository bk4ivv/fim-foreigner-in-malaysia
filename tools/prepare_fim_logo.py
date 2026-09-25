from pathlib import Path
from PIL import Image

source = Path('/home/ubuntu/upload/1_20260925_150933_0000.png')
logo = Image.open(source).convert('RGBA')
assert logo.getchannel('A').getextrema()[0] == 0
assert logo.getpixel((0, 0))[3] == 0

canonical = Path('assets/images/fim_logo.png')
canonical.parent.mkdir(parents=True, exist_ok=True)
logo.save(canonical, format='PNG', optimize=True)

for density, size in {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
}.items():
    output = logo.resize((size, size), Image.Resampling.LANCZOS)
    destination = Path(f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
    destination.parent.mkdir(parents=True, exist_ok=True)
    output.save(destination, format='PNG', optimize=True)

print(f'Installed {canonical} ({logo.width}x{logo.height}, RGBA, transparent corners).')
print('Regenerated Android launcher icons for mdpi through xxxhdpi.')
