"""Copy genuine MCP captures first, then resize/re-encode only when caps require it."""
from pathlib import Path
import shutil
import sys
from PIL import Image

root = Path(__file__).resolve().parents[1] / 'screenshots'
names = ['1-start.jpg', '2-play.jpg', '3-cargo.jpg']
if len(sys.argv) != 4:
    raise SystemExit('Provide the three original Studio capture paths')
for source, name in zip(sys.argv[1:], names):
    destination = root / name
    shutil.copyfile(source, destination)
    with Image.open(destination) as original:
        original.load()
        picture = original.convert('RGB')
        needs_encoding = original.size != (1280, 720) or destination.stat().st_size > 262144 or original.format != 'JPEG'
    if needs_encoding:
        picture = picture.resize((1280, 720), Image.Resampling.LANCZOS)
        for quality in range(92, 29, -4):
            picture.save(destination, 'JPEG', quality=quality, optimize=True)
            if destination.stat().st_size <= 262144:
                break
    with Image.open(destination) as verified:
        verified.load()
        assert verified.size == (1280, 720)
        assert verified.format == 'JPEG'
        assert destination.stat().st_size <= 262144
        print(f'PASS real capture {name}: {verified.width}x{verified.height}, {destination.stat().st_size} bytes')
