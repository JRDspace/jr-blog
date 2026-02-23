import re
from pathlib import Path

root = Path(r'D:\jr-blog')
posts = sorted((root / '_posts').glob('*.html'))

def is_valid_image(p: Path) -> bool:
    if not p.exists() or p.stat().st_size < 12:
        return False
    b = p.read_bytes()[:16]
    return b.startswith(b'\xff\xd8\xff') or b.startswith(b'\x89PNG') or b.startswith(b'GIF8') or (b.startswith(b'RIFF') and b[8:12]==b'WEBP')

for post in posts:
    txt = post.read_text(encoding='utf-8', errors='ignore')
    srcs = re.findall(r'src="([^"]+)"', txt)
    local_srcs = [s for s in srcs if s.startswith('/assets/img/posts/')]
    bad=[]
    for s in local_srcs:
        p = root / s.lstrip('/').replace('/', '\\')
        if not p.exists():
            bad.append(('missing', s))
        elif not is_valid_image(p):
            bad.append(('invalid', s))
    if bad:
        print(f"\n{post.name} bad={len(bad)}")
        for kind, s in bad[:8]:
            print(f"- {kind}: {s}")
