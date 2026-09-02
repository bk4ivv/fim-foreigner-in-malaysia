from pathlib import Path
from PIL import Image

ROOT = Path('/home/ubuntu/expat_status_checker/assets/images')
SOURCES = (
    'culture_batik_texture.png',
    'culture_rainforest_durian.png',
    'culture_lrt_heritage.png',
)

for name in SOURCES:
    source = ROOT / name
    if not source.exists():
        continue
    image = Image.open(source).convert('RGB')
    image.thumbnail((1200, 1200), Image.Resampling.LANCZOS)
    target = source.with_suffix('.jpg')
    image.save(target, format='JPEG', quality=82, optimize=True, progressive=True)
    source.unlink()
    print(f'optimized {target.name}: {image.size}, {target.stat().st_size} bytes')
