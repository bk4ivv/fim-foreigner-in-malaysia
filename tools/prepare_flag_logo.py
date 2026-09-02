from pathlib import Path
from PIL import Image

project = Path('/home/ubuntu/expat_status_checker')
assets = project / 'assets/images'
source = assets / 'fim_malaysia_flag_logo.jpg'

if not source.exists():
    raise FileNotFoundError(source)

# The in-app brand mark is already the preserved user-provided Malaysian flag shield.
source_image = Image.open(source).convert('RGB')

# Android launcher resources are resized copies of that exact shield, not a redesigned logo.
res_dir = project / 'android/app/src/main/res'
for folder, size in {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}.items():
    destination = res_dir / folder / 'ic_launcher.png'
    destination.parent.mkdir(parents=True, exist_ok=True)
    source_image.resize((size, size), Image.Resampling.LANCZOS).save(
        destination,
        format='PNG',
        optimize=True,
    )

print(f'prepared launcher icons from {source}')
