import concurrent.futures as cf
import hashlib
import re
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

ROOT = Path(r"D:\jr-blog")
post = ROOT / "_posts" / "2023-12-26-long-ride-7-hyderabad-nepal-round-trip.html"
slug = "long-ride-7-hyderabad-nepal-round-trip"
media = ROOT / "assets" / "img" / "posts" / slug
media.mkdir(parents=True, exist_ok=True)

content = post.read_text(encoding='utf-8', errors='ignore')
urls = sorted(set(re.findall(r'https?://[^\s\"\'<>]+', content)))
urls = [u for u in urls if urlparse(u).hostname == 'blogger.googleusercontent.com']

def good(b: bytes):
    if len(b) < 12: return False
    return b.startswith(b'\xff\xd8\xff') or b.startswith(b'\x89PNG') or b.startswith(b'GIF8') or (b.startswith(b'RIFF') and b[8:12]==b'WEBP')

def fetch(u):
    req = Request(u, headers={"User-Agent":"Mozilla/5.0"})
    for _ in range(3):
        try:
            with urlopen(req, timeout=12) as r:
                b = r.read()
            if good(b):
                return b
        except Exception:
            pass
    return None

mapping = {}
failed = 0
with cf.ThreadPoolExecutor(max_workers=10) as ex:
    futs = {ex.submit(fetch, u): u for u in urls}
    for fut in cf.as_completed(futs):
        u = futs[fut]
        b = fut.result()
        if not b:
            failed += 1
            continue
        ext = Path(urlparse(u).path).suffix.lower() or '.jpg'
        name = hashlib.sha1(u.encode()).hexdigest()[:16] + ext
        (media / name).write_bytes(b)
        mapping[u] = f"/assets/img/posts/{slug}/{name}"

for u, rel in mapping.items():
    content = content.replace(u, rel)
post.write_text(content, encoding='utf-8')
print(f"nepal total={len(urls)} rewritten={len(mapping)} failed={failed}")
