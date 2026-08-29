from pathlib import Path
from PIL import Image

source = Path('/home/ubuntu/upload/1c2a7097d927aa26fd4cf1611bcefebc.jpg')
project = Path('/home/ubuntu/expat_status_checker')
assets = project / 'assets/images'
assets.mkdir(parents=True, exist_ok=True)

# Preserve the uploaded image itself for the in-app brand mark.
source_image = Image.open(source).convert('RGB')
source_image.save(assets / 'fim_malaysia_flag_logo.jpg', quality=95, optimize=True)

# Android launcher resources require PNG files; these are resized copies of the
# exact uploaded image, not a redesigned or AI-generated logo.
res_dir = project / 'android/app/src/main/res'
for folder, size in {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}.items():
    destination = res_dir / folder / 'ic_launcher.png'
    source_image.resize((size, size), Image.Resampling.LANCZOS).save(destination, format='PNG', optimize=True)

print(f'prepared {assets / "fim_malaysia_flag_logo.jpg"}')
