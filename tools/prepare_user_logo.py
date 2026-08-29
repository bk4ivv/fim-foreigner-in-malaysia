from pathlib import Path
from PIL import Image

source = Path('/home/ubuntu/upload/Screenshot_20260828-233949.png')
project = Path('/home/ubuntu/expat_status_checker')

image = Image.open(source).convert('RGBA')
# The supplied reference is 1080x2280. This box contains only the header shield badge.
crop = image.crop((17, 78, 80, 141))

# Keep the badge as a clean circular mark while making the screenshot background transparent.
width, height = crop.size
cx, cy = (width - 1) / 2, (height - 1) / 2
radius = min(width, height) / 2 - 1
pixels = crop.load()
for y in range(height):
    for x in range(width):
        if ((x - cx) ** 2 + (y - cy) ** 2) > radius ** 2:
            pixels[x, y] = (0, 0, 0, 0)

logo_path = project / 'assets/images/foreigner_in_malaysia_logo.png'
logo_path.parent.mkdir(parents=True, exist_ok=True)
crop.resize((1024, 1024), Image.Resampling.LANCZOS).save(logo_path)

res_dir = project / 'android/app/src/main/res'
for folder, size in {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}.items():
    destination = res_dir / folder / 'ic_launcher.png'
    crop.resize((size, size), Image.Resampling.LANCZOS).save(destination)

print(f'prepared {logo_path}')
