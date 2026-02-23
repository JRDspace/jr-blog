import re
from pathlib import Path

root = Path(r'D:\jr-blog')
posts = sorted((root / '_posts').glob('*.html'))

img_sig = {
    b'\xff\xd8\xff': 'jpeg',
    b'\x89PNG': 'png',
    b'GIF8': 'gif',
}

def is_valid_image(p: Path) -> bool:
    if not p.exists() or p.stat().st_size < 12:
        return False
    b = p.read_bytes()[:16]
    if b.startswith(b'\xff\xd8\xff'):
        return True
    if b.startswith(b'\x89PNG'):
        return True
    if b.startswith(b'GIF8'):
        return True
    if b.startswith(b'RIFF') and b[8:12] == b'WEBP':
        return True
    return False

for post in posts:
    txt = post.read_text(encoding='utf-8', errors='ignore')
    srcs = re.findall(r'src="([^"]+)"', txt)
    local_srcs = [s for s in srcs if s.startswith('/assets/img/posts/')]
    missing = 0
    invalid = 0
    for s in local_srcs:
        p = root / s.lstrip('/').replace('/', '\\')
        if not p.exists():
            missing += 1
        elif not is_valid_image(p):
            invalid += 1
    if local_srcs:
        print(f"{post.name}|local_src={len(local_srcs)}|missing={missing}|invalid={invalid}")
